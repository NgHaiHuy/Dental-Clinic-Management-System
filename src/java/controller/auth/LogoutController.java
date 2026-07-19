package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * ================================================================================
 * FILE: LogoutController.java
 * THÀNH VIÊN 1 (Nghị) - Chức năng: XỬ LÝ ĐĂNG XUẤT
 * ================================================================================
 *
 * MỤC ĐÍCH:
 * - Servlet xử lý chức năng đăng xuất khỏi hệ thống.
 * - Hỗ trợ cả GET và POST request (cả hai đều gọi cùng logic logout).
 * - Ánh xạ URL: "/auth/logout"
 *
 * LUỒNG HOẠT ĐỘNG:
 * 1. User click nút "Đăng xuất" → gửi request đến /auth/logout.
 * 2. Servlet lấy session hiện tại (nếu có) và gọi session.invalidate()
 *    để xóa toàn bộ dữ liệu trong session (loggedInUser, userRole, userFullName...).
 * 3. Xóa cookie JSESSIONID để trình duyệt không gửi session ID cũ trong request tiếp theo.
 * 4. Redirect về trang login kèm parameter ?logout=success
 *    → login.jsp sẽ hiển thị thông báo "Đăng xuất thành công".
 *
 * TƯƠNG TÁC VỚI CÁC THÀNH PHẦN KHÁC:
 * - login.jsp: Nhận parameter "logout=success" và hiển thị thông báo.
 * - Các nút "Đăng xuất" trên sidebar/header của dashboard gửi request đến Servlet này.
 *
 * BẢO MẬT:
 * - session.invalidate(): Hủy hoàn toàn session cũ, ngăn chặn Session Fixation Attack.
 * - Xóa cookie JSESSIONID: Đảm bảo trình duyệt không tái sử dụng session đã hết hiệu lực.
 * ================================================================================
 */
@WebServlet(name = "LogoutController", urlPatterns = {"/auth/logout"})
public class LogoutController extends HttpServlet {

    /**
     * Xử lý GET request - Khi user truy cập URL /auth/logout trực tiếp
     * hoặc click link đăng xuất.
     * Chuyển tiếp đến phương thức logout() chung.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    /**
     * Xử lý POST request - Khi form đăng xuất dùng method POST.
     * Chuyển tiếp đến phương thức logout() chung.
     * Hỗ trợ POST để tương thích với các button submit trong form.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    /**
     * ================================================================
     * PHƯƠNG THỨC LOGOUT - Logic đăng xuất chính
     * ================================================================
     *
     * Phương thức private, được gọi bởi cả doGet() và doPost().
     * Thiết kế tách riêng để tránh duplicate code (DRY principle).
     *
     * CÁC BƯỚC XỬ LÝ:
     *
     * Bước 1: Hủy Session
     * - getSession(false): Lấy session hiện tại, KHÔNG tạo mới nếu chưa có.
     * - Nếu session tồn tại → gọi invalidate() để xóa toàn bộ dữ liệu:
     *   + loggedInUser (đối tượng User)
     *   + userRole (roleID)
     *   + userFullName (tên hiển thị)
     *   + Mọi attribute khác trong session
     *
     * Bước 2: Xóa Cookie JSESSIONID
     * - JSESSIONID là cookie mà server tự động tạo để theo dõi session.
     * - Dù session đã invalidate, cookie vẫn tồn tại trên trình duyệt.
     * - Ta tạo cookie cùng tên với maxAge=0 để trình duyệt xóa cookie cũ.
     * - setPath(): đảm bảo cookie được xóa đúng scope (context path của ứng dụng).
     *
     * Bước 3: Redirect về trang Login
     * - Dùng sendRedirect (không phải forward) để:
     *   + Thay đổi URL trên thanh địa chỉ thành /auth/login
     *   + Tạo request mới (không mang theo dữ liệu cũ)
     * - Kèm parameter ?logout=success để login.jsp hiển thị thông báo.
     */
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Bước 1: Lấy session hiện tại (false = không tạo mới)
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Hủy toàn bộ session - xóa sạch mọi dữ liệu đã lưu
            session.invalidate();
        }

        // Bước 2: Xóa cookie JSESSIONID để tránh trình duyệt gửi lại session ID cũ
        // - Tạo cookie mới cùng tên "JSESSIONID" với giá trị rỗng
        // - setMaxAge(0): yêu cầu trình duyệt xóa cookie ngay lập tức
        // - setPath(): cookie chỉ áp dụng cho context path của ứng dụng này
        jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("JSESSIONID", "");
        cookie.setMaxAge(0);
        cookie.setPath(request.getContextPath());
        response.addCookie(cookie);

        // Bước 3: Redirect về trang login với thông báo đăng xuất thành công
        // login.jsp sẽ kiểm tra parameter "logout" và hiển thị alert-success
        response.sendRedirect(request.getContextPath() + "/auth/login?logout=success");
    }
}
