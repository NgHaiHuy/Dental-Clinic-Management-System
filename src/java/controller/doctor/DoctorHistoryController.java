package controller.doctor;

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
import model.MedicalRecord;
import model.PrescriptionDetail;
import model.User;

@WebServlet(name = "DoctorHistoryController", urlPatterns = {"/doctor/history"})
public class DoctorHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedInUser");
        
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        
        if (loggedUser.getRoleID() != 2) {
            request.getRequestDispatcher("/error/403.jsp").forward(request, response);
            return;
        }
        
        MedicalRecordDAO recordDAO = new MedicalRecordDAO();
        List<MedicalRecord> records = recordDAO.getMedicalRecordsByDoctorID(loggedUser.getUserID());
        
        Map<Integer, List<PrescriptionDetail>> recordMedicines = new HashMap<>();
        for (MedicalRecord mr : records) {
            List<PrescriptionDetail> meds = recordDAO.getMedicinesByRecordID(mr.getRecordID());
            recordMedicines.put(mr.getRecordID(), meds);
        }
        
        request.setAttribute("records", records);
        request.setAttribute("recordMedicines", recordMedicines);
        
        request.getRequestDispatcher("/doctor/history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
