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
 * ================================================================================
 * FILE: LoginController.java
 * THÀNH VIÊN 1 (Nghị) - Chức năng: XỬ LÝ ĐĂNG NHẬP (Server-side)
 * ================================================================================
 *
 * MỤC ĐÍCH:
 * - Servlet xử lý logic đăng nhập cho hệ thống Nha khoa SmileCare.
 * - Ánh xạ URL "/auth/login" (cả GET và POST).
 *
 * LUỒNG HOẠT ĐỘNG:
 *
 *   [GET /auth/login]
 *   1. Kiểm tra session: nếu user đã đăng nhập (session chứa "loggedInUser")
 *      → redirect về dashboard tương ứng với Role (tránh vào lại trang login).
 *   2. Nếu chưa đăng nhập → forward đến login.jsp để hiển thị form.
 *
 *   [POST /auth/login]
 *   1. Nhận dữ liệu username và password từ form.
 *   2. SERVER-SIDE VALIDATION: Kiểm tra input không null, không rỗng.
 *   3. Gọi UserDAO.login() để xác thực với database.
 *   4. Nếu sai thông tin → set errorMessage, forward lại login.jsp.
 *   5. Nếu đúng → tạo session, lưu thông tin user, redirect đến dashboard.
 *
 * TƯƠNG TÁC VỚI CÁC THÀNH PHẦN KHÁC:
 * - login.jsp: Trang giao diện hiển thị form đăng nhập.
 * - UserDAO.login(): Truy vấn database (SELECT ... WHERE Username=? AND Password=?).
 * - Role.getDashboardUrl(): Trả về URL dashboard tương ứng với roleID.
 * - AuthFilter: Filter kiểm tra quyền truy cập, lưu URL gốc vào session
 *   (attribute "redirectAfterLogin") để sau khi login sẽ redirect về đúng trang user muốn vào.
 * ================================================================================
 */
@WebServlet(name = "LoginController", urlPatterns = {"/auth/login"})
public class LoginController extends HttpServlet {

    /**
     * Khởi tạo UserDAO - đối tượng truy cập dữ liệu bảng Users.
     * Dùng "final" vì đối tượng này không thay đổi trong suốt vòng đời của Servlet.
     */
    private final UserDAO userDAO = new UserDAO();

