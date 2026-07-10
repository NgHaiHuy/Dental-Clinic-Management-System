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

    /**
     * Add a new service to the database.
     * @param s The Service object to add
     * @return true if successful, false otherwise
     */
    public boolean addService(Service s) {
        String sql = "INSERT INTO Services (ServiceName, Price, Description, Status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, s.getServiceName());
            ps.setDouble(2, s.getPrice());
            ps.setString(3, s.getDescription());
            ps.setBoolean(4, s.isStatus());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Update an existing service in the database.
     * @param s The Service object with updated details
     * @return true if successful, false otherwise
     */
    public boolean updateService(Service s) {
        String sql = "UPDATE Services SET ServiceName = ?, Price = ?, Description = ?, Status = ? WHERE ServiceID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, s.getServiceName());
            ps.setDouble(2, s.getPrice());
            ps.setString(3, s.getDescription());
            ps.setBoolean(4, s.isStatus());
            ps.setInt(5, s.getServiceID());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Delete a service from the database by ID.
     * If the service is referenced elsewhere (e.g. in booking history),
     * it will fallback to deactivating the service (status = false).
     * @param serviceID The ID of the service to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteService(int serviceID) {
        String sqlDelete = "DELETE FROM Services WHERE ServiceID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sqlDelete)) {
            ps.setInt(1, serviceID);
            int rows = ps.executeUpdate();
            if (rows > 0) return true;
        } catch (SQLException ex) {
            // Fallback: deactivate service if referenced by foreign key constraints
            String sqlUpdate = "UPDATE Services SET Status = 0 WHERE ServiceID = ?";
            try (PreparedStatement ps = connection.prepareStatement(sqlUpdate)) {
                ps.setInt(1, serviceID);
                int rows = ps.executeUpdate();
                return rows > 0;
            } catch (SQLException ex2) {
                Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex2);
            }
        }
        return false;
    }

    /**
     * Search services by name.
     * @param txt Search term
     * @return List of matching services
     */
    public List<Service> searchServicesByName(String txt) {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT ServiceID, ServiceName, Price, Description, Status FROM Services WHERE ServiceName LIKE ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + txt + "%");
            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (SQLException ex) {
            Logger.getLogger(ServiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
