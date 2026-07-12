<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Nếu đã đăng nhập, redirect về dashboard theo role
    model.User user = (model.User) session.getAttribute("loggedInUser");
    if (user != null) {
        response.sendRedirect(request.getContextPath() + model.Role.getDashboardUrl(user.getRoleID()));
    } else {
        response.sendRedirect(request.getContextPath() + "/auth/login");
    }
%>
