<%-- 
    Document   : history
    Created on : May 14, 2026, 10:41:55 PM
    Author     : Nguye
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Appointment"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Lịch đã đặt</title>
    </head>
    <body>
        <h1>Danh sách lịch đã đặt</h1>

        <p>
            <a href="${pageContext.request.contextPath}/customer/booking">
                Đặt lịch mới
            </a>
        </p>

        <%
            List<Appointment> appointments
                    = (List<Appointment>) session.getAttribute("customerAppointments");
        %>

        <% if (appointments == null || appointments.isEmpty()) { %>
        <p>Bạn chưa có lịch đặt nào.</p>
        <% } else { %>
        <table border="1" cellpadding="8" cellspacing="0">
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Bác sĩ</th>
                    <th>Ngày khám</th>
                    <th>Giờ khám</th>
                    <th>Trạng thái</th>
                    <th>Ghi chú</th>
                </tr>
            </thead>

            <tbody>
                <%
                    for (int i = 0; i < appointments.size(); i++) {
                        Appointment appointment = appointments.get(i);
                %>
                <tr>
                    <td><%= i + 1 %></td>
                    <td>Doctor ID: <%= appointment.getDoctorId() %></td>
                    <td><%= appointment.getAppointmentDate() %></td>
                    <td><%= appointment.getAppointmentTime() %></td>
                    <td><%= appointment.getStatus() %></td>
                    <td>
                        <%= appointment.getNotes() == null ? "" : appointment.getNotes() %>
                    </td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <% } %>
    </body>
</html>
