<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Appointment Detail</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
    </head>
    <body style="background:#f4f6f9;">
        <div class="container mt-4">
            <h2 class="text-primary mb-4">
                Appointment Detail
            </h2>
            <!-- Appointment -->
            <div class="card shadow mb-4">
                <div class="card-header bg-primary text-white">
                    Appointment Information
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <p>
                                <b>Appointment ID:</b>
                                ${appointment.appointmentID}
                            </p>
                            <p>
                                <b>Date:</b>
                                ${appointment.appointmentDate}
                            </p>
                            <p>
                                <b>Time:</b>
                                ${appointment.appointmentTime}
                            </p>
                        </div>
                        <div class="col-md-6">
                            <p>
                                <b>Status:</b>
                                <c:choose>
                                    <c:when test="${appointment.status=='Pending'}">
                                        <span class="badge bg-warning">
                                            Pending
                                        </span>
                                    </c:when>
                                    <c:when test="${appointment.status=='Attended'}">
                                        <span class="badge bg-success">
                                            Attended
                                        </span>
                                    </c:when>
                                    <c:when test="${appointment.status=='Cancelled'}">
                                        <span class="badge bg-danger">
                                            Cancelled
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">
                                            ${appointment.status}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <p>
                                <b>Notes:</b>
                                ${appointment.notes}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Customer -->
            <div class="card shadow mb-4">
                <div class="card-header bg-success text-white">
                    Customer Information
                </div>
                <div class="card-body">
                    <p>
                        <b>Name:</b>
                        ${appointment.customerName}
                    </p>
                    <p>
                        <b>Phone:</b>
                        ${appointment.customerPhone}
                    </p>
                    <p>
                        <b>Gender:</b>
                        ${appointment.customerGender}
                    </p>
                    <p>
                        <b>Date of Birth:</b>
                        ${appointment.customerDOB}
                    </p>
                    <p>
                        <b>Address:</b>
                        ${appointment.customerAddress}
                    </p>
                </div>
            </div>
            <!-- Doctor -->
            <div class="card shadow mb-4">
                <div class="card-header bg-info text-white">
                    Doctor Information
                </div>
                <div class="card-body">
                    <p>
                        <b>Name:</b>
                        ${appointment.doctorName}
                    </p>
                    <p>
                        <b>Phone:</b>
                        ${appointment.doctorPhone}
                    </p>
                    <p>
                        <b>Specialization:</b>
                        ${appointment.doctorSpecialization}
                    </p>
                </div>
            </div>
            <!-- Services -->
            <div class="card shadow mb-4">
                <div class="card-header bg-dark text-white">
                    Selected Services
                </div>
                <div class="card-body">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Service</th>
                                <th>Price</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${services}" var="s">
                                <tr>
                                    <td>${s.serviceID}</td>
                                    <td>${s.serviceName}</td>
                                    <td>
                                        $${s.price}
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty services}">
                                <tr>
                                    <td colspan="3" class="text-center">
                                        No service selected.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- Total -->
            <div class="alert alert-warning">
                <h4>
                    Total Service Cost :
                    <span class="text-danger">
                        $${totalPrice}
                    </span>
                </h4>
            </div>
            <!-- Button -->
            <a href="reception"
               class="btn btn-secondary">
                Back
            </a>
            <c:if test="${appointment.status=='Pending'}">
                <a href="checkin?id=${appointment.appointmentID}"
                   class="btn btn-success">
                    Check In
                </a>
            </c:if>
        </div>
    </body>
</html>