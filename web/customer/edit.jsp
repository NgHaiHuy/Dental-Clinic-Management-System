<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sửa lịch hẹn</title>
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
                    <h1>Sửa lịch hẹn</h1>
                    <p class="hint">Chỉ có thể sửa lịch đang chờ xác nhận.</p>
                </div>
                <a class="link" href="${pageContext.request.contextPath}/customer/history">Quay lại danh sách</a>
            </div>

            <section class="panel">
                <c:if test="${not empty errors}">
                    <div class="alert alert-error">
                        <strong>Vui lòng kiểm tra lại thông tin lịch hẹn.</strong>
                        <ul>
                            <c:forEach var="error" items="${errors}">
                                <li><c:out value="${error}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <c:if test="${not empty form}">
                    <form action="${pageContext.request.contextPath}/customer/booking/edit" method="post">
                        <input type="hidden" name="appointmentId" value="${appointmentId}">

                        <div class="grid">
                            <div class="field">
                                <label for="doctorId">Bác sĩ</label>
                                <select id="doctorId" name="doctorId" required>
                                    <option value="">-- Chọn bác sĩ --</option>
                                    <c:forEach var="doctor" items="${doctorOptions}">
                                        <c:choose>
                                            <c:when test="${selectedDoctorId eq doctor.key}">
                                                <option value="${doctor.key}" selected="selected">
                                                    <c:out value="${doctor.value}"/>
                                                </option>
                                            </c:when>
                                            <c:otherwise>
                                                <option value="${doctor.key}">
                                                    <c:out value="${doctor.value}"/>
                                                </option>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="field">
                                <label for="appointmentDate">Ngày khám</label>
                                <input type="date"
                                       id="appointmentDate"
                                       name="appointmentDate"
                                       min="${today}"
                                       value="${form.appointmentDate}"
                                       required>
                            </div>

                            <div class="field">
                                <label for="appointmentTime">Giờ khám</label>
                                <select id="appointmentTime" name="appointmentTime" required>
                                    <option value="">-- Chọn giờ khám --</option>
                                    <c:forEach var="timeSlot" items="${appointmentTimeOptions}">
                                        <c:choose>
                                            <c:when test="${selectedAppointmentTime eq timeSlot.key}">
                                                <option value="${timeSlot.key}" selected="selected">
                                                    <c:out value="${timeSlot.value}"/>
                                                </option>
                                            </c:when>
                                            <c:otherwise>
                                                <option value="${timeSlot.key}">
                                                    <c:out value="${timeSlot.value}"/>
                                                </option>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </select>
                            </div>

                            <fieldset class="field-full">
                                <legend>Dịch vụ</legend>
                                <div class="checkbox-grid">
                                    <c:forEach var="service" items="${serviceOptions}">
                                        <label class="checkbox-option">
                                            <c:choose>
                                                <c:when test="${not empty selectedServiceLookup[service.key]}">
                                                    <input type="checkbox"
                                                           name="serviceIds"
                                                           value="${service.key}"
                                                           checked="checked">
                                                </c:when>
                                                <c:otherwise>
                                                    <input type="checkbox"
                                                           name="serviceIds"
                                                           value="${service.key}">
                                                </c:otherwise>
                                            </c:choose>
                                            <span><c:out value="${service.value}"/></span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </fieldset>

                            <div class="field field-full">
                                <label for="notes">Ghi chú</label>
                                <textarea id="notes"
                                          name="notes"
                                          maxlength="500"
                                          placeholder="Nhập ghi chú nếu có"><c:out value="${form.notes}"/></textarea>
                            </div>
                        </div>

                        <div class="actions">
                            <button type="submit">Lưu thay đổi</button>
                            <a class="link" href="${pageContext.request.contextPath}/customer/booking/detail?id=${appointmentId}">
                                Hủy chỉnh sửa
                            </a>
                        </div>
                    </form>
                </c:if>
            </section>
        </main>
    </body>
</html>
