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
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Bác Sĩ - Khám Bệnh & Kê Đơn</title>
    </head>
    <body>
        <h1>Phòng Khám Răng - Bác Sĩ</h1>
        
        <p>
            <a href="<%= request.getContextPath() %>/doctor/dashboard">Quay lại Dashboard</a>
        </p>
        
        <% if (successMessage != null) { %>
            <p style="color: green;"><strong><%= successMessage %></strong></p>
        <% } %>
        
        <% if (errorMessage != null) { %>
            <p style="color: red;"><strong><%= errorMessage %></strong></p>
        <% } %>
        
        <% if (app == null) { %>
            <!-- QUEUE MODE: List checked-in patients waiting for checkup -->
            <h2>Hàng chờ khám bệnh (Đã Check-in)</h2>
            <table border="1" cellpadding="5" cellspacing="0">
                <thead>
                    <tr>
                        <th>Mã Lịch Hẹn</th>
                        <th>Bệnh Nhân</th>
                        <th>Ngày Hẹn</th>
                        <th>Giờ Hẹn</th>
                        <th>Ghi chú lúc đặt</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (queue == null || queue.isEmpty()) { %>
                        <tr>
                            <td colspan="6" align="center">Hiện tại chưa có bệnh nhân nào check-in đợi khám.</td>
                        </tr>
                    <% } else {
                        for (Appointment q : queue) { %>
                            <tr>
                                <td>#<%= q.getAppointmentID() %></td>
                                <td><%= q.getCustomerName() %></td>
                                <td><%= q.getAppointmentDate() %></td>
                                <td><%= q.getAppointmentTime() %></td>
                                <td><%= q.getNotes() != null ? q.getNotes() : "" %></td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/doctor/checkup?appointmentID=<%= q.getAppointmentID() %>">
                                        <button type="button">Tiến hành Khám</button>
                                    </a>
                                </td>
                            </tr>
                        <% }
                    } %>
                </tbody>
            </table>
        <% } else { %>
            <!-- FORM MODE: Fill medical record and prescription -->
            <h2>Lập Bệnh Án Cho Bệnh Nhân: <%= app.getCustomerName() %></h2>
            <p>Mã lịch hẹn: #<%= app.getAppointmentID() %></p>
            
            <h3>Dịch vụ yêu cầu ban đầu:</h3>
            <ul>
                <% if (selectedServices == null || selectedServices.isEmpty()) { %>
                    <li>Không đăng ký dịch vụ trước.</li>
                <% } else {
                    for (Service s : selectedServices) { %>
                        <li><%= s.getServiceName() %> (<%= String.format("%,.0f", s.getPrice()) %> đ)</li>
                    <% }
                } %>
            </ul>
            
            <hr>
            
            <form action="<%= request.getContextPath() %>/doctor/checkup" method="POST">
                <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                
                <div>
                    <label><strong>Chẩn Đoán Lâm Sàng (Bắt buộc):</strong></label><br>
                    <textarea name="diagnosis" rows="4" cols="50" required placeholder="Nhập kết quả chẩn đoán bệnh lý răng miệng..."></textarea>
                </div>
                
                <br>
                
                <div>
                    <label><strong>Kế Hoạch Điều Trị (Không bắt buộc):</strong></label><br>
                    <textarea name="treatmentPlan" rows="4" cols="50" placeholder="Nhập hướng điều trị tiếp theo..."></textarea>
                </div>
                
                <br>
                
                <h3>Kê Đơn Thuốc (Nhập số lượng > 0 để kê đơn):</h3>
                <table border="1" cellpadding="5" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Tên Thuốc</th>
                            <th>Đơn vị</th>
                            <th>Đơn giá</th>
                            <th>Số Lượng Kê</th>
                            <th>Liều Dùng / Cách Dùng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (medicines != null) {
                            for (Medicine m : medicines) { %>
                                <tr>
                                    <td>
                                        <%= m.getMedicineName() %>
                                        <input type="hidden" name="medicineIDs" value="<%= m.getMedicineID() %>">
                                    </td>
                                    <td><%= m.getUnit() %></td>
                                    <td><%= String.format("%,.0f", m.getPrice()) %> đ</td>
                                    <td>
                                        <input type="number" name="quantities" min="0" value="0" style="width: 60px;">
                                    </td>
                                    <td>
                                        <input type="text" name="dosages" placeholder="Uống ngày 2 lần sau ăn..." style="width: 250px;">
                                    </td>
                                </tr>
                            <% }
                        } %>
                    </tbody>
                </table>
                
                <br>
                
                <button type="submit">Lưu Hồ Sơ Khám & Chuyển Thanh Toán</button>
                <a href="<%= request.getContextPath() %>/doctor/checkup">
                    <button type="button">Hủy bỏ</button>
                </a>
            </form>
        <% } %>
    </body>
</html>
