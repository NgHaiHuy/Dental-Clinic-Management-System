<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Appointment"%>
<%
    List<Appointment> list = (List<Appointment>) request.getAttribute("list");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Reception Dashboard</title>
    </head>
    <body>
        <h2>Today's Appointments</h2>
        <form action="reception" method="get">
            <input type="text" name="keyword"
                   placeholder="Search by ID, customer name, phone">
            <input type="submit" value="Search">
        </form>
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Customer</th>
                <th>Doctor</th>
                <th>Date</th>
                <th>Time</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <%
            if(list!=null){
            for(Appointment a:list){
            %>
            <tr>
                <td><%=a.getAppointmentID()%></td>
                <td><%=a.getCustomerName()%></td>
                <td><%=a.getDoctorName()%></td>
                <td><%=a.getAppointmentDate()%></td>
                <td><%=a.getAppointmentTime()%></td>
                <td><%=a.getStatus()%></td>
                <td>
                    <a href="checkIn?id=<%=a.getAppointmentID()%>">
                        Check In
                    </a>
                    <a href="newAppointment">
                        <button>New Appointment</button>
                    </a>
                </td>
            </tr>
            <%
                }
            }
            %>
        </table>
    </body>
</html>
