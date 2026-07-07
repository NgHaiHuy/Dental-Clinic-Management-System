<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.LinkedHashSet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Set"%>
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

    private String selected(String value, Integer optionId) {
        return String.valueOf(optionId).equals(value) ? " selected" : "";
    }

    private String selected(String value, String optionValue) {
        return optionValue != null && optionValue.equals(value) ? " selected" : "";
    }

    private String checked(Set<Integer> selectedServiceIds, Integer serviceId) {
        return selectedServiceIds != null && selectedServiceIds.contains(serviceId) ? " checked" : "";
    }
%>
<%
    Map<Integer, String> doctorOptions = (Map<Integer, String>) request.getAttribute("doctorOptions");
    if (doctorOptions == null) {
        doctorOptions = new LinkedHashMap<>();
    }

    Map<Integer, String> serviceOptions = (Map<Integer, String>) request.getAttribute("serviceOptions");
    if (serviceOptions == null) {
        serviceOptions = new LinkedHashMap<>();
    }

    Map<String, String> appointmentTimeOptions = (Map<String, String>) request.getAttribute("appointmentTimeOptions");
    if (appointmentTimeOptions == null) {
        appointmentTimeOptions = new LinkedHashMap<>();
    }

    Map<String, String> form = (Map<String, String>) request.getAttribute("form");
    if (form == null) {
        form = new HashMap<>();
    }

    Set<Integer> selectedServiceIds = (Set<Integer>) request.getAttribute("selectedServiceIds");
    if (selectedServiceIds == null) {
        selectedServiceIds = new LinkedHashSet<>();
    }

    List<String> errors = (List<String>) request.getAttribute("errors");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt lịch khám</title>
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
                width: min(920px, calc(100% - 32px));
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
                padding: 24px;
            }

            .alert {
                border-radius: 8px;
                margin-bottom: 20px;
                padding: 14px 16px;
            }

            .alert-error {
                background: #fff1f0;
                border: 1px solid #ffccc7;
                color: #a8071a;
            }

            .alert ul {
                margin: 8px 0 0;
                padding-left: 20px;
            }

            .grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 18px;
            }

            .field {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .field-full {
                grid-column: 1 / -1;
            }

            label,
            legend {
                font-weight: 700;
            }

            select,
            input,
            textarea {
                width: 100%;
                border: 1px solid #c7d0dd;
                border-radius: 6px;
                padding: 10px 12px;
                font: inherit;
            }

            textarea {
                min-height: 110px;
                resize: vertical;
            }

            fieldset {
                border: 1px solid #dfe5ee;
                border-radius: 8px;
                margin: 0;
                padding: 16px;
            }

            .checkbox-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 10px 18px;
                margin-top: 12px;
            }

            .checkbox-option {
                display: flex;
                gap: 8px;
                align-items: center;
                font-weight: 400;
            }

            .checkbox-option input {
                width: auto;
            }

            .actions {
                display: flex;
                gap: 12px;
                align-items: center;
                margin-top: 22px;
            }

            button {
                border: 0;
                border-radius: 6px;
                background: #0b66c3;
                color: #fff;
                cursor: pointer;
                font: inherit;
                font-weight: 700;
                padding: 11px 18px;
            }

            button:hover {
                background: #0957a7;
            }

            @media (max-width: 680px) {
                .page-header,
                .grid,
                .checkbox-grid,
                .actions {
                    grid-template-columns: 1fr;
                    flex-direction: column;
                    align-items: stretch;
                }
            }
        </style>
    </head>
    <body>
        <main class="page">
            <div class="page-header">
                <div>
                    <h1>Đặt lịch khám nha khoa</h1>
                    <p class="hint">Khung giờ nhận lịch: <%= h(request.getAttribute("clinicOpenTime")) %> - <%= h(request.getAttribute("clinicCloseTime")) %>.</p>
                </div>
                <a class="link" href="${pageContext.request.contextPath}/customer/history">Xem lịch đã đặt</a>
            </div>

            <section class="panel">
                <% if (errors != null && !errors.isEmpty()) { %>
                <div class="alert alert-error">
                    <strong>Vui lòng kiểm tra lại thông tin đặt lịch.</strong>
                    <ul>
                        <% for (String error : errors) { %>
                        <li><%= h(error) %></li>
                        <% } %>
                    </ul>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/customer/booking" method="post">
                    <div class="grid">
                        <div class="field">
                            <label for="doctorId">Bác sĩ</label>
                            <select id="doctorId" name="doctorId" required>
                                <option value="">-- Chọn bác sĩ --</option>
                                <% for (Map.Entry<Integer, String> doctor : doctorOptions.entrySet()) { %>
                                <option value="<%= doctor.getKey() %>"<%= selected(form.get("doctorId"), doctor.getKey()) %>>
                                    <%= h(doctor.getValue()) %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="field">
                            <label for="appointmentDate">Ngày khám</label>
                            <input type="date"
                                   id="appointmentDate"
                                   name="appointmentDate"
                                   min="<%= h(request.getAttribute("today")) %>"
                                   value="<%= h(form.get("appointmentDate")) %>"
                                   required>
                        </div>

                        <div class="field">
                            <label for="appointmentTime">Giờ khám</label>
                            <select id="appointmentTime" name="appointmentTime" required>
                                <option value="">-- Chọn giờ khám --</option>
                                <% for (Map.Entry<String, String> timeSlot : appointmentTimeOptions.entrySet()) { %>
                                <option value="<%= h(timeSlot.getKey()) %>"<%= selected(form.get("appointmentTime"), timeSlot.getKey()) %>>
                                    <%= h(timeSlot.getValue()) %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <fieldset class="field-full">
                            <legend>Dịch vụ</legend>
                            <div class="checkbox-grid">
                                <% for (Map.Entry<Integer, String> service : serviceOptions.entrySet()) { %>
                                <label class="checkbox-option">
                                    <input type="checkbox"
                                           name="serviceIds"
                                           value="<%= service.getKey() %>"
                                           <%= checked(selectedServiceIds, service.getKey()) %>>
                                    <span><%= h(service.getValue()) %></span>
                                </label>
                                <% } %>
                            </div>
                        </fieldset>

                        <div class="field field-full">
                            <label for="notes">Ghi chú</label>
                            <textarea id="notes"
                                      name="notes"
                                      maxlength="500"
                                      placeholder="Nhập ghi chú nếu có"><%= h(form.get("notes")) %></textarea>
                        </div>
                    </div>

                    <div class="actions">
                        <button type="submit">Đặt lịch</button>
                        <a class="link" href="${pageContext.request.contextPath}/customer/history">Quay lại lịch đã đặt</a>
                    </div>
                </form>
            </section>
        </main>
    </body>
</html>
