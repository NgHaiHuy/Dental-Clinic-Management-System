package controller.auth;

import dal.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * ================================================================================
 * FILE: RegisterController.java
 * THÀNH VIÊN 1 (Nghị) - Chức năng: XỬ LÝ ĐĂNG KÝ TÀI KHOẢN (Server-side)
 * ================================================================================
 *
 * MỤC ĐÍCH:
 * - Servlet xử lý logic đăng ký tài khoản mới cho Khách hàng (Customer).
 * - Ánh xạ URL "/auth/register" (cả GET và POST).
 * - Tài khoản được tạo mặc định với RoleID = 4 (Customer).
 *
 * LUỒNG HOẠT ĐỘNG:
 *
 *   [GET /auth/register]
 *   - Forward đến register.jsp hiển thị form đăng ký.
 *
 *   [POST /auth/register]
 *   1. Nhận dữ liệu từ form: username, password, confirmPassword, fullName, phone, email.
 *   2. SERVER-SIDE VALIDATION: Gọi validateRegisterInput() kiểm tra toàn bộ input.
 *   3. Kiểm tra username trùng (UserDAO.isUsernameExists()).
 *   4. Kiểm tra email trùng (UserDAO.isEmailExists()) - chỉ khi email không rỗng.
 *   5. Tạo tài khoản mới (UserDAO.register()).
 *   6. Thành công → redirect đến /auth/login?registered=success.
 *   7. Thất bại → forward lại register.jsp kèm errorMessage + giữ lại dữ liệu đã nhập.
 *
 * SERVER-SIDE VALIDATION BAO GỒM:
 * - Username: không trống, 4-50 ký tự, chỉ chứa chữ cái/số/gạch dưới, không trùng.
 * - Password: không trống, ít nhất 3 ký tự.
 * - ConfirmPassword: phải khớp với password.
 * - FullName: không trống.
 * - Phone: không trống, đúng format 10 số bắt đầu bằng 03/08/09.
 * - Email (tùy chọn): nếu có nhập thì phải đúng format, không trùng.
 *
 * TƯƠNG TÁC VỚI CÁC THÀNH PHẦN KHÁC:
 * - register.jsp: Trang giao diện hiển thị form đăng ký.
 * - UserDAO.register(): INSERT bản ghi mới vào bảng Users (RoleID = 4).
 * - UserDAO.isUsernameExists(): SELECT kiểm tra username đã tồn tại chưa.
 * - UserDAO.isEmailExists(): SELECT kiểm tra email đã tồn tại chưa.
 * - login.jsp: Nhận parameter "registered=success" và hiển thị thông báo đăng ký thành công.
 * ================================================================================
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/auth/register"})
public class RegisterController extends HttpServlet {

    /**
     * Khởi tạo UserDAO - đối tượng truy cập dữ liệu bảng Users.
     * Dùng "final" vì đối tượng này không thay đổi trong suốt vòng đời của Servlet.
     */
    private final UserDAO userDAO = new UserDAO();

