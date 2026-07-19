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
        
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedInUser");
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        UserDAO userDAO = new UserDAO();
        ServiceDAO serviceDAO = new ServiceDAO();
        AppointmentDAO appDAO = new AppointmentDAO();
        
        List<User> doctors = userDAO.getUsersByRole(2); // 2 = Doctor
        List<Service> services = serviceDAO.getAllServices();
        
        request.setAttribute("doctors", doctors);
        request.setAttribute("services", services);

        // Edit support
        String editIDStr = request.getParameter("editID");
        if (editIDStr != null && !editIDStr.trim().isEmpty()) {
            try {
                int editID = Integer.parseInt(editIDStr);
                Appointment app = appDAO.getAppointmentByID(editID);
                if (app != null && app.getCustomerID() == loggedUser.getUserID()) {
                    if ("Pending".equalsIgnoreCase(app.getStatus())) {
                        List<Service> chosenServices = appDAO.getServicesForAppointment(editID);
                        request.setAttribute("editApp", app);
                        request.setAttribute("editServices", chosenServices);
                    }
                }
            } catch (Exception e) {
                // ignore
            }
        }
        
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
            String editIDStr = request.getParameter("editID");
            String doctorIDStr = request.getParameter("doctorID");
            Integer doctorID = null;
            if (doctorIDStr != null && !doctorIDStr.trim().isEmpty() && !doctorIDStr.equals("0")) {
                doctorID = Integer.parseInt(doctorIDStr);
            }
            
            String dateStr = request.getParameter("date");
            String timeStr = request.getParameter("time"); // Expected: HH:mm
            String notes = request.getParameter("notes");
            
            // Validation: Prevent booking in the past
            if (dateStr != null && timeStr != null) {
                String fullTimeStr = timeStr;
                if (fullTimeStr.length() == 5) {
                    fullTimeStr += ":00";
                }
                java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);
                java.sql.Time sqlTime = java.sql.Time.valueOf(fullTimeStr);
                java.time.LocalDateTime selectedDateTime = java.time.LocalDateTime.of(
                    sqlDate.toLocalDate(), 
                    sqlTime.toLocalTime()
                );
                if (selectedDateTime.isBefore(java.time.LocalDateTime.now())) {
                    session.setAttribute("errorMessage", "Không thể đặt lịch hẹn ở thời gian trong quá khứ.");
                    if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/customer/booking?editID=" + editIDStr);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/booking");
                    }
                    return;
                }
            }
            
            // Validation: Prevent booking collisions (Same customer or same doctor at the same day & time)
            if (dateStr != null && timeStr != null) {
                String fullTimeStr = timeStr;
                if (fullTimeStr.length() == 5) {
                    fullTimeStr += ":00";
                }
                java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);
                java.sql.Time sqlTime = java.sql.Time.valueOf(fullTimeStr);
                Integer excludeID = null;
                if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                    excludeID = Integer.parseInt(editIDStr);
                }
                
                AppointmentDAO appDAO = new AppointmentDAO();
                
                // 1. Check if customer themselves already has an active appointment at this time
                if (appDAO.isCustomerBooked(loggedUser.getUserID(), dateStr, timeStr, excludeID)) {
                    session.setAttribute("errorMessage", "Bạn đã đăng ký một lịch hẹn khác vào khung giờ này rồi.");
                    if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/customer/booking?editID=" + editIDStr);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/booking");
                    }
                    return;
                }
                
                // Only new bookings need the name/phone duplicate check; edits already exclude themselves by ID.
                if (excludeID == null
                        && appDAO.isDuplicateAppointment(loggedUser.getFullName(), loggedUser.getPhone(), dateStr, timeStr)) {
                    session.setAttribute("errorMessage", "Đã có một lịch hẹn trùng khớp Họ tên và SĐT vào khung giờ này trong hệ thống.");
                    if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/customer/booking?editID=" + editIDStr);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/booking");
                    }
                    return;
                }
                
                // 2. Check if the specified doctor is already booked by another patient at this time
                if (doctorID != null && doctorID > 0) {
                    if (appDAO.isDoctorBooked(doctorID, dateStr, timeStr, excludeID)) {
                        session.setAttribute("errorMessage", "Bác sĩ đã có lịch hẹn với bệnh nhân khác vào khung giờ này.");
                        if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                            response.sendRedirect(request.getContextPath() + "/customer/booking?editID=" + editIDStr);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/customer/booking");
                        }
                        return;
                    }
                }
            }
            
            String[] serviceIDsArr = request.getParameterValues("services");
            List<Integer> serviceIDs = new ArrayList<>();
            if (serviceIDsArr != null) {
                for (String idStr : serviceIDsArr) {
                    serviceIDs.add(Integer.parseInt(idStr));
                }
            }
            
            AppointmentDAO appDAO = new AppointmentDAO();
            boolean success = false;
            
            if (editIDStr != null && !editIDStr.trim().isEmpty()) {
                // Update mode
                int editID = Integer.parseInt(editIDStr);
                Appointment app = appDAO.getAppointmentByID(editID);
                
                if (app != null && app.getCustomerID() == loggedUser.getUserID()) {
                    if ("Pending".equalsIgnoreCase(app.getStatus())) {
                        app.setDoctorID(doctorID);
                        app.setAppointmentDate(Date.valueOf(dateStr));
                        if (timeStr.length() == 5) {
                            timeStr += ":00";
                        }
                        app.setAppointmentTime(Time.valueOf(timeStr));
                        app.setNotes(notes);
                        
                        success = appDAO.updateAppointmentDetails(app, serviceIDs);
                        if (success) {
                            session.setAttribute("successMessage", "Cập nhật lịch hẹn thành công!");
                        } else {
                            session.setAttribute("errorMessage", "Không thể cập nhật lịch hẹn.");
                        }
                    } else {
                        session.setAttribute("errorMessage", "Không thể chỉnh sửa lịch hẹn ở trạng thái này.");
                    }
                } else {
                    session.setAttribute("errorMessage", "Không tìm thấy lịch hẹn hoặc không có quyền.");
                }
            } else {
                // New appointment mode
                Appointment app = new Appointment();
                app.setCustomerID(loggedUser.getUserID());
                app.setDoctorID(doctorID);
                app.setAppointmentDate(Date.valueOf(dateStr));
                
                if (timeStr.length() == 5) {
                    timeStr += ":00";
                }
                app.setAppointmentTime(Time.valueOf(timeStr));
                app.setStatus("Pending");
                app.setNotes(notes);
                
                success = appDAO.addAppointment(app, serviceIDs);
                if (success) {
                    session.setAttribute("successMessage", "Đặt lịch hẹn thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể đặt lịch hẹn. Vui lòng thử lại.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Dữ liệu nhập vào không hợp lệ: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/customer/history");
    }
}
