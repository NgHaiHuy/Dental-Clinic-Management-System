<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Object headerLoggedUser = session.getAttribute("loggedInUser");
    Object headerRoleValue = session.getAttribute("userRole");
    int headerRoleId = headerRoleValue instanceof Number
            ? ((Number) headerRoleValue).intValue()
            : 0;
    boolean headerIsLoggedIn = headerLoggedUser != null;
%>
<header class="site-header" id="top">
    <div class="container nav-wrap">
        <a class="brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Trang chủ SmileCare">
            <span class="brand-mark" aria-hidden="true">✦</span>
            <span>Smile<span>Care</span></span>
        </a>

        <nav class="main-nav" id="mainNav" aria-label="Điều hướng chính">
            <a href="${pageContext.request.contextPath}/index.jsp#about">Về SmileCare</a>
            <a href="${pageContext.request.contextPath}/index.jsp#services">Dịch vụ</a>
            <a href="${pageContext.request.contextPath}/index.jsp#doctors">Bác sĩ</a>
            <a href="${pageContext.request.contextPath}/index.jsp#clinic-info">Giờ làm việc</a>
            <a href="${pageContext.request.contextPath}/index.jsp#contact">Liên hệ</a>
            <a class="mobile-booking-link" href="${pageContext.request.contextPath}/customer/booking.jsp">Đặt lịch khám</a>
        </nav>

        <a class="button button-small header-booking-button" href="${pageContext.request.contextPath}/customer/booking.jsp">Đặt lịch khám</a>

        <div class="nav-actions<%= headerIsLoggedIn ? " has-user" : "" %>">
            <% if (!headerIsLoggedIn) { %>
                <a class="login-link" href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
                <a class="button button-small" href="${pageContext.request.contextPath}/auth/register">Đăng ký</a>
            <% } else { %>
                <div class="account-menu">
                    <button class="account-trigger" type="button" aria-label="Mở menu tài khoản" aria-expanded="false" aria-haspopup="true">
                        <svg class="account-avatar" viewBox="0 0 32 32" aria-hidden="true">
                            <circle cx="16" cy="16" r="14"></circle>
                            <circle class="avatar-head" cx="16" cy="11" r="4.5"></circle>
                            <path class="avatar-body" d="M7.8 25c1.2-4.6 4.1-7 8.2-7s7 2.4 8.2 7"></path>
                        </svg>
                        <span class="account-chevron" aria-hidden="true">⌄</span>
                    </button>

                    <div class="account-dropdown" role="menu">
                        <% if (headerRoleId == 4) { %>
                            <a href="${pageContext.request.contextPath}/customer/booking.jsp" role="menuitem">Đặt lịch khám</a>
                            <a href="${pageContext.request.contextPath}/examination-history" role="menuitem">Lịch sử khám của tôi</a>
                            <a href="${pageContext.request.contextPath}/customer/profile" role="menuitem">Hồ sơ</a>
                        <% } else if (headerRoleId == 1) { %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" role="menuitem">Trang quản lý</a>
                            <a href="${pageContext.request.contextPath}/admin/manage-users" role="menuitem">Quản lý tài khoản</a>
                            <a href="${pageContext.request.contextPath}/admin/manage-services" role="menuitem">Quản lý dịch vụ</a>
                        <% } else if (headerRoleId == 2) { %>
                            <a href="${pageContext.request.contextPath}/doctor/dashboard.jsp" role="menuitem">Trang bác sĩ</a>
                            <a href="${pageContext.request.contextPath}/doctor/checkup.jsp" role="menuitem">Khám bệnh</a>
                            <a href="${pageContext.request.contextPath}/examination-history" role="menuitem">Lịch sử ca đã khám</a>
                        <% } else if (headerRoleId == 3) { %>
                            <a href="${pageContext.request.contextPath}/receptionist/dashboard.jsp" role="menuitem">Trang tiếp nhận</a>
                            <a href="${pageContext.request.contextPath}/receptionist/manage-booking.jsp" role="menuitem">Quản lý lịch khám</a>
                            <a href="${pageContext.request.contextPath}/examination-history" role="menuitem">Lịch sử khám toàn bộ</a>
                            <a href="${pageContext.request.contextPath}/receptionist/billing" role="menuitem">Thanh toán</a>
                        <% } %>
                        <a class="logout-link" href="${pageContext.request.contextPath}/auth/logout" role="menuitem">Thoát</a>
                    </div>
                </div>
            <% } %>
        </div>

        <button class="menu-toggle" type="button" aria-label="Mở menu" aria-controls="mainNav" aria-expanded="false">☰</button>
    </div>
</header>
