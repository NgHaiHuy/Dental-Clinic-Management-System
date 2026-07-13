package dal;

import context.DBContext;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.MedicalRecord;
import model.Role;
import model.Service;

/**
 * Read-only data access for completed examination history.
 */
public class MedicalRecordDAO extends DBContext implements AutoCloseable {

    /**
     * Returns the latest medical record of each examined appointment. The role
     * scope is enforced here so a request parameter can never broaden access.
     */
    public List<MedicalRecord> findExaminationHistory(int userID, int roleID,
            String keyword, LocalDate fromDate, LocalDate toDate,
            Integer serviceID) throws SQLException {
        ensureConnection();

        StringBuilder sql = new StringBuilder(
                "WITH LatestRecords AS ("
                + " SELECT r.RecordID, r.AppointmentID, r.DoctorID, r.Diagnosis, "
                + "        r.TreatmentPlan, r.CreatedAt, "
                + "        ROW_NUMBER() OVER (PARTITION BY r.AppointmentID "
                + "            ORDER BY r.CreatedAt DESC, r.RecordID DESC) AS RowNumber "
                + " FROM MedicalRecords r"
                + ") "
                + "SELECT r.RecordID, r.AppointmentID, r.DoctorID, r.Diagnosis, "
                + "       r.TreatmentPlan, r.CreatedAt, a.CustomerID, "
                + "       a.AppointmentDate, a.AppointmentTime, a.Notes, "
                + "       customer.FullName AS CustomerName, customer.Phone AS CustomerPhone, "
                + "       doctor.FullName AS DoctorName, services.ServiceNames "
                + "FROM LatestRecords r "
                + "INNER JOIN Appointments a ON a.AppointmentID = r.AppointmentID "
                + "INNER JOIN Users customer ON customer.UserID = a.CustomerID "
                + "INNER JOIN Users doctor ON doctor.UserID = r.DoctorID "
                + "OUTER APPLY ("
                + " SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), s.ServiceName), N', ') AS ServiceNames "
                + " FROM AppointmentServices aps "
                + " INNER JOIN Services s ON s.ServiceID = aps.ServiceID "
                + " WHERE aps.AppointmentID = a.AppointmentID"
                + ") services "
                + "WHERE r.RowNumber = 1 ");

        List<Object> parameters = new ArrayList<>();
        if (roleID == Role.CUSTOMER) {
            sql.append("AND a.CustomerID = ? ");
            parameters.add(userID);
        } else if (roleID == Role.DOCTOR) {
            sql.append("AND r.DoctorID = ? ");
            parameters.add(userID);
        } else if (roleID != Role.STAFF) {
            return new ArrayList<>();
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (LOWER(customer.FullName) LIKE ? "
                    + "OR customer.Phone LIKE ? "
                    + "OR LOWER(doctor.FullName) LIKE ? "
                    + "OR LOWER(COALESCE(services.ServiceNames, N'')) LIKE ? "
                    + "OR LOWER(COALESCE(r.Diagnosis, N'')) LIKE ? "
                    + "OR LOWER(COALESCE(r.TreatmentPlan, N'')) LIKE ? "
                    + "OR LOWER(COALESCE(a.Notes, N'')) LIKE ? "
                    + "OR CAST(r.RecordID AS VARCHAR(20)) LIKE ? "
                    + "OR CAST(r.AppointmentID AS VARCHAR(20)) LIKE ?) ");
            String pattern = "%" + keyword.trim().toLowerCase() + "%";
            for (int i = 0; i < 9; i++) {
                parameters.add(pattern);
            }
        }
        if (fromDate != null) {
            sql.append("AND a.AppointmentDate >= ? ");
            parameters.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append("AND a.AppointmentDate <= ? ");
            parameters.add(Date.valueOf(toDate));
        }
        if (serviceID != null) {
            sql.append("AND EXISTS (SELECT 1 FROM AppointmentServices selectedService "
                    + "WHERE selectedService.AppointmentID = a.AppointmentID "
                    + "AND selectedService.ServiceID = ?) ");
            parameters.add(serviceID);
        }
        sql.append("ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC, r.RecordID DESC");

        List<MedicalRecord> records = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                statement.setObject(i + 1, parameters.get(i));
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    records.add(mapRecord(resultSet));
                }
            }
        }
        return records;
    }

    /** Returns only services that have appeared in at least one medical record. */
    public List<Service> findHistoryServices() throws SQLException {
        ensureConnection();
        String sql = "SELECT DISTINCT s.ServiceID, s.ServiceName "
                + "FROM Services s "
                + "INNER JOIN AppointmentServices aps ON aps.ServiceID = s.ServiceID "
                + "INNER JOIN MedicalRecords r ON r.AppointmentID = aps.AppointmentID "
                + "ORDER BY s.ServiceName";
        List<Service> services = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                Service service = new Service();
                service.setServiceID(resultSet.getInt("ServiceID"));
                service.setServiceName(resultSet.getString("ServiceName"));
                services.add(service);
            }
        }
        return services;
    }

    private MedicalRecord mapRecord(ResultSet resultSet) throws SQLException {
        MedicalRecord record = new MedicalRecord();
        record.setRecordID(resultSet.getInt("RecordID"));
        record.setAppointmentID(resultSet.getInt("AppointmentID"));
        record.setDoctorID(resultSet.getInt("DoctorID"));
        record.setCustomerID(resultSet.getInt("CustomerID"));
        record.setDiagnosis(resultSet.getString("Diagnosis"));
        record.setTreatmentPlan(resultSet.getString("TreatmentPlan"));
        record.setCreatedAt(resultSet.getTimestamp("CreatedAt"));
        record.setPatientName(resultSet.getString("CustomerName"));
        record.setCustomerPhone(resultSet.getString("CustomerPhone"));
        record.setDoctorName(resultSet.getString("DoctorName"));
        record.setAppointmentDate(resultSet.getDate("AppointmentDate").toLocalDate());
        record.setAppointmentTime(resultSet.getTime("AppointmentTime").toLocalTime());
        record.setAppointmentNotes(resultSet.getString("Notes"));
        record.setServiceNames(resultSet.getString("ServiceNames"));
        return record;
    }

    private void ensureConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            throw new SQLException("Database connection is not available");
        }
    }

    @Override
    public void close() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException ignored) {
                // Nothing else can be done while closing a read-only request.
            }
        }
    }
}
