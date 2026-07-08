package dal;

import context.DBContext;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Appointment;

public class AppointmentDAO extends DBContext {

    public List<Appointment> getAppointmentsByCustomerId(int customerId) throws SQLException {
        ensureConnection();

        String sql = "SELECT AppointmentID, CustomerID, DoctorID, AppointmentDate, "
                + "AppointmentTime, Status, Notes "
                + "FROM Appointments "
                + "WHERE CustomerID = ? "
                + "ORDER BY AppointmentDate DESC, AppointmentTime DESC, AppointmentID DESC";

        Map<Integer, Appointment> appointmentsById = new LinkedHashMap<>();

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, customerId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        Appointment appointment = mapAppointment(resultSet);
                        appointmentsById.put(appointment.getAppointmentId(), appointment);
                    }
                }
            }

            loadAppointmentServices(appointmentsById);
            return new ArrayList<>(appointmentsById.values());
        } finally {
            closeConnection();
        }
    }

    public Appointment getAppointmentById(int appointmentId, int customerId) throws SQLException {
        ensureConnection();

        String sql = "SELECT AppointmentID, CustomerID, DoctorID, AppointmentDate, "
                + "AppointmentTime, Status, Notes "
                + "FROM Appointments "
                + "WHERE AppointmentID = ? AND CustomerID = ?";

        Map<Integer, Appointment> appointmentsById = new LinkedHashMap<>();

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, appointmentId);
                statement.setInt(2, customerId);

                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        Appointment appointment = mapAppointment(resultSet);
                        appointmentsById.put(appointment.getAppointmentId(), appointment);
                    }
                }
            }

            loadAppointmentServices(appointmentsById);
            return appointmentsById.get(appointmentId);
        } finally {
            closeConnection();
        }
    }

    public int insertAppointment(Appointment appointment) throws SQLException {
        ensureConnection();

        String sql = "INSERT INTO Appointments "
                + "(CustomerID, DoctorID, AppointmentDate, AppointmentTime, Status, Notes) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        boolean oldAutoCommit = connection.getAutoCommit();

        try {
            connection.setAutoCommit(false);
            int appointmentId;

            try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                statement.setInt(1, appointment.getCustomerId());
                if (appointment.getDoctorId() == null) {
                    statement.setNull(2, Types.INTEGER);
                } else {
                    statement.setInt(2, appointment.getDoctorId());
                }
                statement.setDate(3, appointment.getAppointmentDate());
                statement.setTime(4, appointment.getAppointmentTime());
                statement.setString(5, appointment.getStatus());
                statement.setString(6, appointment.getNotes());
                statement.executeUpdate();

                try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                    if (!generatedKeys.next()) {
                        throw new SQLException("Cannot get generated appointment id.");
                    }
                    appointmentId = generatedKeys.getInt(1);
                }
            }

            insertAppointmentServices(appointmentId, appointment.getServiceIds());
            connection.commit();
            return appointmentId;
        } catch (SQLException ex) {
            connection.rollback();
            throw ex;
        } finally {
            connection.setAutoCommit(oldAutoCommit);
            closeConnection();
        }
    }

    public boolean hasDoctorScheduleConflict(int doctorId, Date appointmentDate, Time appointmentTime,
            int durationMinutes) throws SQLException {
        return hasDoctorScheduleConflict(doctorId, appointmentDate, appointmentTime, durationMinutes, null);
    }

    public boolean hasDoctorScheduleConflict(int doctorId, Date appointmentDate, Time appointmentTime,
            int durationMinutes, Integer excludedAppointmentId) throws SQLException {
        ensureConnection();

        String sql = "SELECT COUNT(*) "
                + "FROM Appointments "
                + "WHERE DoctorID = ? "
                + "AND AppointmentDate = ? "
                + "AND Status <> ? "
                + (excludedAppointmentId == null ? "" : "AND AppointmentID <> ? ")
                + "AND DATEDIFF(MINUTE, CAST('00:00:00' AS time), CAST(AppointmentTime AS time)) "
                + "< DATEDIFF(MINUTE, CAST('00:00:00' AS time), CAST(? AS time)) + ? "
                + "AND DATEDIFF(MINUTE, CAST('00:00:00' AS time), CAST(AppointmentTime AS time)) + ? "
                + "> DATEDIFF(MINUTE, CAST('00:00:00' AS time), CAST(? AS time))";

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, doctorId);
                statement.setDate(2, appointmentDate);
                statement.setString(3, "Cancelled");
                int parameterIndex = 4;
                if (excludedAppointmentId != null) {
                    statement.setInt(parameterIndex++, excludedAppointmentId);
                }
                statement.setTime(parameterIndex++, appointmentTime);
                statement.setInt(parameterIndex++, durationMinutes);
                statement.setInt(parameterIndex++, durationMinutes);
                statement.setTime(parameterIndex, appointmentTime);

                try (ResultSet resultSet = statement.executeQuery()) {
                    return resultSet.next() && resultSet.getInt(1) > 0;
                }
            }
        } finally {
            closeConnection();
        }
    }

    public boolean updatePendingAppointment(Appointment appointment) throws SQLException {
        ensureConnection();

        String updateSql = "UPDATE Appointments "
                + "SET DoctorID = ?, AppointmentDate = ?, AppointmentTime = ?, Notes = ? "
                + "WHERE AppointmentID = ? AND CustomerID = ? AND Status = ?";
        boolean oldAutoCommit = connection.getAutoCommit();

        try {
            connection.setAutoCommit(false);

            int updatedRows;
            try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                if (appointment.getDoctorId() == null) {
                    statement.setNull(1, Types.INTEGER);
                } else {
                    statement.setInt(1, appointment.getDoctorId());
                }
                statement.setDate(2, appointment.getAppointmentDate());
                statement.setTime(3, appointment.getAppointmentTime());
                statement.setString(4, appointment.getNotes());
                statement.setInt(5, appointment.getAppointmentId());
                statement.setInt(6, appointment.getCustomerId());
                statement.setString(7, "Pending");
                updatedRows = statement.executeUpdate();
            }

            if (updatedRows == 0) {
                connection.rollback();
                return false;
            }

            deleteAppointmentServices(appointment.getAppointmentId());
            insertAppointmentServices(appointment.getAppointmentId(), appointment.getServiceIds());
            connection.commit();
            return true;
        } catch (SQLException ex) {
            connection.rollback();
            throw ex;
        } finally {
            connection.setAutoCommit(oldAutoCommit);
            closeConnection();
        }
    }

    public boolean cancelPendingAppointment(int appointmentId, int customerId) throws SQLException {
        ensureConnection();

        String sql = "UPDATE Appointments "
                + "SET Status = ? "
                + "WHERE AppointmentID = ? AND CustomerID = ? AND Status = ?";

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, "Cancelled");
                statement.setInt(2, appointmentId);
                statement.setInt(3, customerId);
                statement.setString(4, "Pending");
                return statement.executeUpdate() > 0;
            }
        } finally {
            closeConnection();
        }
    }

    private Appointment mapAppointment(ResultSet resultSet) throws SQLException {
        Integer doctorId = null;
        int doctorIdValue = resultSet.getInt("DoctorID");
        if (!resultSet.wasNull()) {
            doctorId = doctorIdValue;
        }

        return new Appointment(
                resultSet.getInt("AppointmentID"),
                resultSet.getInt("CustomerID"),
                doctorId,
                resultSet.getDate("AppointmentDate"),
                resultSet.getTime("AppointmentTime"),
                resultSet.getString("Status"),
                resultSet.getString("Notes")
        );
    }

    private void loadAppointmentServices(Map<Integer, Appointment> appointmentsById) throws SQLException {
        if (appointmentsById.isEmpty()) {
            return;
        }

        String placeholders = String.join(",", Collections.nCopies(appointmentsById.size(), "?"));
        String sql = "SELECT AppointmentID, ServiceID "
                + "FROM AppointmentServices "
                + "WHERE AppointmentID IN (" + placeholders + ") "
                + "ORDER BY AppointmentID, ServiceID";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = 1;
            for (Integer appointmentId : appointmentsById.keySet()) {
                statement.setInt(index++, appointmentId);
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Appointment appointment = appointmentsById.get(resultSet.getInt("AppointmentID"));
                    if (appointment != null) {
                        appointment.getServiceIds().add(resultSet.getInt("ServiceID"));
                    }
                }
            }
        }
    }

    private void insertAppointmentServices(int appointmentId, List<Integer> serviceIds) throws SQLException {
        if (serviceIds == null || serviceIds.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO AppointmentServices (AppointmentID, ServiceID) VALUES (?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (Integer serviceId : serviceIds) {
                statement.setInt(1, appointmentId);
                statement.setInt(2, serviceId);
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private void deleteAppointmentServices(int appointmentId) throws SQLException {
        String sql = "DELETE FROM AppointmentServices WHERE AppointmentID = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, appointmentId);
            statement.executeUpdate();
        }
    }

    private void ensureConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            throw new SQLException("Cannot connect to database.");
        }
    }

    private void closeConnection() throws SQLException {
        if (connection != null && !connection.isClosed()) {
            connection.close();
        }
    }
}
