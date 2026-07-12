package dal;

import context.DBContext;
import java.util.List;
import model.Appointment;
import org.apache.tomcat.dbcp.dbcp2.SQLExceptionList;
import java.sql.*;
import java.util.ArrayList;

/**
 * Data Access Object for Appointments.
 */
public class AppointmentDAO extends DBContext {

    // Basic skeleton.
    // Lấy danh sách lịch hẹn chờ khám hôm nay của bác sĩ
    public List<Appointment> getWaitingAppointmentToday(int doctorID) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, a.AppointmentTime, a.Status, a.Notes, "
                + "u.FullName AS PatientName, u.Phone AS PatientPhone "
                + "FROM Appointments a "
                + "JOIN Users u ON a.CustomerID = u.UserID "
                + "WHERE a.AppointmentDate = CAST(GETDATE() AS DATE) "
                + "AND a.Status IN ('Pending', 'Confirmed') "
                + "AND (a.DoctorID = ? OR a.DoctorID IS NULL) "
                + "ORDER BY a.AppointmentTime ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, doctorID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment a = new Appointment();
                    a.setAppointmentID(rs.getInt("AppointmentID"));
                    a.setCustomerID(rs.getInt("CustomerID"));
                    a.setDoctorID(rs.getInt("DoctorID"));
                    a.setAppointmentDate(rs.getDate("AppointmentDate"));
                    a.setAppointmentTime(rs.getTime("AppointmentTime"));
                    a.setStatus(rs.getString("Status"));
                    a.setNotes(rs.getString("Notes"));
                    a.setPatientName(rs.getString("PatientName"));
                    a.setPatientPhone(rs.getString("PatientPhone"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật trạng thái lịch hẹn
    public boolean updateStatus(int appointmentId, String status) {
        String sql = "UPDATE Appointments SET Status = ? WHERE AppointmentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }
    
        public int insertMedicalRecord(int appointmentID, int doctorID, String diagnosis, String treatmentPlan) throws SQLException {
        String sql = "INSERT INTO MedicalRecords (AppointmentID, DoctorID, Diagnosis, TreatmentPlan, CreatedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, appointmentID);
            ps.setInt(2, doctorID);
            ps.setString(3, diagnosis);
            ps.setString(4, treatmentPlan);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // Trả về RecordID vừa tạo tự động
                }
            }
        }
        return -1;
    }
}
