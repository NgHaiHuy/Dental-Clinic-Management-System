<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>New Appointment</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
    </head>
    <body style="background:#f5f5f5;">
        <div class="container mt-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h3>Create New Appointment</h3>
                </div>
                <div class="card-body">
                    <form action="saveAppointment" method="post">
                        <!-- Customer -->
                        <div class="mb-3">
                            <label class="form-label">
                                Customer
                            </label>
                            <select name="customerID"
                                    class="form-select"
                                    required>
                                <option value="">
                                    Select Customer
                                </option>
                                <c:forEach items="${customers}" var="c">
                                    <option value="${c.userID}">
                                        ${c.fullName}
                                        -
                                        ${c.phone}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <!-- Doctor -->
                        <div class="mb-3">
                            <label class="form-label">
                                Doctor
                            </label>
                            <select name="doctorID" class="form-select" required>
                                <option value="">
                                    Select Doctor
                                </option>
                                <c:forEach items="${doctors}" var="d">
                                    <option value="${d.userID}">
                                        ${d.fullName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <!-- Date -->
                        <div class="mb-3">
                            <label class="form-label">
                                Appointment Date
                            </label>
                            <input type="date" name="date" class="form-control" required>
                        </div>
                        <!-- Time -->
                        <div class="mb-3">
                            <label class="form-label">
                                Appointment Time
                            </label>
                            <input type="time" name="time" class="form-control" required>
                        </div>
                        <!-- Notes -->
                        <div class="mb-3">
                            <label class="form-label">
                                Notes
                            </label>
                            <textarea name="notes" rows="3" class="form-control"></textarea>
                        </div>
                        <!-- Services -->
                        <div class="mb-3">
                            <label class="form-label">
                                Select Services
                            </label>
                            <div class="border rounded p-3">
                                <c:forEach items="${services}" var="s">
                                    <div class="form-check">
                                        <input
                                            type="checkbox"
                                            class="form-check-input service"
                                            name="serviceID"
                                            value="${s.serviceID}"
                                            data-price="${s.price}">
                                        <label class="form-check-label">
                                            ${s.serviceName}
                                            -
                                            $${s.price}
                                        </label>
                                    </div>
                                </c:forEach>
                                <hr>
                                <h5>
                                    Total :
                                    <span id="total">
                                        $0
                                    </span>
                                </h5>
                            </div>
                        </div>
                        <!-- Error -->
                        <c:if test="${requestScope.error!=null}">
                            <div class="alert alert-danger">
                                ${error}
                            </div>
                        </c:if>
                        <!-- Button -->
                        <div class="text-center">
                            <button class="btn btn-success">
                                Save Appointment
                            </button>
                            <a href="reception"
                               class="btn btn-secondary">
                                Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script>
            const services = document.querySelectorAll(".service");
            const total = document.getElementById("total");
            function calculate() {
                let sum = 0;
                services.forEach(s => {
                    if (s.checked) {
                        sum += parseFloat(s.dataset.price);
                    }
                });
                total.innerHTML = "$" + sum.toFixed(2);
            }
            services.forEach(s => {
                s.addEventListener("change", calculate);
            });
        </script>
    </body>
</html>