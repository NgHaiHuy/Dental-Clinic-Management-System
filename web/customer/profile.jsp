<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, model.CustomerInfo"%>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }
    CustomerInfo custInfo = (CustomerInfo) request.getAttribute("customerInfo");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    if (successMessage != null) session.removeAttribute("successMessage");
    if (errorMessage != null) session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hồ Sơ Cá Nhân - SmileCare</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            .profile-container {
                max-width: 1000px !important;
                margin: 40px auto 60px auto;
            }
            .profile-grid {
                display: grid;
                grid-template-columns: 2fr 1.2fr;
                gap: 30px;
                align-items: start;
            }
            @media (max-width: 900px) {
                .profile-grid {
                    grid-template-columns: 1fr;
                }
            }
            .glass-card {
                background: #ffffff;
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-lg);
                padding: 35px;
                box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.02), 0 8px 10px -6px rgba(0, 0, 0, 0.02);
            }
            .card-title {
                font-family: var(--font-outfit);
                font-size: 1.4rem;
                font-weight: 800;
                color: var(--accent-navy);
                margin-bottom: 20px;
                padding-bottom: 8px;
                border-bottom: 2px solid #f1f5f9;
                display: flex;
                align-items: center;
                gap: 10px;
            }
        </style>
    </head>
    <body>
        <!-- NAVBAR -->
        <nav class="navbar">
            <a href="<%= request.getContextPath() %>/" class="navbar-brand">
                🦷 SmileCare<span>+</span>
            </a>
            <div class="navbar-menu">
                <a href="<%= request.getContextPath() %>/">Trang Chủ</a>
                <a href="<%= request.getContextPath() %>/customer/booking">Đặt lịch hẹn</a>
                <a href="<%= request.getContextPath() %>/customer/history">Xem lịch đã đặt</a>
                <a href="<%= request.getContextPath() %>/customer/profile" style="color: var(--primary); font-weight: 700;">Hồ sơ cá nhân</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>
        
        <!-- CONTAINER -->
        <div class="dashboard-container profile-container">
            <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 30px;">
                ⚙️ Quản Lý Tài Khoản & Thông Tin
            </h1>
            
            <% if (successMessage != null) { %>
                <div class="alert alert-success" style="margin-bottom: 25px; padding: 12px 18px; border-radius: 8px;">
                    <%= successMessage %>
                </div>
            <% } %>
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 25px; padding: 12px 18px; border-radius: 8px;">
                    <%= errorMessage %>
                </div>
            <% } %>
            
            <div class="profile-grid">
                <!-- Left column: Personal details -->
                <div class="glass-card">
                    <h2 class="card-title">
                        <i class="fas fa-user-circle" style="color: var(--primary);"></i> Thông tin cá nhân bệnh nhân
                    </h2>
                    
                    <form action="<%= request.getContextPath() %>/customer/profile" method="POST">
                        <input type="hidden" name="action" value="updateProfile">
                        
                        <div class="form-grid-2">
                            <div class="form-group">
                                <label class="form-label">Tên tài khoản (Không thể sửa)</label>
                                <input type="text" class="form-control" value="<%= loggedUser.getUsername() %>" disabled style="background-color: #f8fafc; color: #94a3b8; cursor: not-allowed; font-weight: 600;">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Họ và tên <span style="color: red;">*</span></label>
                                <input type="text" name="fullName" class="form-control" value="<%= loggedUser.getFullName() %>" required placeholder="Nhập họ và tên đầy đủ">
                            </div>
                        </div>
                        
                        <div class="form-grid-2" style="margin-top: 15px;">
                            <div class="form-group">
                                <label class="form-label">Số điện thoại <span style="color: red;">*</span></label>
                                <input type="tel" name="phone" class="form-control" value="<%= loggedUser.getPhone() %>" required pattern="0[35789]\d{8}" title="Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 03, 05, 07, 08 hoặc 09" placeholder="Nhập số điện thoại liên hệ">
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" value="<%= loggedUser.getEmail() != null ? loggedUser.getEmail() : "" %>" placeholder="example@mail.com">
                            </div>
                        </div>
                        
                        <div class="form-grid-2" style="margin-top: 15px;">
                            <div class="form-group">
                                <label class="form-label">Giới tính</label>
                                <%
                                    String gender = (custInfo != null && custInfo.getGender() != null) ? custInfo.getGender() : "";
                                %>
                                <select name="gender" class="form-select">
                                    <option value="" <%= gender.isEmpty() ? "selected" : "" %>>-- Chọn giới tính --</option>
                                    <option value="Nam" <%= "Nam".equalsIgnoreCase(gender) ? "selected" : "" %>>Nam</option>
                                    <option value="Nữ" <%= "Nữ".equalsIgnoreCase(gender) ? "selected" : "" %>>Nữ</option>
                                    <option value="Khác" <%= "Khác".equalsIgnoreCase(gender) ? "selected" : "" %>>Khác</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Ngày sinh</label>
                                <%
                                    String dobStr = (custInfo != null && custInfo.getDateOfBirth() != null) ? custInfo.getDateOfBirth().toString() : "";
                                %>
                                <input type="date" name="dob" class="form-control" value="<%= dobStr %>" max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            </div>
                        </div>
                        
                        <div class="form-group" style="margin-top: 20px;">
                            <label class="form-label">Địa chỉ thường trú</label>
                            <input type="text" name="address" class="form-control" value="<%= (custInfo != null && custInfo.getAddress() != null) ? custInfo.getAddress() : "" %>" placeholder="Nhập địa chỉ, ngõ, số nhà, phường/xã...">
                        </div>
                        
                        <button type="submit" class="btn btn-cta" style="margin-top: 30px; font-weight: 700; width: 100%; padding: 12px;">Lưu Thay Đổi Thông Tin</button>
                    </form>
                </div>
                
                <!-- Right column: Change Password -->
                <div class="glass-card">
                    <h2 class="card-title">
                        <i class="fas fa-lock" style="color: #ef4444;"></i> Đổi mật khẩu
                    </h2>
                    
                    <form action="<%= request.getContextPath() %>/customer/profile" method="POST">
                        <input type="hidden" name="action" value="changePassword">
                        
                        <div class="form-group">
                            <label class="form-label">Mật khẩu hiện tại</label>
                            <input type="password" name="currentPassword" class="form-control" required placeholder="Nhập mật khẩu hiện tại">
                        </div>
                        
                        <div class="form-group" style="margin-top: 15px;">
                            <label class="form-label">Mật khẩu mới</label>
                            <input type="password" name="newPassword" class="form-control" required minlength="3" placeholder="Nhập mật khẩu mới">
                        </div>
                        
                        <div class="form-group" style="margin-top: 15px;">
                            <label class="form-label">Xác nhận mật khẩu mới</label>
                            <input type="password" name="confirmPassword" class="form-control" required minlength="3" placeholder="Xác nhận lại mật khẩu mới">
                        </div>
                        
                        <button type="submit" class="btn btn-secondary" style="margin-top: 30px; font-weight: 700; width: 100%; padding: 12px; color: #ef4444; border-color: #fecaca; background: #fee2e2;">Cập Nhật Mật Khẩu</button>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>
