<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
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

            .action-stack {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
            }

            .detail-link {
                border: 1px solid #91caff;
                border-radius: 6px;
                color: #0958d9;
                display: inline-block;
                font-weight: 700;
                padding: 7px 12px;
                text-decoration: none;
            }

            .detail-link:hover {
                background: #e6f4ff;
            }

            .edit-link {
                border: 1px solid #b7eb8f;
                border-radius: 6px;
                color: #237804;
                display: inline-block;
                font-weight: 700;
                padding: 7px 12px;
                text-decoration: none;
            }

            .edit-link:hover {
                background: #f6ffed;
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
                    <p class="hint">Danh sách lịch hẹn của bạn.</p>
                </div>
                <a class="link" href="${pageContext.request.contextPath}/customer/booking">Đặt lịch mới</a>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    <c:out value="${successMessage}"/>
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <section class="panel">
                <c:choose>
                    <c:when test="${empty appointments}">
                        <div class="empty">
                            <p>Bạn chưa có lịch đặt nào.</p>
                            <a class="link" href="${pageContext.request.contextPath}/customer/booking">Đặt lịch khám đầu tiên</a>
                        </div>
                    </c:when>
                    <c:otherwise>
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
                                    <c:forEach var="appointment" items="${appointments}" varStatus="loop">
                                        <c:set var="statusClass" value="status status-pending"/>
                                        <c:set var="statusLabel" value="${appointment.status}"/>

                                        <c:choose>
                                            <c:when test="${appointment.status eq 'Cancelled'}">
                                                <c:set var="statusClass" value="status status-cancelled"/>
                                                <c:set var="statusLabel" value="Đã hủy"/>
                                            </c:when>
                                            <c:when test="${appointment.status eq 'Confirmed'}">
                                                <c:set var="statusClass" value="status status-confirmed"/>
                                                <c:set var="statusLabel" value="Đã xác nhận"/>
                                            </c:when>
                                            <c:when test="${appointment.status eq 'Attended'}">
                                                <c:set var="statusClass" value="status status-attended"/>
                                                <c:set var="statusLabel" value="Đã khám"/>
                                            </c:when>
                                            <c:when test="${appointment.status eq 'Pending'}">
                                                <c:set var="statusLabel" value="Chờ xác nhận"/>
                                            </c:when>
                                        </c:choose>

                                        <tr>
                                            <td><c:out value="${loop.count}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty doctorOptions[appointment.doctorId]}">
                                                        <c:out value="${doctorOptions[appointment.doctorId]}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        Doctor ID: <c:out value="${appointment.doctorId}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${empty appointment.serviceIds}">
                                                        Chưa chọn
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="serviceId" items="${appointment.serviceIds}" varStatus="serviceLoop">
                                                            <c:if test="${not serviceLoop.first}">, </c:if>
                                                            <c:choose>
                                                                <c:when test="${not empty serviceOptions[serviceId]}">
                                                                    <c:out value="${serviceOptions[serviceId]}"/>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    Service ID: <c:out value="${serviceId}"/>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${appointment.appointmentDate}"/></td>
                                            <td>
                                                <c:if test="${not empty appointment.appointmentTime}">
                                                    <c:out value="${fn:substring(appointment.appointmentTime, 0, 5)}"/>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="${statusClass}">
                                                    <c:out value="${statusLabel}"/>
                                                </span>
                                            </td>
                                            <td><c:out value="${appointment.notes}"/></td>
                                            <td>
                                                <div class="action-stack">
                                                    <a class="detail-link"
                                                       href="${pageContext.request.contextPath}/customer/booking/detail?id=${appointment.appointmentId}">
                                                        Chi tiết
                                                    </a>
                                                    <c:if test="${appointment.status eq 'Pending'}">
                                                        <a class="edit-link"
                                                           href="${pageContext.request.contextPath}/customer/booking/edit?id=${appointment.appointmentId}">
                                                            Sửa
                                                        </a>
                                                        <form class="cancel-form"
                                                              action="${pageContext.request.contextPath}/customer/booking/cancel"
                                                              method="post"
                                                              onsubmit="return confirm('Bạn chắc chắn muốn hủy lịch này?');">
                                                            <input type="hidden" name="appointmentId" value="${appointment.appointmentId}">
                                                            <button class="cancel-button" type="submit">Hủy</button>
                                                        </form>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>
    </body>
</html>
