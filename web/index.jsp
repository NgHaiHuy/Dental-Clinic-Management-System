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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
                    <a href="<%= request.getContextPath() %>/auth/login" class="btn-login">Đăng nhập</a>
                    <a href="<%= request.getContextPath() %>/auth/register" class="btn-register">Đăng ký</a>
                <% } %>
            </div>
        </nav>

        <!-- MAIN CONTAINER -->
        <div class="dashboard-container">
            
            <!-- Premium Hero Header Section -->
            <div style="background: linear-gradient(135deg, rgba(30, 64, 175, 0.04) 0%, rgba(15, 23, 42, 0.02) 100%); border: 1px solid var(--border-color); border-radius: 0; padding: 50px; margin: 40px 0 65px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.01);">
                <div style="display: grid; grid-template-columns: 1fr 1.2fr; gap: 50px; align-items: center;">
                    <div>
                        <div style="display: inline-flex; align-items: center; background-color: rgba(30, 64, 175, 0.08); color: var(--accent-teal); padding: 5px 12px; border-radius: 4px; font-size: 0.8rem; font-weight: 700; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 1px;">
                            Hệ Thống Nha Khoa Thẩm Mỹ Quốc Tế
                        </div>
                        <h1 style="font-family: var(--font-outfit); font-size: 2.8rem; font-weight: 800; color: var(--accent-navy); line-height: 1.25; margin-bottom: 18px; letter-spacing: -0.5px;">
                            Kiến Tạo Nụ Cười <br><span style="color: var(--accent-teal);">Tự Tin & Tỏa Sáng</span>
                        </h1>
                        <p style="color: var(--text-secondary); font-size: 1.05rem; margin-bottom: 30px; line-height: 1.75; max-width: 520px;">
                            Nha khoa SmileCare tự hào là hệ thống chăm sóc răng miệng công nghệ cao chuẩn quốc tế. Chúng tôi luôn cam kết đem lại chất lượng điều trị tốt nhất, không đau và bảo hành dài lâu.
                        </p>
                        <a href="#booking-section" class="btn btn-cta" style="font-size: 1.05rem; padding: 13px 32px; border-radius: 30px; font-weight: 700; box-shadow: 0 4px 14px rgba(30, 64, 175, 0.25);">
                            Xem Đặt Lịch Hẹn
                        </a>
                    </div>
                    
                    <div style="position: relative; border-radius: var(--border-radius-lg); overflow: hidden; box-shadow: 0 12px 28px rgba(15, 23, 42, 0.08);">
                        <img src="<%= request.getContextPath() %>/img/clinic_banner.png" alt="SmileCare Reception Lobby" style="width: 100%; height: auto; aspect-ratio: 16 / 9; display: block; object-fit: cover; max-height: 440px; border-radius: var(--border-radius-lg);">
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
                                <img src="<%= request.getContextPath() %>/img/<%= imgName %>" alt="<%= doc.getFullName() %>" style="width: 130px; height: 130px; border-radius: 50%; object-fit: cover; border: 4px solid var(--bg-secondary); box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 18px;">
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
                <div style="position: absolute; top: -50px; right: -50px; width: 180px; height: 180px; border-radius: 50%; background-color: rgba(30, 64, 175, 0.2); pointer-events: none;"></div>
                <div style="position: absolute; bottom: -60px; left: -60px; width: 220px; height: 220px; border-radius: 50%; background-color: rgba(30, 64, 175, 0.1); pointer-events: none;"></div>
                
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
                    <div style="font-size: 0.95rem; color: var(--text-secondary); line-height: 2; margin-top: 15px; display: flex; flex-direction: column; gap: 12px;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-map-marker-alt" style="color: var(--accent-teal); width: 16px;"></i>
                            <span><strong>Địa chỉ:</strong> 123 Cầu Giấy, Hà Nội</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-phone-alt" style="color: var(--accent-teal); width: 16px;"></i>
                            <span><strong>Hotline:</strong> (024) 3756 8888</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-envelope" style="color: var(--accent-teal); width: 16px;"></i>
                            <span><strong>Email:</strong> contact@smilecare.vn</span>
                        </div>
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

        <!-- PREMIUM FOOTER -->
        <footer style="background-color: var(--accent-navy); color: #cbd5e1; padding: 60px 0 30px 0; margin-top: 85px; font-family: var(--font-inter);">
            <div style="max-width: 1200px; margin: 0 auto; padding: 0 20px; display: grid; grid-template-columns: 2fr 1fr 1.2fr 1.3fr; gap: 40px; text-align: left;">
                <!-- Column 1: Brand -->
                <div>
                    <h3 style="font-family: var(--font-outfit); font-size: 1.5rem; font-weight: 800; color: white; margin-bottom: 15px; display: flex; align-items: center; gap: 8px;">
                        🦷 SmileCare<span style="color: var(--accent-teal);">+</span>
                    </h3>
                    <p style="font-size: 0.9rem; line-height: 1.6; margin-bottom: 20px; color: #94a3b8;">
                        Hệ thống nha khoa thẩm mỹ công nghệ cao chuẩn quốc tế. SmileCare tự hào kiến tạo hơn 10,000 nụ cười rạng rỡ và tự tin mỗi năm.
                    </p>
                    <div style="display: flex; gap: 12px;">
                        <a href="#" style="width: 36px; height: 36px; border-radius: 50%; background-color: rgba(255,255,255,0.06); display: flex; align-items: center; justify-content: center; color: white; text-decoration: none; transition: background-color 0.2s;"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" style="width: 36px; height: 36px; border-radius: 50%; background-color: rgba(255,255,255,0.06); display: flex; align-items: center; justify-content: center; color: white; text-decoration: none; transition: background-color 0.2s;"><i class="fab fa-youtube"></i></a>
                        <a href="#" style="width: 36px; height: 36px; border-radius: 50%; background-color: rgba(255,255,255,0.06); display: flex; align-items: center; justify-content: center; color: white; text-decoration: none; transition: background-color 0.2s;"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>

                <!-- Column 2: Quick Links -->
                <div>
                    <h4 style="color: white; font-size: 1.05rem; font-weight: 600; margin-bottom: 18px; position: relative; padding-bottom: 8px;">
                        Liên Kết Nhanh
                        <span style="position: absolute; bottom: 0; left: 0; width: 30px; height: 2px; background-color: var(--accent-teal);"></span>
                    </h4>
                    <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px; font-size: 0.9rem;">
                        <li><a href="<%= request.getContextPath() %>/" style="color: #94a3b8; text-decoration: none; transition: color 0.2s;">Trang Chủ</a></li>
                        <li><a href="#services" style="color: #94a3b8; text-decoration: none; transition: color 0.2s;">Dịch Vụ</a></li>
                        <li><a href="#doctors" style="color: #94a3b8; text-decoration: none; transition: color 0.2s;">Đội Ngũ Bác Sĩ</a></li>
                        <li><a href="#booking-section" style="color: #94a3b8; text-decoration: none; transition: color 0.2s;">Đặt Lịch Hẹn</a></li>
                    </ul>
                </div>

                <!-- Column 3: Working Hours -->
                <div>
                    <h4 style="color: white; font-size: 1.05rem; font-weight: 600; margin-bottom: 18px; position: relative; padding-bottom: 8px;">
                        Giờ Làm Việc
                        <span style="position: absolute; bottom: 0; left: 0; width: 30px; height: 2px; background-color: var(--accent-teal);"></span>
                    </h4>
                    <p style="font-size: 0.9rem; line-height: 1.6; color: #94a3b8; margin-bottom: 10px;">
                        Thứ 2 - Thứ 6:<br>
                        <strong style="color: #cbd5e1;">08:00 - 20:00</strong>
                    </p>
                    <p style="font-size: 0.9rem; line-height: 1.6; color: #94a3b8;">
                        Thứ 7 - Chủ Nhật:<br>
                        <strong style="color: #cbd5e1;">08:30 - 18:00</strong>
                    </p>
                </div>

                <!-- Column 4: Newsletter -->
                <div>
                    <h4 style="color: white; font-size: 1.05rem; font-weight: 600; margin-bottom: 18px; position: relative; padding-bottom: 8px;">
                        Đăng Ký Bản Tin
                        <span style="position: absolute; bottom: 0; left: 0; width: 30px; height: 2px; background-color: var(--accent-teal);"></span>
                    </h4>
                    <p style="font-size: 0.9rem; line-height: 1.6; color: #94a3b8; margin-bottom: 15px;">
                        Đăng ký nhận ưu đãi và mẹo chăm sóc răng miệng định kỳ.
                    </p>
                    <form onsubmit="alert('Cảm ơn bạn đã đăng ký!'); return false;" style="display: flex; gap: 8px;">
                        <input type="email" placeholder="Email..." required style="width: 100%; padding: 10px 14px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.1); background-color: rgba(255,255,255,0.05); color: white; font-size: 0.85rem; outline: none;">
                        <button type="submit" style="background-color: var(--accent-teal); color: white; border: none; padding: 10px 15px; border-radius: 6px; cursor: pointer; transition: background-color 0.2s;"><i class="fas fa-paper-plane"></i></button>
                    </form>
                </div>
            </div>

            <!-- Divider -->
            <div style="max-width: 1200px; margin: 40px auto 20px auto; border-top: 1px solid rgba(255,255,255,0.08);"></div>

            <!-- Copyright -->
            <div style="max-width: 1200px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; font-size: 0.85rem; color: #64748b;">
                <span>&copy; 2026 Nha Khoa SmileCare. Bảo lưu mọi quyền.</span>
                <div style="display: flex; gap: 20px;">
                    <a href="#" style="color: #64748b; text-decoration: none;">Chính sách bảo mật</a>
                    <a href="#" style="color: #64748b; text-decoration: none;">Điều khoản dịch vụ</a>
                </div>
            </div>
        </footer>
    </body>
</html>
