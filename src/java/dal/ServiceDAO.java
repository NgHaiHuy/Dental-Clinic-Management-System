package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

public class ServiceDAO extends DBContext {

    public Map<Integer, String> getActiveServiceOptions() throws SQLException {
        ensureConnection();

        String sql = "SELECT ServiceID, ServiceName "
                + "FROM Services "
                + "WHERE Status = ? "
                + "ORDER BY ServiceName, ServiceID";

        Map<Integer, String> serviceOptions = new LinkedHashMap<>();

        try {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setBoolean(1, true);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        serviceOptions.put(
                                resultSet.getInt("ServiceID"),
                                resultSet.getString("ServiceName")
                        );
                    }
                }
            }
            return serviceOptions;
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
