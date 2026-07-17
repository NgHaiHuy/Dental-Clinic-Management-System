package dal;

import context.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Appointment;
import model.Service;

/**
 * Data Access Object for Appointments.
 */
public class AppointmentDAO extends DBContext {

    /**
     * Add a new appointment and its associated services in a transaction.
     */
    public boolean addAppointment(Appointment app, List<Integer> serviceIDs) {
        String insertAppSql = "INSERT INTO Appointments (CustomerID, DoctorID, AppointmentDate, AppointmentTime, Status, Notes) "
                            + "VALUES (?, ?, ?, ?, ?, ?)";
        String insertServiceSql = "INSERT INTO AppointmentServices (AppointmentID, ServiceID) VALUES (?, ?)";
        
        Connection conn = null;
        PreparedStatement psApp = null;
        PreparedStatement psService = null;
        ResultSet rsKeys = null;
        
        try {
            conn = connection; // Use parent DBContext connection
            conn.setAutoCommit(false);
            
            psApp = conn.prepareStatement(insertAppSql, Statement.RETURN_GENERATED_KEYS);
            psApp.setInt(1, app.getCustomerID());
            if (app.getDoctorID() != null) {
                psApp.setInt(2, app.getDoctorID());
            } else {
                psApp.setNull(2, java.sql.Types.INTEGER);
            }
            psApp.setDate(3, app.getAppointmentDate());
            psApp.setTime(4, app.getAppointmentTime());
            psApp.setString(5, app.getStatus());
            psApp.setString(6, app.getNotes());
            
            int affected = psApp.executeUpdate();
            if (affected == 0) {
                conn.rollback();
                return false;
            }
            
            rsKeys = psApp.getGeneratedKeys();
            int appointmentID = 0;
            if (rsKeys.next()) {
                appointmentID = rsKeys.getInt(1);
            } else {
                conn.rollback();
                return false;
            }
            
            if (serviceIDs != null && !serviceIDs.isEmpty()) {
                psService = conn.prepareStatement(insertServiceSql);
                for (int serviceID : serviceIDs) {
                    psService.setInt(1, appointmentID);
                    psService.setInt(2, serviceID);
                    psService.addBatch();
                }
                psService.executeBatch();
            }
            
            conn.commit();
            return true;
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException e) {
                    Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, e);
                }
            }
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
                if (rsKeys != null) rsKeys.close();
                if (psApp != null) psApp.close();
                if (psService != null) psService.close();
            } catch (SQLException e) {
                Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    }

    /**
     * Get appointments history by CustomerID.
     */
    public List<Appointment> getAppointmentsByCustomerID(int customerID) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, a.AppointmentTime, a.Status, a.Notes, "
                   + "u.FullName AS DoctorName "
                   + "FROM Appointments a "
                   + "LEFT JOIN Users u ON a.DoctorID = u.UserID "
                   + "WHERE a.CustomerID = ? "
                   + "ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment app = new Appointment();
                    app.setAppointmentID(rs.getInt("AppointmentID"));
                    app.setCustomerID(rs.getInt("CustomerID"));
                    int docId = rs.getInt("DoctorID");
                    app.setDoctorID(rs.wasNull() ? null : docId);
                    app.setAppointmentDate(rs.getDate("AppointmentDate"));
                    app.setAppointmentTime(rs.getTime("AppointmentTime"));
                    app.setStatus(rs.getString("Status"));
                    app.setNotes(rs.getString("Notes"));
                    app.setDoctorName(rs.getString("DoctorName") != null ? rs.getString("DoctorName") : "General Doctor");
                    list.add(app);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get all appointments (optionally filtered by date).
     */
    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, a.AppointmentTime, a.Status, a.Notes, "
                   + "c.FullName AS CustomerName, c.Phone AS CustomerPhone, c.Email AS CustomerEmail, d.FullName AS DoctorName "
                   + "FROM Appointments a "
                   + "INNER JOIN Users c ON a.CustomerID = c.UserID "
                   + "LEFT JOIN Users d ON a.DoctorID = d.UserID "
                   + "ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Appointment app = new Appointment();
                app.setAppointmentID(rs.getInt("AppointmentID"));
                app.setCustomerID(rs.getInt("CustomerID"));
                int docId = rs.getInt("DoctorID");
                app.setDoctorID(rs.wasNull() ? null : docId);
                app.setAppointmentDate(rs.getDate("AppointmentDate"));
                app.setAppointmentTime(rs.getTime("AppointmentTime"));
                app.setStatus(rs.getString("Status"));
                app.setNotes(rs.getString("Notes"));
                app.setCustomerName(rs.getString("CustomerName"));
                app.setCustomerPhone(rs.getString("CustomerPhone"));
                app.setCustomerEmail(rs.getString("CustomerEmail"));
                app.setDoctorName(rs.getString("DoctorName") != null ? rs.getString("DoctorName") : "Khám tổng quát (General)");
                list.add(app);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Update appointment status.
     */
    public boolean updateAppointmentStatus(int appointmentID, String status) {
        String sql = "UPDATE Appointments SET Status = ? WHERE AppointmentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, appointmentID);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Update appointment details and its chosen services.
     */
    public boolean updateAppointmentDetails(Appointment app, List<Integer> serviceIDs) {
        String updateAppSql = "UPDATE Appointments SET DoctorID = ?, AppointmentDate = ?, AppointmentTime = ?, Notes = ? WHERE AppointmentID = ?";
        String deleteServicesSql = "DELETE FROM AppointmentServices WHERE AppointmentID = ?";
        String insertServiceSql = "INSERT INTO AppointmentServices (AppointmentID, ServiceID) VALUES (?, ?)";
        
        try {
            connection.setAutoCommit(false);
            
            try (PreparedStatement psApp = connection.prepareStatement(updateAppSql)) {
                if (app.getDoctorID() != null) {
                    psApp.setInt(1, app.getDoctorID());
                } else {
                    psApp.setNull(1, java.sql.Types.INTEGER);
                }
                psApp.setDate(2, app.getAppointmentDate());
                psApp.setTime(3, app.getAppointmentTime());
                psApp.setString(4, app.getNotes());
                psApp.setInt(5, app.getAppointmentID());
                psApp.executeUpdate();
            }
            
            try (PreparedStatement psDel = connection.prepareStatement(deleteServicesSql)) {
                psDel.setInt(1, app.getAppointmentID());
                psDel.executeUpdate();
            }
            
            if (serviceIDs != null && !serviceIDs.isEmpty()) {
                try (PreparedStatement psIns = connection.prepareStatement(insertServiceSql)) {
                    for (int serviceID : serviceIDs) {
                        psIns.setInt(1, app.getAppointmentID());
                        psIns.setInt(2, serviceID);
                        psIns.executeUpdate();
                    }
                }
            }
            
            connection.commit();
            return true;
        } catch (SQLException ex) {
            try {
                connection.rollback();
            } catch (SQLException e) {
                Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, e);
            }
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, e);
            }
        }
        return false;
    }

    /**
     * Get single appointment by ID.
     */
    public Appointment getAppointmentByID(int appointmentID) {
        String sql = "SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, a.AppointmentTime, a.Status, a.Notes, "
                   + "c.FullName AS CustomerName, d.FullName AS DoctorName "
                   + "FROM Appointments a "
                   + "INNER JOIN Users c ON a.CustomerID = c.UserID "
                   + "LEFT JOIN Users d ON a.DoctorID = d.UserID "
                   + "WHERE a.AppointmentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appointmentID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment app = new Appointment();
                    app.setAppointmentID(rs.getInt("AppointmentID"));
                    app.setCustomerID(rs.getInt("CustomerID"));
                    int docId = rs.getInt("DoctorID");
                    app.setDoctorID(rs.wasNull() ? null : docId);
                    app.setAppointmentDate(rs.getDate("AppointmentDate"));
                    app.setAppointmentTime(rs.getTime("AppointmentTime"));
                    app.setStatus(rs.getString("Status"));
                    app.setNotes(rs.getString("Notes"));
                    app.setCustomerName(rs.getString("CustomerName"));
                    app.setDoctorName(rs.getString("DoctorName") != null ? rs.getString("DoctorName") : "General Doctor");
                    return app;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Get services chosen for an appointment.
     */
    public List<Service> getServicesForAppointment(int appointmentID) {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT s.ServiceID, s.ServiceName, s.Description, s.Price "
                   + "FROM AppointmentServices aps "
                   + "INNER JOIN Services s ON aps.ServiceID = s.ServiceID "
                   + "WHERE aps.AppointmentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appointmentID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Service s = new Service();
                    s.setServiceID(rs.getInt("ServiceID"));
                    s.setServiceName(rs.getString("ServiceName"));
                    s.setDescription(rs.getString("Description"));
                    s.setPrice(rs.getDouble("Price"));
                    list.add(s);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get checked-in (Attended) appointments for a doctor that don't have a MedicalRecord yet.
     */
    public List<Appointment> getCheckedInAppointmentsForDoctor(int doctorID) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, a.AppointmentTime, a.Status, a.Notes, "
                   + "c.FullName AS CustomerName "
                   + "FROM Appointments a "
                   + "INNER JOIN Users c ON a.CustomerID = c.UserID "
                   + "WHERE a.Status = 'Attended' AND (a.DoctorID = ? OR a.DoctorID IS NULL) "
                   + "AND a.AppointmentID NOT IN (SELECT AppointmentID FROM MedicalRecords) "
                   + "ORDER BY a.AppointmentDate ASC, a.AppointmentTime ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, doctorID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment app = new Appointment();
                    app.setAppointmentID(rs.getInt("AppointmentID"));
                    app.setCustomerID(rs.getInt("CustomerID"));
                    int docId = rs.getInt("DoctorID");
                    app.setDoctorID(rs.wasNull() ? null : docId);
                    app.setAppointmentDate(rs.getDate("AppointmentDate"));
                    app.setAppointmentTime(rs.getTime("AppointmentTime"));
                    app.setStatus(rs.getString("Status"));
                    app.setNotes(rs.getString("Notes"));
                    app.setCustomerName(rs.getString("CustomerName"));
                    list.add(app);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public boolean isDoctorBooked(int doctorID, java.sql.Date date, java.sql.Time time, Integer excludeAppointmentID) {
        String sql = "SELECT COUNT(*) FROM Appointments WHERE DoctorID = ? AND AppointmentDate = ? AND AppointmentTime = ? AND Status IN ('Pending', 'Confirmed', 'Attended')";
        if (excludeAppointmentID != null) {
            sql += " AND AppointmentID <> ?";
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, doctorID);
            ps.setDate(2, date);
            ps.setTime(3, time);
            if (excludeAppointmentID != null) {
                ps.setInt(4, excludeAppointmentID);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    public boolean isCustomerBooked(int customerID, java.sql.Date date, java.sql.Time time, Integer excludeAppointmentID) {
        String sql = "SELECT COUNT(*) FROM Appointments WHERE CustomerID = ? AND AppointmentDate = ? AND AppointmentTime = ? AND Status IN ('Pending', 'Confirmed', 'Attended')";
        if (excludeAppointmentID != null) {
            sql += " AND AppointmentID <> ?";
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            ps.setDate(2, date);
            ps.setTime(3, time);
            if (excludeAppointmentID != null) {
                ps.setInt(4, excludeAppointmentID);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(AppointmentDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }
}
