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
        List<Appointment> appointments = appDAO.getAllAppointments();
        
        request.setAttribute("appointments", appointments);
        request.getRequestDispatcher("/receptionist/manage-booking.jsp").forward(request, response);
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
