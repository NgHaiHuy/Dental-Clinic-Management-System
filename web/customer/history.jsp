<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="model.MedicalRecord"%>
<%@page import="model.Role"%>
<%@page import="model.Service"%>
<%!
    private String html(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String textOr(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private int number(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return value == null ? 0 : Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }
%>
<%
    Object recordsAttribute = request.getAttribute("records");
    if (recordsAttribute == null) {
        response.sendRedirect(request.getContextPath() + "/examination-history");
        return;
    }

    List<MedicalRecord> records = (List<MedicalRecord>) recordsAttribute;
    if (records == null) {
        records = Collections.emptyList();
    }
    List<Service> services = (List<Service>) request.getAttribute("services");
    if (services == null) {
        services = Collections.emptyList();
    }

    int currentRole = number(request.getAttribute("currentRole"));
    if (currentRole != Role.DOCTOR && currentRole != Role.STAFF && currentRole != Role.CUSTOMER) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    boolean isCustomer = currentRole == Role.CUSTOMER;
    boolean isDoctor = currentRole == Role.DOCTOR;
    boolean isStaff = currentRole == Role.STAFF;

    String roleLabel = isCustomer ? "Khách hàng" : (isDoctor ? "Bác sĩ" : "Nhân viên tiếp đón");
    String pageEyebrow = isCustomer ? "HỒ SƠ SỨC KHỎE CỦA BẠN"
            : (isDoctor ? "NHẬT KÝ CHUYÊN MÔN" : "TỔNG QUAN PHÒNG KHÁM");
    String pageTitle = isCustomer ? "Lịch sử khám của tôi"
            : (isDoctor ? "Lịch sử ca đã khám" : "Lịch sử khám toàn hệ thống");
    String pageDescription = isCustomer
            ? "Theo dõi kết quả khám, chẩn đoán và hướng điều trị của từng lần đến SmileCare."
            : (isDoctor
                ? "Tra cứu nhanh các ca bạn đã phụ trách cùng thông tin điều trị đã ghi nhận."
                : "Tìm kiếm và theo dõi toàn bộ ca khám đã hoàn tất tại SmileCare.");
    String searchPlaceholder = isCustomer
            ? "Bác sĩ, dịch vụ hoặc chẩn đoán..."
            : (isDoctor ? "Tên khách hàng, SĐT hoặc chẩn đoán..."
                        : "Khách hàng, bác sĩ, SĐT hoặc chẩn đoán...");
    String accountPath = isCustomer ? "/customer/profile"
            : (isDoctor ? "/doctor/dashboard.jsp" : "/receptionist/dashboard.jsp");
    String accountLinkLabel = isCustomer ? "Hồ sơ" : "Bảng điều khiển";

    String keyword = request.getAttribute("keyword") == null ? "" : String.valueOf(request.getAttribute("keyword"));
    String fromDate = request.getAttribute("fromDate") == null ? "" : String.valueOf(request.getAttribute("fromDate"));
    String toDate = request.getAttribute("toDate") == null ? "" : String.valueOf(request.getAttribute("toDate"));
    int selectedServiceId = number(request.getAttribute("selectedServiceId"));
    String dataError = request.getAttribute("dataError") == null ? "" : String.valueOf(request.getAttribute("dataError"));
    String filterError = request.getAttribute("filterError") == null ? "" : String.valueOf(request.getAttribute("filterError"));
    boolean hasActiveFilter = !keyword.trim().isEmpty() || !fromDate.isEmpty() || !toDate.isEmpty() || selectedServiceId > 0;

    int totalCount = number(request.getAttribute("totalCount"));
    int patientCount = number(request.getAttribute("patientCount"));
    int doctorCount = number(request.getAttribute("doctorCount"));
    int monthCount = number(request.getAttribute("monthCount"));
    int treatmentCount = number(request.getAttribute("treatmentCount"));

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Lịch sử các ca đã khám tại SmileCare">
    <title><%= html(pageTitle) %> | SmileCare</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Nunito+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/examination-history.css">
</head>
<body>
    <header class="history-header">
        <div class="container header-inner">
            <a class="brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Về trang chủ SmileCare">
                <span class="brand-mark" aria-hidden="true">✦</span>
                <span>Smile<span>Care</span></span>
            </a>
            <nav class="header-nav" aria-label="Điều hướng tài khoản">
                <a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a>
                <a href="<%= request.getContextPath() + accountPath %>"><%= html(accountLinkLabel) %></a>
                <a class="logout-link" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
            </nav>
        </div>
    </header>

    <main class="history-page">
        <section class="history-hero">
            <div class="hero-decoration hero-decoration-one" aria-hidden="true"></div>
            <div class="hero-decoration hero-decoration-two" aria-hidden="true"></div>
            <div class="container hero-content">
                <div class="hero-copy">
                    <p class="eyebrow"><span aria-hidden="true">●</span> <%= html(pageEyebrow) %></p>
                    <h1><%= html(pageTitle) %></h1>
                    <p><%= html(pageDescription) %></p>
                </div>
                <div class="role-card" aria-label="Quyền xem hiện tại">
                    <span class="role-icon" aria-hidden="true">
                        <% if (isCustomer) { %>
                            <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm7 8a7 7 0 0 0-14 0"/></svg>
                        <% } else if (isDoctor) { %>
                            <svg viewBox="0 0 24 24"><path d="M9 4H7a2 2 0 0 0-2 2v3a5 5 0 0 0 10 0V6a2 2 0 0 0-2-2h-2M10 17v1a3 3 0 0 0 6 0v-2a2 2 0 1 1 4 0"/></svg>
                        <% } else { %>
                            <svg viewBox="0 0 24 24"><path d="M8 7V3m8 4V3M4 11h16M6 5h12a2 2 0 0 1 2 2v12H4V7a2 2 0 0 1 2-2Zm3 10h6"/></svg>
                        <% } %>
                    </span>
                    <span><small>Đang xem với vai trò</small><strong><%= html(roleLabel) %></strong></span>
                </div>
            </div>
        </section>

        <div class="container history-content">
            <section class="stats-grid" aria-label="Thống kê lịch sử khám">
                <article class="stat-card stat-primary">
                    <span class="stat-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 0 0-2 2v12h14V7a2 2 0 0 0-2-2h-2"></path><path d="M9 5a3 3 0 0 1 6 0v2H9V5Z"></path><path d="m9 14 2 2 4-4"></path></svg>
                    </span>
                    <div><strong><%= totalCount %></strong><span>Tổng ca đã khám</span></div>
                </article>
                <article class="stat-card">
                    <span class="stat-icon calendar-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M8 3v4m8-4v4M3 10h18"></path><path d="M8 14h2m4 0h2m-8 3h2m4 0h2"></path></svg>
                    </span>
                    <div><strong><%= monthCount %></strong><span>Ca khám tháng này</span></div>
                </article>
                <% if (isCustomer) { %>
                    <article class="stat-card">
                        <span class="stat-icon doctor-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M6 3v5a5 5 0 0 0 10 0V3"></path><path d="M6 4H4m12 0h2M11 13v3a4 4 0 0 0 8 0v-1"></path><circle cx="19" cy="12" r="2"></circle></svg>
                        </span>
                        <div><strong><%= doctorCount %></strong><span>Bác sĩ đã thăm khám</span></div>
                    </article>
                <% } else { %>
                    <article class="stat-card">
                        <span class="stat-icon patient-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"></circle><path d="M5 21a7 7 0 0 1 14 0"></path></svg>
                        </span>
                        <div><strong><%= patientCount %></strong><span>Khách hàng đã khám</span></div>
                    </article>
                <% } %>
                <article class="stat-card">
                    <span class="stat-icon treatment-icon" aria-hidden="true">
                        <% if (isStaff) { %>
                            <svg viewBox="0 0 24 24"><circle cx="9" cy="8" r="3"></circle><path d="M3 20a6 6 0 0 1 12 0m3-8v6m-3-3h6"></path></svg>
                        <% } else { %>
                            <svg viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 0 0-2 2v12h14V7a2 2 0 0 0-2-2h-2"></path><path d="M9 5a3 3 0 0 1 6 0v2H9V5Z"></path><path d="M9 12h6m-6 4h4"></path></svg>
                        <% } %>
                    </span>
                    <div>
                        <strong><%= isStaff ? doctorCount : treatmentCount %></strong>
                        <span><%= isStaff ? "Bác sĩ phụ trách" : "Ca có hướng điều trị" %></span>
                    </div>
                </article>
            </section>

            <section class="filter-card" aria-labelledby="filter-title">
                <div class="section-heading filter-heading">
                    <div>
                        <p class="section-kicker">TRA CỨU NHANH</p>
                        <h2 id="filter-title">Tìm kiếm lịch sử khám</h2>
                    </div>
                    <% if (hasActiveFilter) { %>
                        <span class="filter-active"><i aria-hidden="true"></i> Đang áp dụng bộ lọc</span>
                    <% } %>
                </div>

                <form class="filter-form" method="get" action="${pageContext.request.contextPath}/examination-history" id="historyFilterForm">
                    <div class="form-field search-field">
                        <label for="keyword">Từ khóa</label>
                        <div class="input-with-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
                            <input id="keyword" name="keyword" type="search" maxlength="100" value="<%= html(keyword) %>" placeholder="<%= html(searchPlaceholder) %>">
                        </div>
                    </div>
                    <div class="form-field">
                        <label for="fromDate">Từ ngày</label>
                        <input id="fromDate" name="fromDate" type="date" value="<%= html(fromDate) %>">
                    </div>
                    <div class="form-field">
                        <label for="toDate">Đến ngày</label>
                        <input id="toDate" name="toDate" type="date" value="<%= html(toDate) %>">
                    </div>
                    <div class="form-field service-field">
                        <label for="serviceId">Dịch vụ</label>
                        <select id="serviceId" name="serviceId">
                            <option value="">Tất cả dịch vụ</option>
                            <% for (Service service : services) { %>
                                <option value="<%= service.getServiceID() %>"<%= selectedServiceId == service.getServiceID() ? " selected" : "" %>><%= html(service.getServiceName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-actions">
                        <button class="search-button" type="submit" id="filterSubmitButton">
                            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
                            <span>Tìm kiếm</span>
                        </button>
                        <a class="reset-button" href="${pageContext.request.contextPath}/examination-history"<%= hasActiveFilter ? "" : " aria-disabled=\"true\"" %>>Đặt lại</a>
                    </div>
                </form>
            </section>

            <% if (!filterError.isEmpty()) { %>
                <div class="notice notice-warning" role="alert">
                    <span aria-hidden="true">!</span><div><strong>Bộ lọc chưa hợp lệ</strong><p><%= html(filterError) %></p></div>
                </div>
            <% } %>
            <% if (!dataError.isEmpty()) { %>
                <div class="notice notice-error" role="alert">
                    <span aria-hidden="true">!</span><div><strong>Chưa thể tải đầy đủ dữ liệu</strong><p><%= html(dataError) %></p></div>
                </div>
            <% } %>

            <section class="records-card" aria-labelledby="records-title">
                <div class="section-heading records-heading">
                    <div>
                        <p class="section-kicker">KẾT QUẢ TRA CỨU</p>
                        <h2 id="records-title">Danh sách ca đã khám</h2>
                    </div>
                    <span class="result-count"><strong><%= records.size() %></strong> kết quả hiển thị</span>
                </div>

                <% if (records.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="empty-icon" aria-hidden="true">
                            <svg viewBox="0 0 48 48"><path d="M14 7h20a4 4 0 0 1 4 4v30H10V11a4 4 0 0 1 4-4Z"></path><path d="M18 4h12v7H18zM17 20h14M17 27h10"></path><circle cx="33" cy="34" r="8"></circle><path d="m39 40 5 5"></path></svg>
                        </span>
                        <h3><%= hasActiveFilter ? "Không tìm thấy ca khám phù hợp" : "Chưa có lịch sử khám" %></h3>
                        <p><%= hasActiveFilter
                                ? "Hãy thử thay đổi từ khóa hoặc khoảng thời gian để xem thêm kết quả."
                                : (isCustomer ? "Các kết quả khám của bạn sẽ được lưu và hiển thị tại đây."
                                    : "Chưa có ca khám hoàn tất nào trong phạm vi bạn được phép xem.") %></p>
                        <% if (hasActiveFilter) { %><a href="${pageContext.request.contextPath}/examination-history">Xóa toàn bộ bộ lọc</a><% } %>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th scope="col">Mã hồ sơ</th>
                                    <th scope="col">Thời gian khám</th>
                                    <% if (!isCustomer) { %><th scope="col">Khách hàng</th><% } %>
                                    <% if (!isDoctor) { %><th scope="col">Bác sĩ</th><% } %>
                                    <th scope="col">Dịch vụ</th>
                                    <th scope="col">Chẩn đoán</th>
                                    <th scope="col" class="action-column"><span class="sr-only">Chi tiết</span></th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (MedicalRecord record : records) {
                                LocalDate appointmentDate = record.getAppointmentDate();
                                LocalTime appointmentTime = record.getAppointmentTime();
                                if (appointmentDate == null && record.getCreatedAt() != null) {
                                    appointmentDate = record.getCreatedAt().toLocalDateTime().toLocalDate();
                                }
                                if (appointmentTime == null && record.getCreatedAt() != null) {
                                    appointmentTime = record.getCreatedAt().toLocalDateTime().toLocalTime();
                                }
                                String dateText = appointmentDate == null ? "Chưa cập nhật" : appointmentDate.format(dateFormatter);
                                String timeText = appointmentTime == null ? "" : appointmentTime.format(timeFormatter);
                                String patientName = textOr(record.getPatientName(), "Chưa cập nhật");
                                String doctorName = textOr(record.getDoctorName(), "Chưa phân công");
                                String phone = textOr(record.getCustomerPhone(), "Chưa cập nhật");
                                String serviceNames = textOr(record.getServiceNames(), "Chưa ghi nhận");
                                String diagnosis = textOr(record.getDiagnosis(), "Chưa ghi nhận chẩn đoán");
                                String treatmentPlan = textOr(record.getTreatmentPlan(), "Chưa có hướng điều trị");
                                String appointmentNotes = textOr(record.getAppointmentNotes(), "Không có ghi chú");
                                String detailsId = "record-details-" + record.getRecordID();
                            %>
                                <tr class="record-row">
                                    <td data-label="Mã hồ sơ"><span class="record-code">HS-<%= String.format("%04d", record.getRecordID()) %></span><small>Lịch hẹn #<%= record.getAppointmentID() %></small></td>
                                    <td data-label="Thời gian khám"><strong class="date-value"><%= html(dateText) %></strong><span class="time-value"><%= html(timeText.isEmpty() ? "Không rõ giờ" : timeText) %></span></td>
                                    <% if (!isCustomer) { %>
                                        <td data-label="Khách hàng"><strong class="person-name"><%= html(patientName) %></strong><span class="person-meta"><%= html(phone) %></span></td>
                                    <% } %>
                                    <% if (!isDoctor) { %>
                                        <td data-label="Bác sĩ"><strong class="person-name"><%= html(doctorName) %></strong><span class="person-meta">Bác sĩ phụ trách</span></td>
                                    <% } %>
                                    <td data-label="Dịch vụ"><span class="service-badge"><%= html(serviceNames) %></span></td>
                                    <td data-label="Chẩn đoán"><span class="diagnosis-preview" title="<%= html(diagnosis) %>"><%= html(diagnosis) %></span></td>
                                    <td data-label="Chi tiết" class="action-cell">
                                        <button class="detail-button" type="button" aria-expanded="false" aria-controls="<%= detailsId %>" data-details-target="<%= detailsId %>">
                                            <span>Xem chi tiết</span>
                                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
                                        </button>
                                    </td>
                                </tr>
                                <tr class="record-detail-row" id="<%= detailsId %>" hidden>
                                    <td colspan="<%= isStaff ? 7 : 6 %>">
                                        <div class="record-detail-panel">
                                            <div class="detail-panel-heading">
                                                <div><span>KẾT QUẢ KHÁM</span><h3>Hồ sơ HS-<%= String.format("%04d", record.getRecordID()) %></h3></div>
                                                <span class="completed-badge"><i aria-hidden="true">✓</i> Đã khám</span>
                                            </div>
                                            <div class="detail-grid">
                                                <section class="detail-section clinical-section">
                                                    <h4><span aria-hidden="true">✚</span> Thông tin chuyên môn</h4>
                                                    <div class="detail-item"><span>Chẩn đoán</span><p><%= html(diagnosis) %></p></div>
                                                    <div class="detail-item"><span>Hướng điều trị</span><p><%= html(treatmentPlan) %></p></div>
                                                </section>
                                                <section class="detail-section appointment-section">
                                                    <h4><span aria-hidden="true">▦</span> Thông tin buổi khám</h4>
                                                    <dl>
                                                        <% if (isCustomer) { %><div><dt>Bác sĩ</dt><dd><%= html(doctorName) %></dd></div><% } %>
                                                        <% if (isDoctor) { %><div><dt>Khách hàng</dt><dd><%= html(patientName) %> · <%= html(phone) %></dd></div><% } %>
                                                        <% if (isStaff) { %><div><dt>Khách hàng</dt><dd><%= html(patientName) %> · <%= html(phone) %></dd></div><div><dt>Bác sĩ</dt><dd><%= html(doctorName) %></dd></div><% } %>
                                                        <div><dt>Thời gian</dt><dd><%= html(dateText) %><%= timeText.isEmpty() ? "" : " lúc " + html(timeText) %></dd></div>
                                                        <div><dt>Dịch vụ</dt><dd><%= html(serviceNames) %></dd></div>
                                                        <div><dt>Ghi chú lịch hẹn</dt><dd><%= html(appointmentNotes) %></dd></div>
                                                    </dl>
                                                </section>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </section>

            <p class="privacy-note"><span aria-hidden="true">⌾</span> Thông tin lịch sử khám được giới hạn theo đúng quyền truy cập của tài khoản <%= html(roleLabel.toLowerCase()) %>.</p>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/examination-history.js"></script>
</body>
</html>
