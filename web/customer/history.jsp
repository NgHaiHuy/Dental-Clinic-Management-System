<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, model.Appointment, model.MedicalRecord, model.PrescriptionDetail"%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    List<MedicalRecord> records = (List<MedicalRecord>) request.getAttribute("records");
    Map<Integer, List<PrescriptionDetail>> recordMedicines = (Map<Integer, List<PrescriptionDetail>>) request.getAttribute("recordMedicines");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lịch Sử Khám Răng - SmileCare</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>
    <body>
        <!-- NAVBAR -->
        <nav class="navbar">
            <a href="<%= request.getContextPath() %>/" class="navbar-brand">
                🦷 SmileCare<span>+</span>
            </a>
            <div class="navbar-menu">
                <a href="<%= request.getContextPath() %>/">Trang Chủ</a>
                <a href="<%= request.getContextPath() %>/customer/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/customer/booking" class="btn btn-cta" style="padding: 6px 14px;">Đặt lịch ngay</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container">
            <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 30px;">
                📋 Lịch Sử Khám Bệnh & Đặt Lịch
            </h1>
            
            <div class="dashboard-grid">
                <!-- Left panel: Appointments list -->
                <div>
                    <h2 style="font-family: var(--font-outfit); font-size: 1.4rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 15px;">
                        1. Danh sách lịch hẹn đã đăng ký
                    </h2>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Mã Lịch Hẹn</th>
                                    <th>Ngày Khám</th>
                                    <th>Giờ Khám</th>
                                    <th>Bác Sĩ</th>
                                    <th>Ghi Chú</th>
                                    <th>Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (appointments == null || appointments.isEmpty()) { %>
                                    <tr>
                                        <td colspan="6" align="center" style="color: var(--text-muted); padding: 30px 0;">Bạn chưa đăng ký lịch hẹn nào.</td>
                                    </tr>
                                <% } else {
                                    for (Appointment app : appointments) { %>
                                        <tr>
                                            <td>#<%= app.getAppointmentID() %></td>
                                            <td><%= app.getAppointmentDate() %></td>
                                            <td><%= app.getAppointmentTime() %></td>
                                            <td><strong><%= app.getDoctorName() %></strong></td>
                                            <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= app.getNotes() != null ? app.getNotes() : "" %></td>
                                            <td>
                                                <% 
                                                    String status = app.getStatus();
                                                    String badgeClass = "badge-inactive";
                                                    if (status.equalsIgnoreCase("Confirmed") || status.equalsIgnoreCase("Attended")) {
                                                        badgeClass = "badge-active";
                                                    }
                                                %>
                                                <span class="badge <%= badgeClass %>"><%= status %></span>
                                            </td>
                                        </tr>
                                    <% }
                                } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Right panel: Medical Records list -->
                <div>
                    <h2 style="font-family: var(--font-outfit); font-size: 1.4rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 15px;">
                        2. Bệnh án & Kết quả khám
                    </h2>
                    <% if (records == null || records.isEmpty()) { %>
                        <div class="glass-card" style="text-align: center; color: var(--text-muted); padding: 40px 0;">
                            Chưa có thông tin bệnh án từ bác sĩ.
                        </div>
                    <% } else {
                        for (MedicalRecord mr : records) { %>
                            <div class="glass-card" style="margin-bottom: 20px;">
                                <h3 style="font-family: var(--font-outfit); font-size: 1.1rem; font-weight: 700; color: var(--accent-teal); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-bottom: 12px; display: flex; justify-content: space-between;">
                                    <span>Hồ sơ bệnh án #<%= mr.getRecordID() %></span>
                                    <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 400;"><%= mr.getCreatedAt() %></span>
                                </h3>
                                <p style="font-size: 0.9rem; margin-bottom: 6px;">
                                    <strong>Bác sĩ điều trị:</strong> <%= mr.getDoctorName() %>
                                </p>
                                <p style="font-size: 0.9rem; margin-bottom: 6px;">
                                    <strong>Chẩn đoán:</strong> <%= mr.getDiagnosis() %>
                                </p>
                                <p style="font-size: 0.9rem; margin-bottom: 12px;">
                                    <strong>Kế hoạch điều trị:</strong> <%= mr.getTreatmentPlan() != null ? mr.getTreatmentPlan() : "Theo dõi thêm" %>
                                </p>
                                
                                <div style="background-color: var(--bg-tertiary); border-radius: var(--border-radius-md); padding: 12px; border: 1px dashed var(--border-color);">
                                    <strong style="font-size: 0.85rem; display: block; margin-bottom: 6px; color: var(--accent-navy);">💊 Đơn thuốc đính kèm:</strong>
                                    <% 
                                        List<PrescriptionDetail> meds = recordMedicines.get(mr.getRecordID());
                                        if (meds == null || meds.isEmpty()) {
                                    %>
                                        <span style="font-size: 0.85rem; color: var(--text-muted);">Không kê đơn thuốc ngoại trú.</span>
                                    <% } else { %>
                                        <ul style="padding-left: 15px; font-size: 0.85rem; color: var(--text-secondary);">
                                            <% for (PrescriptionDetail m : meds) { %>
                                                <li style="margin-bottom: 4px;">
                                                    <strong><%= m.getMedicineName() %></strong> 
                                                    - SL: <%= m.getQuantity() %> <%= m.getUnit() %> 
                                                    (<em><%= m.getDosage() %></em>)
                                                </li>
                                            <% } %>
                                        </ul>
                                    <% } %>
                                </div>
                            </div>
                        <% }
                    } %>
                </div>
            </div>
        </div>
    </body>
</html>
