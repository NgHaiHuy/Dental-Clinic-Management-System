<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Appointment"%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    
    if (successMessage != null) request.getSession().removeAttribute("successMessage");
    if (errorMessage != null) request.getSession().removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản Lý Lịch Hẹn & Tiếp Đón - SmileCare</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <style>
            .custom-table tbody tr {
                cursor: pointer;
                transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            }
            .custom-table tbody tr:hover {
                transform: translateY(-2px) scale(1.008);
                box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.08);
                background-color: #f8fafc !important;
                position: relative;
                z-index: 5;
            }
            @keyframes modalFadeIn {
                from { opacity: 0; transform: scale(0.95); }
                to { opacity: 1; transform: scale(1); }
            }
            .status-pill {
                padding: 6px 14px;
                border-radius: 20px;
                border: 1px solid var(--border-color);
                background-color: #ffffff;
                color: var(--text-secondary);
                font-size: 0.88rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s ease;
            }
            .status-pill:hover {
                background-color: #f1f5f9;
                color: var(--accent-teal);
                border-color: var(--accent-teal);
            }
            .status-pill.active {
                background-color: var(--accent-teal);
                color: #ffffff;
                border-color: var(--accent-teal);
                box-shadow: 0 4px 6px -1px rgba(20, 184, 166, 0.2);
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
                <a href="<%= request.getContextPath() %>/receptionist/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-secondary" style="padding: 6px 14px;">Hàng chờ thanh toán</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 15px;">
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin: 0;">
                    📋 Danh Sách Lịch Hẹn Đặt (Lễ Tân Tiếp Đón)
                </h1>
                <a href="<%= request.getContextPath() %>/receptionist/manage-booking?action=new" class="btn btn-primary" style="padding: 10px 20px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-plus"></i> Đặt lịch tại quầy
                </a>
            </div>
            
            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
            <% } %>
            
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
            <% } %>

            <!-- BỘ LỌC VÀ TÌM KIẾM -->
            <div style="background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--border-radius-md); padding: 20px; margin-bottom: 25px;">
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; align-items: end; margin-bottom: 15px;">
                    <div class="form-group" style="margin: 0;">
                        <label class="form-label" style="margin-bottom: 6px;"><i class="fas fa-search" style="color: var(--accent-teal);"></i> Tìm kiếm bệnh nhân</label>
                        <input type="text" id="searchQuery" class="form-control" placeholder="Nhập tên khách hàng hoặc số điện thoại để tìm kiếm..." oninput="filterAppointments()">
                    </div>
                    <div class="form-group" style="margin: 0;">
                        <label class="form-label" style="margin-bottom: 6px;"><i class="fas fa-calendar-alt" style="color: var(--accent-teal);"></i> Lọc theo ngày hẹn</label>
                        <div style="display: flex; gap: 8px;">
                            <input type="date" id="filterDate" class="form-control" onchange="filterAppointments()">
                            <button class="btn btn-secondary" onclick="clearFilters()" style="padding: 10px 15px; font-size: 0.9rem;" title="Xóa lọc"><i class="fas fa-undo"></i></button>
                        </div>
                    </div>
                </div>
                
                <div style="border-top: 1px dashed var(--border-color); padding-top: 15px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                    <span style="font-size: 0.88rem; font-weight: 600; color: var(--text-secondary); margin-right: 10px;">Trạng thái lịch hẹn:</span>
                    <button type="button" class="status-pill active" onclick="setStatusFilter('All', this)">Tất cả</button>
                    <button type="button" class="status-pill" onclick="setStatusFilter('Pending', this)">Chờ duyệt</button>
                    <button type="button" class="status-pill" onclick="setStatusFilter('Confirmed', this)">Đã xác nhận</button>
                    <button type="button" class="status-pill" onclick="setStatusFilter('Attended', this)">Đã đến khám</button>
                    <button type="button" class="status-pill" onclick="setStatusFilter('Cancelled', this)">Đã hủy</button>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Mã Lịch Hẹn</th>
                            <th>Khách Hàng</th>
                            <th>Ngày Hẹn</th>
                            <th>Giờ Hẹn</th>
                            <th>Bác Sĩ Chỉ Định</th>
                            <th>Ghi chú lúc đặt</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác Tiếp Đón</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (appointments == null || appointments.isEmpty()) { %>
                            <tr>
                                <td colspan="8" align="center" style="color: var(--text-muted); padding: 30px 0;">Không tìm thấy lịch hẹn nào trong cơ sở dữ liệu.</td>
                            </tr>
                        <% } else {
                            for (Appointment app : appointments) {
                                // Construct JSON array of services safely
                                StringBuilder sb = new StringBuilder("[");
                                List<model.Service> chosen = app.getChosenServices();
                                if (chosen != null) {
                                    for (int i = 0; i < chosen.size(); i++) {
                                        model.Service s = chosen.get(i);
                                        sb.append("{")
                                          .append("\"name\":\"").append(s.getServiceName().replace("\"", "\\\"")).append("\",")
                                          .append("\"price\":").append(s.getPrice())
                                          .append("}");
                                        if (i < chosen.size() - 1) sb.append(",");
                                    }
                                }
                                sb.append("]");
                                String servicesJson = sb.toString();

                                // Construct JSON array of history records safely
                                StringBuilder sbHistory = new StringBuilder("[");
                                List<model.MedicalRecord> records = app.getPatientHistory();
                                if (records != null) {
                                    for (int i = 0; i < records.size(); i++) {
                                        model.MedicalRecord mr = records.get(i);
                                        sbHistory.append("{")
                                          .append("\"date\":\"").append(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(mr.getCreatedAt())).append("\",")
                                          .append("\"doctor\":\"").append(mr.getDoctorName().replace("\"", "\\\"")).append("\",")
                                          .append("\"diagnosis\":\"").append(mr.getDiagnosis().replace("\"", "\\\"").replace("\n", " ").replace("\r", "")).append("\",")
                                          .append("\"treatmentPlan\":\"").append(mr.getTreatmentPlan() != null ? mr.getTreatmentPlan().replace("\"", "\\\"").replace("\n", " ").replace("\r", "") : "").append("\",")
                                          .append("\"medicines\":[");
                                        
                                        List<model.PrescriptionDetail> medList = mr.getMedicines();
                                        if (medList != null) {
                                            for (int j = 0; j < medList.size(); j++) {
                                                model.PrescriptionDetail pd = medList.get(j);
                                                sbHistory.append("{")
                                                  .append("\"name\":\"").append(pd.getMedicineName().replace("\"", "\\\"")).append("\",")
                                                  .append("\"qty\":").append(pd.getQuantity()).append(",")
                                                  .append("\"dosage\":\"").append(pd.getDosage().replace("\"", "\\\"")).append("\"")
                                                  .append("}");
                                                if (j < medList.size() - 1) sbHistory.append(",");
                                            }
                                        }
                                        sbHistory.append("]}");
                                        if (i < records.size() - 1) sbHistory.append(",");
                                    }
                                }
                                sbHistory.append("]");
                                String historyJson = sbHistory.toString();
                        %>
                                <tr class="appointment-row"
                                    data-id="<%= app.getAppointmentID() %>"
                                    data-customer-name="<%= app.getCustomerName().replace("\"", "&quot;").replace("'", "&#39;") %>"
                                    data-customer-phone="<%= app.getCustomerPhone() != null ? app.getCustomerPhone() : "" %>"
                                    data-customer-email="<%= app.getCustomerEmail() != null ? app.getCustomerEmail() : "" %>"
                                    data-date="<%= app.getAppointmentDate() %>"
                                    data-time="<%= app.getAppointmentTime() %>"
                                    data-doctor="<%= app.getDoctorName().replace("\"", "&quot;").replace("'", "&#39;") %>"
                                    data-notes="<%= app.getNotes() != null ? app.getNotes().replace("\"", "&quot;").replace("'", "&#39;").replace("\n", " ").replace("\r", "") : "" %>"
                                    data-status="<%= app.getStatus() %>"
                                    data-services="<%= servicesJson.replace("\"", "&quot;").replace("'", "&#39;") %>"
                                    data-history="<%= historyJson.replace("\"", "&quot;").replace("'", "&#39;") %>">
                                    <td>#<%= app.getAppointmentID() %></td>
                                    <td><strong><%= app.getCustomerName() %></strong></td>
                                    <td><%= app.getAppointmentDate() %></td>
                                    <td><%= app.getAppointmentTime() %></td>
                                    <td><%= app.getDoctorName() %></td>
                                    <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= app.getNotes() != null ? app.getNotes() : "" %></td>
                                    <td>
                                        <% 
                                            String status = app.getStatus();
                                            String badgeClass = "badge-pending";
                                            if (status.equalsIgnoreCase("Confirmed")) {
                                                badgeClass = "badge-confirmed";
                                            } else if (status.equalsIgnoreCase("Attended")) {
                                                badgeClass = "badge-attended";
                                            } else if (status.equalsIgnoreCase("Cancelled")) {
                                                badgeClass = "badge-cancelled";
                                            }
                                        %>
                                        <span class="badge <%= badgeClass %>"><%= status %></span>
                                    </td>
                                    <td style="white-space: nowrap;">
                                        <div style="display: flex; gap: 8px; align-items: center;">
                                            <% if (app.getStatus().equalsIgnoreCase("Pending")) { %>
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="confirm">
                                                    <button type="submit" class="action-btn-confirm"><i class="fas fa-check"></i> Xác nhận</button>
                                                </form>
                                                
                                                <button type="button" class="action-btn-reschedule" onclick="openRescheduleModal('<%= app.getAppointmentID() %>', '<%= app.getAppointmentDate() %>', '<%= app.getAppointmentTime() %>')"><i class="fas fa-calendar-alt"></i> Đổi lịch</button>
                                                
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <button type="submit" class="action-btn-cancel" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');"><i class="fas fa-times"></i> Hủy</button>
                                                </form>
                                            <% } else if (app.getStatus().equalsIgnoreCase("Confirmed")) { %>
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="checkin">
                                                    <button type="submit" class="action-btn-checkin" onclick="return confirm('Bạn có chắc muốn check-in lịch này?');"><i class="fas fa-user-check"></i> Check-in</button>
                                                </form>
                                                
                                                <button type="button" class="action-btn-reschedule" onclick="openRescheduleModal('<%= app.getAppointmentID() %>', '<%= app.getAppointmentDate() %>', '<%= app.getAppointmentTime() %>')"><i class="fas fa-calendar-alt"></i> Đổi lịch</button>
                                                
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <button type="submit" class="action-btn-cancel" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');"><i class="fas fa-times"></i> Hủy</button>
                                                </form>
                                            <% } else { %>
                                                <span style="color: var(--text-muted); font-size: 0.85rem; font-style: italic;">Không có thao tác</span>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- APPOINTMENT DETAILS MODAL -->
        <div id="appointmentModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(8px); z-index: 1000; align-items: center; justify-content: center; padding: 20px;">
            <div style="background-color: #ffffff; border-radius: 16px; max-width: 600px; width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); position: relative; overflow: hidden; display: flex; flex-direction: column; max-height: 90vh; border: 1px solid #e2e8f0; animation: modalFadeIn 0.3s ease-out;">
                <!-- Close Button -->
                <button onclick="closeAppointmentModal()" style="position: absolute; top: 16px; right: 16px; background: none; border: none; font-size: 1.5rem; color: #64748b; cursor: pointer; transition: color 0.2s;"><i class="fas fa-times"></i></button>
                
                <!-- Modal Header -->
                <div style="padding: 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; background-color: #f8fafc;">
                    <span style="font-size: 2.2rem;">📅</span>
                    <div>
                        <h2 style="font-family: var(--font-outfit); font-size: 1.35rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0;" id="modalAppTitle">Chi Tiết Lịch Hẹn #...</h2>
                        <span id="modalAppStatus" class="badge">Pending</span>
                    </div>
                </div>

                <!-- Modal Body -->
                <div style="padding: 24px; overflow-y: auto; display: flex; flex-direction: column; gap: 20px;">
                    <!-- Two Column Grid -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <!-- Customer Info -->
                        <div style="background-color: #fafafa; padding: 16px; border-radius: 12px; border: 1px solid #f1f5f9;">
                            <h4 style="font-family: var(--font-outfit); font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 12px 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                                <i class="fas fa-user" style="color: #2563eb; margin-right: 6px;"></i> Khách Hàng
                            </h4>
                            <p style="margin: 4px 0; font-size: 0.9rem;"><strong id="modalCustomerName">...</strong></p>
                            <p style="margin: 4px 0; font-size: 0.85rem; color: #64748b;" id="modalCustomerPhone"><i class="fas fa-phone" style="width: 16px; color: var(--primary);"></i> ...</p>
                            <p style="margin: 4px 0; font-size: 0.85rem; color: #64748b;" id="modalCustomerEmail"><i class="fas fa-envelope" style="width: 16px; color: var(--primary);"></i> ...</p>
                        </div>
                        
                        <!-- Appointment Info -->
                        <div style="background-color: #fafafa; padding: 16px; border-radius: 12px; border: 1px solid #f1f5f9;">
                            <h4 style="font-family: var(--font-outfit); font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 12px 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                                <i class="fas fa-calendar-check" style="color: #2563eb; margin-right: 6px;"></i> Lịch Khám
                            </h4>
                            <p style="margin: 4px 0; font-size: 0.88rem;"><strong>Ngày:</strong> <span id="modalAppDate">...</span></p>
                            <p style="margin: 4px 0; font-size: 0.88rem;"><strong>Giờ:</strong> <span id="modalAppTime">...</span></p>
                            <p style="margin: 4px 0; font-size: 0.88rem;"><strong>Bác sĩ:</strong> <span id="modalAppDoctor" style="color: #0369a1; font-weight: 600;">...</span></p>
                        </div>
                    </div>

                    <!-- Services Block -->
                    <div style="background-color: #fafafa; padding: 16px; border-radius: 12px; border: 1px solid #f1f5f9;">
                        <h4 style="font-family: var(--font-outfit); font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 12px 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                            <i class="fas fa-hand-holding-medical" style="color: #2563eb; margin-right: 6px;"></i> Dịch Vụ Đăng Ký
                        </h4>
                        <div id="modalAppServices" style="display: flex; flex-wrap: wrap; gap: 8px;">
                            <!-- Dynamic Badges -->
                        </div>
                    </div>

                    <!-- Notes -->
                    <div>
                        <h4 style="font-family: var(--font-outfit); font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 8px 0;">
                            <i class="fas fa-comment-alt" style="color: #64748b; margin-right: 6px;"></i> Ghi chú của khách hàng
                        </h4>
                        <div id="modalAppNotes" style="font-size: 0.9rem; color: #334155; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; min-height: 50px; white-space: pre-wrap;">
                            ...
                        </div>
                    </div>

                    <!-- Patient History Section inside Modal -->
                    <div style="border-top: 1px dashed #e2e8f0; padding-top: 16px;">
                        <h4 style="font-family: var(--font-outfit); font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 12px 0;">
                            <i class="fas fa-history" style="color: #2563eb; margin-right: 6px;"></i> Lịch Sử Khám Bệnh Của Khách Hàng
                        </h4>
                        <div id="modalAppHistory" style="display: flex; flex-direction: column; gap: 12px; max-height: 200px; overflow-y: auto; padding-right: 5px;">
                            <!-- Dynamic History List -->
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; background-color: #f8fafc;">
                    <button onclick="closeAppointmentModal()" class="btn btn-secondary" style="padding: 8px 20px; font-weight: 600;">Đóng</button>
                </div>
            </div>
        </div>

        <!-- RESCHEDULE APPOINTMENT MODAL -->
        <div id="rescheduleModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(8px); z-index: 1000; align-items: center; justify-content: center; padding: 20px;">
            <div style="background-color: #ffffff; border-radius: 16px; max-width: 450px; width: 100%; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); position: relative; overflow: hidden; display: flex; flex-direction: column; border: 1px solid #e2e8f0; animation: modalFadeIn 0.3s ease-out;">
                <!-- Close Button -->
                <button onclick="closeRescheduleModal()" style="position: absolute; top: 16px; right: 16px; background: none; border: none; font-size: 1.5rem; color: #64748b; cursor: pointer; transition: color 0.2s;"><i class="fas fa-times"></i></button>
                
                <!-- Modal Header -->
                <div style="padding: 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; background-color: #f8fafc;">
                    <span style="font-size: 2.2rem;">🔄</span>
                    <div>
                        <h2 style="font-family: var(--font-outfit); font-size: 1.35rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0;">Đổi Lịch Hẹn</h2>
                        <span id="rescheduleAppIdLabel" style="font-size: 0.85rem; color: var(--text-secondary); font-weight: 600;">Lịch hẹn #...</span>
                    </div>
                </div>

                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" onsubmit="return validateRescheduleForm()" style="margin: 0;">
                    <input type="hidden" name="action" value="reschedule">
                    <input type="hidden" name="appointmentID" id="rescheduleAppId">
                    
                    <!-- Modal Body -->
                    <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Chọn ngày khám mới <span style="color: red;">*</span></label>
                            <input type="date" name="newDate" id="rescheduleDate" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Chọn giờ khám mới <span style="color: red;">*</span></label>
                            <select name="newTime" id="rescheduleTime" class="form-select" required>
                                <option value="">-- Chọn giờ hẹn --</option>
                                <option value="08:00">08:00</option>
                                <option value="09:00">09:00</option>
                                <option value="10:00">10:00</option>
                                <option value="11:00">11:00</option>
                                <option value="12:00">12:00</option>
                                <option value="13:00">13:00</option>
                                <option value="14:00">14:00</option>
                                <option value="15:00">15:00</option>
                                <option value="16:00">16:00</option>
                                <option value="17:00">17:00</option>
                            </select>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; background-color: #f8fafc;">
                        <button type="button" onclick="closeRescheduleModal()" class="btn btn-secondary" style="padding: 8px 16px; font-weight: 600;">Hủy</button>
                        <button type="submit" class="btn btn-primary" style="padding: 8px 20px; font-weight: 600;">Xác Nhận</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                document.querySelectorAll('.appointment-row').forEach(row => {
                    row.addEventListener('click', function(e) {
                        // If the user clicked on standard action buttons/forms in the last column, don't show the modal
                        const actionsCell = e.target.closest('td');
                        if (actionsCell && actionsCell.cellIndex === 7) {
                            return;
                        }
                        
                        const id = this.getAttribute('data-id');
                        const customerName = this.getAttribute('data-customer-name');
                        const phone = this.getAttribute('data-customer-phone');
                        const email = this.getAttribute('data-customer-email');
                        const date = this.getAttribute('data-date');
                        const time = this.getAttribute('data-time');
                        const doctor = this.getAttribute('data-doctor');
                        const notes = this.getAttribute('data-notes');
                        const status = this.getAttribute('data-status');
                        const servicesJson = this.getAttribute('data-services');
                        const historyJson = this.getAttribute('data-history');
                        
                        showAppointmentDetail(id, customerName, phone, email, date, time, doctor, notes, status, servicesJson, historyJson);
                    });
                });
            });

            function showAppointmentDetail(id, customerName, phone, email, date, time, doctor, notes, status, servicesJson, historyJson) {
                document.getElementById('modalAppTitle').innerText = 'Chi Tiết Lịch Hẹn #' + id;
                document.getElementById('modalCustomerName').innerText = customerName;
                document.getElementById('modalCustomerPhone').innerHTML = '<i class="fas fa-phone" style="width: 16px; color: var(--primary);"></i> ' + (phone ? phone : 'Chưa cập nhật');
                document.getElementById('modalCustomerEmail').innerHTML = '<i class="fas fa-envelope" style="width: 16px; color: var(--primary);"></i> ' + (email ? email : 'Chưa cập nhật');
                
                document.getElementById('modalAppDate').innerText = date;
                document.getElementById('modalAppTime').innerText = time;
                document.getElementById('modalAppDoctor').innerText = doctor;
                document.getElementById('modalAppNotes').innerText = notes ? notes : 'Không có ghi chú nào.';

                // Status Badge styling
                const statusEl = document.getElementById('modalAppStatus');
                statusEl.innerText = status;
                statusEl.className = 'badge';
                if (status.toLowerCase() === 'confirmed') {
                    statusEl.classList.add('badge-confirmed');
                } else if (status.toLowerCase() === 'attended') {
                    statusEl.classList.add('badge-attended');
                } else if (status.toLowerCase() === 'cancelled') {
                    statusEl.classList.add('badge-cancelled');
                } else {
                    statusEl.classList.add('badge-pending');
                }

                // Render selected services badges
                let servicesList = [];
                try {
                    servicesList = JSON.parse(servicesJson);
                } catch (e) {
                    console.error("Error parsing servicesJson:", e);
                }
                const servicesContainer = document.getElementById('modalAppServices');
                servicesContainer.innerHTML = '';

                if (servicesList && servicesList.length > 0) {
                    servicesList.forEach(s => {
                        const badge = document.createElement('span');
                        badge.style.backgroundColor = '#dbeafe';
                        badge.style.color = '#1e40af';
                        badge.style.border = '1px solid #bfdbfe';
                        badge.style.padding = '6px 12px';
                        badge.style.borderRadius = '20px';
                        badge.style.fontSize = '0.82rem';
                        badge.style.fontWeight = '600';
                        badge.style.display = 'inline-block';
                        badge.innerText = s.name + ' (' + s.price.toLocaleString('vi-VN') + ' đ)';
                        servicesContainer.appendChild(badge);
                    });
                } else {
                    servicesContainer.innerHTML = '<span style="font-size: 0.88rem; color: #64748b; font-style: italic;">Khám tổng quát (General Checkup)</span>';
                }

                // Render history
                let historyList = [];
                try {
                    historyList = JSON.parse(historyJson);
                } catch (e) {
                    console.error("Error parsing historyJson:", e);
                }
                const historyContainer = document.getElementById('modalAppHistory');
                historyContainer.innerHTML = '';

                if (historyList && historyList.length > 0) {
                    historyList.forEach(h => {
                        const itemDiv = document.createElement('div');
                        itemDiv.style.backgroundColor = '#f8fafc';
                        itemDiv.style.border = '1px solid #e2e8f0';
                        itemDiv.style.borderRadius = '8px';
                        itemDiv.style.padding = '12px';
                        itemDiv.style.fontSize = '0.85rem';
                        
                        let medsHtml = '';
                        if (h.medicines && h.medicines.length > 0) {
                            let listItems = '';
                            h.medicines.forEach(m => {
                                listItems += '<li>' + m.name + ' - SL: ' + m.qty + ' (' + m.dosage + ')</li>';
                            });
                            medsHtml = 
                                '<div style="margin-top: 6px; padding-top: 6px; border-top: 1px dashed #e2e8f0; font-size: 0.8rem; color: #475569;">' +
                                '    <strong>Đơn thuốc:</strong>' +
                                '    <ul style="padding-left: 15px; margin: 2px 0 0 0; list-style-type: disc;">' +
                                         listItems +
                                '    </ul>' +
                                '</div>';
                        }

                        let treatmentPlanHtml = '';
                        if (h.treatmentPlan) {
                            treatmentPlanHtml = '<div style="color: #334155; margin-top: 2px;"><strong>Lời dặn:</strong> ' + h.treatmentPlan + '</div>';
                        }

                        itemDiv.innerHTML = 
                            '<div style="font-weight: 600; color: #0f172a; margin-bottom: 2px;">' +
                            '    Chẩn đoán: ' + h.diagnosis +
                            '</div>' +
                            '<div style="font-size: 0.78rem; color: #64748b; margin-bottom: 4px;">' +
                            '    Ngày khám: ' + h.date + ' | BS. ' + h.doctor +
                            '</div>' +
                            treatmentPlanHtml +
                            medsHtml;
                        historyContainer.appendChild(itemDiv);
                    });
                } else {
                    historyContainer.innerHTML = '<span style="font-size: 0.88rem; color: #64748b; font-style: italic;">Chưa có lịch sử khám bệnh trước đó.</span>';
                }

                document.getElementById('appointmentModal').style.display = 'flex';
            }

            function closeAppointmentModal() {
                document.getElementById('appointmentModal').style.display = 'none';
            }

            // Close modal when clicking outside content
            window.addEventListener('click', function(e) {
                const detailsModal = document.getElementById('appointmentModal');
                const rescheduleModal = document.getElementById('rescheduleModal');
                if (e.target === detailsModal) {
                    closeAppointmentModal();
                }
                if (e.target === rescheduleModal) {
                    closeRescheduleModal();
                }
            });

            function openRescheduleModal(appointmentID, currentDate, currentTime) {
                document.getElementById('rescheduleAppId').value = appointmentID;
                document.getElementById('rescheduleAppIdLabel').innerText = 'Lịch hẹn #' + appointmentID;
                
                document.getElementById('rescheduleDate').value = currentDate;
                document.getElementById('rescheduleTime').value = currentTime.substring(0, 5);
                
                const todayStr = new Date().toISOString().split('T')[0];
                document.getElementById('rescheduleDate').min = todayStr;
                
                document.getElementById('rescheduleModal').style.display = 'flex';
            }
            
            function closeRescheduleModal() {
                document.getElementById('rescheduleModal').style.display = 'none';
            }

            function validateRescheduleForm() {
                const dateStr = document.getElementById('rescheduleDate').value;
                const timeStr = document.getElementById('rescheduleTime').value;
                
                if (!dateStr || !timeStr) {
                    alert('Vui lòng chọn đầy đủ ngày và giờ!');
                    return false;
                }
                
                const selectedDateTime = new Date(dateStr + 'T' + timeStr);
                const now = new Date();
                
                if (selectedDateTime < now) {
                    alert('Thời gian hẹn khám mới không được ở trong quá khứ!');
                    return false;
                }
                
                return true;
            }

            function removeDiacritics(str) {
                if (!str) return '';
                return str.normalize("NFD")
                          .replace(/[\u0300-\u036f]/g, "")
                          .replace(/đ/g, "d")
                          .replace(/Đ/g, "D");
            }

            // Realtime search, date, and status filtering logic
            let currentStatusFilter = 'All';

            function setStatusFilter(status, btnElement) {
                currentStatusFilter = status;
                
                // Toggle active class on pills
                const pills = document.querySelectorAll('.status-pill');
                pills.forEach(pill => pill.classList.remove('active'));
                
                if (btnElement) {
                    btnElement.classList.add('active');
                } else {
                    // Fallback to highlight 'All' pill if no button passed (e.g. on clear)
                    const allPill = Array.from(pills).find(p => p.textContent.trim() === 'Tất cả');
                    if (allPill) allPill.classList.add('active');
                }
                
                filterAppointments();
            }

            function filterAppointments() {
                const searchVal = removeDiacritics(document.getElementById('searchQuery').value.toLowerCase());
                const dateVal = document.getElementById('filterDate').value;
                const rows = document.querySelectorAll('.appointment-row');
                
                rows.forEach(row => {
                    const name = removeDiacritics((row.getAttribute('data-customer-name') || '').toLowerCase());
                    const phone = row.getAttribute('data-customer-phone') || '';
                    const date = row.getAttribute('data-date'); // yyyy-MM-dd
                    const status = row.getAttribute('data-status') || '';
                    
                    let matchesSearch = true;
                    if (searchVal) {
                        matchesSearch = name.indexOf(searchVal) > -1 || phone.indexOf(searchVal) > -1;
                    }
                    
                    let matchesDate = true;
                    if (dateVal) {
                        matchesDate = (date === dateVal);
                    }
                    
                    let matchesStatus = true;
                    if (currentStatusFilter !== 'All') {
                        matchesStatus = (status.toLowerCase() === currentStatusFilter.toLowerCase());
                    }
                    
                    if (matchesSearch && matchesDate && matchesStatus) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function clearFilters() {
                document.getElementById('searchQuery').value = '';
                document.getElementById('filterDate').value = '';
                setStatusFilter('All');
            }
        </script>
    </body>
</html>
