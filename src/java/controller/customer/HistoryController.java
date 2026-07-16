package controller.customer;

import dal.AppointmentDAO;
import dal.MedicalRecordDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Appointment;
import model.MedicalRecord;
import model.PrescriptionDetail;
import model.User;

@WebServlet(name = "HistoryController", urlPatterns = {"/customer/history"})
public class HistoryController extends HttpServlet {

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
        MedicalRecordDAO recordDAO = new MedicalRecordDAO();
        
        int userID = loggedUser.getUserID();
        
        List<Appointment> appointments = appDAO.getAppointmentsByCustomerID(userID);
        List<MedicalRecord> records = recordDAO.getMedicalRecordsByCustomerID(userID);
        
        // Map to store medicines for each medical record
        Map<Integer, List<PrescriptionDetail>> recordMedicines = new HashMap<>();
        for (MedicalRecord mr : records) {
            List<PrescriptionDetail> meds = recordDAO.getMedicinesByRecordID(mr.getRecordID());
            recordMedicines.put(mr.getRecordID(), meds);
        }
        
        request.setAttribute("appointments", appointments);
        request.setAttribute("records", records);
        request.setAttribute("recordMedicines", recordMedicines);
        
        request.getRequestDispatcher("/customer/history.jsp").forward(request, response);
    }
}
