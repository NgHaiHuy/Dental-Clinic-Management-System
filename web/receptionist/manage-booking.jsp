<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Appointment"%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
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
        <title>Quản Lý Lịch Hẹn & Tiếp Đón - SmileCare</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
                <a href="<%= request.getContextPath() %>/receptionist/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-secondary" style="padding: 6px 14px;">💵 Hàng chờ thanh toán</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container">
            <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 30px;">
                📋 Danh Sách Lịch Hẹn Đặt (Lễ Tân Tiếp Đón)
            </h1>
            
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
            
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Mã Lịch Hẹn</th>
                            <th>Khách Hàng</th>
                            <th>Ngày Hẹn</th>
                            <th>Giờ Hẹn</th>
                            <th>Bác Sĩ Chỉ Định</th>
                            <th>Ghi chú lúc đặt</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác Tiếp Đón</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (appointments == null || appointments.isEmpty()) { %>
                            <tr>
                                <td colspan="8" align="center" style="color: var(--text-muted); padding: 30px 0;">Không tìm thấy lịch hẹn nào trong cơ sở dữ liệu.</td>
                            </tr>
                        <% } else {
                            for (Appointment app : appointments) { %>
                                <tr>
                                    <td>#<%= app.getAppointmentID() %></td>
                                    <td><strong><%= app.getCustomerName() %></strong></td>
                                    <td><%= app.getAppointmentDate() %></td>
                                    <td><%= app.getAppointmentTime() %></td>
                                    <td><%= app.getDoctorName() %></td>
                                    <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= app.getNotes() != null ? app.getNotes() : "" %></td>
                                    <td>
                                        <% 
                                            String status = app.getStatus();
                                            String badgeClass = "badge-pending";
                                            if (status.equalsIgnoreCase("Confirmed")) {
                                                badgeClass = "badge-confirmed";
                                            } else if (status.equalsIgnoreCase("Attended")) {
                                                badgeClass = "badge-attended";
                                            } else if (status.equalsIgnoreCase("Cancelled")) {
                                                badgeClass = "badge-cancelled";
                                            }
                                        %>
                                        <span class="badge <%= badgeClass %>"><%= status %></span>
                                    </td>
                                    <td>
                                        <% if (app.getStatus().equalsIgnoreCase("Pending")) { %>
                                            <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline; margin-right: 5px;">
                                                <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                <input type="hidden" name="action" value="confirm">
                                                <button type="submit" class="action-btn-confirm"><i class="fas fa-check"></i> Xác nhận</button>
                                            </form>
                                            
                                            <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                                <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                <input type="hidden" name="action" value="cancel">
                                                <button type="submit" class="action-btn-cancel" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');"><i class="fas fa-times"></i> Hủy</button>
                                            </form>
                                        <% } else if (app.getStatus().equalsIgnoreCase("Confirmed")) { %>
                                            <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline; margin-right: 5px;">
                                                <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                <input type="hidden" name="action" value="checkin">
                                                <button type="submit" class="action-btn-checkin"><i class="fas fa-user-check"></i> Check-in</button>
                                            </form>
                                            
                                            <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                                <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                <input type="hidden" name="action" value="cancel">
                                                <button type="submit" class="action-btn-cancel" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');"><i class="fas fa-times"></i> Hủy</button>
                                            </form>
                                        <% } else { %>
                                            <span style="color: var(--text-muted); font-size: 0.85rem; font-style: italic;">Không có thao tác</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
