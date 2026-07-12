package controller.auth;

import dal.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * RegisterController - Thành viên 1 (Nghị)
 *
 * Xử lý chức năng Đăng ký tài khoản Khách hàng mới.
 * - GET  /auth/register → hiển thị trang register.jsp
 * - POST /auth/register → xử lý đăng ký, tạo tài khoản với Role = Customer (4)
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/auth/register"})
public class RegisterController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * GET: Hiển thị form đăng ký.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
    }

    /**
     * POST: Xử lý form đăng ký.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username        = request.getParameter("username");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName        = request.getParameter("fullName");
        String phone           = request.getParameter("phone");
        String email           = request.getParameter("email");

        // --- Validate input ---
        String error = validateRegisterInput(username, password, confirmPassword, fullName, phone, email);

        if (error != null) {
            request.setAttribute("errorMessage", error);
            // Giữ lại dữ liệu đã nhập để user không phải nhập lại
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // --- Kiểm tra username trùng ---
        if (userDAO.isUsernameExists(username.trim())) {
            request.setAttribute("errorMessage", "Tên đăng nhập \"" + username + "\" đã được sử dụng. Vui lòng chọn tên khác.");
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // --- Kiểm tra email trùng ---
        if (email != null && !email.trim().isEmpty() && userDAO.isEmailExists(email.trim())) {
            request.setAttribute("errorMessage", "Email \"" + email + "\" đã được đăng ký. Vui lòng dùng email khác.");
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // --- Tạo tài khoản mới ---
        boolean success = userDAO.register(
                username.trim(),
                password.trim(),
                fullName.trim(),
                phone.trim(),
                email != null ? email.trim() : ""
        );

        if (success) {
            // Đăng ký thành công → redirect về trang login kèm thông báo
            response.sendRedirect(request.getContextPath() + "/auth/login?registered=success");
        } else {
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Validate dữ liệu form đăng ký.
     *
     * @return Chuỗi thông báo lỗi, hoặc null nếu không có lỗi
     */
    private String validateRegisterInput(String username, String password,
            String confirmPassword, String fullName, String phone, String email) {

        if (username == null || username.trim().isEmpty()) {
            return "Tên đăng nhập không được để trống.";
        }
        if (username.trim().length() < 4 || username.trim().length() > 50) {
            return "Tên đăng nhập phải từ 4 đến 50 ký tự.";
        }
        if (!username.trim().matches("[a-zA-Z0-9_]+")) {
            return "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới.";
        }

        if (password == null || password.trim().isEmpty()) {
            return "Mật khẩu không được để trống.";
        }
        if (password.trim().length() < 3) {
            return "Mật khẩu phải có ít nhất 3 ký tự.";
        }

        if (!password.equals(confirmPassword)) {
            return "Xác nhận mật khẩu không khớp.";
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }

        if (phone == null || phone.trim().isEmpty()) {
            return "Số điện thoại không được để trống.";
        }
        if (!phone.trim().matches("^(0|\\+84)[0-9]{9,10}$")) {
            return "Số điện thoại không hợp lệ (ví dụ: 0912345678).";
        }

        if (email != null && !email.trim().isEmpty()) {
            if (!email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                return "Địa chỉ email không hợp lệ.";
            }
        }

        return null; // Không có lỗi
    }
}
