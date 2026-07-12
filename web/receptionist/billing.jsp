<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, controller.receptionist.BillingController.BillingQueueItem, java.text.SimpleDateFormat"%>
<%
    List<BillingQueueItem> billingQueue = (List<BillingQueueItem>) request.getAttribute("billingQueue");
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    if (successMessage != null) {
        request.getSession().removeAttribute("successMessage");
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hàng chờ Thanh toán - Dental Clinic</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    </head>
    <body>
        <div class="dashboard-container">
            <!-- Header Banner -->
            <header class="header-banner">
                <div class="header-title-section">
                    <h1>HÀNG CHỜ THANH TOÁN</h1>
                    <p>Hệ thống nha khoa Dental Clinic - Tiếp đón & Thanh toán hóa đơn</p>
                </div>
                <div class="header-actions">
                    <a href="<%= request.getContextPath() %>/receptionist/manage-booking.jsp" class="btn btn-secondary">
                        <svg style="width: 18px; height: 18px; fill: currentColor; margin-right: 5px;" viewBox="0 0 24 24">
                            <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
                        </svg>
                        Quản lý Lịch hẹn
                    </a>
                </div>
            </header>

            <!-- Alerts Section -->
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <svg style="width: 20px; height: 20px; fill: currentColor;" viewBox="0 0 24 24">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                    </svg>
                    <span><%= errorMessage %></span>
                </div>
            <% } %>

            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <svg style="width: 20px; height: 20px; fill: currentColor;" viewBox="0 0 24 24">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                    </svg>
                    <span><%= successMessage %></span>
                </div>
            <% } %>

            <!-- Queue list -->
            <main class="glass-card">
                <div class="card-title">
                    <svg style="width: 24px; height: 24px; fill: var(--accent-blue);" viewBox="0 0 24 24">
                        <path d="M15 1H9v2h6V1zm-4 13h2V8h-2v6zm8.03-6.61l1.42-1.42c-.43-.51-.9-.99-1.41-1.41l-1.42 1.42C16.07 4.74 14.12 4 12 4c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-2.12-.74-4.07-1.97-5.61zM12 20c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z"/>
                    </svg>
                    Danh sách Ca khám chờ Thanh toán
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th style="width: 100px;">Mã bệnh án</th>
                                <th>Khách Hàng (Bệnh Nhân)</th>
                                <th>Bác Sĩ Điều Trị</th>
                                <th>Chẩn Đoán Lâm Sàng</th>
                                <th>Thời Gian Khám</th>
                                <th style="width: 160px; text-align: center;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (billingQueue == null || billingQueue.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-secondary); padding: 50px 0;">
                                        Hiện không có ca khám nào đang chờ thanh toán.
                                    </td>
                                </tr>
                            <% } else {
                                for (BillingQueueItem item : billingQueue) { %>
                                    <tr>
                                        <td>#<%= item.getRecord().getRecordID() %></td>
                                        <td class="service-name-cell"><%= item.getCustomerName() %></td>
                                        <td style="font-weight: 500;"><%= item.getDoctorName() %></td>
                                        <td style="color: var(--text-secondary); font-size: 0.85rem; max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= item.getRecord().getDiagnosis() %>">
                                            <%= item.getRecord().getDiagnosis() %>
                                        </td>
                                        <td style="color: var(--text-muted); font-size: 0.85rem;">
                                            <%= sdf.format(item.getRecord().getCreatedAt()) %>
                                        </td>
                                        <td style="text-align: center;">
                                            <a href="<%= request.getContextPath() %>/receptionist/billing?action=checkout&recordID=<%= item.getRecord().getRecordID() %>" 
                                               class="btn btn-primary" style="padding: 8px 16px; font-size: 0.85rem; border-radius: var(--border-radius-md); box-shadow: none;">
                                                <svg style="width: 16px; height: 16px; fill: currentColor; margin-right: 4px;" viewBox="0 0 24 24">
                                                    <path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9zm-9-2h10V8H12v8zm4-2.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/>
                                                </svg>
                                                Thanh toán
                                            </a>
                                        </td>
                                    </tr>
                                <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    </body>
</html>
