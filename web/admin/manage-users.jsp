<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, model.Role, java.util.List"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Người dùng - Admin Dashboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --primary:      #2563eb;
            --primary-dark: #1d4ed8;
            --sidebar-bg:   #0f172a;
            --sidebar-text: #94a3b8;
            --sidebar-active:#2563eb;
            --bg:           #f1f5f9;
            --white:        #ffffff;
            --text-dark:    #0f172a;
            --text-muted:   #64748b;
            --border:       #e2e8f0;
            --danger:       #ef4444;
            --success:      #10b981;
            --warning:      #f59e0b;
            --radius:       12px;
            --shadow:       0 1px 3px rgba(0,0,0,0.08), 0 4px 16px rgba(0,0,0,0.04);
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text-dark); display: flex; min-height: 100vh; }

        /* ---- SIDEBAR ---- */
        .sidebar {
            width: 240px; background: var(--sidebar-bg);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; bottom: 0;
        }
        .sidebar-brand {
            padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.06);
            display: flex; align-items: center; gap: 12px;
        }
        .sidebar-brand-icon {
            width: 38px; height: 38px;
            background: linear-gradient(135deg, var(--primary), #06b6d4);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 17px; color: white;
        }
        .sidebar-brand-text { font-size: 16px; font-weight: 700; color: white; }
        .sidebar-brand-sub  { font-size: 11px; color: var(--sidebar-text); }

        .sidebar-nav { padding: 16px 0; flex: 1; }
        .nav-section-label {
            padding: 8px 20px; font-size: 10px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px; color: #475569;
        }
        .nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 20px; font-size: 14px; color: var(--sidebar-text);
            text-decoration: none; transition: all 0.2s; border-radius: 0;
        }
        .nav-item:hover, .nav-item.active {
            color: white; background: rgba(37,99,235,0.15);
        }
        .nav-item.active { color: white; background: rgba(37,99,235,0.25); border-right: 3px solid var(--primary); }
        .nav-item i { width: 18px; text-align: center; }

        .sidebar-footer {
            padding: 16px 20px; border-top: 1px solid rgba(255,255,255,0.06);
        }
        .user-info { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .user-avatar {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), #06b6d4);
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; color: white; font-weight: 600; flex-shrink: 0;
        }
        .user-name { font-size: 13px; font-weight: 600; color: white; }
        .user-role { font-size: 11px; color: var(--sidebar-text); }
        .btn-logout {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 12px; width: 100%;
            background: rgba(239,68,68,0.1); color: #fca5a5;
            border: 1px solid rgba(239,68,68,0.2); border-radius: 8px;
            font-size: 13px; font-weight: 500; cursor: pointer;
            font-family: 'Inter', sans-serif; text-decoration: none;
            transition: all 0.2s; justify-content: center;
        }
        .btn-logout:hover { background: rgba(239,68,68,0.2); color: white; }

        /* ---- MAIN ---- */
        .main { margin-left: 240px; flex: 1; display: flex; flex-direction: column; }

        .topbar {
            background: var(--white); border-bottom: 1px solid var(--border);
            padding: 16px 28px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .page-title { font-size: 20px; font-weight: 700; color: var(--text-dark); }
        .breadcrumb { font-size: 13px; color: var(--text-muted); margin-top: 2px; }

        .content { padding: 24px 28px; }

        /* Stats */
        .stats-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; margin-bottom: 24px; }
        .stat-card {
            background: var(--white); border-radius: var(--radius);
            padding: 18px 20px; box-shadow: var(--shadow);
            display: flex; align-items: center; gap: 14px;
        }
        .stat-icon {
            width: 44px; height: 44px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
        }
        .stat-icon.blue   { background: #eff6ff; color: var(--primary); }
        .stat-icon.green  { background: #f0fdf4; color: var(--success); }
        .stat-icon.yellow { background: #fffbeb; color: var(--warning); }
        .stat-icon.cyan   { background: #ecfeff; color: #06b6d4; }
        .stat-num  { font-size: 22px; font-weight: 700; color: var(--text-dark); }
        .stat-label{ font-size: 12px; color: var(--text-muted); margin-top: 2px; }

        /* Alerts */
        .alert {
            padding: 12px 16px; border-radius: var(--radius);
            font-size: 14px; margin-bottom: 16px;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-success { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
        .alert-danger  { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }

        /* Table card */
        .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); }
        .card-header {
            padding: 18px 20px; border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
        }
        .card-title { font-size: 16px; font-weight: 700; }
        .btn-primary {
            padding: 9px 18px; background: var(--primary); color: white;
            border: none; border-radius: 9px; font-size: 13px; font-weight: 600;
            cursor: pointer; font-family: 'Inter', sans-serif;
            display: flex; align-items: center; gap: 7px;
            transition: background 0.2s;
        }
        .btn-primary:hover { background: var(--primary-dark); }

        /* Search */
        .table-toolbar {
            padding: 14px 20px; border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 12px;
        }
        .search-input {
            flex: 1; padding: 9px 14px 9px 36px;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-size: 14px; font-family: 'Inter', sans-serif;
            outline: none; background: #f8fafc;
            max-width: 320px;
        }
        .search-input:focus { border-color: var(--primary); background: white; }
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 13px; }

        .filter-select {
            padding: 9px 13px; border: 1.5px solid var(--border); border-radius: 9px;
            font-size: 13px; font-family: 'Inter', sans-serif; outline: none;
            background: #f8fafc; cursor: pointer;
        }
        .filter-select:focus { border-color: var(--primary); }

        /* Table */
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            padding: 12px 16px; text-align: left;
            font-size: 11px; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.5px; color: var(--text-muted);
            background: #f8fafc; border-bottom: 1px solid var(--border);
        }
        tbody tr { border-bottom: 1px solid var(--border); transition: background 0.15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f8fafc; }
        td { padding: 13px 16px; font-size: 14px; }

        .user-cell { display: flex; align-items: center; gap: 10px; }
        .avatar {
            width: 36px; height: 36px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 600; color: white; flex-shrink: 0;
        }
        .avatar.admin    { background: linear-gradient(135deg,#7c3aed,#a855f7); }
        .avatar.doctor   { background: linear-gradient(135deg,#0284c7,#06b6d4); }
        .avatar.staff    { background: linear-gradient(135deg,#059669,#10b981); }
        .avatar.customer { background: linear-gradient(135deg,#d97706,#f59e0b); }

        .user-name-cell  { font-weight: 600; font-size: 14px; }
        .user-username   { font-size: 12px; color: var(--text-muted); }

        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 600; white-space: nowrap;
        }
        .badge-admin    { background: #f3e8ff; color: #7c3aed; }
        .badge-doctor   { background: #e0f2fe; color: #0369a1; }
        .badge-staff    { background: #dcfce7; color: #15803d; }
        .badge-customer { background: #fef3c7; color: #92400e; }

        .action-btns { display: flex; gap: 6px; }
        .btn-icon {
            width: 32px; height: 32px; border-radius: 8px; border: none;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; font-size: 13px; transition: all 0.2s;
        }
        .btn-edit   { background: #eff6ff; color: var(--primary); }
        .btn-edit:hover { background: var(--primary); color: white; }
        .btn-delete { background: #fef2f2; color: var(--danger); }
        .btn-delete:hover { background: var(--danger); color: white; }

        /* Modal */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(15,23,42,0.5); backdrop-filter: blur(4px);
            z-index: 1000; align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: var(--white); border-radius: 16px; width: 100%; max-width: 500px;
            margin: 20px; padding: 28px; box-shadow: 0 24px 64px rgba(0,0,0,0.2);
            max-height: 90vh; overflow-y: auto;
        }
        .modal-title { font-size: 18px; font-weight: 700; margin-bottom: 22px; }
        .modal-form-group { margin-bottom: 16px; }
        .modal-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 7px; }
        .modal-input, .modal-select {
            width: 100%; padding: 10px 13px;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-size: 14px; font-family: 'Inter', sans-serif;
            outline: none; background: #fafafa;
        }
        .modal-input:focus, .modal-select:focus { border-color: var(--primary); background: white; }
        .modal-footer { display: flex; gap: 10px; justify-content: flex-end; margin-top: 22px; }
        .btn-cancel {
            padding: 9px 18px; background: var(--bg); color: var(--text-muted);
            border: 1px solid var(--border); border-radius: 9px;
            font-size: 14px; cursor: pointer; font-family: 'Inter', sans-serif;
        }
        .btn-save {
            padding: 9px 22px; background: var(--primary); color: white;
            border: none; border-radius: 9px; font-size: 14px; font-weight: 600;
            cursor: pointer; font-family: 'Inter', sans-serif;
        }
        .btn-save:hover { background: var(--primary-dark); }
    </style>
</head>
<body>

<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    String initials = loggedUser != null ? String.valueOf(loggedUser.getFullName().charAt(0)) : "A";
    List<User> userList = (List<User>) request.getAttribute("userList");
    int totalAdmin = 0, totalDoctor = 0, totalStaff = 0, totalCustomer = 0;
    if (userList != null) {
        for (User u : userList) {
            switch (u.getRoleID()) {
                case 1: totalAdmin++;    break;
                case 2: totalDoctor++;   break;
                case 3: totalStaff++;    break;
                case 4: totalCustomer++; break;
            }
        }
    }
%>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon"><i class="fas fa-tooth"></i></div>
        <div>
            <div class="sidebar-brand-text">SmileCare</div>
            <div class="sidebar-brand-sub">Admin Panel</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Tổng quan</div>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">
            <i class="fas fa-chart-pie"></i> Dashboard
        </a>

        <div class="nav-section-label" style="margin-top:12px">Quản lý</div>
        <a href="${pageContext.request.contextPath}/admin/manage-users" class="nav-item active">
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
                <div class="user-name"><%= loggedUser != null ? loggedUser.getFullName() : "Admin" %></div>
                <div class="user-role">Quản trị viên</div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/auth/logout" class="btn-logout">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>
</aside>

<!-- MAIN -->
<main class="main">
    <div class="topbar">
        <div>
            <div class="page-title"><i class="fas fa-users" style="margin-right:8px;color:var(--primary)"></i>Quản lý Người dùng</div>
            <div class="breadcrumb">Admin &rsaquo; Người dùng</div>
        </div>
        <button class="btn-primary" onclick="openCreateModal()">
            <i class="fas fa-plus"></i> Thêm tài khoản
        </button>
    </div>

    <div class="content">
        <!-- Stats -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-shield-alt"></i></div>
                <div><div class="stat-num"><%= totalAdmin %></div><div class="stat-label">Quản trị viên</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon cyan"><i class="fas fa-user-md"></i></div>
                <div><div class="stat-num"><%= totalDoctor %></div><div class="stat-label">Bác sĩ</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fas fa-user-tie"></i></div>
                <div><div class="stat-num"><%= totalStaff %></div><div class="stat-label">Tiếp đón</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon yellow"><i class="fas fa-users"></i></div>
                <div><div class="stat-num"><%= totalCustomer %></div><div class="stat-label">Khách hàng</div></div>
            </div>
        </div>

        <!-- Alerts -->
        <% String msg = request.getParameter("msg");
           if ("created".equals(msg)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Tạo tài khoản thành công!</div><% }
           else if ("updated".equals(msg)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Cập nhật thông tin thành công!</div><% }
           else if ("deleted".equals(msg)) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> Đã xoá tài khoản.</div><% } %>

        <% String errMsg = (String) request.getAttribute("errorMessage");
           if (errMsg != null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= errMsg %></div><% } %>

        <!-- Table -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">Danh sách Người dùng</div>
                <span style="font-size:13px;color:var(--text-muted)">
                    Tổng: <%= userList != null ? userList.size() : 0 %> tài khoản
                </span>
            </div>

            <div class="table-toolbar">
                <div class="search-wrap">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" class="search-input"
                           placeholder="Tìm theo tên, username..."
                           oninput="filterTable()">
                </div>
                <select class="filter-select" id="roleFilter" onchange="filterTable()">
                    <option value="">Tất cả Role</option>
                    <option value="Quản trị viên">Quản trị viên</option>
                    <option value="Bác sĩ">Bác sĩ</option>
                    <option value="Nhân viên tiếp đón">Tiếp đón</option>
                    <option value="Khách hàng">Khách hàng</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="userTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Người dùng</th>
                            <th>Liên hệ</th>
                            <th>Vai trò</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (userList != null && !userList.isEmpty()) {
                               int idx = 1;
                               for (User u : userList) {
                                   String roleNameVi = Role.getRoleNameVi(u.getRoleID());
                                   String avatarClass = u.getRoleID() == 1 ? "admin" : u.getRoleID() == 2 ? "doctor" : u.getRoleID() == 3 ? "staff" : "customer";
                                   String badgeClass  = u.getRoleID() == 1 ? "badge-admin" : u.getRoleID() == 2 ? "badge-doctor" : u.getRoleID() == 3 ? "badge-staff" : "badge-customer";
                                   String firstChar   = u.getFullName() != null && !u.getFullName().isEmpty() ? String.valueOf(u.getFullName().charAt(0)) : "?";
                        %>
                        <tr>
                            <td style="color:var(--text-muted);font-size:13px"><%= idx++ %></td>
                            <td>
                                <div class="user-cell">
                                    <div class="avatar <%= avatarClass %>"><%= firstChar %></div>
                                    <div>
                                        <div class="user-name-cell"><%= u.getFullName() %></div>
                                        <div class="user-username">@<%= u.getUsername() %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="font-size:13px"><i class="fas fa-phone" style="color:var(--text-muted);margin-right:5px"></i><%= u.getPhone() != null ? u.getPhone() : "—" %></div>
                                <div style="font-size:12px;color:var(--text-muted);margin-top:2px"><i class="fas fa-envelope" style="margin-right:5px"></i><%= u.getEmail() != null && !u.getEmail().isEmpty() ? u.getEmail() : "—" %></div>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>" data-role="<%= roleNameVi %>">
                                    <%= roleNameVi %>
                                </span>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-icon btn-edit" title="Chỉnh sửa"
                                        onclick="openEditModal(<%= u.getUserID() %>, '<%= u.getUsername() %>', '<%= u.getFullName().replace("'", "\\'") %>', '<%= u.getPhone() != null ? u.getPhone() : "" %>', '<%= u.getEmail() != null ? u.getEmail() : "" %>', <%= u.getRoleID() %>)">
                                        <i class="fas fa-pen"></i>
                                    </button>
                                    <% if (loggedUser == null || u.getUserID() != loggedUser.getUserID()) { %>
                                    <button class="btn-icon btn-delete" title="Xoá"
                                        onclick="confirmDelete(<%= u.getUserID() %>, '<%= u.getUsername() %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% }} else { %>
                        <tr><td colspan="5" style="text-align:center;padding:40px;color:var(--text-muted)">
                            <i class="fas fa-users" style="font-size:32px;margin-bottom:10px;display:block;opacity:0.3"></i>
                            Chưa có người dùng nào.
                        </td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- MODAL: Tạo tài khoản mới -->
<div class="modal-overlay" id="createModal">
    <div class="modal">
        <h2 class="modal-title"><i class="fas fa-user-plus" style="margin-right:8px;color:var(--primary)"></i>Tạo tài khoản mới</h2>
        <form action="${pageContext.request.contextPath}/admin/manage-users" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-form-group">
                <label class="modal-label">Tên đăng nhập *</label>
                <input type="text" name="username" class="modal-input" placeholder="Nhập username" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Mật khẩu *</label>
                <input type="password" name="password" class="modal-input" placeholder="Nhập mật khẩu" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Họ và tên *</label>
                <input type="text" name="fullName" class="modal-input" placeholder="Nguyễn Văn A" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Số điện thoại *</label>
                <input type="tel" name="phone" class="modal-input" placeholder="0912345678" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Email</label>
                <input type="email" name="email" class="modal-input" placeholder="email@dental.com">
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Vai trò *</label>
                <select name="roleID" class="modal-select" required>
                    <option value="">-- Chọn vai trò --</option>
                    <option value="1">Quản trị viên</option>
                    <option value="2">Bác sĩ</option>
                    <option value="3">Nhân viên tiếp đón</option>
                    <option value="4">Khách hàng</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('createModal')">Huỷ</button>
                <button type="submit" class="btn-save"><i class="fas fa-plus" style="margin-right:6px"></i>Tạo tài khoản</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL: Chỉnh sửa user -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <h2 class="modal-title"><i class="fas fa-pen" style="margin-right:8px;color:var(--primary)"></i>Chỉnh sửa tài khoản</h2>
        <form action="${pageContext.request.contextPath}/admin/manage-users" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="userID" id="editUserID">
            <div class="modal-form-group">
                <label class="modal-label">Tên đăng nhập</label>
                <input type="text" id="editUsername" class="modal-input" disabled style="background:#f1f5f9;color:var(--text-muted)">
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Họ và tên *</label>
                <input type="text" name="fullName" id="editFullName" class="modal-input" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Số điện thoại *</label>
                <input type="tel" name="phone" id="editPhone" class="modal-input" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Email</label>
                <input type="email" name="email" id="editEmail" class="modal-input">
            </div>
            <div class="modal-form-group">
                <label class="modal-label">Vai trò *</label>
                <select name="roleID" id="editRoleID" class="modal-select" required>
                    <option value="1">Quản trị viên</option>
                    <option value="2">Bác sĩ</option>
                    <option value="3">Nhân viên tiếp đón</option>
                    <option value="4">Khách hàng</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Huỷ</button>
                <button type="submit" class="btn-save"><i class="fas fa-save" style="margin-right:6px"></i>Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<!-- FORM ẩn để DELETE -->
<form id="deleteForm" action="${pageContext.request.contextPath}/admin/manage-users" method="POST" style="display:none">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="userID" id="deleteUserID">
</form>

<script>
    function openCreateModal() {
        document.getElementById('createModal').classList.add('show');
    }
    function openEditModal(id, username, fullName, phone, email, roleID) {
        document.getElementById('editUserID').value  = id;
        document.getElementById('editUsername').value = username;
        document.getElementById('editFullName').value = fullName;
        document.getElementById('editPhone').value   = phone;
        document.getElementById('editEmail').value   = email;
        document.getElementById('editRoleID').value  = roleID;
        document.getElementById('editModal').classList.add('show');
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }
    function confirmDelete(id, username) {
        if (confirm('Bạn có chắc muốn xoá tài khoản "' + username + '"?\nHành động này không thể hoàn tác.')) {
            document.getElementById('deleteUserID').value = id;
            document.getElementById('deleteForm').submit();
        }
    }
    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) overlay.classList.remove('show');
        });
    });

    // Filter table
    function filterTable() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        const role   = document.getElementById('roleFilter').value.toLowerCase();
        const rows   = document.querySelectorAll('#userTable tbody tr');
        rows.forEach(function(row) {
            const text     = row.textContent.toLowerCase();
            const badgeEl  = row.querySelector('.badge');
            const roleName = badgeEl ? badgeEl.dataset.role.toLowerCase() : '';
            const matchSearch = text.includes(search);
            const matchRole   = !role || roleName.includes(role.toLowerCase());
            row.style.display = (matchSearch && matchRole) ? '' : 'none';
        });
    }
</script>
</body>
</html>
