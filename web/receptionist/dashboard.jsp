<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, model.Appointment, java.util.List, java.text.SimpleDateFormat"%>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    if (loggedUser == null) { 
        response.sendRedirect(request.getContextPath() + "/auth/login"); 
        return; 
    }
    if (loggedUser.getRoleID() != 3) { 
        request.getRequestDispatcher("/error/403.jsp").forward(request, response); 
        return; 
    }

    // Load statistics from request
    Integer todayAppointmentsCount = (Integer) request.getAttribute("todayAppointmentsCount");
    Integer todayCheckedInCount = (Integer) request.getAttribute("todayCheckedInCount");
    Integer pendingCheckInCount = (Integer) request.getAttribute("pendingCheckInCount");
    Integer unpaidCount = (Integer) request.getAttribute("unpaidCount");
    Double todayRevenue = (Double) request.getAttribute("todayRevenue");
    List<Appointment> todayList = (List<Appointment>) request.getAttribute("todayList");

    if (todayAppointmentsCount == null) todayAppointmentsCount = 0;
    if (todayCheckedInCount == null) todayCheckedInCount = 0;
    if (pendingCheckInCount == null) pendingCheckInCount = 0;
    if (unpaidCount == null) unpaidCount = 0;
    if (todayRevenue == null) todayRevenue = 0.0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Tiếp Đón | SmileCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <style>
        /* Dashboard Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 35px;
        }
        
        .stat-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius-lg);
            padding: 24px;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            transition: all 0.25s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.05);
        }
        
        .stat-icon {
            width: 56px;
            height: 56px;
            border-radius: var(--border-radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            color: white;
        }
        
        .stat-info {
            display: flex;
            flex-direction: column;
        }
        
        .stat-value {
            font-family: var(--font-outfit);
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--accent-navy);
            line-height: 1.1;
            margin-bottom: 4px;
        }
        
        .stat-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 500;
        }
        
        /* Color variations for KPIs */
        .stat-blue .stat-icon { background: linear-gradient(135deg, #0ea5e9, #0284c7); }
        .stat-blue { border-left: 4px solid #0ea5e9; }
        
        .stat-green .stat-icon { background: linear-gradient(135deg, #10b981, #059669); }
        .stat-green { border-left: 4px solid #10b981; }
        
        .stat-orange .stat-icon { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .stat-orange { border-left: 4px solid #f59e0b; }
        
        .stat-purple .stat-icon { background: linear-gradient(135deg, #6366f1, #4f46e5); }
        .stat-purple { border-left: 4px solid #6366f1; }

        /* Dashboard content split layout */
        .dashboard-split {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
        }
        
        @media (max-width: 992px) {
            .dashboard-split {
                grid-template-columns: 1fr;
            }
        }
        
        /* Quick Actions Card */
        .quick-actions-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .action-link-btn {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            background-color: var(--bg-tertiary);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius-md);
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            gap: 15px;
        }
        
        .action-link-btn i {
            font-size: 18px;
            width: 32px;
            height: 32px;
            background-color: #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            transition: all 0.2s;
        }
        
        .action-link-btn:hover {
            background-color: var(--bg-primary);
            border-color: var(--accent-teal);
            transform: translateX(4px);
        }
        
        .action-link-btn:hover i {
            background-color: var(--accent-teal);
            color: white;
        }
        
        /* Notification alert styling */
        .revenue-alert {
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(14, 165, 233, 0.08) 100%);
            border: 1px solid rgba(99, 102, 241, 0.15);
            border-radius: var(--border-radius-md);
            padding: 15px 20px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.9rem;
            color: #312e81;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <!-- NAVBAR -->
    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/" class="navbar-brand">
            🦷 SmileCare<span>+</span>
        </a>
        <div class="navbar-menu">
            <a href="<%= request.getContextPath() %>/">Trang Chủ</a>
            <a href="<%= request.getContextPath() %>/receptionist/dashboard" class="active">Dashboard</a>
            <a href="<%= request.getContextPath() %>/receptionist/manage-booking">Quản lý lịch hẹn</a>
            <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-secondary" style="padding: 6px 14px;">Hàng chờ thanh toán</a>
            <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
        </div>
    </nav>

    <!-- CONTAINER -->
    <div class="dashboard-container">
        <!-- Welcoming & Intro -->
        <div style="margin-bottom: 30px;">
            <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 4px;">
                Xin chào, <%= loggedUser.getFullName() %>!
            </h1>
            <p style="color: var(--text-secondary); margin: 0; font-size: 1rem;">
                Chào mừng bạn quay lại hệ thống Tiếp đón & Thu ngân SmileCare
            </p>
        </div>

        <!-- Revenue Alert if unpaid queue is high -->
        <% if (unpaidCount > 0) { %>
            <div class="revenue-alert">
                <span style="font-size: 20px;">💰</span>
                <span>Hiện có <strong><%= unpaidCount %></strong> hồ sơ bệnh án đang chờ lập hóa đơn và thanh toán. Vui lòng kiểm tra hàng chờ!</span>
            </div>
        <% } %>

        <!-- STATISTICS GRID KPIs -->
        <div class="stats-grid">
            <!-- Stats item 1 -->
            <div class="stat-card stat-blue">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-info">
                    <span class="stat-value"><%= todayAppointmentsCount %></span>
                    <span class="stat-label">Lịch hẹn hôm nay</span>
                </div>
            </div>
            
            <!-- Stats item 2 -->
            <div class="stat-card stat-green">
                <div class="stat-icon"><i class="fas fa-user-check"></i></div>
                <div class="stat-info">
                    <span class="stat-value"><%= todayCheckedInCount %></span>
                    <span class="stat-label">Đã check-in khám</span>
                </div>
            </div>
            
            <!-- Stats item 3 -->
            <div class="stat-card stat-orange">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-info">
                    <span class="stat-value"><%= pendingCheckInCount %></span>
                    <span class="stat-label">Chờ khám / Chưa tới</span>
                </div>
            </div>
            
            <!-- Stats item 4 -->
            <div class="stat-card stat-purple">
                <div class="stat-icon"><i class="fas fa-wallet"></i></div>
                <div class="stat-info">
                    <span class="stat-value"><%= String.format("%,.0f", todayRevenue) %> đ</span>
                    <span class="stat-label">Doanh thu hôm nay</span>
                </div>
            </div>
        </div>

        <!-- SPLIT LAYOUT -->
        <div class="dashboard-split">
            <!-- Left Side: Today's Appointments List -->
            <main class="glass-card">
                <div class="card-title" style="margin-bottom: 20px;">
                    <i class="fas fa-list-ul" style="color: var(--accent-blue); margin-right: 8px;"></i>
                    Danh sách hẹn khám hôm nay (<%= todayList != null ? todayList.size() : 0 %>)
                </div>
                
                <!-- Quick Search Input -->
                <div style="margin-bottom: 15px;">
                    <input type="text" id="dashboardSearch" class="form-control" placeholder="🔍 Tìm nhanh bệnh nhân (Tên hoặc SĐT)..." oninput="filterDashboardAppointments()" style="font-size: 0.85rem; padding: 8px 12px; border-radius: var(--border-radius-md); width: 100%; box-sizing: border-box;">
                </div>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Giờ hẹn</th>
                                <th>Khách Hàng (Bệnh Nhân)</th>
                                <th>Bác sĩ điều trị</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (todayList == null || todayList.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" align="center" style="color: var(--text-muted); padding: 40px 0;">
                                        Không có cuộc hẹn nào được lên lịch trong ngày hôm nay.
                                    </td>
                                </tr>
                            <% } else {
                                for (Appointment app : todayList) { 
                                    String badgeClass = "badge-pending";
                                    if (app.getStatus().equalsIgnoreCase("Confirmed")) {
                                        badgeClass = "badge-confirmed";
                                    } else if (app.getStatus().equalsIgnoreCase("Attended")) {
                                        badgeClass = "badge-attended";
                                    } else if (app.getStatus().equalsIgnoreCase("Cancelled")) {
                                        badgeClass = "badge-cancelled";
                                    }
                            %>
                                    <tr class="appointment-row" data-customer-name="<%= app.getCustomerName() != null ? app.getCustomerName() : "" %>" data-customer-phone="<%= app.getCustomerPhone() != null ? app.getCustomerPhone() : "" %>">
                                        <td style="font-weight: 600; color: var(--accent-navy);"><%= app.getAppointmentTime() %></td>
                                        <td>
                                            <strong><%= app.getCustomerName() %></strong>
                                            <span style="display:block; font-size: 0.75rem; color: var(--text-muted);"><%= app.getCustomerPhone() %></span>
                                        </td>
                                        <td><%= app.getDoctorName() %></td>
                                        <td><span class="badge <%= badgeClass %>"><%= app.getStatus() %></span></td>
                                    </tr>
                                <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            </main>

            <!-- Right Side: Quick Actions Panel -->
            <aside class="glass-card">
                <div class="card-title" style="margin-bottom: 20px;">
                    <i class="fas fa-bolt" style="color: var(--accent-teal); margin-right: 8px;"></i>
                    Thao tác nhanh
                </div>
                
                <div class="quick-actions-list">
                    <a href="<%= request.getContextPath() %>/receptionist/manage-booking?action=new" class="action-link-btn">
                        <i class="fas fa-plus" style="color: #10b981;"></i>
                        <div>
                            <span style="display: block;">Đặt lịch tại quầy</span>
                            <span style="display: block; font-size: 0.75rem; color: var(--text-muted); font-weight: normal;">Đăng ký khám cho khách trực tiếp</span>
                        </div>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/receptionist/manage-booking" class="action-link-btn">
                        <i class="fas fa-clipboard-list" style="color: #0ea5e9;"></i>
                        <div>
                            <span style="display: block;">Quản lý & Tiếp đón</span>
                            <span style="display: block; font-size: 0.75rem; color: var(--text-muted); font-weight: normal;">Check-in khách hàng đến khám</span>
                        </div>
                    </a>
                    
                    <a href="<%= request.getContextPath() %>/receptionist/billing" class="action-link-btn">
                        <i class="fas fa-file-invoice-dollar" style="color: #6366f1;"></i>
                        <div>
                            <span style="display: block;">Hàng chờ thanh toán</span>
                            <span style="display: block; font-size: 0.75rem; color: var(--text-muted); font-weight: normal;">Lập hóa đơn và thanh toán thuốc</span>
                        </div>
                    </a>
                </div>
            </aside>
        </div>
    </div>
    
    <script>
        function removeDiacritics(str) {
            if (!str) return '';
            return str.normalize("NFD")
                      .replace(/[\u0300-\u036f]/g, "")
                      .replace(/đ/g, "d")
                      .replace(/Đ/g, "D");
        }

        function filterDashboardAppointments() {
            const searchVal = removeDiacritics(document.getElementById('dashboardSearch').value.toLowerCase().trim());
            const rows = document.querySelectorAll('.appointment-row');
            
            rows.forEach(row => {
                const name = removeDiacritics((row.getAttribute('data-customer-name') || '').toLowerCase());
                const phone = row.getAttribute('data-customer-phone') || '';
                
                let matchesSearch = true;
                if (searchVal) {
                    matchesSearch = name.indexOf(searchVal) > -1 || phone.indexOf(searchVal) > -1;
                }
                
                if (matchesSearch) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
