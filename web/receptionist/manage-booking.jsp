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
            <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 30px;">
                📋 Danh Sách Lịch Hẹn Đặt (Lễ Tân Tiếp Đón)
            </h1>
            
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
                        %>
                                <tr onclick="showAppointmentDetail(event, '<%= app.getAppointmentID() %>', '<%= app.getCustomerName().replace("'", "\\'") %>', '<%= app.getCustomerPhone() != null ? app.getCustomerPhone() : "" %>', '<%= app.getCustomerEmail() != null ? app.getCustomerEmail() : "" %>', '<%= app.getAppointmentDate() %>', '<%= app.getAppointmentTime() %>', '<%= app.getDoctorName().replace("'", "\\'") %>', '<%= app.getNotes() != null ? app.getNotes().replace("'", "\\'").replace("\n", "\\n").replace("\r", "") : "" %>', '<%= app.getStatus() %>', '<%= servicesJson.replace("'", "\\'") %>')">
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
                                                
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <button type="submit" class="action-btn-cancel" onclick="return confirm('Bạn có chắc muốn hủy lịch này?');"><i class="fas fa-times"></i> Hủy</button>
                                                </form>
                                            <% } else if (app.getStatus().equalsIgnoreCase("Confirmed")) { %>
                                                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                                                    <input type="hidden" name="action" value="checkin">
                                                    <button type="submit" class="action-btn-checkin"><i class="fas fa-user-check"></i> Check-in</button>
                                                </form>
                                                
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
                </div>

                <!-- Footer -->
                <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; background-color: #f8fafc;">
                    <button onclick="closeAppointmentModal()" class="btn btn-secondary" style="padding: 8px 20px; font-weight: 600;">Đóng</button>
                </div>
            </div>
        </div>

        <script>
            function showAppointmentDetail(event, id, customerName, phone, email, date, time, doctor, notes, status, servicesJson) {
                // If the user clicked on standard action buttons/forms in the last column, don't show the modal
                const actionsCell = event.target.closest('td');
                if (actionsCell && actionsCell.cellIndex === 7) {
                    return;
                }

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
                const servicesList = JSON.parse(servicesJson);
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

                document.getElementById('appointmentModal').style.display = 'flex';
            }

            function closeAppointmentModal() {
                document.getElementById('appointmentModal').style.display = 'none';
            }

            // Close modal when clicking outside content
            window.addEventListener('click', function(e) {
                const modal = document.getElementById('appointmentModal');
                if (e.target === modal) {
                    closeAppointmentModal();
                }
            });
        </script>
    </body>
</html>
