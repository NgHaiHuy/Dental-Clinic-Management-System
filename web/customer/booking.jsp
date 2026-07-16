<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.User, model.Service"%>
<%
    List<User> doctors = (List<User>) request.getAttribute("doctors");
    List<Service> services = (List<Service>) request.getAttribute("services");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt Lịch Hẹn - SmileCare</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <style>
            .booking-container {
                max-width: 750px !important;
                margin: 40px auto 60px auto;
            }
            .booking-card {
                background: var(--bg-secondary);
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-lg);
                padding: 45px;
                box-shadow: 0 15px 35px rgba(15, 23, 42, 0.04);
            }
            .section-title {
                font-family: var(--font-outfit);
                font-size: 1.05rem;
                font-weight: 700;
                color: var(--accent-teal);
                margin: 28px 0 16px 0;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .section-title::after {
                content: '';
                flex: 1;
                height: 1px;
                background-color: var(--border-color);
            }
            .form-grid-2 {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .form-group {
                margin-bottom: 20px;
            }
            .form-label {
                font-size: 0.9rem;
                font-weight: 600;
                color: var(--text-primary);
                margin-bottom: 8px;
                display: block;
            }
            .form-control, .form-select {
                width: 100%;
                padding: 12px 16px;
                font-size: 0.95rem;
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-md);
                background-color: var(--bg-primary);
                color: var(--text-primary);
                transition: all 0.2s ease;
            }
            .form-control:focus, .form-select:focus {
                border-color: var(--accent-teal);
                background-color: var(--bg-secondary);
                box-shadow: 0 0 0 4px rgba(13, 148, 136, 0.1);
                outline: none;
            }
            textarea.form-control {
                resize: vertical;
                min-height: 100px;
            }
            /* Custom Service Grid Card design */
            .services-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
                margin-top: 5px;
            }
            .service-card {
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-md);
                padding: 16px;
                display: flex;
                align-items: center;
                gap: 14px;
                cursor: pointer;
                transition: all 0.2s ease;
                background: var(--bg-secondary);
                position: relative;
                user-select: none;
            }
            .service-card:hover {
                border-color: var(--accent-teal);
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
            }
            .service-card-icon {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background-color: rgba(13, 148, 136, 0.08);
                color: var(--accent-teal);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 1.1rem;
                flex-shrink: 0;
                transition: all 0.2s ease;
            }
            .service-card-info {
                flex-grow: 1;
            }
            .service-card-title {
                font-size: 0.92rem;
                font-weight: 600;
                color: var(--accent-navy);
                margin-bottom: 3px;
                line-height: 1.3;
            }
            .service-card-price {
                font-size: 0.85rem;
                font-weight: 700;
                color: var(--text-muted);
            }
            .service-card-check {
                width: 20px;
                height: 20px;
                border-radius: 50%;
                border: 2px solid var(--border-color);
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.2s ease;
                flex-shrink: 0;
            }
            .service-card-check i {
                font-style: normal;
                font-weight: 800;
                font-size: 0.75rem;
                color: white;
                display: none;
            }
            /* Active state */
            .service-card.active {
                border-color: var(--accent-teal);
                background-color: rgba(13, 148, 136, 0.02);
                box-shadow: 0 4px 12px rgba(13, 148, 136, 0.06);
            }
            .service-card.active .service-card-icon {
                background-color: var(--accent-teal);
                color: white;
            }
            .service-card.active .service-card-check {
                border-color: var(--accent-teal);
                background-color: var(--accent-teal);
            }
            .service-card.active .service-card-check i {
                display: block;
            }
            .service-card.active .service-card-price {
                color: var(--accent-teal);
            }
            @media (max-width: 768px) {
                .form-grid-2, .services-grid {
                    grid-template-columns: 1fr;
                }
                .booking-card {
                    padding: 30px 20px;
                }
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
                <a href="<%= request.getContextPath() %>/customer/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/customer/history">Lịch sử khám</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container booking-container">
            <div class="booking-card">
                <h2 style="font-family: var(--font-outfit); font-size: 2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 6px; text-align: center;">
                    Đăng Ký Đặt Lịch Hẹn Khám
                </h2>
                <p style="color: var(--text-secondary); font-size: 0.95rem; text-align: center; margin-bottom: 10px;">
                    Vui lòng điền thông tin chi tiết để SmileCare sắp xếp bác sĩ và lịch hẹn phù hợp nhất với bạn.
                </p>
                
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger" style="margin-top: 20px; margin-bottom: 10px;">
                        <%= errorMessage %>
                    </div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/customer/booking" method="POST" style="margin-top: 15px;">
                    
                    <!-- Section 1: Thông tin khám -->
                    <div class="section-title">Thông tin lịch khám</div>
                    
                    <div class="form-group">
                        <label class="form-label">Chọn Bác sĩ chỉ định</label>
                        <select name="doctorID" class="form-select">
                            <option value="0">Khám tổng quát (Hệ thống tự động phân công bác sĩ)</option>
                            <% if (doctors != null) {
                                for (User doc : doctors) { %>
                                    <option value="<%= doc.getUserID() %>">Bác sĩ: <%= doc.getFullName() %></option>
                                <% }
                            } %>
                        </select>
                    </div>
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label class="form-label">Ngày khám mong muốn</label>
                            <input type="date" name="date" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Giờ khám (08:00 - 17:00)</label>
                            <input type="time" name="time" class="form-control" required>
                        </div>
                    </div>
                    
                    <!-- Section 2: Ghi chú triệu chứng -->
                    <div class="section-title">Triệu chứng & Nhu cầu khám</div>
                    <div class="form-group">
                        <label class="form-label">Mô tả tình trạng răng miệng</label>
                        <textarea name="notes" class="form-control" placeholder="Mô tả ngắn triệu chứng ê buốt, đau nhức hoặc nhu cầu thẩm mỹ của bạn..."></textarea>
                    </div>
                    
                    <!-- Section 3: Chọn dịch vụ -->
                    <div class="section-title">Dịch vụ quan tâm (Chọn trước)</div>
                    <div class="services-grid">
                        <% if (services != null) {
                            for (Service s : services) { 
                                String firstChar = s.getServiceName().substring(0, 1).toUpperCase();
                        %>
                                <div class="service-card" onclick="toggleServiceCard('s-<%= s.getServiceID() %>', this)">
                                    <input type="checkbox" name="services" value="<%= s.getServiceID() %>" id="s-<%= s.getServiceID() %>" style="display: none;">
                                    <div class="service-card-icon">
                                        <%= firstChar %>
                                    </div>
                                    <div class="service-card-info">
                                        <div class="service-card-title"><%= s.getServiceName() %></div>
                                        <div class="service-card-price"><%= String.format("%,.0f", s.getPrice()) %> đ</div>
                                    </div>
                                    <div class="service-card-check">
                                        <i>✓</i>
                                    </div>
                                </div>
                            <% }
                        } %>
                    </div>
                    
                    <div style="display: flex; gap: 15px; margin-top: 45px;">
                        <button type="submit" class="btn btn-cta" style="flex: 2; font-size: 1rem; font-weight: 700; padding: 14px;">Đặt Lịch Hẹn</button>
                        <a href="<%= request.getContextPath() %>/customer/dashboard" class="btn btn-secondary" style="flex: 1; text-align: center; line-height: 2.2; font-size: 1rem; font-weight: 600;">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>
        
        <script>
            function toggleServiceCard(checkboxId, cardElement) {
                const checkbox = document.getElementById(checkboxId);
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                    if (checkbox.checked) {
                        cardElement.classList.add('active');
                    } else {
                        cardElement.classList.remove('active');
                    }
                }
            }
        </script>
    </body>
</html>
