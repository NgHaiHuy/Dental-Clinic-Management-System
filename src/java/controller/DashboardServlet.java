package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "DashboardServlet", urlPatterns = {
    "/admin/dashboard",
    "/doctor/dashboard",
    "/receptionist/dashboard",
    "/customer/dashboard"
})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String relativePath = request.getServletPath();
        
        if ("/receptionist/dashboard".equals(relativePath)) {
            dal.AppointmentDAO appDAO = new dal.AppointmentDAO();
            dal.InvoiceDAO invDAO = new dal.InvoiceDAO();
            
            int todayAppointmentsCount = appDAO.getTodayAppointmentsCount();
            int todayCheckedInCount = appDAO.getTodayCheckedInCount();
            int pendingCheckInCount = appDAO.getPendingCheckInCount();
            int unpaidCount = invDAO.getUnpaidCount();
            double todayRevenue = invDAO.getTodayRevenue();
            java.util.List<model.Appointment> todayList = appDAO.getTodayAppointments();
            
            request.setAttribute("todayAppointmentsCount", todayAppointmentsCount);
            request.setAttribute("todayCheckedInCount", todayCheckedInCount);
            request.setAttribute("pendingCheckInCount", pendingCheckInCount);
            request.setAttribute("unpaidCount", unpaidCount);
            request.setAttribute("todayRevenue", todayRevenue);
            request.setAttribute("todayList", todayList);
        }
        
        String jspPath = relativePath + ".jsp";
        request.getRequestDispatcher(jspPath).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
