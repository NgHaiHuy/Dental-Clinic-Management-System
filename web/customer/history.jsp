<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.Appointment"%>
<%!
    private String h(Object value) {
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

    private String doctorName(Appointment appointment, Map<Integer, String> doctorOptions) {
        if (appointment == null || appointment.getDoctorId() == null) {
            return "";
        }

        String doctorName = doctorOptions == null ? null : doctorOptions.get(appointment.getDoctorId());
        return doctorName == null ? "Doctor ID: " + appointment.getDoctorId() : doctorName;
    }

    private String serviceSummary(Appointment appointment, Map<Integer, String> serviceOptions) {
        if (appointment == null || appointment.getServiceIds() == null || appointment.getServiceIds().isEmpty()) {
            return "Chưa chọn";
        }

        StringBuilder summary = new StringBuilder();
        for (Integer serviceId : appointment.getServiceIds()) {
            if (summary.length() > 0) {
                summary.append(", ");
            }
            String serviceName = serviceOptions == null ? null : serviceOptions.get(serviceId);
            summary.append(serviceName == null ? "Service ID: " + serviceId : serviceName);
        }
        return summary.toString();
    }

    private String statusLabel(String status) {
        if ("Pending".equals(status)) {
            return "Chờ xác nhận";
        }
        if ("Confirmed".equals(status)) {
            return "Đã xác nhận";
        }
        if ("Attended".equals(status)) {
            return "Đã khám";
        }
        if ("Cancelled".equals(status)) {
            return "Đã hủy";
        }
        return status == null ? "" : status;
    }

    private String statusClass(String status) {
        if ("Cancelled".equals(status)) {
            return "status status-cancelled";
        }
        if ("Confirmed".equals(status)) {
            return "status status-confirmed";
        }
        if ("Attended".equals(status)) {
            return "status status-attended";
        }
        return "status status-pending";
    }

    private boolean canCancel(Appointment appointment) {
        return appointment != null && "Pending".equals(appointment.getStatus());
    }

    private String formatTime(Appointment appointment) {
        if (appointment == null || appointment.getAppointmentTime() == null) {
            return "";
        }
        return appointment.getAppointmentTime().toLocalTime().toString();
    }
%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) {
        appointments = (List<Appointment>) session.getAttribute("customerAppointments");
    }

    Map<Integer, String> doctorOptions = (Map<Integer, String>) request.getAttribute("doctorOptions");
    if (doctorOptions == null) {
        doctorOptions = new LinkedHashMap<>();
    }

    Map<Integer, String> serviceOptions = (Map<Integer, String>) request.getAttribute("serviceOptions");
    if (serviceOptions == null) {
        serviceOptions = new LinkedHashMap<>();
    }

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lịch đã đặt</title>
        <style>
            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                font-family: Arial, sans-serif;
                background: #f6f8fb;
                color: #172033;
            }

            .page {
                width: min(1100px, calc(100% - 32px));
                margin: 32px auto;
            }

            .page-header {
                display: flex;
                justify-content: space-between;
                gap: 16px;
                align-items: flex-start;
                margin-bottom: 20px;
            }

            h1 {
                margin: 0 0 8px;
                font-size: 30px;
            }

            .hint {
                margin: 0;
                color: #5d687a;
            }

            .link {
                color: #075db3;
                font-weight: 700;
                text-decoration: none;
            }

            .link:hover {
                text-decoration: underline;
            }

            .panel {
                background: #fff;
                border: 1px solid #dfe5ee;
                border-radius: 8px;
                overflow: hidden;
            }

            .alert {
                border-radius: 8px;
                margin-bottom: 16px;
                padding: 14px 16px;
            }

            .alert-success {
                background: #f0fff4;
                border: 1px solid #b7ebc6;
                color: #135200;
            }

            .alert-error {
                background: #fff1f0;
                border: 1px solid #ffccc7;
                color: #a8071a;
            }

            .empty {
                padding: 28px;
                text-align: center;
            }

            .table-wrap {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 900px;
            }

            th,
            td {
                border-bottom: 1px solid #e8edf4;
                padding: 13px 14px;
                text-align: left;
                vertical-align: top;
            }

            th {
                background: #f0f4f9;
                font-size: 14px;
            }

            .status {
                border-radius: 999px;
                display: inline-block;
                font-size: 13px;
                font-weight: 700;
                padding: 5px 10px;
                white-space: nowrap;
            }

            .status-pending {
                background: #fff7e6;
                color: #ad6800;
            }

            .status-confirmed {
                background: #e6f4ff;
                color: #0958d9;
            }

            .status-attended {
                background: #f0fff4;
                color: #135200;
            }

            .status-cancelled {
                background: #f5f5f5;
                color: #595959;
            }

            .cancel-form {
                margin: 0;
            }

            .cancel-button {
                border: 1px solid #ff7875;
                border-radius: 6px;
                background: #fff;
                color: #cf1322;
                cursor: pointer;
                font: inherit;
                font-weight: 700;
                padding: 7px 12px;
            }

            .cancel-button:hover {
                background: #fff1f0;
            }

            @media (max-width: 680px) {
                .page-header {
                    flex-direction: column;
                }
            }
        </style>
    </head>
    <body>
        <main class="page">
            <div class="page-header">
                <div>
                    <h1>Lịch khám đã đặt</h1>
                    <p class="hint">Danh sách lịch trong phiên làm việc hiện tại.</p>
                </div>
                <a class="link" href="${pageContext.request.contextPath}/customer/booking">Đặt lịch mới</a>
            </div>

            <% if (successMessage != null && !successMessage.isBlank()) { %>
            <div class="alert alert-success"><%= h(successMessage) %></div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
            <div class="alert alert-error"><%= h(errorMessage) %></div>
            <% } %>

            <section class="panel">
                <% if (appointments == null || appointments.isEmpty()) { %>
                <div class="empty">
                    <p>Bạn chưa có lịch đặt nào.</p>
                    <a class="link" href="${pageContext.request.contextPath}/customer/booking">Đặt lịch khám đầu tiên</a>
                </div>
                <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>Bác sĩ</th>
                                <th>Dịch vụ</th>
                                <th>Ngày khám</th>
                                <th>Giờ khám</th>
                                <th>Trạng thái</th>
                                <th>Ghi chú</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < appointments.size(); i++) {
                                    Appointment appointment = appointments.get(i);
                            %>
                            <tr>
                                <td><%= i + 1 %></td>
                                <td><%= h(doctorName(appointment, doctorOptions)) %></td>
                                <td><%= h(serviceSummary(appointment, serviceOptions)) %></td>
                                <td><%= h(appointment.getAppointmentDate()) %></td>
                                <td><%= h(formatTime(appointment)) %></td>
                                <td>
                                    <span class="<%= h(statusClass(appointment.getStatus())) %>">
                                        <%= h(statusLabel(appointment.getStatus())) %>
                                    </span>
                                </td>
                                <td><%= h(appointment.getNotes()) %></td>
                                <td>
                                    <% if (canCancel(appointment)) { %>
                                    <form class="cancel-form"
                                          action="${pageContext.request.contextPath}/customer/booking/cancel"
                                          method="post"
                                          onsubmit="return confirm('Bạn chắc chắn muốn hủy lịch này?');">
                                        <input type="hidden" name="appointmentId" value="<%= appointment.getAppointmentId() %>">
                                        <button class="cancel-button" type="submit">Hủy</button>
                                    </form>
                                    <% } else { %>
                                    <span class="hint">Không có</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </section>
        </main>
    </body>
</html>
