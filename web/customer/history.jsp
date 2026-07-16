<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.Map, model.Appointment, model.MedicalRecord, model.PrescriptionDetail"%>
<%
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    List<MedicalRecord> records = (List<MedicalRecord>) request.getAttribute("records");
    Map<Integer, List<PrescriptionDetail>> recordMedicines = (Map<Integer, List<PrescriptionDetail>>) request.getAttribute("recordMedicines");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lịch Sử Khám Bệnh</title>
    </head>
    <body>
        <h1>Lịch Sử Khám Răng và Đặt Lịch của Bạn</h1>
        
        <p><a href="<%= request.getContextPath() %>/customer/dashboard">Quay lại Dashboard</a></p>
        
        <h2>1. Danh sách lịch hẹn đã đặt</h2>
        <table border="1" cellpadding="5" cellspacing="0">
            <thead>
                <tr>
                    <th>Mã Lịch Hẹn</th>
                    <th>Ngày Khám</th>
                    <th>Giờ Khám</th>
                    <th>Bác sĩ</th>
                    <th>Trạng thái</th>
                    <th>Ghi chú</th>
                </tr>
            </thead>
            <tbody>
                <% if (appointments == null || appointments.isEmpty()) { %>
                    <tr>
                        <td colspan="6">Bạn chưa đặt lịch hẹn nào.</td>
                    </tr>
                <% } else {
                    for (Appointment app : appointments) { %>
                        <tr>
                            <td>#<%= app.getAppointmentID() %></td>
                            <td><%= app.getAppointmentDate() %></td>
                            <td><%= app.getAppointmentTime() %></td>
                            <td><%= app.getDoctorName() %></td>
                            <td><strong><%= app.getStatus() %></strong></td>
                            <td><%= app.getNotes() != null ? app.getNotes() : "" %></td>
                        </tr>
                    <% }
                } %>
            </tbody>
        </table>
        
        <br><hr><br>
        
        <h2>2. Lịch sử bệnh án & kết quả khám</h2>
        <% if (records == null || records.isEmpty()) { %>
            <p>Chưa có thông tin bệnh án được ghi nhận.</p>
        <% } else {
            for (MedicalRecord mr : records) { %>
                <table border="1" cellpadding="5" cellspacing="0" style="margin-bottom: 20px; width: 100%;">
                    <tr>
                        <th width="200" align="left">Mã bệnh án:</th>
                        <td>#<%= mr.getRecordID() %> (Thời gian: <%= mr.getCreatedAt() %>)</td>
                    </tr>
                    <tr>
                        <th align="left">Bác sĩ khám:</th>
                        <td><%= mr.getDoctorName() %></td>
                    </tr>
                    <tr>
                        <th align="left">Chẩn đoán:</th>
                        <td><%= mr.getDiagnosis() %></td>
                    </tr>
                    <tr>
                        <th align="left">Kế hoạch điều trị:</th>
                        <td><%= mr.getTreatmentPlan() != null ? mr.getTreatmentPlan() : "N/A" %></td>
                    </tr>
                    <tr>
                        <th align="left">Thuốc được kê:</th>
                        <td>
                            <% 
                                List<PrescriptionDetail> meds = recordMedicines.get(mr.getRecordID());
                                if (meds == null || meds.isEmpty()) {
                            %>
                                Không kê đơn thuốc.
                            <% } else { %>
                                <ul>
                                    <% for (PrescriptionDetail m : meds) { %>
                                        <li>
                                            <strong><%= m.getMedicineName() %></strong> 
                                            - Số lượng: <%= m.getQuantity() %> <%= m.getUnit() %> 
                                            (Cách dùng: <%= m.getDosage() %>)
                                        </li>
                                    <% } %>
                                </ul>
                            <% } %>
                        </td>
                    </tr>
                </table>
            <% }
        } %>
    </body>
</html>
