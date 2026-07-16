package controller.customer;

import dal.AppointmentDAO;
import dal.ServiceDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import model.Appointment;
import model.Service;
import model.User;

@WebServlet(name = "BookingController", urlPatterns = {"/customer/booking"})
public class BookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        UserDAO userDAO = new UserDAO();
        ServiceDAO serviceDAO = new ServiceDAO();
        
        List<User> doctors = userDAO.getUsersByRole(2); // 2 = Doctor
        List<Service> services = serviceDAO.getAllServices();
        
        request.setAttribute("doctors", doctors);
        request.setAttribute("services", services);
        
        request.getRequestDispatcher("/customer/booking.jsp").forward(request, response);
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
            String doctorIDStr = request.getParameter("doctorID");
            Integer doctorID = null;
            if (doctorIDStr != null && !doctorIDStr.trim().isEmpty() && !doctorIDStr.equals("0")) {
                doctorID = Integer.parseInt(doctorIDStr);
            }
            
            String dateStr = request.getParameter("date");
            String timeStr = request.getParameter("time"); // Expected: HH:mm
            String notes = request.getParameter("notes");
            
            String[] serviceIDsArr = request.getParameterValues("services");
            List<Integer> serviceIDs = new ArrayList<>();
            if (serviceIDsArr != null) {
                for (String idStr : serviceIDsArr) {
                    serviceIDs.add(Integer.parseInt(idStr));
                }
            }
            
            Appointment app = new Appointment();
            app.setCustomerID(loggedUser.getUserID());
            app.setDoctorID(doctorID);
            app.setAppointmentDate(Date.valueOf(dateStr));
            
            // Ensure time format has seconds for Time.valueOf (HH:mm:ss)
            if (timeStr.length() == 5) {
                timeStr += ":00";
            }
            app.setAppointmentTime(Time.valueOf(timeStr));
            app.setStatus("Pending");
            app.setNotes(notes);
            
            AppointmentDAO appDAO = new AppointmentDAO();
            boolean success = appDAO.addAppointment(app, serviceIDs);
            
            if (success) {
                session.setAttribute("successMessage", "Đặt lịch hẹn thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể đặt lịch hẹn. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Dữ liệu nhập vào không hợp lệ: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/customer/dashboard");
    }
}
