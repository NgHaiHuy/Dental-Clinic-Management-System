<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    User profileUser = (User) session.getAttribute("loggedInUser");
    if (profileUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }
    String displayName = profileUser.getFullName();
    if (displayName == null || displayName.trim().isEmpty()) displayName = profileUser.getUsername();
    String fullNameValue = request.getAttribute("submittedFullName") != null ? (String) request.getAttribute("submittedFullName") : profileUser.getFullName();
    String phoneValue = request.getAttribute("submittedPhone") != null ? (String) request.getAttribute("submittedPhone") : profileUser.getPhone();
    String emailValue = request.getAttribute("submittedEmail") != null ? (String) request.getAttribute("submittedEmail") : profileUser.getEmail();
    String activeTab = request.getAttribute("activeTab") != null ? (String) request.getAttribute("activeTab") : "profile";
    String csrfToken = (String) session.getAttribute("customerProfileCsrfToken");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ khách hàng | SmileCare</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Nunito+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer-profile.css">
</head>
<body>
    <header class="profile-header">
        <div class="container header-inner">
            <a class="brand" href="${pageContext.request.contextPath}/index.jsp"><span class="brand-mark">✦</span><span>Smile<span>Care</span></span></a>
            <nav class="header-links"><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a><a class="logout" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a></nav>
        </div>
    </header>

    <main class="profile-page container">
        <div class="page-heading"><div><p>TÀI KHOẢN KHÁCH HÀNG</p><h1>Hồ sơ của tôi</h1><span>Quản lý thông tin cá nhân và bảo mật tài khoản.</span></div><a href="${pageContext.request.contextPath}/index.jsp">← Quay lại SmileCare</a></div>
        <div class="profile-layout">
            <aside class="profile-sidebar">
                <div class="user-card"><div class="user-avatar"><%= html(displayName.substring(0, 1).toUpperCase()) %></div><h2><%= html(displayName) %></h2><p>@<%= html(profileUser.getUsername()) %></p><span>Khách hàng</span></div>
                <nav class="profile-tabs" aria-label="Cài đặt hồ sơ">
                    <button class="tab-button<%= "profile".equals(activeTab) ? " active" : "" %>" type="button" data-tab="profile-panel"><span>👤</span> Thông tin cá nhân</button>
                    <button class="tab-button<%= "password".equals(activeTab) ? " active" : "" %>" type="button" data-tab="password-panel"><span>🔒</span> Đổi mật khẩu</button>
                    <a href="${pageContext.request.contextPath}/customer/booking.jsp"><span>▣</span> Lịch khám</a>
                </nav>
            </aside>

            <section class="profile-content">
                <% if ("profile".equals(request.getParameter("success"))) { %><div class="alert success">✓ Thông tin cá nhân đã được cập nhật.</div><% } %>
                <% if ("password".equals(request.getParameter("success"))) { %><div class="alert success">✓ Mật khẩu đã được thay đổi thành công.</div><% } %>
                <% if (request.getAttribute("errorMessage") != null) { %><div class="alert error"><%= html((String) request.getAttribute("errorMessage")) %></div><% } %>

                <div class="tab-panel<%= "profile".equals(activeTab) ? " active" : "" %>" id="profile-panel">
                    <div class="panel-heading"><h2>Thông tin cá nhân</h2><p>Cập nhật thông tin liên hệ của bạn.</p></div>
                    <form method="post" action="${pageContext.request.contextPath}/customer/profile">
                        <input type="hidden" name="action" value="update-profile"><input type="hidden" name="csrfToken" value="<%= html(csrfToken) %>">
                        <div class="form-group"><label for="username">Tên đăng nhập</label><input id="username" value="<%= html(profileUser.getUsername()) %>" disabled><small>Tên đăng nhập không thể thay đổi.</small></div>
                        <div class="form-group"><label for="fullName">Họ và tên <b>*</b></label><input id="fullName" name="fullName" value="<%= html(fullNameValue) %>" maxlength="100" required></div>
                        <div class="form-row"><div class="form-group"><label for="phone">Số điện thoại</label><input id="phone" name="phone" value="<%= html(phoneValue) %>" maxlength="15" placeholder="0901 234 567"></div><div class="form-group"><label for="email">Email</label><input id="email" name="email" type="email" value="<%= html(emailValue) %>" maxlength="100" placeholder="name@example.com"></div></div>
                        <div class="form-actions"><a href="${pageContext.request.contextPath}/index.jsp">Hủy</a><button type="submit">Lưu thay đổi</button></div>
                    </form>
                </div>

                <div class="tab-panel<%= "password".equals(activeTab) ? " active" : "" %>" id="password-panel">
                    <div class="panel-heading"><h2>Đổi mật khẩu</h2><p>Sử dụng mật khẩu có ít nhất 6 ký tự.</p></div>
                    <form method="post" action="${pageContext.request.contextPath}/customer/profile">
                        <input type="hidden" name="action" value="change-password"><input type="hidden" name="csrfToken" value="<%= html(csrfToken) %>">
                        <div class="form-group password-field"><label for="currentPassword">Mật khẩu hiện tại</label><input id="currentPassword" name="currentPassword" type="password" required autocomplete="current-password"><button type="button">Hiện</button></div>
                        <div class="form-row"><div class="form-group password-field"><label for="newPassword">Mật khẩu mới</label><input id="newPassword" name="newPassword" type="password" minlength="6" maxlength="100" required autocomplete="new-password"><button type="button">Hiện</button></div><div class="form-group password-field"><label for="confirmPassword">Xác nhận mật khẩu</label><input id="confirmPassword" name="confirmPassword" type="password" minlength="6" maxlength="100" required autocomplete="new-password"><button type="button">Hiện</button></div></div>
                        <div class="password-note">Sau khi đổi mật khẩu, hãy sử dụng mật khẩu mới cho lần đăng nhập tiếp theo.</div>
                        <div class="form-actions"><button type="reset" class="secondary">Nhập lại</button><button type="submit">Đổi mật khẩu</button></div>
                    </form>
                </div>
            </section>
        </div>
    </main>
    <script src="${pageContext.request.contextPath}/assets/js/customer-profile.js"></script>
</body>
</html>
