package controller.doctor;

import dal.AppointmentDAO;
import dal.MedicalRecordDAO;
import dal.MedicineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Appointment;
import model.MedicalRecord;
import model.Medicine;
import model.PrescriptionDetail;
import model.Service;
import model.User;

@WebServlet(name = "MedicalRecordController", urlPatterns = {"/doctor/checkup"})
public class MedicalRecordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedInUser");
        
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        
        AppointmentDAO appDAO = new AppointmentDAO();
        String appIDStr = request.getParameter("appointmentID");
        
        if (appIDStr == null || appIDStr.trim().isEmpty()) {
            // View Doctor's Queue of checked-in patients
            List<Appointment> queue = appDAO.getCheckedInAppointmentsForDoctor(loggedUser.getUserID());
            request.setAttribute("queue", queue);
            request.getRequestDispatcher("/doctor/checkup.jsp").forward(request, response);
        } else {
            // Fill medical record for a specific patient
            try {
                int appointmentID = Integer.parseInt(appIDStr);
                Appointment app = appDAO.getAppointmentByID(appointmentID);
                List<Service> selectedServices = appDAO.getServicesForAppointment(appointmentID);
                
                MedicineDAO medDAO = new MedicineDAO();
                List<Medicine> medicines = medDAO.getAllMedicines();
                
                request.setAttribute("appointment", app);
                request.setAttribute("selectedServices", selectedServices);
                request.setAttribute("medicines", medicines);
                
                request.getRequestDispatcher("/doctor/checkup.jsp").forward(request, response);
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/doctor/checkup");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedInUser");
        
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        
        try {
            int appointmentID = Integer.parseInt(request.getParameter("appointmentID"));
            String diagnosis = request.getParameter("diagnosis");
            String treatmentPlan = request.getParameter("treatmentPlan");
            
            // Prescription medicines
            String[] medicineIDsArr = request.getParameterValues("medicineIDs");
            String[] quantitiesArr = request.getParameterValues("quantities");
            String[] dosagesArr = request.getParameterValues("dosages");
            
            List<PrescriptionDetail> prescriptionDetails = new ArrayList<>();
            if (medicineIDsArr != null) {
                for (int i = 0; i < medicineIDsArr.length; i++) {
                    int medicineID = Integer.parseInt(medicineIDsArr[i]);
                    int quantity = Integer.parseInt(quantitiesArr[i]);
                    String dosage = dosagesArr[i];
                    
                    if (quantity > 0) {
                        PrescriptionDetail detail = new PrescriptionDetail();
                        detail.setMedicineID(medicineID);
                        detail.setQuantity(quantity);
                        detail.setDosage(dosage);
                        prescriptionDetails.add(detail);
                    }
                }
            }
            
            MedicalRecord record = new MedicalRecord();
            record.setAppointmentID(appointmentID);
            record.setDoctorID(loggedUser.getUserID());
            record.setDiagnosis(diagnosis);
            record.setTreatmentPlan(treatmentPlan);
            
            MedicalRecordDAO recordDAO = new MedicalRecordDAO();
            boolean success = recordDAO.addMedicalRecord(record, prescriptionDetails);
            
            if (success) {
                session.setAttribute("successMessage", "Lập hồ sơ bệnh án thành công cho lịch hẹn #" + appointmentID);
            } else {
                session.setAttribute("errorMessage", "Không thể lưu bệnh án. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi xử lý dữ liệu bệnh án: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/doctor/checkup");
    }
}
