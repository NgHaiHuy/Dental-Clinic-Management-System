package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Service;

/**
 * Data Access Object for Services.
 */
public class ServiceDAO extends DBContext {

    /**
     * Get all services from the database.
     * @return List of services
     */
    public List<Service> getAllServices() {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT ServiceID, ServiceName, Price, Description, Status FROM Services";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Service s = new Service(
                        rs.getInt("ServiceID"),
                        rs.getString("ServiceName"),
                        rs.getDouble("Price"),
                        rs.getString("Description"),
                        rs.getBoolean("Status")
                );
                list.add(s);
            }
        } catch (SQLException ex) {
            Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get service by its ID.
     * @param serviceID The ID of the service
     * @return The Service object, or null if not found
     */
    public Service getServiceByID(int serviceID) {
        String sql = "SELECT ServiceID, ServiceName, Price, Description, Status FROM Services WHERE ServiceID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, serviceID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Service(
                            rs.getInt("ServiceID"),
                            rs.getString("ServiceName"),
                            rs.getDouble("Price"),
                            rs.getString("Description"),
                            rs.getBoolean("Status")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}
