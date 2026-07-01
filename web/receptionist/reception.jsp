<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Appointment"%>

<%
    List<Appointment> list = (List<Appointment>) request.getAttribute("list");
%>
<h2>Today's Appointments</h2>
<table border="1">
    <tr>
        <th>ID</th>
        <th>Customer</th>
        <th>Doctor</th>
        <th>Date</th>
        <th>Time</th>
        <th>Status</th>
    </tr>
<%
if(list!=null){
    for(Appointment a:list){
%>
<tr>
    <td><%=a.getAppointmentID()%></td>
    <td><%=a.getCustomerID()%></td>
    <td><%=a.getDoctorID()%></td>
    <td><%=a.getAppointmentDate()%></td>
    <td><%=a.getAppointmentTime()%></td>
    <td><%=a.getStatus()%></td>
</tr>
<%
    }
}
%>
</table>