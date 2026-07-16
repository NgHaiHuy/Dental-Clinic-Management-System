<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Appointment, model.Service, model.Medicine"%>
<%
    List<Appointment> queue = (List<Appointment>) request.getAttribute("queue");
    Appointment app = (Appointment) request.getAttribute("appointment");
    List<Service> selectedServices = (List<Service>) request.getAttribute("selectedServices");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    
    if (successMessage != null) request.getSession().removeAttribute("successMessage");
    if (errorMessage != null) request.getSession().removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bác Sĩ - Khám Bệnh & Kê Đơn - SmileCare</title>
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
                <a href="<%= request.getContextPath() %>/doctor/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container">
            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
            <% } %>
            
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
            <% } %>
            
            <% if (app == null) { %>
                <!-- QUEUE MODE: List checked-in patients -->
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 35px;">
                    🩺 Hàng chờ khám bệnh của Bác sĩ
                </h1>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Mã Lịch Hẹn</th>
                                <th>Bệnh Nhân</th>
                                <th>Ngày Hẹn</th>
                                <th>Giờ Hẹn</th>
                                <th>Ghi Chú Triệu Chứng</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (queue == null || queue.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" align="center" style="color: var(--text-muted); padding: 30px 0;">Không có bệnh nhân nào đang chờ khám.</td>
                                </tr>
                            <% } else {
                                for (Appointment q : queue) { %>
                                    <tr>
                                        <td>#<%= q.getAppointmentID() %></td>
                                        <td><strong><%= q.getCustomerName() %></strong></td>
                                        <td><%= q.getAppointmentDate() %></td>
                                        <td><%= q.getAppointmentTime() %></td>
                                        <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= q.getNotes() != null ? q.getNotes() : "" %></td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/doctor/checkup?appointmentID=<%= q.getAppointmentID() %>" class="btn btn-primary" style="padding: 6px 12px; font-size: 0.8rem;">
                                                🩺 Tiến hành khám
                                            </a>
                                        </td>
                                    </tr>
                                <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <!-- FORM MODE: Fill medical record and prescription -->
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 35px;">
                    📝 Lập bệnh án & Đơn thuốc
                </h1>
                
                <div class="dashboard-grid">
                    <!-- Left: Form -->
                    <div class="glass-card">
                        <h2 style="font-family: var(--font-outfit); font-size: 1.4rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 20px;">
                            Bệnh nhân: <%= app.getCustomerName() %> (Mã hẹn: #<%= app.getAppointmentID() %>)
                        </h2>
                        
                        <form action="<%= request.getContextPath() %>/doctor/checkup" method="POST">
                            <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                            
                            <div class="form-group">
                                <label class="form-label">Chẩn đoán lâm sàng (Bắt buộc)</label>
                                <textarea name="diagnosis" class="form-control" placeholder="Mô tả kết quả chuẩn đoán bệnh lý..." required></textarea>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Kế hoạch điều trị / Hướng dẫn tiếp theo</label>
                                <textarea name="treatmentPlan" class="form-control" placeholder="Nhập phác đồ điều trị hoặc lời dặn của bác sĩ..."></textarea>
                            </div>
                            
                            <h3 style="font-family: var(--font-outfit); font-size: 1.15rem; font-weight: 700; color: var(--accent-navy); margin: 25px 0 12px 0;">
                                💊 Kê đơn thuốc ngoại trú (Nhập số lượng > 0)
                            </h3>
                            
                            <div class="table-responsive" style="margin-bottom: 25px;">
                                <table class="custom-table">
                                    <thead>
                                        <tr>
                                            <th>Tên Thuốc</th>
                                            <th>Đơn vị</th>
                                            <th>Đơn giá</th>
                                            <th style="width: 100px;">Số Lượng</th>
                                            <th>Hướng Dẫn Sử Dụng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (medicines != null) {
                                            for (Medicine m : medicines) { %>
                                                <tr>
                                                    <td style="display: flex; align-items: center; gap: 10px;">
                                                        <img src="${pageContext.request.contextPath}<%= m.getImagePath() %>" alt="<%= m.getMedicineName() %>" style="width: 40px; height: 40px; object-fit: contain; border: 1px solid var(--border-color); border-radius: var(--border-radius-md); padding: 2px; background: white;">
                                                        <div>
                                                            <strong><%= m.getMedicineName() %></strong>
                                                            <input type="hidden" name="medicineIDs" value="<%= m.getMedicineID() %>">
                                                        </div>
                                                    </td>
                                                    <td><%= m.getUnit() %></td>
                                                    <td><%= String.format("%,.0f", m.getPrice()) %> đ</td>
                                                    <td>
                                                        <input type="number" name="quantities" min="0" value="0" class="form-control" style="padding: 6px 10px;">
                                                    </td>
                                                    <td>
                                                        <input type="text" name="dosages" class="form-control" placeholder="VD: Uống ngày 2 lần sau ăn" style="padding: 6px 10px;">
                                                    </td>
                                                </tr>
                                            <% }
                                        } %>
                                    </tbody>
                                </table>
                            </div>
                            
                            <div style="display: flex; gap: 15px;">
                                <button type="submit" class="btn btn-cta">💾 Lưu Hồ Sơ Khám & Gửi Thanh Toán</button>
                                <a href="<%= request.getContextPath() %>/doctor/checkup" class="btn btn-secondary">Quay lại</a>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Right: Info Summary -->
                    <div>
                        <div class="glass-card" style="position: sticky; top: 100px;">
                            <h3 style="font-family: var(--font-outfit); font-size: 1.2rem; font-weight: 700; color: var(--accent-navy); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-bottom: 15px;">
                                Yêu cầu dịch vụ ban đầu
                            </h3>
                            <ul style="padding-left: 20px; font-size: 0.92rem; color: var(--text-secondary); line-height: 1.8;">
                                <% if (selectedServices == null || selectedServices.isEmpty()) { %>
                                    <li>Khách không đăng ký dịch vụ trước. Khám tổng quát.</li>
                                <% } else {
                                    for (Service s : selectedServices) { %>
                                        <li><%= s.getServiceName() %> (<code><%= String.format("%,.0f", s.getPrice()) %> đ</code>)</li>
                                    <% }
                                } %>
                            </ul>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </body>
</html>