    /**
     * ================================================================
     * PHƯƠNG THỨC doGet() - Xử lý yêu cầu GET
     * ================================================================
     *
     * Được gọi khi:
     * - User truy cập trực tiếp URL: http://localhost:8080/DentalClinic/auth/login
     * - User click vào link "Đăng nhập" từ trang khác.
     * - User bị redirect từ LogoutController sau khi đăng xuất.
     *
     * Logic:
     * 1. Lấy session hiện tại (getSession(false) = KHÔNG tạo session mới nếu chưa có).
     * 2. Kiểm tra session có tồn tại và có chứa "loggedInUser" không.
     *    - Nếu CÓ: User đã đăng nhập rồi → redirect về dashboard (không cần login lại).
     *    - Nếu KHÔNG: Chưa đăng nhập → forward đến login.jsp hiển thị form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy session hiện tại. Tham số false = không tạo session mới nếu chưa có.
        // Nếu user chưa từng truy cập hệ thống → session = null.
        HttpSession session = request.getSession(false);

        // Kiểm tra: nếu session tồn tại VÀ trong session có attribute "loggedInUser"
        // → Nghĩa là user đã đăng nhập trước đó và session chưa hết hạn.
        if (session != null && session.getAttribute("loggedInUser") != null) {
            // Lấy đối tượng User từ session
            User user = (User) session.getAttribute("loggedInUser");
            // Redirect về dashboard tương ứng với Role của user:
            // - Admin (roleID=1)    → /admin/dashboard
            // - Doctor (roleID=2)   → /doctor/checkup
            // - Staff (roleID=3)    → /receptionist/dashboard
            // - Customer (roleID=4) → / (trang chủ)
            response.sendRedirect(request.getContextPath() + Role.getDashboardUrl(user.getRoleID()));
            return; // Kết thúc, không thực thi code phía dưới
        }

        // Chưa đăng nhập → forward request đến login.jsp để hiển thị form đăng nhập.
        // Dùng forward (không phải redirect) để giữ nguyên URL trên thanh địa chỉ.
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }

    /**
     * ================================================================
     * PHƯƠNG THỨC doPost() - Xử lý yêu cầu POST (Submit form đăng nhập)
     * ================================================================
     *
     * Được gọi khi user nhấn nút "Đăng nhập" trên form login.jsp.
     * Form gửi POST request với 2 parameter: "username" và "password".
     *
     * LUỒNG XỬ LÝ CHI TIẾT:
     *
     * Bước 1: Thiết lập encoding UTF-8 (hỗ trợ tiếng Việt).
     * Bước 2: Lấy dữ liệu username và password từ request.
     * Bước 3: SERVER-SIDE VALIDATION - Kiểm tra input hợp lệ.
     * Bước 4: Xác thực với database qua UserDAO.login().
     * Bước 5: Xử lý kết quả (thành công hoặc thất bại).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ---- Bước 1: Thiết lập encoding UTF-8 để đọc đúng ký tự tiếng Việt ----
        request.setCharacterEncoding("UTF-8");

        // ---- Bước 2: Lấy dữ liệu từ form ----
        // request.getParameter("username") lấy giá trị của input có name="username" trong form.
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // ================================================================
        // Bước 3: SERVER-SIDE VALIDATION - Kiểm tra input cơ bản
        // ================================================================
        // Kiểm tra username và password KHÔNG ĐƯỢC null hoặc rỗng (sau khi trim).
        // Đây là lớp bảo vệ chính - ngay cả khi client-side validation bị tắt (vd: tắt JS),
        // server vẫn đảm bảo dữ liệu hợp lệ trước khi truy vấn database.
        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            // Set thông báo lỗi vào request attribute → login.jsp sẽ đọc và hiển thị
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            // Giữ lại username đã nhập để user không phải gõ lại (sticky form)
            request.setAttribute("username", username);
            // Forward lại login.jsp (không phải redirect) để giữ request attributes
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return; // Kết thúc xử lý
        }

        // ================================================================
        // Bước 4: Xác thực với Database
        // ================================================================
        // Gọi UserDAO.login() để truy vấn database:
        // SELECT ... FROM Users WHERE Username = ? AND Password = ?
        // - Nếu tìm thấy bản ghi khớp → trả về đối tượng User chứa đầy đủ thông tin.
        // - Nếu không tìm thấy (sai username hoặc sai password) → trả về null.
        // Lưu ý: dùng .trim() để loại bỏ khoảng trắng thừa trước khi truy vấn.
        User user = userDAO.login(username.trim(), password.trim());

        if (user == null) {
            // ---- Xác thực THẤT BẠI: Sai username hoặc password ----
            // Thông báo lỗi chung "Tên đăng nhập hoặc mật khẩu không đúng"
            // (không nói cụ thể sai cái nào để tránh lộ thông tin - best practice bảo mật).
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.setAttribute("username", username); // Giữ lại username
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // ================================================================
        // Bước 5: Đăng nhập THÀNH CÔNG - Tạo session và lưu thông tin
        // ================================================================
        // request.getSession() (không có tham số false) → tạo session MỚI nếu chưa có.
        HttpSession session = request.getSession();

        // Lưu các thông tin cần thiết vào session:
        // - "loggedInUser": Đối tượng User đầy đủ (dùng để kiểm tra đăng nhập ở các trang khác)
        // - "userRole": RoleID dạng int (dùng để phân quyền nhanh trong AuthFilter)
        // - "userFullName": Tên hiển thị trên giao diện (header, sidebar...)
        session.setAttribute("loggedInUser", user);
        session.setAttribute("userRole", user.getRoleID());
        session.setAttribute("userFullName", user.getFullName());

        // ================================================================
        // Kiểm tra URL redirect sau đăng nhập (Deep Linking)
        // ================================================================
        // Trường hợp: User truy cập trang cần đăng nhập (vd: /admin/dashboard),
        // AuthFilter chặn lại, lưu URL gốc vào session attribute "redirectAfterLogin",
        // rồi redirect user về trang login.
        // Sau khi login thành công, ta kiểm tra xem có URL đang chờ không.
        // Nếu có → redirect về URL đó (thay vì về dashboard mặc định).
        // Điều kiện bổ sung: URL không bắt đầu bằng "/auth/" (tránh redirect lặp vô hạn).
        String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
        if (redirectUrl != null && !redirectUrl.isEmpty()
                && !redirectUrl.startsWith("/auth/")) {
            // Xóa attribute sau khi đã sử dụng (tránh redirect nhầm lần sau)
            session.removeAttribute("redirectAfterLogin");
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            // Không có URL chờ → redirect đến dashboard mặc định theo Role
            response.sendRedirect(request.getContextPath() + Role.getDashboardUrl(user.getRoleID()));
        }
    }
}
