<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - Nha khoa SmileCare</title>
    <meta name="description" content="Đăng ký tài khoản Khách hàng tại Nha khoa SmileCare">
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
            display: flex; align-items: center; justify-content: center;
            padding: 24px;
            background-image:
                radial-gradient(ellipse at 20% 50%, rgba(37,99,235,0.08) 0%, transparent 60%),
                radial-gradient(ellipse at 80% 20%, rgba(6,182,212,0.08) 0%, transparent 60%);
        }

        .register-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-lg);
            width: 100%; max-width: 520px;
            padding: 44px 44px 36px;
        }

        /* Header */
        .card-header {
            text-align: center; margin-bottom: 32px;
        }
        .brand-icon {
            width: 56px; height: 56px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            border-radius: 16px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 24px; color: white; margin-bottom: 16px;
        }
        .card-title   { font-size: 24px; font-weight: 700; color: var(--text-dark); margin-bottom: 6px; }
        .card-subtitle { font-size: 14px; color: var(--text-muted); }

        /* Alert */
        .alert {
            padding: 12px 16px; border-radius: var(--radius-md);
            font-size: 14px; margin-bottom: 20px;
            display: flex; align-items: flex-start; gap: 10px;
        }
        .alert-danger  { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .alert-success { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
        .alert i { margin-top: 1px; flex-shrink: 0; }

        /* Form */
        .form-row {
            display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
        }
        .form-group { margin-bottom: 18px; }
        .form-label {
            display: block; font-size: 13px; font-weight: 600;
            color: var(--text-dark); margin-bottom: 7px;
        }
        .form-label .required { color: var(--danger); margin-left: 2px; }

        .input-wrapper { position: relative; }
        .input-icon {
            position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
            color: var(--text-muted); font-size: 14px; pointer-events: none;
        }
        .form-control {
            width: 100%; padding: 11px 13px 11px 38px;
            border: 1.5px solid var(--border); border-radius: var(--radius-md);
            font-size: 14px; font-family: 'Inter', sans-serif;
            color: var(--text-dark); background: #fafafa;
            transition: all 0.2s ease; outline: none;
        }
        .form-control:focus {
            border-color: var(--primary); background: var(--white);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
        }
        .form-control.is-invalid { border-color: var(--danger); }
        .form-control::placeholder { color: #cbd5e1; }

        .toggle-password {
            position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: var(--text-muted); font-size: 14px;
            transition: color 0.2s;
        }
        .toggle-password:hover { color: var(--primary); }

        /* Password strength */
        .strength-bar {
            height: 4px; border-radius: 2px;
            background: var(--border); margin-top: 6px; overflow: hidden;
        }
        .strength-fill {
            height: 100%; border-radius: 2px; width: 0%;
            transition: width 0.3s, background 0.3s;
        }
        .strength-label { font-size: 11px; color: var(--text-muted); margin-top: 4px; }

        /* Terms */
        .terms-check {
            display: flex; align-items: flex-start; gap: 10px;
            font-size: 13px; color: var(--text-muted); margin-bottom: 22px;
        }
        .terms-check input { margin-top: 2px; accent-color: var(--primary); flex-shrink: 0; }
        .terms-check a { color: var(--primary); font-weight: 500; }

        /* Submit */
        .btn-submit {
            width: 100%; padding: 13px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white; border: none; border-radius: var(--radius-md);
            font-size: 15px; font-weight: 600; font-family: 'Inter', sans-serif;
            cursor: pointer; letter-spacing: 0.3px;
            transition: all 0.25s ease;
        }
        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 24px rgba(37,99,235,0.35);
        }
        .btn-submit:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

        /* Footer */
        .form-footer {
            text-align: center; margin-top: 22px;
            font-size: 14px; color: var(--text-muted);
        }
        .form-footer a { color: var(--primary); font-weight: 600; text-decoration: none; }
        .form-footer a:hover { text-decoration: underline; }

        @media (max-width: 480px) {
            .register-card { padding: 32px 24px; }
            .form-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="register-card">
    <div class="card-header">
        <div class="brand-icon"><i class="fas fa-tooth"></i></div>
        <h1 class="card-title">Tạo tài khoản mới</h1>
        <p class="card-subtitle">Đăng ký để đặt lịch khám nha khoa trực tuyến</p>
    </div>

    <%-- Thông báo lỗi --%>
    <% String errorMsg = (String) request.getAttribute("errorMessage");
       if (errorMsg != null && !errorMsg.isEmpty()) { %>
    <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle"></i>
        <span><%= errorMsg %></span>
    </div>
    <% } %>

    <form id="registerForm" action="${pageContext.request.contextPath}/auth/register" method="POST" novalidate>
        <div class="form-row">
            <div class="form-group">
                <label class="form-label" for="username">
                    Tên đăng nhập <span class="required">*</span>
                </label>
                <div class="input-wrapper">
                    <i class="fas fa-user input-icon"></i>
                    <input type="text" id="username" name="username" class="form-control"
                           placeholder="vd: nguyenvan"
                           value="${not empty regUsername ? regUsername : ''}"
                           autocomplete="username" required>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="fullName">
                    Họ và tên <span class="required">*</span>
                </label>
                <div class="input-wrapper">
                    <i class="fas fa-id-card input-icon"></i>
                    <input type="text" id="fullName" name="fullName" class="form-control"
                           placeholder="vd: Nguyễn Văn A"
                           value="${not empty regFullName ? regFullName : ''}"
                           required>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" for="password">
                Mật khẩu <span class="required">*</span>
            </label>
            <div class="input-wrapper">
                <i class="fas fa-lock input-icon"></i>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="Ít nhất 3 ký tự"
                       autocomplete="new-password" required
                       oninput="checkPasswordStrength(this.value)">
                <button type="button" class="toggle-password" onclick="togglePwd('password','icon1')" title="Hiện/Ẩn">
                    <i class="fas fa-eye" id="icon1"></i>
                </button>
            </div>
            <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
            <div class="strength-label" id="strengthLabel"></div>
        </div>

        <div class="form-group">
            <label class="form-label" for="confirmPassword">
                Xác nhận mật khẩu <span class="required">*</span>
            </label>
            <div class="input-wrapper">
                <i class="fas fa-lock input-icon"></i>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                       placeholder="Nhập lại mật khẩu"
                       autocomplete="new-password" required>
                <button type="button" class="toggle-password" onclick="togglePwd('confirmPassword','icon2')" title="Hiện/Ẩn">
                    <i class="fas fa-eye" id="icon2"></i>
                </button>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label" for="phone">
                    Số điện thoại <span class="required">*</span>
                </label>
                <div class="input-wrapper">
                    <i class="fas fa-phone input-icon"></i>
                    <input type="tel" id="phone" name="phone" class="form-control"
                           placeholder="0912345678"
                           value="${not empty regPhone ? regPhone : ''}"
                           required pattern="0[389]\d{8}" title="Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 03, 08 hoặc 09" oninput="this.value = this.value.replace(/[^0-9]/g, '')">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <div class="input-wrapper">
                    <i class="fas fa-envelope input-icon"></i>
                    <input type="email" id="email" name="email" class="form-control"
                           placeholder="email@example.com"
                           value="${not empty regEmail ? regEmail : ''}">
                </div>
            </div>
        </div>

        <div class="terms-check">
            <input type="checkbox" id="agreeTerms" required>
            <label for="agreeTerms">
                Tôi đồng ý với <a href="#">Điều khoản sử dụng</a>
                và <a href="#">Chính sách bảo mật</a> của SmileCare.
            </label>
        </div>

        <button type="submit" class="btn-submit" id="submitBtn">
            <i class="fas fa-user-plus" style="margin-right:8px;"></i>
            Tạo tài khoản
        </button>
    </form>

    <div class="form-footer">
        Đã có tài khoản?
        <a href="${pageContext.request.contextPath}/auth/login">Đăng nhập ngay</a>
    </div>
</div>

<script>
    // Toggle show/hide password
    function togglePwd(inputId, iconId) {
        const input = document.getElementById(inputId);
        const icon  = document.getElementById(iconId);
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    // Password strength checker
    function checkPasswordStrength(pwd) {
        const fill  = document.getElementById('strengthFill');
        const label = document.getElementById('strengthLabel');
        let score = 0;
        if (pwd.length >= 6)                              score++;
        if (pwd.length >= 10)                             score++;
        if (/[A-Z]/.test(pwd) && /[a-z]/.test(pwd))      score++;
        if (/[0-9]/.test(pwd))                            score++;
        if (/[^A-Za-z0-9]/.test(pwd))                    score++;

        const levels = [
            { pct: '0%',   color: '',          text: '' },
            { pct: '25%',  color: '#ef4444',   text: 'Rất yếu' },
            { pct: '50%',  color: '#f59e0b',   text: 'Trung bình' },
            { pct: '75%',  color: '#06b6d4',   text: 'Khá mạnh' },
            { pct: '90%',  color: '#10b981',   text: 'Mạnh' },
            { pct: '100%', color: '#059669',   text: 'Rất mạnh' },
        ];
        const lv = levels[Math.min(score, 5)];
        fill.style.width  = lv.pct;
        fill.style.background = lv.color;
        label.textContent = pwd.length ? lv.text : '';
        label.style.color = lv.color;
    }

    // Client-side validation
    document.getElementById('registerForm').addEventListener('submit', function(e) {
        const username = document.getElementById('username').value.trim();
        const pwd      = document.getElementById('password').value;
        const cfm      = document.getElementById('confirmPassword').value;
        const fullName = document.getElementById('fullName').value.trim();
        const phone    = document.getElementById('phone').value.trim();
        const terms    = document.getElementById('agreeTerms').checked;

        if (!username || !pwd || !cfm || !fullName || !phone) {
            e.preventDefault();
            alert('Vui lòng điền đầy đủ các trường bắt buộc (*).');
            return;
        }
        if (pwd !== cfm) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp!');
            return;
        }
        if (!terms) {
            e.preventDefault();
            alert('Bạn phải đồng ý với Điều khoản sử dụng để tiếp tục.');
            return;
        }
    });
</script>
</body>
</html>
