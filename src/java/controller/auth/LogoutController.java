package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * LogoutController - Thành viên 1 (Nghị)
 *
 * Xử lý chức năng Đăng xuất.
 * - GET hoặc POST /auth/logout → huỷ session, redirect về trang login
 */
@WebServlet(name = "LogoutController", urlPatterns = {"/auth/logout"})
public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    /**
     * Huỷ toàn bộ session và redirect về trang đăng nhập.
     */
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Xoá toàn bộ dữ liệu trong session
        }

        // Xoá cookie JSESSIONID để tránh cache session cũ
        jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("JSESSIONID", "");
        cookie.setMaxAge(0);
        cookie.setPath(request.getContextPath());
        response.addCookie(cookie);

        // Redirect về trang login với thông báo thành công
        response.sendRedirect(request.getContextPath() + "/auth/login?logout=success");
    }
}
