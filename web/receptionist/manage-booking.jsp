<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Appointment"%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    
    // Clean up session messages after reading
    if (successMessage != null) request.getSession().removeAttribute("successMessage");
    if (errorMessage != null) request.getSession().removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản Lý Lịch Hẹn & Tiếp Đón</title>
    </head>
    <body>
        <h1>Danh Sách Lịch Hẹn Khám Răng (Lễ Tân Tiếp Đón)</h1>
        
        <p>
            <a href="<%= request.getContextPath() %>/receptionist/dashboard">Quay lại Dashboard</a> |
            <a href="<%= request.getContextPath() %>/receptionist/billing">Đến hàng chờ thanh toán</a>
        </p>
        
        <% if (successMessage != null) { %>
            <p style="color: green;"><strong><%= successMessage %></strong></p>
        <% } %>
        
        <% if (errorMessage != null) { %>
            <p style="color: red;"><strong><%= errorMessage %></strong></p>
        <% } %>
        
        <table border="1" cellpadding="5" cellspacing="0" style="width: 100%;">
            <thead>
                <tr>
                    <th>Mã Lịch Hẹn</th>
                    <th>Khách Hàng</th>
                    <th>Ngày Hẹn</th>
                    <th>Giờ Hẹn</th>
                    <th>Bác Sĩ Chỉ Định</th>
                    <th>Ghi chú</th>
                    <th>Trạng Thái</th>
                    <th>Thao Tác Tiếp Đón</th>
                </tr>
            </thead>
            <tbody>
                <% if (appointments == null || appointments.isEmpty()) { %>
                    <tr>
                        <td colspan="8" align="center">Không có lịch hẹn nào.</td>
                    </tr>
                <% } else {
                    for (Appointment app : appointments) { %>
                        <tr>
                            <td>#<%= app.getAppointmentID() %></td>
                            <td><%= app.getCustomerName() %></td>
                            <td><%= app.getAppointmentDate() %></td>
                            <td><%= app.getAppointmentTime() %></td>
                            <td><%= app.getDoctorName() %></td>
                            <td><%= app.getNotes() != null ? app.getNotes() : "" %></td>
                            <td><strong><%= app.getStatus() %></strong></td>
                            <td>
                                <% if (app.getStatus().equalsIgnoreCase("Pending")) { %>
                                    <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                        <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                        <input type="hidden" name="action" value="confirm">
                                        <button type="submit">Xác nhận lịch</button>
                                    </form>
                                    
                                    <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                        <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                        <input type="hidden" name="action" value="cancel">
                                        <button type="submit" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');">Hủy lịch</button>
                                    </form>
                                <% } else if (app.getStatus().equalsIgnoreCase("Confirmed")) { %>
                                    <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                        <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                        <input type="hidden" name="action" value="checkin">
                                        <button type="submit">Khách đã đến (Check-in)</button>
                                    </form>
                                    
                                    <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="display:inline;">
                                        <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                        <input type="hidden" name="action" value="cancel">
                                        <button type="submit" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');">Hủy lịch</button>
                                    </form>
                                <% } else { %>
                                    <span>N/A</span>
                                <% } %>
                            </td>
                        </tr>
                    <% }
                } %>
            </tbody>
        </table>
    </body>
</html>
