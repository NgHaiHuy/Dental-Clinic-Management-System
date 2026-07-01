/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Date;
import java.util.List;
import model.Appointment;
import java.sql.Time;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

/**
 *
 * @author Nguye
 */
public class AppointmentDAO extends DBContext {

    // 1. Lấy danh sách lịch hẹn trong ngày
    public List<Appointment> getTodayAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, "
                + "c.FullName AS CustomerName, "
                + "d.FullName AS DoctorName "
                + "FROM Appointments a "
                + "JOIN Users c ON a.CustomerID = c.UserID "
                + "LEFT JOIN Users d ON a.DoctorID = d.UserID "
                + "WHERE a.AppointmentDate = CAST(GETDATE() AS DATE) "
                + "ORDER BY a.AppointmentTime";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentID(rs.getInt("AppointmentID"));
                a.setCustomerID(rs.getInt("CustomerID"));
                a.setDoctorID(rs.getInt("DoctorID"));
                a.setAppointmentDate(rs.getDate("AppointmentDate"));
                a.setAppointmentTime(rs.getTime("AppointmentTime"));
                a.setStatus(rs.getString("Status"));
                a.setNotes(rs.getString("Notes"));
                a.setCustomerName(rs.getString("CustomerName"));
                a.setDoctorName(rs.getString("DoctorName"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;

    }

    // 2. Tìm kiếm lịch hẹn theo tên khách, số điện thoại hoặc mã lịch
    public List<Appointment> searchAppointment(String keyword) {
        List<Appointment> list = new ArrayList<>();
        String sql = """
    SELECT a.*,
           c.FullName AS CustomerName,
           d.FullName AS DoctorName
    FROM Appointments a
    JOIN Users c ON a.CustomerID = c.UserID
    LEFT JOIN Users d ON a.DoctorID = d.UserID
    WHERE CAST(a.AppointmentID AS VARCHAR) LIKE ?
       OR c.FullName LIKE ?
       OR c.Phone LIKE ?
    ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC
    """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String search = "%" + keyword + "%";
            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentID(rs.getInt("AppointmentID"));
                a.setCustomerID(rs.getInt("CustomerID"));
                a.setDoctorID(rs.getInt("DoctorID"));
                a.setAppointmentDate(rs.getDate("AppointmentDate"));
                a.setAppointmentTime(rs.getTime("AppointmentTime"));
                a.setStatus(rs.getString("Status"));
                a.setNotes(rs.getString("Notes"));
                a.setCustomerName(rs.getString("CustomerName"));
                a.setDoctorName(rs.getString("DoctorName"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Lấy chi tiết một lịch hẹn
    public Appointment getAppointmentById(int appointmentID) {
        String sql = "SELECT * FROM Appointments WHERE AppointmentID = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, appointmentID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentID(rs.getInt("AppointmentID"));
                a.setCustomerID(rs.getInt("CustomerID"));
                a.setDoctorID(rs.getInt("DoctorID"));
                a.setAppointmentDate(rs.getDate("AppointmentDate"));
                a.setAppointmentTime(rs.getTime("AppointmentTime"));
                a.setStatus(rs.getString("Status"));
                a.setNotes(rs.getString("Notes"));
                return a;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Đổi trạng thái lịch hẹn (Pending -> Attended)
    public boolean updateStatus(int appointmentID, String status) {
        String sql = "UPDATE Appointments SET Status=? WHERE AppointmentID=?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, appointmentID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. Kiểm tra bác sĩ có lịch trùng hay không
    public boolean isDoctorAvailable(int doctorID, Date date, Time time) {
        String sql = """
                 SELECT *
                 FROM Appointments
                 WHERE DoctorID=?
                 AND AppointmentDate=?
                 AND AppointmentTime=?
                 AND Status<>'Cancelled'
                 """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, doctorID);
            ps.setDate(2, date);
            ps.setTime(3, time);
            ResultSet rs = ps.executeQuery();
            return !rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Đặt lịch tại quầy
    public int insertAppointment(Appointment appointment) {
        String sql = """
        INSERT INTO Appointments
        (CustomerID,DoctorID,AppointmentDate,
         AppointmentTime,Status,Notes)
        VALUES(?,?,?,?,?,?)
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setInt(1, appointment.getCustomerID());
            ps.setInt(2, appointment.getDoctorID());
            ps.setDate(3, new java.sql.Date(appointment.getAppointmentDate().getTime()));
            ps.setTime(4, appointment.getAppointmentTime());
            ps.setString(5, appointment.getStatus());
            ps.setString(6, appointment.getNotes());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 7. Thêm dịch vụ cho lịch hẹn
    public boolean addAppointmentService(int appointmentID, int serviceID) {
        String sql = "INSERT INTO AppointmentServices VALUES(?,?)";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, appointmentID);
            ps.setInt(2, serviceID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
