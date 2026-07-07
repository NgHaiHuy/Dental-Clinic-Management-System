package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

public class UserDAO extends DBContext {

    private static final int ROLE_DOCTOR = 2;

    public Map<Integer, String> getDoctorOptions() throws SQLException {
        ensureConnection();

        String sql = "SELECT UserID, FullName "
                + "FROM Users "
                + "WHERE RoleID = ? "
                + "ORDER BY FullName, UserID";

        Map<Integer, String> doctorOptions = new LinkedHashMap<>();

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, ROLE_DOCTOR);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        doctorOptions.put(
                                resultSet.getInt("UserID"),
                                resultSet.getString("FullName")
                        );
                    }
                }
            }
            return doctorOptions;
        } finally {
            closeConnection();
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
