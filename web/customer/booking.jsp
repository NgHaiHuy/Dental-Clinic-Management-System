<%-- 
    Document   : booking
    Created on : May 14, 2026, 10:41:49 PM
    Author     : Nguye
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Đặt lịch khám</title>
    </head>
    <body>
        <h1>Đặt lịch khám nha khoa</h1>

        <form action="${pageContext.request.contextPath}/customer/booking" method="post">
            <div>
                <label for="doctorId">Chọn bác sĩ:</label>
                <select id="doctorId" name="doctorId" required>
                    <option value="">-- Chọn bác sĩ --</option>
                    <option value="1">BS. A</option>
                    <option value="2">BS. B</option>
                    <option value="3">BS. C</option>
                </select>
            </div>

            <br>

            <div>
                <label for="appointmentDate">Ngày khám:</label>
                <input type="date" id="appointmentDate" name="appointmentDate" required>
            </div>

            <br>

            <div>
                <label for="appointmentTime">Giờ khám:</label>
                <input type="time" id="appointmentTime" name="appointmentTime" required>
            </div>

            <br>

            <div>
                <p>Chọn dịch vụ:</p>

                <label>
                    <input type="checkbox" name="serviceIds" value="1">
                    Khám tổng quát
                </label>
                <br>

                <label>
                    <input type="checkbox" name="serviceIds" value="2">
                    Cạo vôi răng
                </label>
                <br>

                <label>
                    <input type="checkbox" name="serviceIds" value="3">
                    Trám răng
                </label>
                <br>

                <label>
                    <input type="checkbox" name="serviceIds" value="4">
                    Nhổ răng
                </label>
            </div>

            <br>

            <div>
                <label for="notes">Ghi chú:</label>
                <br>
                <textarea id="notes" name="notes" rows="4" cols="40"
                          placeholder="Nhập ghi chú nếu có"></textarea>
            </div>

            <br>

            <button type="submit">Đặt lịch</button>
        </form>

        <script>
            const dateInput = document.getElementById("appointmentDate");
            const today = new Date().toISOString().split("T")[0];
            dateInput.min = today;
        </script>
    </body>
</html>
