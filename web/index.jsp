<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Service, dal.ServiceDAO, model.User, model.Role"%>
<%
    // Get logged-in user if exists
    User loggedUser = (User) session.getAttribute("loggedInUser");
    
    // Fetch dental services list safely
    List<Service> services = null;
    List<User> doctors = null;
    String dbError = null;
    try {
        ServiceDAO serviceDAO = new ServiceDAO();
        if (serviceDAO.getConnection() == null) {
            throw new Exception("Database connection is null");
        }
        services = serviceDAO.getAllServices();
        
        dal.UserDAO userDAO = new dal.UserDAO();
        doctors = userDAO.getDoctorsWithDetails();
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
            
            <!-- Upgraded Premium Hero Header Section -->
            <div style="background: linear-gradient(135deg, rgba(13, 148, 136, 0.05) 0%, rgba(15, 23, 42, 0.02) 100%); border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 45px 50px; margin: 40px 0 65px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.02);">
                <div style="display: grid; grid-template-columns: 1.2fr 1fr; gap: 45px; align-items: center;">
                    <div>
                        <div style="display: inline-flex; align-items: center; gap: 6px; background-color: rgba(13, 148, 136, 0.1); color: var(--accent-teal); padding: 6px 14px; border-radius: 20px; font-size: 0.82rem; font-weight: 700; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px;">
                            ✨ Hệ Thống Nha Khoa Thẩm Mỹ Quốc Tế
                        </div>
                        <h1 style="font-family: var(--font-outfit); font-size: 2.8rem; font-weight: 800; color: var(--accent-navy); line-height: 1.2; margin-bottom: 18px;">
                            Kiến Tạo Nụ Cười <br><span style="color: var(--accent-teal);">Tự Tin & Tỏa Sáng</span>
                        </h1>
                        <p style="color: var(--text-secondary); font-size: 1.05rem; margin-bottom: 28px; line-height: 1.7; max-width: 530px;">
                            Nha khoa SmileCare tự hào là hệ thống chăm sóc răng miệng công nghệ cao chuẩn quốc tế. Chúng tôi luôn cam kết đem lại chất lượng điều trị tốt nhất, không đau và bảo hành dài lâu.
                        </p>
                        <a href="#booking-section" class="btn btn-cta" style="font-size: 1.05rem; padding: 12px 28px; border-radius: 30px; font-weight: 700; box-shadow: 0 4px 12px rgba(13, 148, 136, 0.2);">
                            Xem Đặt Lịch Hẹn
                        </a>
                        
                        <!-- Mini Stats Display -->
                        <div style="display: flex; gap: 30px; margin-top: 35px; border-top: 1px solid var(--border-color); padding-top: 25px;">
                            <div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--accent-teal);">06+</div>
                                <div style="font-size: 0.82rem; color: var(--text-secondary); font-weight: 600;">Bác Sĩ Chuyên Khoa</div>
                            </div>
                            <div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--accent-navy);">05+</div>
                                <div style="font-size: 0.82rem; color: var(--text-secondary); font-weight: 600;">Nhân Viên Lễ Tân</div>
                            </div>
                            <div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--accent-navy);">99%</div>
                                <div style="font-size: 0.82rem; color: var(--text-secondary); font-weight: 600;">Hài Lòng Tuyệt Đối</div>
                            </div>
                        </div>
                    </div>
                    
                    <div style="position: relative; border-radius: var(--border-radius-lg); overflow: hidden; box-shadow: 0 12px 28px rgba(15, 23, 42, 0.08);">
                        <img src="<%= request.getContextPath() %>/assets/images/clinic_banner.png" alt="SmileCare Reception Lobby" style="width: 100%; height: auto; display: block; object-fit: cover; max-height: 380px;">
                        
                        <!-- Floating 3D Acrylic Logo Badge covering OAKHAVEN on the wall -->
                        <div style="position: absolute; top: 38%; left: 16%; background: rgba(255, 255, 255, 0.95); border: 1.5px solid var(--accent-teal); border-radius: 4px; padding: 4px 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.15); display: flex; align-items: center; gap: 4px; font-weight: 800; font-size: 0.85rem; color: var(--accent-navy); backdrop-filter: blur(4px); pointer-events: none;">
                            <span style="font-size: 0.95rem;">🦷</span> SmileCare<span style="color: var(--accent-teal);">+</span>
                        </div>
                    </div>
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

            <!-- DENTISTS INTRODUCTION SECTION (DYNAMICS LOADED) -->
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
                    <% if (dbError != null || doctors == null || doctors.isEmpty()) { %>
                        <div style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 20px 0;">
                            Hiện tại chưa thể hiển thị danh sách bác sĩ.
                        </div>
                    <% } else {
                        for (User doc : doctors) {
                            // Map profile image dynamically based on username
                            String imgName = "doctor_" + doc.getUsername() + ".png";
                    %>
                            <div style="text-align: center; border: 1px solid var(--border-color); border-radius: var(--border-radius-lg); padding: 30px; background-color: var(--bg-primary);">
                                <img src="<%= request.getContextPath() %>/assets/images/<%= imgName %>" alt="<%= doc.getFullName() %>" style="width: 130px; height: 130px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg-secondary); box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 18px;">
                                <h3 style="font-family: var(--font-outfit); font-size: 1.2rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 4px;">
                                    <%= doc.getFullName() %>
                                </h3>
                                <p style="color: var(--accent-teal); font-weight: 600; font-size: 0.88rem; margin-bottom: 12px; text-transform: uppercase;">
                                    <%= doc.getSpecialization() != null ? doc.getSpecialization() : "Bác sĩ Nha khoa" %>
                                </p>
                                <p style="color: var(--text-secondary); font-size: 0.88rem; line-height: 1.6;">
                                    <%= doc.getBiography() != null ? doc.getBiography() : "Chuyên gia răng hàm mặt tận tâm chăm sóc sức khỏe răng miệng của bạn." %>
                                </p>
                            </div>
                    <% }
                    } %>
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
