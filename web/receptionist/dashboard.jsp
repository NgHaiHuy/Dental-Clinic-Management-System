<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    if (loggedUser.getRoleID() != 3) { request.getRequestDispatcher("/error/403.jsp").forward(request, response); return; }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Tiếp đón | SmileCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family:'Inter',sans-serif; background:#f1f5f9; margin:0; display:flex; align-items:center; justify-content:center; min-height:100vh; }
        .card { background:white; border-radius:20px; padding:48px 40px; text-align:center; box-shadow:0 8px 32px rgba(0,0,0,0.08); max-width:480px; width:100%; }
        .icon { width:72px; height:72px; background:linear-gradient(135deg,#059669,#10b981); border-radius:20px; display:inline-flex; align-items:center; justify-content:center; font-size:30px; color:white; margin-bottom:20px; }
        h1 { font-size:22px; color:#0f172a; margin-bottom:8px; }
        p  { color:#64748b; font-size:15px; margin-bottom:28px; }
        .links { display:flex; gap:10px; justify-content:center; flex-wrap:wrap; }
        a { padding:10px 20px; background:#059669; color:white; border-radius:10px; text-decoration:none; font-size:13px; font-weight:600; transition:background 0.2s; }
        a:hover { background:#047857; }
        a.sec { background:#f1f5f9; color:#64748b; border:1px solid #e2e8f0; }
        a.sec:hover { background:#e2e8f0; }
    </style>
</head>
<body>
<div class="card">
    <div class="icon"><i class="fas fa-user-tie"></i></div>
    <h1>Xin chào, <%= loggedUser.getFullName() %>!</h1>
    <p>Đây là Dashboard Nhân viên Tiếp đón. Thành viên 4 sẽ phát triển đầy đủ giao diện này.</p>
    <div class="links">
        <a href="${pageContext.request.contextPath}/receptionist/manage-booking">Quản lý lịch hẹn</a>
        <a href="${pageContext.request.contextPath}/auth/logout" class="sec"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
    </div>
</div>
</body>
</html>
