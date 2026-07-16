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
        if (serviceDAO.getConnection() == null) {
            throw new Exception("Database connection is null");
        }
        services = serviceDAO.getAllServices();
    } catch (Exception e) {
        dbError = "Không thể kết nối đến cơ sở dữ liệu. Lỗi: Dịch vụ SQL Server (MSSQLSERVER) có thể chưa khởi động hoặc cổng kết nối (Port 1434) đang bị chặn/sai cấu hình.";
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Nha Khoa SmileCare - Dịch Vụ Nha Khoa Chuyên Nghiệp</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>
    <body>
        <!-- FIXED NAVBAR -->
        <nav class="navbar">
            <a href="<%= request.getContextPath() %>/" class="navbar-brand">
                🦷 SmileCare<span>+</span>
            </a>
            
            <div class="navbar-menu">
                <a href="<%= request.getContextPath() %>/">Trang Chủ</a>
                <a href="#services">Dịch Vụ</a>
                <a href="#contact">Liên Hệ</a>
                <% if (loggedUser != null) { %>
                    <a href="<%= request.getContextPath() %><%= Role.getDashboardUrl(loggedUser.getRoleID()) %>">Dashboard Menu</a>
                    <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/auth/login" class="btn btn-primary" style="padding: 6px 14px;">Đăng nhập</a>
                    <a href="<%= request.getContextPath() %>/auth/register" class="btn btn-secondary" style="padding: 6px 14px;">Đăng ký</a>
                <% } %>
            </div>
        </nav>

        <!-- MAIN CONTAINER -->
        <div class="dashboard-container">
            
            <!-- Welcome Section -->
            <div style="text-align: center; margin: 40px 0 60px 0;">
                <h1 style="font-family: var(--font-outfit); font-size: 2.8rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 12px;">
                    Chăm Sóc Nụ Cười Của Bạn
                </h1>
                <p style="color: var(--text-secondary); max-width: 600px; margin: 0 auto 30px auto; font-size: 1.1rem;">
                    Hệ thống nha khoa công nghệ cao SmileCare cung cấp các dịch vụ chăm sóc răng miệng toàn diện, an toàn và chuyên nghiệp nhất.
                </p>
                <a href="<%= request.getContextPath() %>/customer/booking" class="btn btn-cta" style="font-size: 1.1rem; padding: 12px 28px;">
                    📅 Đặt Lịch Hẹn Khám Ngay
                </a>
            </div>

            <!-- Database connection error warning banner -->
            <% if (dbError != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 40px;">
                    <strong>⚠️ Lỗi Kết Nối Cơ Sở Dữ Liệu:</strong> <%= dbError %> 
                    <br><em>Cách khắc phục: Mở Command Prompt (cmd) dưới quyền Admin và chạy lệnh <code>net start MSSQLSERVER</code> để khởi động Database.</em>
                </div>
            <% } %>

            <!-- SERVICES SECTION WITH CARDS HOVER SYSTEM -->
            <div id="services" style="margin-bottom: 80px;">
                <h2 style="font-family: var(--font-outfit); font-size: 2rem; font-weight: 800; color: var(--accent-navy); border-bottom: 2px solid var(--accent-teal); padding-bottom: 8px; display: inline-block; margin-bottom: 30px;">
                    Dịch Vụ Nổi Bật
                </h2>
                
                <div class="services-grid">
                    <% if (dbError != null) { %>
                        <div class="glass-card" style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 40px 0;">
                            Không thể tải danh sách dịch vụ do lỗi kết nối cơ sở dữ liệu.
                        </div>
                    <% } else if (services == null || services.isEmpty()) { %>
                        <div class="glass-card" style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 40px 0;">
                            Hiện tại chưa có dịch vụ nào trong hệ thống.
                        </div>
                    <% } else {
                        for (Service s : services) { %>
                            <div class="glass-card">
                                <div class="card-title">
                                    🩺 <%= s.getServiceName() %>
                                </div>
                                <div class="card-desc">
                                    <%= s.getDescription() != null ? s.getDescription() : "Chăm sóc và điều trị chuyên sâu bảo vệ sức khỏe nụ cười răng miệng." %>
                                </div>
                                <div class="card-price">
                                    <span><%= String.format("%,.0f", s.getPrice()) %> đ</span>
                                    <a href="<%= request.getContextPath() %>/customer/booking" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;">
                                        Đặt hẹn
                                    </a>
                                </div>
                            </div>
                        <% }
                    } %>
                </div>
            </div>

            <!-- CONTACT FORM SECTION -->
            <div id="contact" class="dashboard-grid" style="margin-top: 60px; background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 40px;">
                <div>
                    <h2 style="font-family: var(--font-outfit); font-size: 2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 12px;">
                        Gửi Yêu Cầu Tư Vấn
                    </h2>
                    <p style="color: var(--text-secondary); margin-bottom: 25px;">
                        Hãy để lại thông tin liên hệ và tình trạng răng miệng hiện tại, đội ngũ nha sĩ SmileCare sẽ gọi lại tư vấn miễn phí cho bạn trong vòng 15 phút.
                    </p>
                    <div style="font-size: 0.95rem; color: var(--text-secondary); line-height: 2;">
                        📍 <strong>Địa chỉ:</strong> 123 Cầu Giấy, Hà Nội<br>
                        📞 <strong>Hotline:</strong> (024) 3756 8888<br>
                        ✉️ <strong>Email:</strong> contact@smilecare.vn
                    </div>
                </div>
                
                <div>
                    <form action="#" method="POST" onsubmit="alert('Cảm ơn bạn! Chúng tôi đã nhận được thông tin liên hệ và sẽ sớm gọi điện tư vấn.'); return false;">
                        <div class="form-group">
                            <label class="form-label">Họ và tên của bạn</label>
                            <input type="text" class="form-control" placeholder="Nguyễn Văn A" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Số điện thoại liên hệ</label>
                            <input type="tel" class="form-control" placeholder="0912345678" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Nội dung / Câu hỏi cần tư vấn</label>
                            <textarea class="form-control" placeholder="Tôi muốn hỏi về chi phí niềng răng..." required></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-cta" style="width: 100%; margin-top: 10px;">
                            📩 Gửi Yêu Cầu Liên Hệ
                        </button>
                    </form>
                </div>
            </div>

        </div>
    </body>
</html>
