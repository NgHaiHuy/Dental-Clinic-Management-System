<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Service, dal.ServiceDAO, model.User, model.Role"%>
<%
    // Get logged-in user if exists
    User loggedUser = (User) session.getAttribute("loggedInUser");
    
    // Fetch dental services list
    ServiceDAO serviceDAO = new ServiceDAO();
    List<Service> services = serviceDAO.getAllServices();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Nha Khoa SmileCare - Danh Sách Dịch Vụ</title>
    </head>
    <body>
        <h1>Chào mừng tới Nha Khoa SmileCare</h1>
        
        <div>
            <% if (loggedUser != null) { %>
                <p>
                    Xin chào, <strong><%= loggedUser.getFullName() %></strong> 
                    (<%= Role.getRoleNameVi(loggedUser.getRoleID()) %>) | 
                    <a href="<%= request.getContextPath() %><%= Role.getDashboardUrl(loggedUser.getRoleID()) %>"><strong>Đến trang Dashboard Menu</strong></a> | 
                    <a href="<%= request.getContextPath() %>/auth/logout">Đăng xuất</a>
                </p>
            <% } else { %>
                <p>
                    Khách vãng lai | 
                    <a href="<%= request.getContextPath() %>/auth/login"><strong>Đăng nhập</strong></a> | 
                    <a href="<%= request.getContextPath() %>/auth/register">Đăng ký tài khoản</a>
                </p>
            <% } %>
        </div>
        
        <hr>
        
        <h2>Các Dịch Vụ Nha Khoa Chúng Tôi Cung Cấp</h2>
        <table border="1" cellpadding="8" cellspacing="0" style="width: 100%;">
            <thead>
                <tr>
                    <th>Tên Dịch Vụ</th>
                    <th>Mô Tả</th>
                    <th>Đơn Giá</th>
                    <th>Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <% if (services == null || services.isEmpty()) { %>
                    <tr>
                        <td colspan="4" align="center">Hiện tại chưa có dịch vụ nào được cấu hình.</td>
                    </tr>
                <% } else {
                    for (Service s : services) { %>
                        <tr>
                            <td><strong><%= s.getServiceName() %></strong></td>
                            <td><%= s.getDescription() != null ? s.getDescription() : "Chưa có mô tả." %></td>
                            <td><%= String.format("%,.0f", s.getPrice()) %> đ</td>
                            <td align="center">
                                <a href="<%= request.getContextPath() %>/customer/booking">
                                    <button type="button">Đặt Lịch Hẹn Ngay</button>
                                </a>
                            </td>
                        </tr>
                    <% }
                } %>
            </tbody>
        </table>
        
        <br>
        <div style="text-align: center;">
            <a href="<%= request.getContextPath() %>/customer/booking">
                <button type="button" style="font-size: 1.2em; padding: 10px 20px;">Tiến hành đặt lịch khám răng tổng hợp</button>
            </a>
        </div>
    </body>
</html>
