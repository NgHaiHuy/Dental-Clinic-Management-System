<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User, model.Role" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Admin | SmileCare</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --primary: #2563eb; --primary-dark: #1d4ed8;
            --sidebar-bg: #0f172a; --bg: #f1f5f9; --white: #ffffff;
            --text-dark: #0f172a; --text-muted: #64748b; --border: #e2e8f0;
            --success: #10b981; --warning: #f59e0b; --danger: #ef4444;
            --radius: 12px; --shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 16px rgba(0,0,0,0.04);
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; min-height: 100vh; }

        /* Sidebar */
        .sidebar {
            width: 240px; background: var(--sidebar-bg);
            display: flex; flex-direction: column;
            position: fixed; top:0; left:0; bottom:0;
        }
        .sidebar-brand { padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.06); display: flex; align-items: center; gap: 12px; }
        .sidebar-brand-icon { width:38px; height:38px; background: linear-gradient(135deg,var(--primary),#06b6d4); border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:17px; color:white; }
        .sidebar-brand-text { font-size:16px; font-weight:700; color:white; }
        .sidebar-brand-sub  { font-size:11px; color:#94a3b8; }
        .sidebar-nav { padding: 16px 0; flex:1; }
        .nav-section-label { padding: 8px 20px; font-size: 10px; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#475569; }
        .nav-item { display:flex; align-items:center; gap:10px; padding:10px 20px; font-size:14px; color:#94a3b8; text-decoration:none; transition:all 0.2s; }
        .nav-item:hover, .nav-item.active { color:white; background:rgba(37,99,235,0.15); }
        .nav-item.active { border-right:3px solid var(--primary); background:rgba(37,99,235,0.25); }
        .nav-item i { width:18px; text-align:center; }
        .sidebar-footer { padding:16px 20px; border-top:1px solid rgba(255,255,255,0.06); }
        .user-info { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
        .user-avatar { width:34px; height:34px; border-radius:50%; background:linear-gradient(135deg,var(--primary),#06b6d4); display:flex; align-items:center; justify-content:center; font-size:14px; color:white; font-weight:600; }
        .user-name { font-size:13px; font-weight:600; color:white; }
        .user-role { font-size:11px; color:#94a3b8; }
        .btn-logout { display:flex; align-items:center; gap:8px; padding:8px 12px; width:100%; background:rgba(239,68,68,0.1); color:#fca5a5; border:1px solid rgba(239,68,68,0.2); border-radius:8px; font-size:13px; font-weight:500; cursor:pointer; font-family:'Inter',sans-serif; text-decoration:none; transition:all 0.2s; justify-content:center; }
        .btn-logout:hover { background:rgba(239,68,68,0.2); color:white; }

        /* Main */
        .main { margin-left:240px; flex:1; }
        .topbar { background:var(--white); border-bottom:1px solid var(--border); padding:16px 28px; display:flex; align-items:center; justify-content:space-between; }
        .page-title { font-size:20px; font-weight:700; }
        .content { padding:24px 28px; }

        /* Welcome banner */
        .welcome-banner {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 60%, #06b6d4 100%);
            border-radius: 16px; padding: 28px 32px; color: white; margin-bottom: 24px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .welcome-banner h2 { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
        .welcome-banner p  { font-size: 14px; opacity: 0.85; }
        .welcome-icon { font-size: 56px; opacity: 0.3; }

        /* Quick links */
        .quick-links { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px; }
        .quick-card {
            background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 22px; text-decoration: none; color: var(--text-dark);
            display: flex; align-items: center; gap: 16px;
            transition: all 0.2s; border: 1.5px solid transparent;
        }
        .quick-card:hover { border-color: var(--primary); transform: translateY(-2px); box-shadow: 0 8px 24px rgba(37,99,235,0.12); }
        .quick-icon { width:48px; height:48px; border-radius:14px; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .quick-icon.blue   { background:#eff6ff; color:var(--primary); }
        .quick-icon.cyan   { background:#ecfeff; color:#06b6d4; }
        .quick-icon.green  { background:#f0fdf4; color:var(--success); }
        .quick-label { font-size:15px; font-weight:600; }
        .quick-sub   { font-size:12px; color:var(--text-muted); margin-top:3px; }
    </style>
</head>
<body>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }
    String initials = String.valueOf(loggedUser.getFullName().charAt(0));
%>

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon"><i class="fas fa-tooth"></i></div>
        <div><div class="sidebar-brand-text">SmileCare</div><div class="sidebar-brand-sub">Admin Panel</div></div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section-label">Tổng quan</div>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item active">
            <i class="fas fa-chart-pie"></i> Dashboard
        </a>
        <div class="nav-section-label" style="margin-top:12px">Quản lý</div>
        <a href="${pageContext.request.contextPath}/admin/manage-users" class="nav-item">
            <i class="fas fa-users"></i> Người dùng
        </a>
        <a href="${pageContext.request.contextPath}/admin/manage-services" class="nav-item">
            <i class="fas fa-stethoscope"></i> Dịch vụ
        </a>
        <a href="${pageContext.request.contextPath}/admin/manage-medicines" class="nav-item">
            <i class="fas fa-pills"></i> Thuốc
        </a>
    </nav>
    <div class="sidebar-footer">
        <div class="user-info">
            <div class="user-avatar"><%= initials %></div>
            <div>
                <div class="user-name"><%= loggedUser.getFullName() %></div>
                <div class="user-role">Quản trị viên</div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/auth/logout" class="btn-logout">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>
</aside>

<main class="main">
    <div class="topbar">
        <div class="page-title">
            <i class="fas fa-chart-pie" style="margin-right:8px;color:var(--primary)"></i>
            Dashboard
        </div>
        <div style="font-size:13px;color:var(--text-muted)">
            <i class="fas fa-clock" style="margin-right:5px"></i>
            Chào mừng, <strong><%= loggedUser.getFullName() %></strong>
        </div>
    </div>

    <div class="content">
        <div class="welcome-banner">
            <div>
                <h2>Xin chào, <%= loggedUser.getFullName() %>! 👋</h2>
                <p>Chào mừng bạn quay trở lại Hệ thống Quản lý Nha khoa SmileCare.</p>
            </div>
            <div class="welcome-icon"><i class="fas fa-tooth"></i></div>
        </div>

        <div class="quick-links">
            <a href="${pageContext.request.contextPath}/admin/manage-users" class="quick-card">
                <div class="quick-icon blue"><i class="fas fa-users-cog"></i></div>
                <div><div class="quick-label">Quản lý Người dùng</div><div class="quick-sub">Thêm, sửa, xoá tài khoản</div></div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/manage-services" class="quick-card">
                <div class="quick-icon cyan"><i class="fas fa-stethoscope"></i></div>
                <div><div class="quick-label">Quản lý Dịch vụ</div><div class="quick-sub">Danh mục dịch vụ nha khoa</div></div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/manage-medicines" class="quick-card">
                <div class="quick-icon green"><i class="fas fa-pills"></i></div>
                <div><div class="quick-label">Quản lý Thuốc</div><div class="quick-sub">Danh mục thuốc & tồn kho</div></div>
            </a>
        </div>
    </div>
</main>
</body>
</html>
