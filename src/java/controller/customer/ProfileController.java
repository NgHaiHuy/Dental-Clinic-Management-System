package controller.customer;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import model.CustomerInfo;
import model.User;

@WebServlet(name = "ProfileController", urlPatterns = {"/customer/profile"})
public class ProfileController extends HttpServlet {

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
        CustomerInfo customerInfo = userDAO.getCustomerInfo(loggedUser.getUserID());
        
        request.setAttribute("customerInfo", customerInfo);
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
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

        UserDAO userDAO = new UserDAO();
        String action = request.getParameter("action");

        try {
            if ("updateProfile".equalsIgnoreCase(action)) {
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String email = request.getParameter("email");
                String address = request.getParameter("address");
                String gender = request.getParameter("gender");
                String dobStr = request.getParameter("dob");

                if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Họ tên và Số điện thoại không được để trống.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                // Validate Full Name length
                if (fullName.trim().length() > 100) {
                    session.setAttribute("errorMessage", "Họ và tên không được vượt quá 100 ký tự.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                // Validate Phone Number (Vietnamese mobile format: 10 digits starting with 03, 08, 09)
                if (!phone.trim().matches("^0[389]\\d{8}$")) {
                    session.setAttribute("errorMessage", "Số điện thoại không hợp lệ. Phải gồm 10 chữ số và bắt đầu bằng 03, 08 hoặc 09.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                // Validate Email
                if (email != null && !email.trim().isEmpty()) {
                    if (!email.trim().matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
                        session.setAttribute("errorMessage", "Địa chỉ email không đúng định dạng.");
                        response.sendRedirect(request.getContextPath() + "/customer/profile");
                        return;
                    }
                }

                // Validate Date of Birth
                Date dob = null;
                if (dobStr != null && !dobStr.trim().isEmpty()) {
                    try {
                        dob = Date.valueOf(dobStr);
                        Date today = new Date(System.currentTimeMillis());
                        if (dob.after(today)) {
                            session.setAttribute("errorMessage", "Ngày sinh không thể ở trong tương lai.");
                            response.sendRedirect(request.getContextPath() + "/customer/profile");
                            return;
                        }
                        if (dob.before(Date.valueOf("1900-01-01"))) {
                            session.setAttribute("errorMessage", "Ngày sinh không hợp lệ (phải sau năm 1900).");
                            response.sendRedirect(request.getContextPath() + "/customer/profile");
                            return;
                        }
                    } catch (IllegalArgumentException e) {
                        session.setAttribute("errorMessage", "Định dạng ngày sinh không hợp lệ.");
                        response.sendRedirect(request.getContextPath() + "/customer/profile");
                        return;
                    }
                }

                // Update User model fields
                loggedUser.setFullName(fullName);
                loggedUser.setPhone(phone);
                loggedUser.setEmail(email);

                // Create CustomerInfo model
                CustomerInfo custInfo = new CustomerInfo();
                custInfo.setCustomerID(loggedUser.getUserID());
                custInfo.setAddress(address);
                custInfo.setGender(gender);
                custInfo.setDateOfBirth(dob);

                boolean success = userDAO.updateCustomerProfile(loggedUser, custInfo);
                if (success) {
                    session.setAttribute("loggedInUser", loggedUser); // Save updated user model in session
                    session.setAttribute("successMessage", "Cập nhật thông tin cá nhân thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật thông tin cá nhân.");
                }
            } 
            else if ("changePassword".equalsIgnoreCase(action)) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (currentPassword == null || currentPassword.isEmpty() ||
                    newPassword == null || newPassword.isEmpty() ||
                    confirmPassword == null || confirmPassword.isEmpty()) {
                    session.setAttribute("errorMessage", "Mật khẩu không được để trống.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                if (!loggedUser.getPassword().equals(currentPassword)) {
                    session.setAttribute("errorMessage", "Mật khẩu hiện tại không chính xác.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                if (currentPassword.equals(newPassword)) {
                    session.setAttribute("errorMessage", "Mật khẩu mới không được trùng với mật khẩu cũ.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("errorMessage", "Mật khẩu mới và xác nhận mật khẩu không trùng khớp.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                // Validate Password length (minimum 3 characters)
                if (newPassword.length() < 3) {
                    session.setAttribute("errorMessage", "Mật khẩu mới phải có độ dài từ 3 ký tự trở lên.");
                    response.sendRedirect(request.getContextPath() + "/customer/profile");
                    return;
                }

                boolean success = userDAO.updatePassword(loggedUser.getUserID(), newPassword);
                if (success) {
                    loggedUser.setPassword(newPassword);
                    session.setAttribute("loggedInUser", loggedUser);
                    session.setAttribute("successMessage", "Thay đổi mật khẩu thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể thay đổi mật khẩu.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Đã xảy ra lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/profile");
    }
}
