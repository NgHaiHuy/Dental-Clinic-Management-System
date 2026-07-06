package dal;

import dal.DBContext;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import model.Appointment;
import model.Service;

public class AppointmentDAO extends DBContext {

    // =========================
    // Mapping Appointment
    // =========================
    private Appointment mapAppointment(ResultSet rs) throws Exception {
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

    // =========================
    // Mapping Full Appointment
    // =========================
    private Appointment mapAppointmentFull(ResultSet rs) throws Exception {
        Appointment a = mapAppointment(rs);
        a.setCustomerName(rs.getString("CustomerName"));
        a.setCustomerPhone(rs.getString("CustomerPhone"));
        a.setDoctorName(rs.getString("DoctorName"));
        a.setDoctorPhone(rs.getString("DoctorPhone"));
        a.setDoctorSpecialization(rs.getString("Specialization"));
        return a;
    }

    // =========================
    // Today's Appointment
    // =========================
    public List<Appointment> getTodayAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = """
        SELECT
            a.*,
            c.FullName AS CustomerName,
            c.Phone AS CustomerPhone,
            d.FullName AS DoctorName,
            d.Phone AS DoctorPhone,
            di.Specialization
        FROM Appointments a
        JOIN Users c ON a.CustomerID = c.UserID
        LEFT JOIN Users d ON a.DoctorID = d.UserID
        LEFT JOIN DoctorInfo di ON d.UserID = di.DoctorID
        WHERE a.AppointmentDate = CAST(GETDATE() AS DATE)
        ORDER BY a.AppointmentTime
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapAppointmentFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================
    // Search Appointment
    // =========================
    public List<Appointment> searchAppointment(String keyword) {
        List<Appointment> list = new ArrayList<>();
        String sql = """
        SELECT
            a.*,
            c.FullName AS CustomerName,
            c.Phone AS CustomerPhone,
            d.FullName AS DoctorName,
            d.Phone AS DoctorPhone,
            di.Specialization
        FROM Appointments a
        JOIN Users c ON a.CustomerID = c.UserID
        LEFT JOIN Users d ON a.DoctorID = d.UserID
        LEFT JOIN DoctorInfo di ON d.UserID = di.DoctorID
        WHERE CAST(a.AppointmentID AS VARCHAR) LIKE ?
           OR c.FullName LIKE ?
           OR c.Phone LIKE ?
           OR d.FullName LIKE ?
           OR a.Status LIKE ?
        ORDER BY a.AppointmentDate DESC,
                 a.AppointmentTime DESC
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String search = "%" + keyword + "%";
            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ps.setString(4, search);
            ps.setString(5, search);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapAppointmentFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================
    // Appointment Detail
    // =========================
    public Appointment getAppointmentById(int appointmentID) {
        String sql = """
        SELECT
            a.*,
            c.FullName AS CustomerName,
            c.Phone AS CustomerPhone,
            ci.Address,
            ci.Gender,
            ci.DateOfBirth,
            d.FullName AS DoctorName,
            d.Phone AS DoctorPhone,
            di.Specialization
        FROM Appointments a
        JOIN Users c ON a.CustomerID = c.UserID
        LEFT JOIN CustomerInfo ci ON c.UserID = ci.CustomerID
        LEFT JOIN Users d ON a.DoctorID = d.UserID
        LEFT JOIN DoctorInfo di ON d.UserID = di.DoctorID
        WHERE a.AppointmentID = ?
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, appointmentID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Appointment a = mapAppointmentFull(rs);
                a.setCustomerAddress(rs.getString("Address"));
                a.setCustomerGender(rs.getString("Gender"));
                a.setCustomerDOB(rs.getDate("DateOfBirth"));
                a.setTotalPrice(getTotalServicePrice(appointmentID));
                return a;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================
    // Update Appointment Status
    // =========================
    public boolean updateStatus(int appointmentID, String status) {
        String sql = """
                     UPDATE Appointments
                     SET Status = ?
                     WHERE AppointmentID = ?
                     """;
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

    // =========================
    // Check Doctor Available
    // =========================
    public boolean isDoctorAvailable(int doctorID, Date date, Time time) {

        // Bước 1: Kiểm tra bác sĩ có lịch làm việc không
        String scheduleSql = """
                             SELECT *
                             FROM DoctorSchedules
                             WHERE DoctorID = ?
                               AND WorkDate = ?
                               AND Status = 'Active'
                             """;

        // Bước 2: Kiểm tra bác sĩ đã có lịch hẹn cùng giờ chưa
        String appointmentSql = """
                                SELECT *
                                FROM Appointments
                                WHERE DoctorID = ?
                                  AND AppointmentDate = ?
                                  AND AppointmentTime = ?
                                  AND Status <> 'Cancelled'
                                """;
        try {

            // Check lịch làm việc
            PreparedStatement ps1 = connection.prepareStatement(scheduleSql);
            ps1.setInt(1, doctorID);
            ps1.setDate(2, date);
            ResultSet rs1 = ps1.executeQuery();

            // Không có ca làm
            if (!rs1.next()) {
                return false;
            }

            // Check lịch hẹn trùng
            PreparedStatement ps2 = connection.prepareStatement(appointmentSql);
            ps2.setInt(1, doctorID);
            ps2.setDate(2, date);
            ps2.setTime(3, time);
            ResultSet rs2 = ps2.executeQuery();

            // true = rảnh
            return !rs2.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================
    // Insert Appointment
    // =========================
    public int insertAppointment(Appointment appointment) {

        String sql = """
                     INSERT INTO Appointments
                     (
                        CustomerID,
                        DoctorID,
                        AppointmentDate,
                        AppointmentTime,
                        Status,
                        Notes
                     )
                     VALUES
                     (
                        ?, ?, ?, ?, ?, ?
                     )
                     """;
        try {
            PreparedStatement ps = connection.prepareStatement(
                    sql,
                    PreparedStatement.RETURN_GENERATED_KEYS
            );
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

    // =========================
    // Add Service To Appointment
    // =========================
    public boolean addAppointmentService(int appointmentID, int serviceID) {
        String sql = """
                     INSERT INTO AppointmentServices
                     VALUES(?,?)
                     """;
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

    // =========================
    // Get Services By Appointment
    // =========================
    public List<Service> getServicesByAppointment(int appointmentID) {
        List<Service> list = new ArrayList<>();
        String sql = """
                     SELECT s.*
                     FROM AppointmentServices aps
                     JOIN Services s
                        ON aps.ServiceID = s.ServiceID
                     WHERE aps.AppointmentID = ?
                     ORDER BY s.ServiceName
                     """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, appointmentID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Service s = new Service();
                s.setServiceID(rs.getInt("ServiceID"));
                s.setServiceName(rs.getString("ServiceName"));
                s.setPrice(rs.getDouble("Price"));
                s.setDescription(rs.getString("Description"));
                s.setStatus(rs.getBoolean("Status"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================
    // Calculate Total Service Price
    // =========================
    public double getTotalServicePrice(int appointmentID) {
        String sql = """
                     SELECT SUM(s.Price) AS TotalPrice
                     FROM AppointmentServices aps
                     JOIN Services s
                        ON aps.ServiceID = s.ServiceID
                     WHERE aps.AppointmentID = ?
                     """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, appointmentID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("TotalPrice");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isDoctorWorking(int doctorID, Date date, Time time) {
        String sql = """
        SELECT ShiftName
        FROM DoctorSchedules
        WHERE DoctorID = ?
          AND WorkDate = ?
          AND Status = 'Active'
        """;

        try {

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, doctorID);
            ps.setDate(2, date);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                String shift = rs.getString("ShiftName");

                LocalTime t = time.toLocalTime();

                switch (shift) {

                    case "Morning":
                        return !t.isBefore(LocalTime.of(8, 0))
                                && !t.isAfter(LocalTime.of(11, 30));

                    case "Afternoon":
                        return !t.isBefore(LocalTime.of(13, 0))
                                && !t.isAfter(LocalTime.of(17, 0));

                    case "FullDay":
                        return !t.isBefore(LocalTime.of(8, 0))
                                && !t.isAfter(LocalTime.of(17, 0));
                }

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;

    }
}
