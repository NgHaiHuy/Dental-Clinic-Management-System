<%--
================================================================================
    FILE: login.jsp
    THÀNH VIÊN 1 (Nghị) - Chức năng: ĐĂNG NHẬP
================================================================================

    MỤC ĐÍCH:
    - Trang giao diện cho phép người dùng nhập thông tin đăng nhập (username, password).
    - Hiển thị thông báo lỗi khi đăng nhập thất bại (sai username/password).
    - Hiển thị thông báo thành công khi vừa đăng ký xong hoặc vừa đăng xuất.
    - Cung cấp tài khoản demo để giảng viên/người kiểm thử dễ dàng test hệ thống.

    LUỒNG HOẠT ĐỘNG:
    1. Người dùng truy cập URL "/auth/login" → LoginController.doGet() được gọi.
    2. LoginController kiểm tra: nếu đã đăng nhập (session có "loggedInUser") thì redirect
       về dashboard tương ứng; nếu chưa thì forward đến file login.jsp này.
    3. Trang login.jsp hiển thị form đăng nhập.
    4. Người dùng nhập username/password và nhấn "Đăng nhập".
    5. JavaScript thực hiện CLIENT-SIDE VALIDATION trước khi gửi form:
       - Kiểm tra username và password không được để trống.
       - Nếu trống → hiển thị alert() và chặn form gửi đi (e.preventDefault()).
    6. Nếu validation phía client pass → form gửi POST request đến "/auth/login".
    7. LoginController.doPost() nhận dữ liệu, thực hiện SERVER-SIDE VALIDATION,
       truy vấn database qua UserDAO.login(), và xử lý kết quả:
       - Sai thông tin → forward lại login.jsp kèm errorMessage.
       - Đúng → lưu User vào session, redirect đến dashboard theo Role.

    TƯƠNG TÁC VỚI CÁC THÀNH PHẦN KHÁC:
    - LoginController.java: Servlet xử lý logic đăng nhập (GET hiển thị, POST xử lý).
    - UserDAO.login(): Truy vấn database kiểm tra username/password.
    - Role.getDashboardUrl(): Trả về URL dashboard tương ứng với roleID của user.
    - register.jsp: Link "Đăng ký ngay" chuyển hướng đến trang đăng ký.
    - LogoutController: Khi đăng xuất, redirect về login.jsp?logout=success.
================================================================================
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, model.Role"%>
<%--
    SCRIPTLET ĐẦU TRANG:
    - Kiểm tra xem người dùng đã đăng nhập hay chưa (lấy từ session).
    - Nếu đã đăng nhập: link logo (brand) sẽ dẫn về dashboard tương ứng với role.
    - Nếu chưa đăng nhập: link logo dẫn về trang chủ ("/").
    - Mục đích: Cho phép user click vào logo để quay về trang phù hợp.
