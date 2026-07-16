<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Service, dal.ServiceDAO, model.User, model.Role"%>
<%
    // Get logged-in user if exists
    User loggedUser = (User) session.getAttribute("loggedInUser");
    
    // Fetch dental services list safely
    List<Service> services = null;
    String dbError = null;
    try {
        ServiceDAO serviceDAO = new ServiceDAO();
        // Check if connection is established
        if (serviceDAO.getConnection() == null) {
            throw new Exception("Database connection is null");
        }
        services = serviceDAO.getAllServices();
    } catch (Exception e) {
        dbError = "Không thể kết nối đến cơ sở dữ liệu. Lỗi: Dịch vụ SQL Server (MSSQLSERVER) có thể chưa khởi động hoặc cổng kết nối (Port 1434) đang bị chặn/sai cấu hình.";
    }
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
                    Khách | 
                    <a href="<%= request.getContextPath() %>/auth/login"><strong>Đăng nhập</strong></a> | 
                    <a href="<%= request.getContextPath() %>/auth/register">Đăng ký tài khoản</a>
                </p>
            <% } %>
        </div>
        
        <hr>
        
        <% if (dbError != null) { %>
            <div style="background-color: #fce8e6; color: #c5221f; border: 1px solid #fad2cf; padding: 15px; border-radius: 4px; margin-bottom: 20px;">
                <h3>⚠️ Lỗi Kết Nối Cơ Sở Dữ Liệu</h3>
                <p><%= dbError %></p>
                <p><strong>Cách khắc phục:</strong> Vui lòng mở <strong>Command Prompt (cmd) dưới quyền Admin</strong> và chạy lệnh: <code>net start MSSQLSERVER</code> để bật cơ sở dữ liệu.</p>
            </div>
        <% } %>
        
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
                <% if (dbError != null) { %>
                    <tr>
                        <td colspan="4" align="center" style="color: gray;">Không thể tải dịch vụ do lỗi kết nối DB.</td>
                    </tr>
                <% } else if (services == null || services.isEmpty()) { %>
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
