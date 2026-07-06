<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Reception Dashboard</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body{
                background:#f5f7fb;
            }
            .card{
                border:none;
                border-radius:12px;
            }
            .table{
                background:white;
            }
            .badge{
                font-size:14px;
                padding:8px 12px;
            }
        </style>
    </head>
    <body>
        <div class="container mt-4">
            <h2 class="mb-4 text-primary">
                Reception Dashboard
            </h2>
            <c:if test="${sessionScope.message!=null}">
                <div class="alert alert-info">
                    ${sessionScope.message}
                </div>
                <c:remove var="message" scope="session"/>
            </c:if>
            <!-- Statistics -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card bg-primary text-white shadow">
                        <div class="card-body text-center">
                            <h2>${totalAppointment}</h2>
                            Today's Appointments
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-warning text-white shadow">
                        <div class="card-body text-center">
                            <h2>${pending}</h2>
                            Pending
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-success text-white shadow">
                        <div class="card-body text-center">
                            <h2>${attended}</h2>
                            Attended
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-danger text-white shadow">
                        <div class="card-body text-center">
                            <h2>${cancelled}</h2>
                            Cancelled
                        </div>
                    </div>
                </div>
            </div>
            <!-- Search -->
            <div class="card shadow mb-3">
                <div class="card-body">
                    <form action="reception" method="get">
                        <div class="row">
                            <div class="col-md-9">
                                <input
                                    class="form-control"
                                    type="text"
                                    name="keyword"
                                    value="${param.keyword}"
                                    placeholder="Search by Appointment ID, Customer, Doctor or Phone">
                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-primary w-100">
                                    Search
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <!-- Button -->
            <div class="mb-3">
                <a href="newAppointment"
                   class="btn btn-success">
                    + New Appointment
                </a>
            </div>
            <!-- Appointment Table -->
            <table class="table table-bordered table-hover shadow">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Doctor</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Status</th>
                        <th width="170">
                            Action
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${list}" var="a">
                        <tr>
                            <td>${a.appointmentID}</td>
                            <td>${a.customerName}</td>
                            <td>${a.doctorName}</td>
                            <td>${a.appointmentDate}</td>
                            <td>${a.appointmentTime}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${a.status=='Pending'}">
                                        <span class="badge bg-warning">
                                            Pending
                                        </span>
                                    </c:when>
                                    <c:when test="${a.status=='Attended'}">
                                        <span class="badge bg-success">
                                            Attended
                                        </span>
                                    </c:when>
                                    <c:when test="${a.status=='Cancelled'}">
                                        <span class="badge bg-danger">
                                            Cancelled
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">
                                            ${a.status}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a href="appointmentDetail?id=${a.appointmentID}"
                                   class="btn btn-sm btn-primary">
                                    Detail
                                </a>
                                <c:choose>
                                    <c:when test="${a.status=='Pending'}">
                                        <a href="checkIn?id=${a.appointmentID}"
                                           class="btn btn-success btn-sm">
                                            Check In
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-secondary btn-sm"
                                                disabled>
                                            Checked
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty list}">
                        <tr>
                            <td colspan="7"
                                class="text-center text-danger">
                                No appointment found.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>