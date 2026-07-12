package controller.customer;

import dal.UserDAO;
import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "CustomerProfileController", urlPatterns = {"/customer/profile"})
public class ProfileController extends HttpServlet {

    private static final String VIEW = "/customer/profile.jsp";
    private static final String CSRF_KEY = "customerProfileCsrfToken";
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        ensureCsrfToken(session);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedInUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        if (!isValidCsrfToken(request, session)) {
            request.setAttribute("errorMessage", "Phiên làm việc không hợp lệ. Vui lòng tải lại trang.");
            forwardProfile(request, response, session);
            return;
        }

        if ("change-password".equals(request.getParameter("action"))) {
            changePassword(request, response, session, user);
        } else {
            updateProfile(request, response, session, user);
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User user) throws ServletException, IOException {
        String fullName = clean(request.getParameter("fullName"));
        String phone = clean(request.getParameter("phone"));
        String email = clean(request.getParameter("email"));

        request.setAttribute("activeTab", "profile");
        request.setAttribute("submittedFullName", fullName);
        request.setAttribute("submittedPhone", phone);
        request.setAttribute("submittedEmail", email);

        if (fullName.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập họ và tên.");
        } else if (fullName.length() > 100) {
            request.setAttribute("errorMessage", "Họ và tên không được vượt quá 100 ký tự.");
        } else if (!phone.isEmpty() && !phone.matches("^[0-9+ .-]{8,15}$")) {
            request.setAttribute("errorMessage", "Số điện thoại không hợp lệ.");
        } else if (!email.isEmpty() && !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            request.setAttribute("errorMessage", "Địa chỉ email không hợp lệ.");
        } else if (userDAO.updateProfile(user.getUserID(), fullName, phone, email)) {
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setEmail(email);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("userFullName", fullName);
            rotateCsrfToken(session);
            response.sendRedirect(request.getContextPath() + "/customer/profile?success=profile");
            return;
        } else {
            request.setAttribute("errorMessage", "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
        }
        forwardProfile(request, response, session);
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User user) throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        request.setAttribute("activeTab", "password");

        if (isEmpty(currentPassword) || isEmpty(newPassword) || isEmpty(confirmPassword)) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin mật khẩu.");
        } else if (newPassword.length() < 6) {
            request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 6 ký tự.");
        } else if (newPassword.length() > 100) {
            request.setAttribute("errorMessage", "Mật khẩu mới không được vượt quá 100 ký tự.");
        } else if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Xác nhận mật khẩu mới không khớp.");
        } else if (userDAO.login(user.getUsername(), currentPassword) == null) {
            request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng.");
        } else if (userDAO.updatePassword(user.getUserID(), newPassword)) {
            rotateCsrfToken(session);
            response.sendRedirect(request.getContextPath() + "/customer/profile?success=password");
            return;
        } else {
            request.setAttribute("errorMessage", "Không thể đổi mật khẩu. Vui lòng thử lại.");
        }
        forwardProfile(request, response, session);
    }

    private void forwardProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session) throws ServletException, IOException {
        ensureCsrfToken(session);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private boolean isValidCsrfToken(HttpServletRequest request, HttpSession session) {
        Object sessionToken = session.getAttribute(CSRF_KEY);
        String requestToken = request.getParameter("csrfToken");
        return sessionToken != null && sessionToken.toString().equals(requestToken);
    }

    private void ensureCsrfToken(HttpSession session) {
        if (session.getAttribute(CSRF_KEY) == null) rotateCsrfToken(session);
    }

    private void rotateCsrfToken(HttpSession session) {
        session.setAttribute(CSRF_KEY, UUID.randomUUID().toString());
    }

    private String clean(String value) { return value == null ? "" : value.trim(); }
    private boolean isEmpty(String value) { return value == null || value.isEmpty(); }
}
