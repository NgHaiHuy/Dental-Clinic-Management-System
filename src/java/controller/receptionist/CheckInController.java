package controller.receptionist;

import dal.AppointmentDAO;
import dal.UserDAO;
import dal.ServiceDAO;
import dal.MedicalRecordDAO;
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
import model.User;
import model.Service;

@WebServlet(name = "CheckInController", urlPatterns = {"/receptionist/manage-booking"})
public class CheckInController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("new".equalsIgnoreCase(action)) {
            UserDAO userDAO = new UserDAO();
            ServiceDAO serviceDAO = new ServiceDAO();
            
            List<User> customers = userDAO.getUsersByRole(4); // 4 = Customer
            List<User> doctors = userDAO.getUsersByRole(2); // 2 = Doctor
            List<Service> services = serviceDAO.getAllServices();
            
            request.setAttribute("customers", customers);
            request.setAttribute("doctors", doctors);
            request.setAttribute("services", services);
            
            request.getRequestDispatcher("/receptionist/booking-create.jsp").forward(request, response);
            return;
        }
        
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
        
        if ("create".equalsIgnoreCase(action)) {
            processDirectBooking(request, response, session);
            return;
        }
        
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
                } else if (action.equalsIgnoreCase("reschedule")) {
                    String newDateStr = request.getParameter("newDate");
                    String newTimeStr = request.getParameter("newTime");
                    
                    if (newDateStr == null || newDateStr.trim().isEmpty() || newTimeStr == null || newTimeStr.trim().isEmpty()) {
                        throw new Exception("Vui lòng nhập ngày và giờ hẹn mới.");
                    }
                    
                    if (newTimeStr.length() == 5) {
                        newTimeStr += ":00";
                    }
                    
                    java.sql.Date newDate = java.sql.Date.valueOf(newDateStr);
                    java.sql.Time newTime = java.sql.Time.valueOf(newTimeStr);
                    
                    // Prevent booking in the past
                    java.time.LocalDateTime selectedDateTime = java.time.LocalDateTime.of(
                        newDate.toLocalDate(), 
                        newTime.toLocalTime()
                    );
                    if (selectedDateTime.isBefore(java.time.LocalDateTime.now())) {
                        throw new Exception("Không thể đổi lịch sang thời gian trong quá khứ.");
                    }
                    
                    // Validate working hours (08:00 - 17:00, on the hour)
                    java.time.LocalTime localTime = newTime.toLocalTime();
                    int hour = localTime.getHour();
                    int minute = localTime.getMinute();
                    if (hour < 8 || hour > 17 || minute != 0) {
                        throw new Exception("Giờ khám mới không hợp lệ. Chỉ được chọn giờ làm việc từ 08:00 đến 17:00 (mỗi ca tròn giờ).");
                    }
                    
                    Appointment app = appDAO.getAppointmentByID(appointmentID);
                    if (app == null) {
                        throw new Exception("Không tìm thấy cuộc hẹn.");
                    }
                                        // Check customer overlap
                    if (appDAO.isCustomerBooked(app.getCustomerID(), newDateStr, newTimeStr, appointmentID)) {
                        throw new Exception("Khách hàng này đã có một lịch hẹn khác vào khung giờ được chọn.");
                    }
                    
                    // Check doctor overlap
                    if (app.getDoctorID() != null) {
                        if (appDAO.isDoctorBooked(app.getDoctorID(), newDateStr, newTimeStr, appointmentID)) {
                            throw new Exception("Bác sĩ chỉ định đã có lịch hẹn với bệnh nhân khác vào khung giờ này.");
                        }
                    }
                    
                    // Check if another patient has booked this slot (regardless of doctor)
                    if (appDAO.isSlotBooked(newDateStr, newTimeStr, appointmentID)) {
                        throw new Exception("Khung giờ này đã được đặt bởi một bệnh nhân khác.");
                    }
                    
                    boolean success = appDAO.rescheduleAppointment(appointmentID, newDate, newTime);
                    if (success) {
                        session.setAttribute("successMessage", "Đổi lịch hẹn #" + appointmentID + " thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể đổi lịch hẹn.");
                    }
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

    private void forwardWithErrorMessage(HttpServletRequest request, HttpServletResponse response, String errorMsg)
            throws ServletException, IOException {
        try {
            UserDAO userDAO = new UserDAO();
            ServiceDAO serviceDAO = new ServiceDAO();
            List<User> customers = userDAO.getUsersByRole(4);
            List<User> doctors = userDAO.getUsersByRole(2);
            List<Service> services = serviceDAO.getAllServices();
            
            request.setAttribute("customers", customers);
            request.setAttribute("doctors", doctors);
            request.setAttribute("services", services);
            request.setAttribute("errorMessage", errorMsg);
            
            request.getRequestDispatcher("/receptionist/booking-create.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/receptionist/manage-booking");
        }
    }

    private void processDirectBooking(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            String customerType = request.getParameter("customerType");
            String customerIDStr = request.getParameter("customerID");
            String walkInName = request.getParameter("walkInName");
            String walkInPhone = request.getParameter("walkInPhone");
            String walkInEmail = request.getParameter("walkInEmail");
            
            String doctorIDStr = request.getParameter("doctorID");
            String dateStr = request.getParameter("date");
            String timeStr = request.getParameter("time");
            String notes = request.getParameter("notes");
            String[] servicesArr = request.getParameterValues("services");
            
            int customerID = -1;
            String customerName = "";
            String customerPhone = "";
            UserDAO userDAO = new UserDAO();
            
            if ("walkin".equalsIgnoreCase(customerType)) {
                if (walkInName == null || walkInName.trim().isEmpty() || walkInPhone == null || walkInPhone.trim().isEmpty()) {
                    forwardWithErrorMessage(request, response, "Vui lòng nhập tên và số điện thoại cho khách vãng lai.");
                    return;
                }
                
                // Validate Phone format: 10 digits starting with 03, 08, 09
                if (!walkInPhone.trim().matches("^0(3|8|9)\\d{8}$")) {
                    forwardWithErrorMessage(request, response, "Số điện thoại không hợp lệ. Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng 03, 08 hoặc 09.");
                    return;
                }
                
                // Validate Email format (if provided): must be gmail.com
                if (walkInEmail != null && !walkInEmail.trim().isEmpty()) {
                    if (!walkInEmail.trim().matches("^[a-zA-Z0-9._%+-]+@gmail\\.com$")) {
                        forwardWithErrorMessage(request, response, "Địa chỉ email không hợp lệ. Chỉ chấp nhận tài khoản Gmail kết thúc bằng @gmail.com.");
                        return;
                    }
                }
                
                // Check if user already exists with this phone number
                User existingCustomer = userDAO.getCustomerByPhone(walkInPhone.trim());
                if (existingCustomer != null) {
                    forwardWithErrorMessage(request, response, "Khách hàng đã có tài khoản, không đăng kí được.");
                    return;
                }
                
                customerName = walkInName.trim();
                customerPhone = walkInPhone.trim();
            } else {
                if (customerIDStr == null || customerIDStr.trim().isEmpty()) {
                    forwardWithErrorMessage(request, response, "Vui lòng chọn khách hàng.");
                    return;
                }
                customerID = Integer.parseInt(customerIDStr);
                User existingUser = userDAO.getUserByID(customerID);
                if (existingUser != null) {
                    customerName = existingUser.getFullName();
                    customerPhone = existingUser.getPhone();
                }
            }
            
            if (dateStr == null || timeStr == null || dateStr.trim().isEmpty() || timeStr.trim().isEmpty()) {
                forwardWithErrorMessage(request, response, "Thông tin đặt lịch không hợp lệ hoặc thiếu thông tin bắt buộc.");
                return;
            }
            
            Integer doctorID = null;
            if (doctorIDStr != null && !doctorIDStr.trim().isEmpty() && !doctorIDStr.equals("0")) {
                doctorID = Integer.parseInt(doctorIDStr);
            }
            
            // Format time
            String fullTimeStr = timeStr;
            if (fullTimeStr.length() == 5) {
                fullTimeStr += ":00";
            }
            
            java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);
            java.sql.Time sqlTime = java.sql.Time.valueOf(fullTimeStr);
            
            // Validation: Prevent booking in the past
            java.time.LocalDateTime selectedDateTime = java.time.LocalDateTime.of(
                sqlDate.toLocalDate(), 
                sqlTime.toLocalTime()
            );
            if (selectedDateTime.isBefore(java.time.LocalDateTime.now())) {
                forwardWithErrorMessage(request, response, "Không thể đặt lịch hẹn ở thời gian trong quá khứ.");
                return;
            }
            
            AppointmentDAO appDAO = new AppointmentDAO();
            
            // Validation 1: Prevent duplicate booking by Name, Phone, and Time (date & time)
            System.out.println("==================================================");
            System.out.println("[DUPLICATE CHECK] Checking Name: '" + customerName + "', Phone: '" + customerPhone + "', Date: " + dateStr + ", Time: " + timeStr);
            boolean isDuplicate = appDAO.isDuplicateAppointment(customerName, customerPhone, dateStr, timeStr);
            System.out.println("[DUPLICATE CHECK] Result: " + isDuplicate);
            System.out.println("==================================================");
            
            if (isDuplicate) {
                forwardWithErrorMessage(request, response, "Bệnh nhân có Tên và SĐT này đã có lịch hẹn trùng vào khung giờ được chọn.");
                return;
            }
            
            // Check if walk-in customer already exists in DB, or create them
            if ("walkin".equalsIgnoreCase(customerType)) {
                User existingCustomer = userDAO.getCustomerByPhone(walkInPhone.trim());
                if (existingCustomer != null) {
                    customerID = existingCustomer.getUserID();
                } else {
                    customerID = userDAO.createWalkInCustomer(walkInName.trim(), walkInPhone.trim(), walkInEmail.trim());
                }
            }
            
            if (customerID <= 0) {
                forwardWithErrorMessage(request, response, "Không thể xác định thông tin bệnh nhân.");
                return;
            }
            
            // Validation 2: Customer overlap
            if (appDAO.isCustomerBooked(customerID, dateStr, timeStr, null)) {
                forwardWithErrorMessage(request, response, "Khách hàng này đã có một lịch hẹn khác vào khung giờ được chọn.");
                return;
            }
            
            // Validation 2: Doctor overlap
            if (doctorID != null) {
                if (appDAO.isDoctorBooked(doctorID, dateStr, timeStr, null)) {
                    forwardWithErrorMessage(request, response, "Bác sĩ chỉ định đã có lịch hẹn với bệnh nhân khác vào khung giờ này.");
                    return;
                }
            }
            
            // Create appointment
            Appointment app = new Appointment();
            app.setCustomerID(customerID);
            app.setDoctorID(doctorID);
            app.setAppointmentDate(sqlDate);
            app.setAppointmentTime(sqlTime);
            app.setStatus("Confirmed"); // Direct booking is confirmed immediately
            app.setNotes(notes);
            
            List<Integer> serviceIDs = new ArrayList<>();
            if (servicesArr != null) {
                for (String sId : servicesArr) {
                    serviceIDs.add(Integer.parseInt(sId));
                }
            }
            
            boolean success = appDAO.addAppointment(app, serviceIDs);
            if (success) {
                session.setAttribute("successMessage", "Đặt lịch trực tiếp tại quầy thành công!");
                response.sendRedirect(request.getContextPath() + "/receptionist/manage-booking");
            } else {
                forwardWithErrorMessage(request, response, "Lỗi hệ thống: Không thể tạo lịch hẹn.");
            }
            
        } catch (Exception e) {
            forwardWithErrorMessage(request, response, "Lỗi dữ liệu đầu vào: " + e.getMessage());
        }
    }
}
