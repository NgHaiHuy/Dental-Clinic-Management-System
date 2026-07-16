<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Service, model.User"%>
<%
    List<Service> services = (List<Service>) request.getAttribute("services");
    Service serviceToEdit = (Service) request.getAttribute("serviceToEdit");
    
    // Read messages from request or session
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    if (successMessage != null) {
        request.getSession().removeAttribute("successMessage");
    }
    
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) {
        searchQuery = "";
    }
    
    User loggedUser = (User) session.getAttribute("loggedInUser");
    String initials = loggedUser != null ? String.valueOf(loggedUser.getFullName().charAt(0)) : "A";
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý Dịch vụ - Dental Clinic</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>
    <body class="admin-body">
        
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
                <a href="${pageContext.request.contextPath}/admin/manage-users" class="nav-item">
                    <i class="fas fa-users"></i> Người dùng
                </a>
                <a href="${pageContext.request.contextPath}/admin/manage-services" class="nav-item active">
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
                    <div class="page-title"><i class="fas fa-stethoscope" style="margin-right:8px;color:var(--primary)"></i>Quản lý Dịch vụ</div>
                    <div class="breadcrumb">Admin &rsaquo; Dịch vụ</div>
                </div>
            </div>
            
            <div class="content">
                <!-- Alerts Section -->
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        <svg style="width: 20px; height: 20px; fill: currentColor;" viewBox="0 0 24 24">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                        </svg>
                        <span><%= errorMessage %></span>
                    </div>
                <% } %>

                <% if (successMessage != null) { %>
                    <div class="alert alert-success">
                        <svg style="width: 20px; height: 20px; fill: currentColor;" viewBox="0 0 24 24">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                        </svg>
                        <span><%= successMessage %></span>
                    </div>
                <% } %>

                <!-- Metrics stats row -->
                <div class="stats-row">
                    <div class="stat-box">
                        <span class="stat-label">Tổng Dịch Vụ</span>
                        <span class="stat-value">
                            <%= (services != null) ? services.size() : 0 %>
                        </span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Đang Hoạt Động</span>
                        <span class="stat-value" style="color: var(--emerald-text);">
                            <%
                                int activeCount = 0;
                                if (services != null) {
                                    for (Service s : services) {
                                        if (s.isStatus()) activeCount++;
                                    }
                                }
                                out.print(activeCount);
                            %>
                        </span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Ngừng Cung Cấp</span>
                        <span class="stat-value" style="color: var(--rose-text);">
                            <%= (services != null) ? (services.size() - activeCount) : 0 %>
                        </span>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <!-- Left Column: Services Table List -->
                    <main class="glass-card">
                        <div class="card-title">
                            <svg style="width: 24px; height: 24px; fill: var(--accent-blue);" viewBox="0 0 24 24">
                                <path d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H8V4h12v12z"/>
                            </svg>
                            Danh sách Dịch vụ Nha khoa
                        </div>

                        <!-- Search Controls -->
                        <div class="controls-row">
                            <form action="<%= request.getContextPath() %>/admin/manage-services" method="GET" class="search-box-wrapper">
                                <svg class="search-icon-svg" viewBox="0 0 24 24">
                                    <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                                </svg>
                                <input type="text" name="search" class="search-input" placeholder="Tìm kiếm tên dịch vụ..." value="<%= searchQuery %>">
                            </form>
                            <% if (!searchQuery.isEmpty()) { %>
                                <a href="<%= request.getContextPath() %>/admin/manage-services" class="btn btn-secondary" style="padding: 10px 18px; font-size: 0.85rem;">Xóa bộ lọc</a>
                            <% } %>
                        </div>

                        <!-- Table -->
                        <div class="table-responsive">
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Mã</th>
                                        <th>Tên Dịch Vụ</th>
                                        <th style="width: 150px;">Đơn Giá</th>
                                        <th>Mô Tả</th>
                                        <th style="width: 140px;">Trạng Thái</th>
                                        <th style="width: 120px; text-align: center;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (services == null || services.isEmpty()) { %>
                                        <tr>
                                            <td colspan="6" style="text-align: center; color: var(--text-secondary); padding: 40px 0;">
                                                Không tìm thấy dịch vụ nào.
                                            </td>
                                        </tr>
                                    <% } else { 
                                        for (Service s : services) { %>
                                            <tr>
                                                <td>#<%= s.getServiceID() %></td>
                                                <td class="service-name-cell"><%= s.getServiceName() %></td>
                                                <td class="service-price-cell">
                                                    <%= String.format("%,.0f", s.getPrice()) %> đ
                                                </td>
                                                <td style="color: var(--text-secondary); font-size: 0.85rem; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                    <%= (s.getDescription() != null) ? s.getDescription() : "Không có mô tả" %>
                                                </td>
                                                <td>
                                                    <% if (s.isStatus()) { %>
                                                        <span class="badge badge-active">Hoạt động</span>
                                                    <% } else { %>
                                                        <span class="badge badge-inactive">Ngừng cung cấp</span>
                                                    <% } %>
                                                </td>
                                                <td style="text-align: center;">
                                                    <div class="action-buttons" style="justify-content: center;">
                                                        <!-- Toggle Status -->
                                                        <a href="<%= request.getContextPath() %>/admin/manage-services?action=toggle&id=<%= s.getServiceID() %>" 
                                                           class="btn-icon" title="Bật/Tắt trạng thái">
                                                            <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                                                                <path d="M17 7H7c-2.76 0-5 2.24-5 5s2.24 5 5 5h10c2.76 0 5-2.24 5-5s-2.24-5-5-5zm0 8c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z"/>
                                                            </svg>
                                                        </a>
                                                        <!-- Edit -->
                                                        <a href="<%= request.getContextPath() %>/admin/manage-services?action=edit&id=<%= s.getServiceID() %>" 
                                                           class="btn-icon" title="Chỉnh sửa">
                                                            <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                                                                <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                                                            </svg>
                                                        </a>
                                                        <!-- Delete -->
                                                        <a href="<%= request.getContextPath() %>/admin/manage-services?action=delete&id=<%= s.getServiceID() %>" 
                                                           class="btn-icon btn-icon-danger" title="Xóa/Ngừng hoạt động"
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa/ngừng hoạt động dịch vụ này?');">
                                                            <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                                                                <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
                                                            </svg>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } 
                                    } %>
                                </tbody>
                            </table>
                        </div>
                    </main>

                    <!-- Right Column: Add / Edit Form -->
                    <aside class="glass-card">
                        <% if (serviceToEdit != null) { %>
                            <!-- EDIT SERVICE FORM -->
                            <div class="card-title" style="color: var(--accent-purple);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M14.06 9.02l.92.92L5.92 19H5v-.92l9.06-9.06M17.66 3c-.25 0-.51.1-.7.29l-1.83 1.83 3.75 3.75 1.83-1.83c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.2-.2-.45-.29-.71-.29zm-3.6 3.19L3 17.25V21h3.75L17.81 9.94l-3.75-3.75z"/>
                                </svg>
                                Cập nhật Dịch vụ
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-services" method="POST">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= serviceToEdit.getServiceID() %>">

                                <div class="form-group">
                                    <label class="form-label">Tên Dịch Vụ</label>
                                    <input type="text" name="name" class="form-control" placeholder="Nhập tên dịch vụ..." value="<%= serviceToEdit.getServiceName() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá (đ)</label>
                                    <input type="number" name="price" class="form-control" placeholder="Ví dụ: 500000" min="1" step="any" value="<%= String.format("%.0f", serviceToEdit.getPrice()) %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Mô Tả Chi Tiết</label>
                                    <textarea name="description" class="form-control" placeholder="Nhập mô tả chi tiết về dịch vụ..."><%= (serviceToEdit.getDescription() != null) ? serviceToEdit.getDescription() : "" %></textarea>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Trạng Thái Hoạt Động</label>
                                    <select name="status" class="form-select">
                                        <option value="true" <%= serviceToEdit.isStatus() ? "selected" : "" %>>Đang cung cấp (Active)</option>
                                        <option value="false" <%= !serviceToEdit.isStatus() ? "selected" : "" %>>Ngừng cung cấp (Inactive)</option>
                                    </select>
                                </div>

                                <div style="display: flex; gap: 10px; margin-top: 25px;">
                                    <button type="submit" class="btn btn-primary" style="flex: 1;">Lưu Thay Đổi</button>
                                    <a href="<%= request.getContextPath() %>/admin/manage-services" class="btn btn-secondary">Hủy</a>
                                </div>
                            </form>
                        <% } else { %>
                            <!-- ADD NEW SERVICE FORM -->
                            <div class="card-title" style="color: var(--accent-blue);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                                </svg>
                                Thêm Dịch vụ Mới
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-services" method="POST">
                                <input type="hidden" name="action" value="add">

                                <div class="form-group">
                                    <label class="form-label">Tên Dịch Vụ</label>
                                    <input type="text" name="name" class="form-control" placeholder="Nhập tên dịch vụ..." required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá (đ)</label>
                                    <input type="number" name="price" class="form-control" placeholder="Ví dụ: 300000" min="1" step="any" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Mô Tả Chi Tiết</label>
                                    <textarea name="description" class="form-control" placeholder="Mô tả công nghệ sử dụng, đối tượng chỉ định..."></textarea>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Trạng Thái Hoạt Động</label>
                                    <select name="status" class="form-select">
                                        <option value="true" selected>Đang cung cấp (Active)</option>
                                        <option value="false">Ngừng cung cấp (Inactive)</option>
                                    </select>
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 25px;">Thêm Mới Dịch Vụ</button>
                            </form>
                        <% } %>
                    </aside>
                </div>
            </div>
        </main>
    </body>
</html>
