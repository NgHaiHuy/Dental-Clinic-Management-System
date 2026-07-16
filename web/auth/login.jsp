<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, model.Role"%>
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
    <!-- LEFT: Branding panel -->
    <div class="auth-panel-left">
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

    <!-- RIGHT: Login form -->
    <div class="auth-panel-right">
        <h1 class="auth-form-title">Đăng nhập</h1>
        <p class="auth-form-subtitle">Chào mừng trở lại! Vui lòng nhập thông tin đăng nhập.</p>

        <%-- Thông báo đăng xuất thành công --%>
        <% if ("success".equals(request.getParameter("logout"))) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            Bạn đã đăng xuất thành công.
        </div>
        <% } %>

        <%-- Thông báo đăng ký thành công --%>
        <% if ("success".equals(request.getParameter("registered"))) { %>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            Đăng ký thành công! Hãy đăng nhập bằng tài khoản vừa tạo.
        </div>
        <% } %>

        <%-- Thông báo lỗi --%>
        <% String errorMsg = (String) request.getAttribute("errorMessage");
           if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i>
            <%= errorMsg %>
        </div>
        <% } %>

        <form id="loginForm" action="${pageContext.request.contextPath}/auth/login" method="POST" novalidate>
            <div class="form-group">
                <label class="form-label" for="username">Tên đăng nhập</label>
                <div class="input-wrapper">
                    <i class="fas fa-user input-icon"></i>
                    <input type="text" id="username" name="username" class="form-control"
                           placeholder="Nhập tên đăng nhập"
                           value="${not empty username ? username : ''}"
                           autocomplete="username" required>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu</label>
                <div class="input-wrapper">
                    <i class="fas fa-lock input-icon"></i>
                    <input type="password" id="password" name="password" class="form-control"
                           placeholder="Nhập mật khẩu"
                           autocomplete="current-password" required>
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

        <div class="auth-footer">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/auth/register">Đăng ký ngay</a>
        </div>

        <!-- Demo account hints -->
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
    // Toggle hiển thị/ẩn mật khẩu
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

    // Điền tài khoản demo
    function fillDemo(user, pass) {
        document.getElementById('username').value = user;
        document.getElementById('password').value = pass;
        document.getElementById('username').focus();
    }

    // Client-side validation trước khi submit
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
