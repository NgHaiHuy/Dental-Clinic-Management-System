<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Medicine, model.MedicalSupply, model.User, java.text.SimpleDateFormat"%>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) {
        activeTab = "medicine";
    }

    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<MedicalSupply> supplies = (List<MedicalSupply>) request.getAttribute("supplies");

    Medicine medicineToEdit = (Medicine) request.getAttribute("medicineToEdit");
    MedicalSupply supplyToEdit = (MedicalSupply) request.getAttribute("supplyToEdit");

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

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    User loggedUser = (User) session.getAttribute("loggedInUser");
    String initials = loggedUser != null ? String.valueOf(loggedUser.getFullName().charAt(0)) : "A";
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý Kho & Thuốc - Dental Clinic</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <style>
            /* Custom Tab Styling */
            .tabs-header {
                display: flex;
                gap: 10px;
                margin-bottom: 25px;
                border-bottom: 1px solid var(--border-color);
                padding-bottom: 10px;
            }
            .tab-btn {
                background: none;
                border: none;
                padding: 12px 24px;
                font-family: var(--font-outfit);
                font-size: 1.05rem;
                font-weight: 600;
                color: var(--text-secondary);
                cursor: pointer;
                border-radius: var(--border-radius-md);
                transition: all var(--transition-speed);
                text-decoration: none;
            }
            .tab-btn:hover {
                color: var(--text-primary);
                background-color: rgba(255, 255, 255, 0.05);
            }
            .tab-btn.active {
                color: var(--accent-blue);
                background-color: rgba(14, 165, 233, 0.1);
                border: 1px solid rgba(14, 165, 233, 0.2);
            }
            
            /* Low Stock Warning Row Styles */
            .row-warning {
                background-color: rgba(245, 158, 11, 0.08) !important;
            }
            .row-warning:hover {
                background-color: rgba(245, 158, 11, 0.12) !important;
            }
            .badge-warning {
                background-color: rgba(245, 158, 11, 0.15);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.2);
            }
        </style>
    </head>
    <body>
        
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
                <a href="${pageContext.request.contextPath}/admin/manage-services" class="nav-item">
                    <i class="fas fa-stethoscope"></i> Dịch vụ
                </a>
                <a href="${pageContext.request.contextPath}/admin/manage-medicines" class="nav-item active">
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
                    <div class="page-title"><i class="fas fa-pills" style="margin-right:8px;color:var(--primary)"></i>Quản lý Kho & Thuốc</div>
                    <div class="breadcrumb">Admin &rsaquo; Kho & Thuốc</div>
                </div>
            </div>
            
            <div class="content">

            <!-- Tabs Selection -->
            <div class="tabs-header">
                <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=medicine" 
                   class="tab-btn <%= "medicine".equals(activeTab) ? "active" : "" %>">
                   💊 Danh mục Thuốc
                </a>
                <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=supply" 
                   class="tab-btn <%= "supply".equals(activeTab) ? "active" : "" %>">
                   📦 Kho Vật tư Y tế
                </a>
            </div>

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
                <% if ("supply".equals(activeTab)) { %>
                    <div class="stat-box">
                        <span class="stat-label">Tổng Loại Vật Tư</span>
                        <span class="stat-value"><%= (supplies != null) ? supplies.size() : 0 %></span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Cần Nhập Thêm (Hết/Sắp Hết)</span>
                        <span class="stat-value" style="color: var(--rose-text);">
                            <%
                                int lowStockCount = 0;
                                if (supplies != null) {
                                    for (MedicalSupply s : supplies) {
                                        if (s.getQuantity() <= s.getMinQuantity()) lowStockCount++;
                                    }
                                }
                                out.print(lowStockCount);
                            %>
                        </span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Tồn Kho An Toàn</span>
                        <span class="stat-value" style="color: var(--emerald-text);">
                            <%= (supplies != null) ? (supplies.size() - lowStockCount) : 0 %>
                        </span>
                    </div>
                <% } else { %>
                    <div class="stat-box">
                        <span class="stat-label">Tổng Loại Thuốc</span>
                        <span class="stat-value"><%= (medicines != null) ? medicines.size() : 0 %></span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Đang Bán (Active)</span>
                        <span class="stat-value" style="color: var(--emerald-text);">
                            <%
                                int activeMedicines = 0;
                                if (medicines != null) {
                                    for (Medicine m : medicines) {
                                        if (m.isStatus()) activeMedicines++;
                                    }
                                }
                                out.print(activeMedicines);
                            %>
                        </span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-label">Ngừng Bán</span>
                        <span class="stat-value" style="color: var(--rose-text);">
                            <%= (medicines != null) ? (medicines.size() - activeMedicines) : 0 %>
                        </span>
                    </div>
                <% } %>
            </div>

            <div class="dashboard-grid">
                <!-- Left Column: Items Table List -->
                <main class="glass-card">
                    <div class="card-title">
                        <svg style="width: 24px; height: 24px; fill: var(--accent-blue);" viewBox="0 0 24 24">
                            <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10H7v-2h10v2zm0-4H7V7h10v2zm0 8H7v-2h10v2z"/>
                        </svg>
                        <%= "supply".equals(activeTab) ? "Danh sách Vật tư trong kho" : "Danh mục Thuốc bán lẻ" %>
                    </div>

                    <!-- Search Controls -->
                    <div class="controls-row">
                        <form action="<%= request.getContextPath() %>/admin/manage-medicines" method="GET" class="search-box-wrapper">
                            <input type="hidden" name="tab" value="<%= activeTab %>">
                            <svg class="search-icon-svg" viewBox="0 0 24 24">
                                <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                            </svg>
                            <input type="text" name="search" class="search-input" placeholder="Tìm kiếm tên sản phẩm..." value="<%= searchQuery %>">
                        </form>
                        <% if (!searchQuery.isEmpty()) { %>
                            <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=<%= activeTab %>" class="btn btn-secondary" style="padding: 10px 18px; font-size: 0.85rem;">Xóa bộ lọc</a>
                        <% } %>
                    </div>

                    <!-- Table Container -->
                    <div class="table-responsive">
                        <% if ("supply".equals(activeTab)) { %>
                            <!-- SUPPLIES TABLE -->
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Mã</th>
                                        <th>Tên Vật Tư</th>
                                        <th>Đơn Vị</th>
                                        <th style="width: 100px;">Số Lượng</th>
                                        <th style="width: 120px;">Đơn Giá</th>
                                        <th>Supplier</th>
                                        <th>Cập Nhật Cuối</th>
                                        <th style="width: 100px; text-align: center;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (supplies == null || supplies.isEmpty()) { %>
                                        <tr>
                                            <td colspan="8" style="text-align: center; color: var(--text-secondary); padding: 40px 0;">
                                                Không có vật tư y tế nào.
                                            </td>
                                        </tr>
                                    <% } else {
                                        for (MedicalSupply s : supplies) { 
                                            boolean isLow = s.getQuantity() <= s.getMinQuantity();
                                        %>
                                            <tr class="<%= isLow ? "row-warning" : "" %>">
                                                <td>#<%= s.getSupplyID() %></td>
                                                <td class="service-name-cell"><%= s.getSupplyName() %></td>
                                                <td><%= s.getUnit() %></td>
                                                <td>
                                                    <% if (isLow) { %>
                                                        <span class="badge badge-warning" title="Dưới mức an toàn (<%= s.getMinQuantity() %>)"><%= s.getQuantity() %> (Thấp)</span>
                                                    <% } else { %>
                                                        <%= s.getQuantity() %>
                                                    <% } %>
                                                </td>
                                                <td class="service-price-cell"><%= String.format("%,.0f", s.getUnitPrice()) %> đ</td>
                                                <td style="color: var(--text-secondary); font-size: 0.85rem;"><%= s.getSupplier() != null ? s.getSupplier() : "N/A" %></td>
                                                <td style="color: var(--text-muted); font-size: 0.8rem;"><%= s.getLastUpdated() != null ? sdf.format(s.getLastUpdated()) : "N/A" %></td>
                                                <td style="text-align: center;">
                                                    <div class="action-buttons" style="justify-content: center;">
                                                        <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=supply&action=edit&id=<%= s.getSupplyID() %>" 
                                                           class="btn-icon" title="Sửa">
                                                            <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                                                                <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                                                            </svg>
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=supply&action=delete&id=<%= s.getSupplyID() %>" 
                                                           class="btn-icon btn-icon-danger" title="Xóa"
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa vật tư này?');">
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
                        <% } else { %>
                            <!-- MEDICINES TABLE -->
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Mã</th>
                                        <th>Tên Thuốc</th>
                                        <th>Đơn Vị</th>
                                        <th style="width: 100px;">Đơn Giá</th>
                                        <th style="width: 100px;">Tồn Kho</th>
                                        <th style="width: 140px;">Trạng Thái</th>
                                        <th style="width: 100px; text-align: center;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (medicines == null || medicines.isEmpty()) { %>
                                        <tr>
                                            <td colspan="7" style="text-align: center; color: var(--text-secondary); padding: 40px 0;">
                                                Không có thuốc nào được tìm thấy.
                                            </td>
                                        </tr>
                                    <% } else {
                                        for (Medicine m : medicines) { %>
                                            <tr>
                                                <td>#<%= m.getMedicineID() %></td>
                                                <td class="service-name-cell"><%= m.getMedicineName() %></td>
                                                <td><%= m.getUnit() %></td>
                                                <td class="service-price-cell"><%= String.format("%,.0f", m.getPrice()) %> đ</td>
                                                <td><%= m.getStockQuantity() %></td>
                                                <td>
                                                    <% if (m.isStatus()) { %>
                                                        <span class="badge badge-active">Đang bán</span>
                                                    <% } else { %>
                                                        <span class="badge badge-inactive">Ngừng bán</span>
                                                    <% } %>
                                                </td>
                                                <td style="text-align: center;">
                                                    <div class="action-buttons" style="justify-content: center;">
                                                        <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=medicine&action=edit&id=<%= m.getMedicineID() %>" 
                                                           class="btn-icon" title="Sửa">
                                                            <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                                                                <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                                                            </svg>
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=medicine&action=delete&id=<%= m.getMedicineID() %>" 
                                                           class="btn-icon btn-icon-danger" title="Xóa/Ngừng bán"
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa/ngừng bán thuốc này?');">
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
                        <% } %>
                    </div>
                </main>

                <!-- Right Column: Add / Edit Form -->
                <aside class="glass-card">
                    <% if ("supply".equals(activeTab)) { %>
                        <!-- MEDICAL SUPPLY FORM -->
                        <% if (supplyToEdit != null) { %>
                            <div class="card-title" style="color: var(--accent-purple);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M14.06 9.02l.92.92L5.92 19H5v-.92l9.06-9.06M17.66 3c-.25 0-.51.1-.7.29l-1.83 1.83 3.75 3.75 1.83-1.83c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.2-.2-.45-.29-.71-.29zm-3.6 3.19L3 17.25V21h3.75L17.81 9.94l-3.75-3.75z"/>
                                </svg>
                                Cập nhật Vật tư
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-medicines" method="POST">
                                <input type="hidden" name="tab" value="supply">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= supplyToEdit.getSupplyID() %>">

                                <div class="form-group">
                                    <label class="form-label">Tên Vật Tư</label>
                                    <input type="text" name="supplyName" class="form-control" value="<%= supplyToEdit.getSupplyName() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Vị</label>
                                    <input type="text" name="unit" class="form-control" placeholder="Ví dụ: Hộp, Cái, Cuộn" value="<%= supplyToEdit.getUnit() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Số Lượng Tồn Kho</label>
                                    <input type="number" name="quantity" class="form-control" min="0" value="<%= supplyToEdit.getQuantity() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Ngưỡng Tối Thiểu (Cảnh báo)</label>
                                    <input type="number" name="minQuantity" class="form-control" min="0" value="<%= supplyToEdit.getMinQuantity() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá Nhập (đ)</label>
                                    <input type="number" name="unitPrice" class="form-control" min="1" step="any" value="<%= String.format("%.0f", supplyToEdit.getUnitPrice()) %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Nhà Cung Cấp</label>
                                    <input type="text" name="supplier" class="form-control" value="<%= supplyToEdit.getSupplier() != null ? supplyToEdit.getSupplier() : "" %>">
                                </div>

                                <div style="display: flex; gap: 10px; margin-top: 25px;">
                                    <button type="submit" class="btn btn-primary" style="flex: 1;">Lưu Thay Đổi</button>
                                    <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=supply" class="btn btn-secondary">Hủy</a>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="card-title" style="color: var(--accent-blue);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                                </svg>
                                Thêm Vật tư Mới
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-medicines" method="POST">
                                <input type="hidden" name="tab" value="supply">
                                <input type="hidden" name="action" value="add">

                                <div class="form-group">
                                    <label class="form-label">Tên Vật Tư</label>
                                    <input type="text" name="supplyName" class="form-control" placeholder="Nhập tên vật tư..." required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Vị</label>
                                    <input type="text" name="unit" class="form-control" placeholder="Ví dụ: Hộp, Cái, Cuộn" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Số Lượng Nhập</label>
                                    <input type="number" name="quantity" class="form-control" min="0" value="0" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Ngưỡng Tối Thiểu (Cảnh báo)</label>
                                    <input type="number" name="minQuantity" class="form-control" min="0" value="5" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá Nhập (đ)</label>
                                    <input type="number" name="unitPrice" class="form-control" placeholder="Ví dụ: 150000" min="1" step="any" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Nhà Cung Cấp</label>
                                    <input type="text" name="supplier" class="form-control" placeholder="Tên công ty phân phối...">
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 25px;">Thêm Mới Vật Tư</button>
                            </form>
                        <% } %>
                    <% } else { %>
                        <!-- MEDICINES FORM -->
                        <% if (medicineToEdit != null) { %>
                            <div class="card-title" style="color: var(--accent-purple);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M14.06 9.02l.92.92L5.92 19H5v-.92l9.06-9.06M17.66 3c-.25 0-.51.1-.7.29l-1.83 1.83 3.75 3.75 1.83-1.83c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.2-.2-.45-.29-.71-.29zm-3.6 3.19L3 17.25V21h3.75L17.81 9.94l-3.75-3.75z"/>
                                </svg>
                                Cập nhật Dược phẩm
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-medicines" method="POST">
                                <input type="hidden" name="tab" value="medicine">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= medicineToEdit.getMedicineID() %>">

                                <div class="form-group">
                                    <label class="form-label">Tên Thuốc</label>
                                    <input type="text" name="medicineName" class="form-control" value="<%= medicineToEdit.getMedicineName() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Vị Tính</label>
                                    <input type="text" name="unit" class="form-control" placeholder="Ví dụ: Viên, Vỉ, Chai" value="<%= medicineToEdit.getUnit() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá Bán (đ)</label>
                                    <input type="number" name="price" class="form-control" min="1" step="any" value="<%= String.format("%.0f", medicineToEdit.getPrice()) %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Số Lượng Tồn Kho</label>
                                    <input type="number" name="stockQuantity" class="form-control" min="0" value="<%= medicineToEdit.getStockQuantity() %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Trạng Thái Kinh Doanh</label>
                                    <select name="status" class="form-select">
                                        <option value="true" <%= medicineToEdit.isStatus() ? "selected" : "" %>>Đang kinh doanh (Active)</option>
                                        <option value="false" <%= !medicineToEdit.isStatus() ? "selected" : "" %>>Ngừng bán (Inactive)</option>
                                    </select>
                                </div>

                                <div style="display: flex; gap: 10px; margin-top: 25px;">
                                    <button type="submit" class="btn btn-primary" style="flex: 1;">Lưu Thay Đổi</button>
                                    <a href="<%= request.getContextPath() %>/admin/manage-medicines?tab=medicine" class="btn btn-secondary">Hủy</a>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="card-title" style="color: var(--accent-blue);">
                                <svg style="width: 24px; height: 24px; fill: currentColor;" viewBox="0 0 24 24">
                                    <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                                </svg>
                                Thêm Thuốc Mới
                            </div>
                            <form action="<%= request.getContextPath() %>/admin/manage-medicines" method="POST">
                                <input type="hidden" name="tab" value="medicine">
                                <input type="hidden" name="action" value="add">

                                <div class="form-group">
                                    <label class="form-label">Tên Thuốc</label>
                                    <input type="text" name="medicineName" class="form-control" placeholder="Nhập tên loại thuốc..." required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Vị Tính</label>
                                    <input type="text" name="unit" class="form-control" placeholder="Ví dụ: Viên, Vỉ, Chai" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Đơn Giá Bán (đ)</label>
                                    <input type="number" name="price" class="form-control" placeholder="Ví dụ: 25000" min="1" step="any" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Số Lượng Ban Đầu</label>
                                    <input type="number" name="stockQuantity" class="form-control" min="0" value="100" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Trạng Thái Kinh Doanh</label>
                                    <select name="status" class="form-select">
                                        <option value="true" selected>Đang kinh doanh (Active)</option>
                                        <option value="false">Ngừng bán (Inactive)</option>
                                    </select>
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 25px;">Thêm Mới Thuốc</button>
                            </form>
                        <% } %>
                    <% } %>
                </aside>
            </div>
        </main>
    </body>
</html>