    /**
     * ================================================================
     * PHƯƠNG THỨC doGet() - Hiển thị form đăng ký
     * ================================================================
     *
     * Được gọi khi user truy cập URL /auth/register hoặc click link "Đăng ký ngay".
     * Đơn giản forward đến register.jsp (không cần kiểm tra session vì ai cũng có thể đăng ký).
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
    }

    /**
     * ================================================================
     * PHƯƠNG THỨC doPost() - Xử lý form đăng ký
     * ================================================================
     *
     * Được gọi khi user nhấn nút "Tạo tài khoản" trên register.jsp.
     * Form gửi POST request với các parameter: username, password,
     * confirmPassword, fullName, phone, email.
     *
     * LUỒNG XỬ LÝ:
     * 1. Thiết lập UTF-8 encoding.
     * 2. Lấy tất cả dữ liệu từ form.
     * 3. Gọi validateRegisterInput() để kiểm tra tính hợp lệ.
     * 4. Kiểm tra username trùng trong database.
     * 5. Kiểm tra email trùng trong database (nếu có nhập email).
     * 6. Tạo tài khoản mới.
     * 7. Redirect hoặc forward tùy kết quả.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ---- Bước 1: Thiết lập encoding UTF-8 để đọc đúng ký tự tiếng Việt ----
        request.setCharacterEncoding("UTF-8");

        // ---- Bước 2: Lấy tất cả dữ liệu từ form đăng ký ----
        // request.getParameter("tên") lấy giá trị từ input có name="tên" trong form.
        String username        = request.getParameter("username");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName        = request.getParameter("fullName");
        String phone           = request.getParameter("phone");
        String email           = request.getParameter("email");

        // ================================================================
        // Bước 3: SERVER-SIDE VALIDATION
        // ================================================================
        // Gọi phương thức validateRegisterInput() để kiểm tra toàn bộ input.
        // Phương thức trả về:
        // - String chứa thông báo lỗi nếu có lỗi.
        // - null nếu tất cả input hợp lệ.
        String error = validateRegisterInput(username, password, confirmPassword, fullName, phone, email);

        if (error != null) {
            // Có lỗi validation → set thông báo lỗi và forward lại form
            request.setAttribute("errorMessage", error);

            // GIỮ LẠI DỮ LIỆU ĐÃ NHẬP (Sticky Form):
            // Set các attribute với prefix "reg" để register.jsp hiển thị lại
            // giá trị cũ trong các input field → user không phải nhập lại từ đầu.
            // Lưu ý: KHÔNG giữ lại password và confirmPassword (bảo mật).
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return; // Kết thúc xử lý
        }

        // ================================================================
        // Bước 4: Kiểm tra USERNAME trùng trong database
        // ================================================================
        // Gọi UserDAO.isUsernameExists() → SELECT 1 FROM Users WHERE Username = ?
        // Trả về true nếu đã có bản ghi với username này.
        if (userDAO.isUsernameExists(username.trim())) {
            request.setAttribute("errorMessage", "Tên đăng nhập \"" + username + "\" đã được sử dụng. Vui lòng chọn tên khác.");
            // Giữ lại dữ liệu đã nhập
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // ================================================================
        // Bước 5: Kiểm tra EMAIL trùng trong database (chỉ khi user có nhập email)
        // ================================================================
        // Email là trường không bắt buộc, nên chỉ kiểm tra khi email không null và không rỗng.
        // Gọi UserDAO.isEmailExists() → SELECT 1 FROM Users WHERE Email = ?
        if (email != null && !email.trim().isEmpty() && userDAO.isEmailExists(email.trim())) {
            request.setAttribute("errorMessage", "Email \"" + email + "\" đã được đăng ký. Vui lòng dùng email khác.");
            request.setAttribute("regUsername", username);
            request.setAttribute("regFullName", fullName);
            request.setAttribute("regPhone",    phone);
            request.setAttribute("regEmail",    email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // ================================================================
        // Bước 6: Tạo tài khoản mới trong database
        // ================================================================
        // Gọi UserDAO.register() → INSERT INTO Users (..., RoleID) VALUES (..., 4)
        // RoleID = 4 (Customer) được hardcode trong UserDAO.register().
        // Tất cả giá trị đều được .trim() để loại bỏ khoảng trắng thừa.
        // Email nếu null thì thay bằng chuỗi rỗng "".
        boolean success = userDAO.register(
                username.trim(),
                password.trim(),
                fullName.trim(),
                phone.trim(),
                email != null ? email.trim() : ""
        );

        if (success) {
            // ---- Đăng ký THÀNH CÔNG ----
            // Dùng sendRedirect (không phải forward) vì:
            // 1. Thay đổi URL trên thanh địa chỉ thành /auth/login.
            // 2. Tránh vấn đề "double submit" khi user nhấn F5 refresh
            //    (nếu dùng forward, F5 sẽ gửi lại POST → tạo trùng tài khoản).
            // 3. Pattern PRG (Post/Redirect/Get) - best practice trong web development.
            // Kèm parameter ?registered=success → login.jsp hiển thị thông báo thành công.
            response.sendRedirect(request.getContextPath() + "/auth/login?registered=success");
        } else {
            // ---- Đăng ký THẤT BẠI (lỗi database hoặc lỗi hệ thống) ----
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * ================================================================================
     * PHƯƠNG THỨC validateRegisterInput() - Validate toàn bộ dữ liệu đăng ký
     * ================================================================================
     *
     * Phương thức private, chỉ được gọi bởi doPost().
     * Tách riêng logic validation ra khỏi doPost() để code sạch hơn và dễ bảo trì.
     *
     * @param username        Tên đăng nhập
     * @param password        Mật khẩu
     * @param confirmPassword Mật khẩu xác nhận
     * @param fullName        Họ và tên
     * @param phone           Số điện thoại
     * @param email           Email (có thể null hoặc rỗng)
     * @return Chuỗi thông báo lỗi nếu có lỗi, hoặc null nếu tất cả hợp lệ.
     *
     * CÁC VALIDATION ĐƯỢC THỰC HIỆN (theo thứ tự):
     *
     * 1. USERNAME:
     *    - Không được null hoặc rỗng.
     *    - Độ dài 4-50 ký tự (sau khi trim).
     *    - Chỉ chứa chữ cái (a-z, A-Z), số (0-9), và dấu gạch dưới (_).
     *      Regex: [a-zA-Z0-9_]+
     *      → Ngăn chặn SQL Injection và ký tự đặc biệt gây lỗi.
     *
     * 2. PASSWORD:
     *    - Không được null hoặc rỗng.
     *    - Ít nhất 3 ký tự (hệ thống demo nên yêu cầu thấp; production nên >= 8).
     *
     * 3. CONFIRM PASSWORD:
     *    - Phải giống hệt password (so sánh bằng .equals()).
     *    - Lưu ý: so sánh giá trị gốc (chưa trim) để đảm bảo chính xác.
     *
     * 4. FULL NAME:
     *    - Không được null hoặc rỗng.
     *
     * 5. PHONE:
     *    - Không được null hoặc rỗng.
     *    - Phải khớp regex: ^0[389]\d{8}$
     *      + ^ : bắt đầu chuỗi
     *      + 0 : ký tự đầu tiên phải là số 0
     *      + [389] : ký tự thứ 2 phải là 3, 8, hoặc 9 (đầu số nhà mạng VN)
     *      + \d{8} : tiếp theo đúng 8 chữ số
     *      + $ : kết thúc chuỗi
     *      → Tổng cộng 10 chữ số, bắt đầu bằng 03, 08, hoặc 09.
     *      Lưu ý: Trong Java, regex cần escape "\\" → "\\d" thay vì "\d".
     *
     * 6. EMAIL (tùy chọn):
     *    - Nếu user KHÔNG nhập email → bỏ qua validation (return null = hợp lệ).
     *    - Nếu user CÓ nhập → phải khớp regex: ^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$
     *      + Phần trước @: cho phép chữ, số, +, _, ., -
     *      + Sau @: tên miền chứa chữ, số, ., -
     *      + Kết thúc: dấu chấm + ít nhất 2 chữ cái (vd: .com, .vn, .edu)
     */
    private String validateRegisterInput(String username, String password,
            String confirmPassword, String fullName, String phone, String email) {

        // ---- Validate USERNAME ----
        if (username == null || username.trim().isEmpty()) {
            return "Tên đăng nhập không được để trống.";
        }
        if (username.trim().length() < 4 || username.trim().length() > 50) {
            return "Tên đăng nhập phải từ 4 đến 50 ký tự.";
        }
        // Regex: chỉ cho phép chữ cái (a-z, A-Z), số (0-9), dấu gạch dưới (_)
        // Loại bỏ khoảng trắng, ký tự đặc biệt, tiếng Việt có dấu...
        if (!username.trim().matches("[a-zA-Z0-9_]+")) {
            return "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới.";
        }

        // ---- Validate PASSWORD ----
        if (password == null || password.trim().isEmpty()) {
            return "Mật khẩu không được để trống.";
        }
        if (password.trim().length() < 3) {
            return "Mật khẩu phải có ít nhất 3 ký tự.";
        }

        // ---- Validate CONFIRM PASSWORD ----
        // So sánh giá trị gốc (không trim) để đảm bảo user nhập đúng 100%
        if (!password.equals(confirmPassword)) {
            return "Xác nhận mật khẩu không khớp.";
        }

        // ---- Validate FULL NAME ----
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }

        // ---- Validate PHONE ----
        if (phone == null || phone.trim().isEmpty()) {
            return "Số điện thoại không được để trống.";
        }
        // Regex: ^0[389]\d{8}$ → đúng 10 số, bắt đầu bằng 03, 08, hoặc 09
        // Trong Java String, dấu \ phải escape thành \\ → "\\d" đại diện cho \d trong regex
        if (!phone.trim().matches("^0[389]\\d{8}$")) {
            return "Số điện thoại không hợp lệ. Phải gồm 10 chữ số và bắt đầu bằng 03, 08 hoặc 09.";
        }

        // ---- Validate EMAIL (tùy chọn - chỉ validate nếu user có nhập) ----
        if (email != null && !email.trim().isEmpty()) {
            // Regex kiểm tra format email cơ bản:
            // - Trước @: cho phép chữ, số, +, _, ., -
            // - Sau @: tên miền
            // - Kết thúc: .xx (ít nhất 2 ký tự, vd: .com, .vn)
            if (!email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                return "Địa chỉ email không hợp lệ.";
            }
        }

        // Tất cả validation đều pass → trả về null (không có lỗi)
        return null;
    }
}
