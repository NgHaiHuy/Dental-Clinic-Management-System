<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.User, model.Service"%>
<%
    List<User> doctors = (List<User>) request.getAttribute("doctors");
    List<Service> services = (List<Service>) request.getAttribute("services");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đặt Lịch Hẹn</title>
    </head>
    <body>
        <h1>Đặt Lịch Hẹn Khám Răng</h1>
        
        <p><a href="<%= request.getContextPath() %>/customer/dashboard">Quay lại Dashboard</a></p>
        
        <% if (errorMessage != null) { %>
            <p style="color: red;"><%= errorMessage %></p>
        <% } %>
        
        <form action="<%= request.getContextPath() %>/customer/booking" method="POST">
            <div>
                <label>Chọn Bác sĩ:</label><br>
                <select name="doctorID">
                    <option value="0">Khám tổng quát (Bác sĩ ngẫu nhiên)</option>
                    <% if (doctors != null) {
                        for (User doc : doctors) { %>
                            <option value="<%= doc.getUserID() %>">Bác sĩ: <%= doc.getFullName() %></option>
                        <% }
                    } %>
                </select>
            </div>
            
            <br>
            
            <div>
                <label>Ngày khám:</label><br>
                <input type="date" name="date" required>
            </div>
            
            <br>
            
            <div>
                <label>Giờ khám (Giờ mở cửa: 08:00 - 17:00):</label><br>
                <input type="time" name="time" required>
            </div>
            
            <br>
            
            <div>
                <label>Ghi chú / Triệu chứng:</label><br>
                <textarea name="notes" rows="4" cols="40" placeholder="Mô tả tình trạng răng miệng..."></textarea>
            </div>
            
            <br>
            
            <div>
                <label>Chọn dịch vụ quan tâm trước (không bắt buộc):</label><br>
                <% if (services != null) {
                    for (Service s : services) { %>
                        <input type="checkbox" name="services" value="<%= s.getServiceID() %>"> 
                        <%= s.getServiceName() %> - <%= String.format("%,.0f", s.getPrice()) %> đ<br>
                    <% }
                } %>
            </div>
            
            <br>
            
            <button type="submit">Đặt Lịch Hẹn</button>
        </form>
    </body>
</html>