--%>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    String brandUrl = (loggedUser != null) ? (request.getContextPath() + Role.getDashboardUrl(loggedUser.getRoleID())) : (request.getContextPath() + "/");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Nha khoa SmileCare</title>
    <meta name="description" content="Đăng nhập vào hệ thống quản lý Nha khoa SmileCare">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --primary:       #2563eb;
            --primary-dark:  #1d4ed8;
            --primary-light: #eff6ff;
            --accent:        #06b6d4;
            --success:       #10b981;
            --danger:        #ef4444;
            --warning:       #f59e0b;
            --text-dark:     #0f172a;
            --text-muted:    #64748b;
            --border:        #e2e8f0;
            --bg-page:       #f0f4ff;
            --white:         #ffffff;
            --shadow-lg:     0 20px 60px rgba(37,99,235,0.15);
            --radius-xl:     20px;
            --radius-md:     12px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-page);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background-image:
                radial-gradient(ellipse at 20% 50%, rgba(37,99,235,0.08) 0%, transparent 60%),
                radial-gradient(ellipse at 80% 20%, rgba(6,182,212,0.08) 0%, transparent 60%);
        }

        .auth-wrapper {
            display: flex;
            width: 100%;
            max-width: 960px;
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            min-height: 560px;
        }

        /* ---- LEFT PANEL ---- */
        .auth-panel-left {
            flex: 1;
            background: linear-gradient(145deg, #1e3a8a 0%, #2563eb 50%, #06b6d4 100%);
            padding: 48px 40px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            color: white;
            position: relative;
            overflow: hidden;
        }
        .auth-panel-left::before {
            content: '';
            position: absolute;
            top: -80px; right: -80px;
            width: 300px; height: 300px;
            border-radius: 50%;
            background: rgba(255,255,255,0.06);
        }
        .auth-panel-left::after {
            content: '';
            position: absolute;
            bottom: -60px; left: -60px;
            width: 250px; height: 250px;
            border-radius: 50%;
            background: rgba(255,255,255,0.04);
        }

        a.brand {
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 1;
            text-decoration: none;
            color: var(--white) !important;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        a.brand:hover {
            opacity: 0.85;
        }
        .brand-icon {
            width: 48px; height: 48px;
            background: rgba(255,255,255,0.2);
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px;
            backdrop-filter: blur(10px);
        }
        .brand-name { font-size: 22px; font-weight: 700; letter-spacing: -0.5px; }
        .brand-sub  { font-size: 12px; opacity: 0.75; font-weight: 400; }

        .panel-content { z-index: 1; }
        .panel-content h2 {
            font-size: 28px; font-weight: 700;
            line-height: 1.3; margin-bottom: 16px;
        }
        .panel-content p { font-size: 15px; opacity: 0.85; line-height: 1.6; }

        .feature-list { list-style: none; margin-top: 28px; z-index: 1; }
        .feature-list li {
            display: flex; align-items: center; gap: 10px;
            font-size: 14px; margin-bottom: 12px; opacity: 0.9;
        }
        .feature-list li i {
            width: 28px; height: 28px;
            background: rgba(255,255,255,0.15);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; flex-shrink: 0;
        }

        /* ---- RIGHT PANEL ---- */
        .auth-panel-right {
            flex: 1;
            padding: 48px 44px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .auth-form-title {
            font-size: 26px; font-weight: 700;
            color: var(--text-dark); margin-bottom: 6px;
        }
        .auth-form-subtitle {
            font-size: 14px; color: var(--text-muted); margin-bottom: 32px;
        }

        /* Alert messages */
        .alert {
            padding: 12px 16px; border-radius: var(--radius-md);
            font-size: 14px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-danger  { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .alert-success { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }

        /* Form */
        .form-group { margin-bottom: 20px; }
        .form-label {
            display: block; font-size: 13px; font-weight: 600;
            color: var(--text-dark); margin-bottom: 8px;
        }
        .input-wrapper {
            position: relative;
        }
        .input-icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: var(--text-muted); font-size: 15px;
            pointer-events: none;
        }
        .form-control {
            width: 100%; padding: 12px 14px 12px 42px;
            border: 1.5px solid var(--border); border-radius: var(--radius-md);
            font-size: 15px; font-family: 'Inter', sans-serif;
            color: var(--text-dark); background: #fafafa;
            transition: all 0.2s ease; outline: none;
        }
        .form-control:focus {
            border-color: var(--primary);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
        }
        .form-control::placeholder { color: #cbd5e1; }

        /* Toggle password visibility */
        .toggle-password {
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: var(--text-muted); font-size: 15px;
            transition: color 0.2s;
        }
        .toggle-password:hover { color: var(--primary); }

        /* Remember me & forgot */
        .form-options {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 24px;
        }
        .remember-label {
            display: flex; align-items: center; gap: 8px;
            font-size: 14px; color: var(--text-muted); cursor: pointer;
        }
        .remember-label input[type="checkbox"] { accent-color: var(--primary); }
        .forgot-link {
            font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 500;
        }
        .forgot-link:hover { text-decoration: underline; }

        /* Submit button */
        .btn-submit {
            width: 100%; padding: 13px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white; border: none; border-radius: var(--radius-md);
            font-size: 15px; font-weight: 600; font-family: 'Inter', sans-serif;
            cursor: pointer; letter-spacing: 0.3px;
            transition: all 0.25s ease; position: relative; overflow: hidden;
        }
        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 24px rgba(37,99,235,0.35);
        }
        .btn-submit:active { transform: translateY(0); }

        /* Register link */
        .auth-footer {
            text-align: center; margin-top: 28px;
            font-size: 14px; color: var(--text-muted);
        }
        .auth-footer a {
            color: var(--primary); font-weight: 600; text-decoration: none;
        }
        .auth-footer a:hover { text-decoration: underline; }

        /* Demo accounts */
        .demo-accounts {
            margin-top: 24px; padding: 14px 18px;
            background: var(--primary-light); border-radius: var(--radius-md);
            border: 1px solid #bfdbfe;
        }
        .demo-accounts h4 {
            font-size: 12px; font-weight: 700; color: var(--primary);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;
        }
        .demo-row {
            display: flex; justify-content: space-between;
            font-size: 12px; color: var(--text-muted); margin-bottom: 3px;
        }
        .demo-row span:first-child { font-weight: 600; color: var(--text-dark); }
        .demo-btn {
            background: none; border: none; cursor: pointer;
            color: var(--primary); font-size: 11px; font-weight: 600;
            padding: 2px 6px; border-radius: 4px;
            transition: background 0.2s;
        }
        .demo-btn:hover { background: rgba(37,99,235,0.1); }

        /* Responsive */
        @media (max-width: 720px) {
            .auth-panel-left { display: none; }
            .auth-panel-right { padding: 36px 28px; }
        }
    </style>
</head>
<body>

<div class="auth-wrapper">
    <!-- LEFT: Branding panel - Panel bên trái hiển thị thông tin thương hiệu và tính năng -->
    <div class="auth-panel-left">
        <%-- Link logo: dẫn về dashboard (nếu đã login) hoặc trang chủ (nếu chưa) --%>
        <a href="<%= brandUrl %>" class="brand">
            <div class="brand-icon"><i class="fas fa-tooth"></i></div>
            <div>
                <div class="brand-name">SmileCare</div>
                <div class="brand-sub">Dental Management System</div>
            </div>
        </a>

        <div class="panel-content">
            <h2>Hệ thống quản lý<br>Phòng khám Nha khoa</h2>
            <p>Nền tảng toàn diện giúp quản lý lịch hẹn, hồ sơ bệnh án và thanh toán một cách hiệu quả.</p>

            <ul class="feature-list">
                <li><i class="fas fa-calendar-check"></i> Đặt lịch hẹn trực tuyến</li>
                <li><i class="fas fa-file-medical"></i> Hồ sơ bệnh án điện tử</li>
                <li><i class="fas fa-receipt"></i> Quản lý hóa đơn & thanh toán</li>
                <li><i class="fas fa-shield-alt"></i> Bảo mật & phân quyền chặt chẽ</li>
            </ul>
        </div>

        <div style="font-size:12px; opacity:0.6; z-index:1;">
            &copy; 2026 SmileCare &mdash; Dental Clinic Management System
        </div>
    </div>

    <!-- RIGHT: Login form - Panel bên phải chứa form đăng nhập -->
    <div class="auth-panel-right">
        <h1 class="auth-form-title">Đăng nhập</h1>
        <p class="auth-form-subtitle">Chào mừng trở lại! Vui lòng nhập thông tin đăng nhập.</p>

        <%--
            HIỂN THỊ THÔNG BÁO ĐĂNG XUẤT THÀNH CÔNG:
            - Khi LogoutController xử lý đăng xuất, nó redirect về: /auth/login?logout=success
            - Ở đây ta kiểm tra parameter "logout" trong URL.
            - Nếu giá trị = "success" → hiển thị thông báo xanh (alert-success).
        --%>
        <% if ("success".equals(request.getParameter("logout"))) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            Bạn đã đăng xuất thành công.
        </div>
        <% } %>

        <%--
            HIỂN THỊ THÔNG BÁO ĐĂNG KÝ THÀNH CÔNG:
            - Khi RegisterController tạo tài khoản thành công, nó redirect về: /auth/login?registered=success
            - Ở đây ta kiểm tra parameter "registered" trong URL.
            - Nếu giá trị = "success" → hiển thị thông báo xanh, hướng dẫn user đăng nhập.
        --%>
        <% if ("success".equals(request.getParameter("registered"))) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            Đăng ký thành công! Hãy đăng nhập bằng tài khoản vừa tạo.
        </div>
        <% } %>

        <%--
            HIỂN THỊ THÔNG BÁO LỖI TỪ SERVER:
            - Khi LoginController.doPost() phát hiện lỗi (input trống, sai mật khẩu...),
              nó gán errorMessage vào request attribute rồi forward lại login.jsp.
            - Ở đây ta lấy attribute "errorMessage" từ request.
            - Nếu có giá trị (không null, không rỗng) → hiển thị thông báo đỏ (alert-danger).
            - Các lỗi có thể gặp:
              + "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu." (input trống)
              + "Tên đăng nhập hoặc mật khẩu không đúng." (xác thực thất bại)
        --%>
        <% String errorMsg = (String) request.getAttribute("errorMessage");
           if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i>
            <%= errorMsg %>
        </div>
        <% } %>

        <%--
            FORM ĐĂNG NHẬP:
            - action: gửi POST request đến URL "/auth/login" (LoginController.doPost()).
            - method="POST": gửi dữ liệu qua request body (bảo mật hơn GET).
            - novalidate: tắt validation mặc định của trình duyệt, dùng JS validation thay thế.
            - Khi submit, JavaScript sẽ chặn và kiểm tra trước (client-side validation).
            - Nếu pass validation → form gửi dữ liệu lên server.
        --%>
        <form id="loginForm" action="${pageContext.request.contextPath}/auth/login" method="POST" novalidate>
            <%-- TRƯỜNG TÊN ĐĂNG NHẬP --%>
            <div class="form-group">
                <label class="form-label" for="username">Tên đăng nhập</label>
                <div class="input-wrapper">
                    <i class="fas fa-user input-icon"></i>
                    <%--
                        GIỮ LẠI GIÁ TRỊ ĐÃ NHẬP (Sticky Form):
                        - Nếu đăng nhập thất bại, LoginController set attribute "username" = giá trị đã nhập.
                        - EL expression ${not empty username ? username : ''} sẽ hiển thị lại giá trị cũ.
                        - Mục đích: User không phải gõ lại username khi chỉ nhập sai password.
                        
                        HTML5 VALIDATION:
                        - required: trình duyệt sẽ không cho submit nếu trường trống
                          (tuy nhiên đã dùng novalidate nên thuộc tính này chỉ mang tính ngữ nghĩa,
                           việc validate thực tế do JavaScript đảm nhận).
                    --%>
                    <input type="text" id="username" name="username" class="form-control"
                           placeholder="Nhập tên đăng nhập"
                           value="${not empty username ? username : ''}"
                           autocomplete="username" required>
                </div>
            </div>

            <%-- TRƯỜNG MẬT KHẨU --%>
            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu</label>
                <div class="input-wrapper">
                    <i class="fas fa-lock input-icon"></i>
                    <%--
                        INPUT PASSWORD:
                        - type="password": ẩn ký tự nhập vào (hiển thị dấu chấm).
                        - Có nút toggle để chuyển đổi giữa hiện/ẩn mật khẩu.
                        - Không giữ lại giá trị password khi đăng nhập thất bại (bảo mật).
                    --%>
                    <input type="password" id="password" name="password" class="form-control"
                           placeholder="Nhập mật khẩu"
                           autocomplete="current-password" required>
                    <%--
                        NÚT HIỆN/ẨN MẬT KHẨU:
                        - type="button": không submit form khi click.
                        - onclick="togglePassword()": gọi hàm JS để chuyển đổi type input
                          giữa "password" (ẩn) và "text" (hiện).
                    --%>
                    <button type="button" class="toggle-password" onclick="togglePassword()" title="Hiện/Ẩn mật khẩu">
                        <i class="fas fa-eye" id="toggleIcon"></i>
                    </button>
                </div>
            </div>

            <div class="form-options">
                <label class="remember-label">
                    <input type="checkbox" name="remember"> Ghi nhớ đăng nhập
                </label>
                <a href="#" class="forgot-link">Quên mật khẩu?</a>
            </div>

            <button type="submit" class="btn-submit" id="loginBtn">
                <i class="fas fa-sign-in-alt" style="margin-right:8px;"></i>
                Đăng nhập
            </button>
        </form>

        <%-- LINK CHUYỂN ĐẾN TRANG ĐĂNG KÝ --%>
        <div class="auth-footer">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/auth/register">Đăng ký ngay</a>
        </div>

        <%--
            BẢNG TÀI KHOẢN DEMO:
            - Cung cấp các tài khoản mẫu để giảng viên/tester có thể nhanh chóng đăng nhập
              và kiểm tra từng role trong hệ thống.
            - Nút "Dùng" gọi hàm fillDemo() để tự động điền username/password vào form.
            - Bao gồm 4 role: Admin, Doctor (Bác sĩ), Staff (Tiếp đón), Customer (Khách hàng).
        --%>
        <div class="demo-accounts">
            <h4>Tài khoản demo</h4>
            <div class="demo-row">
                <span>admin</span>
                <span>Quản trị viên</span>
                <button class="demo-btn" onclick="fillDemo('admin','123')">Dùng</button>
            </div>
            <div class="demo-row">
                <span>doctor01</span>
                <span>Bác sĩ</span>
                <button class="demo-btn" onclick="fillDemo('doctor01','123')">Dùng</button>
            </div>
            <div class="demo-row">
                <span>staff01</span>
                <span>Tiếp đón</span>
                <button class="demo-btn" onclick="fillDemo('staff01','123')">Dùng</button>
            </div>
            <div class="demo-row">
                <span>customer01</span>
                <span>Khách hàng</span>
                <button class="demo-btn" onclick="fillDemo('customer01','123')">Dùng</button>
            </div>
        </div>
    </div>
</div>

<script>
    /**
     * HÀM TOGGLE HIỆN/ẨN MẬT KHẨU
     * - Lấy input password và icon toggle.
     * - Nếu đang ẩn (type="password") → chuyển sang hiện (type="text"), đổi icon thành "fa-eye-slash".
     * - Nếu đang hiện (type="text") → chuyển sang ẩn (type="password"), đổi icon thành "fa-eye".
     * - Giúp người dùng kiểm tra lại mật khẩu đã nhập có đúng không.
     */
    function togglePassword() {
        const input = document.getElementById('password');
        const icon  = document.getElementById('toggleIcon');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    /**
     * HÀM ĐIỀN TÀI KHOẢN DEMO
     * - Nhận username và password của tài khoản demo.
     * - Tự động điền vào 2 input field tương ứng.
     * - Focus vào trường username để user biết đã điền xong, chỉ cần nhấn Enter hoặc click Đăng nhập.
     *
     * @param {string} user - Tên đăng nhập demo (vd: 'admin', 'doctor01')
     * @param {string} pass - Mật khẩu demo (vd: '123')
     */
    function fillDemo(user, pass) {
        document.getElementById('username').value = user;
        document.getElementById('password').value = pass;
        document.getElementById('username').focus();
    }

    /**
     * ============================================================
     * CLIENT-SIDE VALIDATION - Kiểm tra dữ liệu phía trình duyệt
     * ============================================================
     *
     * Mục đích:
     * - Kiểm tra nhanh trước khi gửi request lên server.
     * - Tránh gửi request không cần thiết, giảm tải cho server.
     * - Mang lại trải nghiệm phản hồi nhanh cho người dùng.
     *
     * Logic kiểm tra:
     * 1. Lấy giá trị username và password, dùng .trim() để loại bỏ khoảng trắng thừa.
     * 2. Kiểm tra: nếu username HOẶC password rỗng (sau khi trim):
     *    - Gọi e.preventDefault() để CHẶN form không gửi đi.
     *    - Hiển thị alert() thông báo cho người dùng.
     * 3. Nếu cả hai đều có giá trị → cho phép form submit bình thường → gửi POST đến server.
     *
     * LƯU Ý:
     * - Client-side validation chỉ là lớp bảo vệ đầu tiên, có thể bị bypass (tắt JS).
     * - Server-side validation (trong LoginController.doPost()) là lớp bảo vệ chính,
     *   LUÔN kiểm tra lại lần nữa để đảm bảo an toàn.
     */
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        if (!username || !password) {
            e.preventDefault();
            alert('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.');
        }
    });
</script>
</body>
</html>
