package controller.receptionist;

import dal.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Appointment;

@WebServlet(name = "CheckInController", urlPatterns = {"/receptionist/manage-booking"})
public class CheckInController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        AppointmentDAO appDAO = new AppointmentDAO();
        dal.MedicalRecordDAO mrDAO = new dal.MedicalRecordDAO();
        List<Appointment> appointments = appDAO.getAllAppointments();
        for (Appointment app : appointments) {
            app.setChosenServices(appDAO.getServicesForAppointment(app.getAppointmentID()));
            List<model.MedicalRecord> history = mrDAO.getMedicalRecordsByCustomerID(app.getCustomerID());
            if (history != null) {
                for (model.MedicalRecord mr : history) {
                    mr.setMedicines(mrDAO.getMedicinesByRecordID(mr.getRecordID()));
                }
            }
            app.setPatientHistory(history);
        }
        
        // Sort: Confirmed -> Pending -> Attended -> Cancelled/Others
        appointments.sort((a1, a2) -> {
            int p1 = getStatusPriority(a1.getStatus());
            int p2 = getStatusPriority(a2.getStatus());
            if (p1 != p2) {
                return Integer.compare(p1, p2);
            }
            // Same status -> sort by Date
            int dateCompare = a1.getAppointmentDate().compareTo(a2.getAppointmentDate());
            if (dateCompare != 0) {
                return dateCompare;
            }
            // Same date -> sort by Time
            return a1.getAppointmentTime().compareTo(a2.getAppointmentTime());
        });
        
        request.setAttribute("appointments", appointments);
        request.getRequestDispatcher("/receptionist/manage-booking.jsp").forward(request, response);
    }

    private int getStatusPriority(String status) {
        if (status == null) return 4;
        switch (status.toLowerCase()) {
            case "confirmed":
                return 1;
            case "pending":
                return 2;
            case "attended":
                return 3;
            default:
                return 4; // Cancelled, etc.
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String appIDStr = request.getParameter("appointmentID");
        
        if (action != null && appIDStr != null) {
            try {
                int appointmentID = Integer.parseInt(appIDStr);
                AppointmentDAO appDAO = new AppointmentDAO();
                String newStatus = null;
                
                if (action.equalsIgnoreCase("confirm")) {
                    newStatus = "Confirmed";
                } else if (action.equalsIgnoreCase("checkin")) {
                    newStatus = "Attended"; // Attended means checked-in / doctor's queue
                } else if (action.equalsIgnoreCase("cancel")) {
                    newStatus = "Cancelled";
                }
                
                if (newStatus != null) {
                    boolean success = appDAO.updateAppointmentStatus(appointmentID, newStatus);
                    if (success) {
                        session.setAttribute("successMessage", "Cập nhật trạng thái lịch hẹn #" + appointmentID + " thành " + newStatus + " thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể cập nhật trạng thái lịch hẹn.");
                    }
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/receptionist/manage-booking");
    }
}
