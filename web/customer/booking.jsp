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
        <div class="dashboard-container" style="max-width: 600px;">
            <div class="glass-card" style="margin-top: 30px;">
                <h2 style="font-family: var(--font-outfit); font-size: 1.8rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 20px;">
                    📅 Đăng Ký Đặt Lịch Hẹn Khám
                </h2>
                
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        <%= errorMessage %>
                    </div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/customer/booking" method="POST">
                    <div class="form-group">
                        <label class="form-label">Chọn Bác sĩ chỉ định</label>
                        <select name="doctorID" class="form-select">
                            <option value="0">Khám tổng quát (Bác sĩ ngẫu nhiên)</option>
                            <% if (doctors != null) {
                                for (User doc : doctors) { %>
                                    <option value="<%= doc.getUserID() %>">Bác sĩ: <%= doc.getFullName() %></option>
                                <% }
                            } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Ngày khám mong muốn</label>
                        <input type="date" name="date" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Giờ khám (Giờ làm việc: 08:00 - 17:00)</label>
                        <input type="time" name="time" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Ghi chú triệu chứng / Nhu cầu khám</label>
                        <textarea name="notes" class="form-control" placeholder="Mô tả tình trạng răng miệng hiện tại của bạn..."></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" style="margin-bottom: 12px;">Dịch vụ quan tâm (chọn trước)</label>
                        <div style="border: 1px solid var(--border-color); border-radius: var(--border-radius-md); padding: 15px; background-color: var(--bg-tertiary); max-height: 200px; overflow-y: auto;">
                            <% if (services != null) {
                                for (Service s : services) { %>
                                    <div style="margin-bottom: 10px; display: flex; align-items: center; gap: 8px;">
                                        <input type="checkbox" name="services" value="<%= s.getServiceID() %>" id="s-<%= s.getServiceID() %>">
                                        <label for="s-<%= s.getServiceID() %>" style="font-size: 0.92rem; cursor: pointer;">
                                            <%= s.getServiceName() %> (<code><%= String.format("%,.0f", s.getPrice()) %> đ</code>)
                                        </label>
                                    </div>
                                <% }
                            } %>
                        </div>
                    </div>
                    
                    <div style="display: flex; gap: 15px; margin-top: 30px;">
                        <button type="submit" class="btn btn-cta" style="flex: 1;">📅 Đặt Lịch Hẹn</button>
                        <a href="<%= request.getContextPath() %>/customer/dashboard" class="btn btn-secondary">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>
