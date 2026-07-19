<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, model.User, model.MedicalRecord, model.PrescriptionDetail, java.text.SimpleDateFormat"%>
<%
    User loggedUser = (User) session.getAttribute("loggedInUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }
    if (loggedUser.getRoleID() != 2) {
        request.getRequestDispatcher("/error/403.jsp").forward(request, response);
        return;
    }

    List<MedicalRecord> records = (List<MedicalRecord>) request.getAttribute("records");
    Map<Integer, List<PrescriptionDetail>> recordMedicines = (Map<Integer, List<PrescriptionDetail>>) request.getAttribute("recordMedicines");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lịch Sử Khám Bệnh - Bác Sĩ | SmileCare</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            .history-card {
                background: #ffffff;
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-lg);
                padding: 25px;
                margin-bottom: 20px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
                transition: all 0.25s ease;
            }
            .history-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(15, 23, 42, 0.04);
            }
            .med-badge {
                display: inline-block;
                background-color: #f1f5f9;
                color: #475569;
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 0.85rem;
                margin-right: 8px;
                margin-bottom: 8px;
                border: 1px solid #e2e8f0;
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
                <a href="<%= request.getContextPath() %>/doctor/checkup">Khám bệnh</a>
                <a href="<%= request.getContextPath() %>/doctor/history" style="color: #60a5fa; font-weight: 700;">Lịch sử khám</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container" style="max-width: 900px !important;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                <div>
                    <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 6px;">
                        📋 Lịch Sử Khám Bệnh
                    </h1>
                    <p style="color: var(--text-secondary); font-size: 1rem;">
                        Danh sách các ca khám bệnh đã được bạn chẩn đoán và điều trị tại SmileCare.
                    </p>
                </div>
                <div style="text-align: right;">
                    <span class="badge badge-active" style="padding: 8px 16px; font-size: 0.9rem;">
                        Bác sĩ: <%= loggedUser.getFullName() %>
                    </span>
                </div>
            </div>

            <% if (records == null || records.isEmpty()) { %>
                <div class="glass-card" style="text-align: center; color: var(--text-muted); padding: 50px 0;">
                    <i class="fas fa-folder-open" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 15px; display: block;"></i>
                    Bạn chưa hoàn thành ca khám bệnh nào.
                </div>
            <% } else {
                for (MedicalRecord mr : records) {
                    List<PrescriptionDetail> meds = recordMedicines.get(mr.getRecordID());
            %>
                    <div class="history-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; margin-bottom: 15px;">
                            <div>
                                <span style="font-size: 0.85rem; color: var(--text-muted); font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;">Bệnh nhân</span>
                                <h3 style="font-family: var(--font-outfit); font-size: 1.25rem; font-weight: 700; color: var(--accent-navy); margin-top: 2px;">
                                    👤 <%= mr.getPatientName() != null ? mr.getPatientName() : "Khách hàng vãng lai" %>
                                </h3>
                            </div>
                            <div style="text-align: right;">
                                <span style="font-size: 0.85rem; color: var(--text-muted); display: block;"><%= sdf.format(mr.getCreatedAt()) %></span>
                                <span style="font-size: 0.8rem; background: #e0f2fe; color: #0369a1; padding: 3px 8px; border-radius: 4px; font-weight: 600; display: inline-block; margin-top: 4px;">
                                    Mã bệnh án: #<%= mr.getRecordID() %>
                                </span>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr; gap: 15px; margin-bottom: 15px;">
                            <div>
                                <strong style="color: var(--accent-navy); font-size: 0.95rem; display: block; margin-bottom: 4px;">🩺 Chẩn đoán / Triệu chứng:</strong>
                                <p style="color: var(--text-secondary); line-height: 1.6; margin: 0; font-size: 0.95rem; white-space: pre-line;"><%= mr.getDiagnosis() %></p>
                            </div>
                            <% if (mr.getTreatmentPlan() != null && !mr.getTreatmentPlan().trim().isEmpty()) { %>
                                <div>
                                    <strong style="color: var(--accent-navy); font-size: 0.95rem; display: block; margin-bottom: 4px;">📝 Hướng điều trị / Lời khuyên:</strong>
                                    <p style="color: var(--text-secondary); line-height: 1.6; margin: 0; font-size: 0.95rem; white-space: pre-line;"><%= mr.getTreatmentPlan() %></p>
                                </div>
                            <% } %>
                        </div>

                        <% if (meds != null && !meds.isEmpty()) { %>
                            <div style="border-top: 1px dashed var(--border-color); padding-top: 15px; margin-top: 15px;">
                                <strong style="color: var(--accent-navy); font-size: 0.95rem; display: block; margin-bottom: 8px;">💊 Đơn thuốc đã kê:</strong>
                                <div style="display: flex; flex-wrap: wrap;">
                                    <% for (PrescriptionDetail m : meds) { %>
                                        <span class="med-badge">
                                            <strong><%= m.getMedicineName() %></strong> (<%= m.getQuantity() %> <%= m.getUnit() %>) - <i><%= m.getDosage() %></i>
                                        </span>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
            <%
                }
            }
            %>
        </div>
    </body>
</html>
