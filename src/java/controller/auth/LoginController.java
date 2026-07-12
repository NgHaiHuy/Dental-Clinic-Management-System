package controller.auth;

import dal.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;
import model.User;

/**
 * LoginController - Thành viên 1 (Nghị)
 *
 * Xử lý chức năng Đăng nhập.
 * - GET  /auth/login → hiển thị trang login.jsp
 * - POST /auth/login → xử lý đăng nhập, lưu session, redirect theo role
 */
@WebServlet(name = "LoginController", urlPatterns = {"/auth/login"})
public class LoginController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * GET: Hiển thị trang đăng nhập.
     * Nếu đã đăng nhập rồi thì redirect về dashboard luôn.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Nếu đã đăng nhập → redirect về dashboard tương ứng
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            User user = (User) session.getAttribute("loggedInUser");
            response.sendRedirect(request.getContextPath() + Role.getDashboardUrl(user.getRoleID()));
            return;
        }

        // Chưa đăng nhập → forward tới login.jsp
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }

    /**
     * POST: Xử lý form đăng nhập.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // --- Validate input cơ bản ---
        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            request.setAttribute("username", username); // giữ lại username đã nhập
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // --- Xác thực với DB ---
        User user = userDAO.login(username.trim(), password.trim());

        if (user == null) {
            // Sai username hoặc password
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // --- Đăng nhập thành công: lưu thông tin vào session ---
        HttpSession session = request.getSession(); // tạo session mới
        session.setAttribute("loggedInUser", user);
        session.setAttribute("userRole", user.getRoleID());
        session.setAttribute("userFullName", user.getFullName());

        // --- Kiểm tra xem có URL đang chờ redirect không ---
        String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
        if (redirectUrl != null && !redirectUrl.isEmpty()
                && !redirectUrl.startsWith("/auth/")) {
            session.removeAttribute("redirectAfterLogin");
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            // Redirect đến dashboard tương ứng với Role
            response.sendRedirect(request.getContextPath() + Role.getDashboardUrl(user.getRoleID()));
        }
    }
}
