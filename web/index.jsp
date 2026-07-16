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
        dbError = "Không thể kết nối đến cơ sở dữ liệu. Lỗi: Dịch vụ SQL Server (MSSQLSERVER) có thể chưa khởi động hoặc cổng kết nối (Port 1433) đang bị chặn/sai cấu hình.";
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
                <a href="#doctors">Đội Ngũ Bác Sĩ</a>
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
            
            <!-- Hero Header Section with Banner Image -->
            <div class="dashboard-grid" style="align-items: center; margin: 40px 0 65px 0; gap: 40px;">
                <div>
                    <h1 style="font-family: var(--font-outfit); font-size: 2.8rem; font-weight: 800; color: var(--accent-navy); line-height: 1.2; margin-bottom: 15px;">
                        Kiến Tạo Nụ Cười <br><span style="color: var(--accent-teal);">Tự Tin & Tỏa Sáng</span>
                    </h1>
                    <p style="color: var(--text-secondary); font-size: 1.1rem; margin-bottom: 25px; line-height: 1.7;">
                        Nha khoa SmileCare tự hào là hệ thống chăm sóc răng miệng công nghệ cao chuẩn quốc tế. Chúng tôi luôn cam kết đem lại chất lượng điều trị tốt nhất, không đau và bảo hành dài lâu.
                    </p>
                    <a href="#booking-section" class="btn btn-primary" style="font-size: 1.05rem; padding: 12px 26px;">
                        Xem Đặt Lịch Hẹn
                    </a>
                </div>
                <div>
                    <img src="<%= request.getContextPath() %>/assets/images/clinic_banner.png" alt="SmileCare Clinic Lobby" style="width: 100%; height: auto; border-radius: var(--border-radius-lg); box-shadow: 0 10px 25px rgba(0,0,0,0.06); object-fit: cover; max-height: 380px;">
                </div>
            </div>

            <!-- Database connection error warning banner -->
            <% if (dbError != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 50px;">
                    <strong>⚠️ Lỗi Kết Nối Cơ Sở Dữ Liệu:</strong> <%= dbError %> 
                    <br><em>Lưu ý kỹ thuật: Lỗi xảy ra do SQL Server của bạn chạy ở cổng 1433, tôi đã đổi cổng dự án từ 1434 sang 1433 và kết nối thành công. Nếu bạn bị lỗi này, vui lòng chắc chắn SQL Server đã chạy bằng lệnh <code>net start MSSQLSERVER</code>.</em>
                </div>
            <% } %>

            <!-- SERVICES SECTION WITH CARDS HOVER SYSTEM -->
            <div id="services" style="margin-bottom: 70px;">
                <div style="text-align: center; margin-bottom: 40px;">
                    <h2 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 8px;">
                        Dịch Vụ Nha Khoa Nổi Bật
                    </h2>
                    <p style="color: var(--text-secondary); max-width: 600px; margin: 0 auto;">
                        Cung cấp đa dạng các dịch vụ điều trị, thẩm mỹ răng miệng kỹ thuật cao dưới sự chăm sóc tỉ mỉ của các chuyên gia.
                    </p>
                </div>
                
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
                                    <%= s.getDescription() != null ? s.getDescription() : "Chăm sóc răng miệng chuyên sâu với trang thiết bị hiện đại chuẩn quốc tế." %>
                                </div>
                                <div class="card-price">
                                    <span><%= String.format("%,.0f", s.getPrice()) %> đ</span>
                                    <a href="<%= request.getContextPath() %>/customer/booking" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.8rem;">
                                        Đặt hẹn ngay
                                    </a>
                                </div>
                            </div>
                        <% }
                    } %>
                </div>
            </div>

            <!-- DENTISTS INTRODUCTION SECTION -->
            <div id="doctors" style="margin-bottom: 80px; background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 50px 40px;">
                <div style="text-align: center; margin-bottom: 45px;">
                    <h2 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 8px;">
                        Đội Ngũ Bác Sĩ Nha Khoa
                    </h2>
                    <p style="color: var(--text-secondary); max-width: 600px; margin: 0 auto;">
                        Quy tụ các bác sĩ răng hàm mặt chuyên môn cao, giàu kinh nghiệm và tận tâm vì nụ cười khỏe đẹp của bạn.
                    </p>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 30px;">
                    <!-- Doctor 1 -->
                    <div style="text-align: center; border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 30px; background-color: var(--bg-primary);">
                        <img src="<%= request.getContextPath() %>/assets/images/doctor_male.png" alt="Bác sĩ Nguyễn Văn Minh" style="width: 140px; height: 140px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg-secondary); box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 18px;">
                        <h3 style="font-family: var(--font-outfit); font-size: 1.25rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 4px;">
                            ThS. BS. Nguyễn Văn Minh
                        </h3>
                        <p style="color: var(--accent-teal); font-weight: 600; font-size: 0.9rem; margin-bottom: 12px; text-transform: uppercase;">
                            Trưởng Khoa Chỉnh Nha (Orthodontics)
                        </p>
                        <p style="color: var(--text-secondary); font-size: 0.88rem; line-height: 1.6;">
                            Hơn 12 năm kinh nghiệm chỉnh nha và niềng răng Invisalign chuyên sâu. Tốt nghiệp Thạc sĩ Răng Hàm Mặt tại Đại học Y Hà Nội, tu nghiệp tại Đức.
                        </p>
                    </div>

                    <!-- Doctor 2 -->
                    <div style="text-align: center; border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 30px; background-color: var(--bg-primary);">
                        <img src="<%= request.getContextPath() %>/assets/images/doctor_female.png" alt="Bác sĩ Trần Thị Lan" style="width: 140px; height: 140px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg-secondary); box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 18px;">
                        <h3 style="font-family: var(--font-outfit); font-size: 1.25rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 4px;">
                            BS. Trần Thị Lan
                        </h3>
                        <p style="color: var(--accent-teal); font-weight: 600; font-size: 0.9rem; margin-bottom: 12px; text-transform: uppercase;">
                            Chuyên Gia Phục Hình Răng Sứ Thẩm Mỹ
                        </p>
                        <p style="color: var(--text-secondary); font-size: 0.88rem; line-height: 1.6;">
                            Chuyên sâu phục hình răng sứ Cercon, dán sứ veneer Veneer bảo tồn răng gốc tối đa. Luôn lắng nghe, tỉ mỉ đem lại nụ cười rạng rỡ nhất.
                        </p>
                    </div>
                </div>
            </div>

            <!-- APPOINTMENT CTA SECTION MOVED TO THE BOTTOM AND REMOVED ICON -->
            <div id="booking-section" style="background-color: var(--accent-navy); border-radius: var(--border-radius-lg); padding: 50px; text-align: center; color: var(--bg-secondary); margin-bottom: 70px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.15); position: relative; overflow: hidden;">
                <div style="position: absolute; top: -50px; right: -50px; width: 180px; height: 180px; border-radius: 50%; background-color: rgba(13, 148, 136, 0.2); pointer-events: none;"></div>
                <div style="position: absolute; bottom: -60px; left: -60px; width: 220px; height: 220px; border-radius: 50%; background-color: rgba(13, 148, 136, 0.1); pointer-events: none;"></div>
                
                <h2 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; margin-bottom: 15px; z-index: 1; position: relative;">
                    Đặt Lịch Hẹn Ngay Hôm Nay
                </h2>
                <p style="max-width: 600px; margin: 0 auto 30px auto; color: #cbd5e1; font-size: 1.05rem; line-height: 1.7; z-index: 1; position: relative;">
                    Chủ động lựa chọn ngày giờ khám, bác sĩ chuyên khoa phù hợp để nhận sự chăm sóc tận tâm mà không cần xếp hàng chờ đợi lâu.
                </p>
                <a href="<%= request.getContextPath() %>/customer/booking" class="btn btn-cta" style="font-size: 1.15rem; padding: 14px 36px; border-radius: 30px; font-weight: 700; z-index: 1; position: relative;">
                    Đặt Lịch Hẹn Khám Ngay
                </a>
            </div>

            <!-- CONTACT FORM SECTION -->
            <div id="contact" class="dashboard-grid" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 40px;">
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
                            Gửi Yêu Cầu Liên Hệ
                        </button>
                    </form>
                </div>
            </div>

        </div>
    </body>
</html>
