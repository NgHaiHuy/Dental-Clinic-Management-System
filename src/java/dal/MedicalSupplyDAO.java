package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.MedicalSupply;

/**
 * Data Access Object for MedicalSupplies (Inventory Management).
 */
public class MedicalSupplyDAO extends DBContext {

    /**
     * Get all medical supplies from the database.
     * @return List of medical supplies
     */
    public List<MedicalSupply> getAllSupplies() {
        List<MedicalSupply> list = new ArrayList<>();
        String sql = "SELECT SupplyID, SupplyName, Unit, Quantity, MinQuantity, UnitPrice, Supplier, LastUpdated FROM MedicalSupplies";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MedicalSupply s = new MedicalSupply(
                        rs.getInt("SupplyID"),
                        rs.getString("SupplyName"),
                        rs.getString("Unit"),
                        rs.getInt("Quantity"),
                        rs.getInt("MinQuantity"),
                        rs.getDouble("UnitPrice"),
                        rs.getString("Supplier"),
                        rs.getTimestamp("LastUpdated")
                );
                list.add(s);
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get medical supply by its ID.
     * @param supplyID The ID of the supply
     * @return The MedicalSupply object, or null if not found
     */
    public MedicalSupply getSupplyByID(int supplyID) {
        String sql = "SELECT SupplyID, SupplyName, Unit, Quantity, MinQuantity, UnitPrice, Supplier, LastUpdated FROM MedicalSupplies WHERE SupplyID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplyID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new MedicalSupply(
                            rs.getInt("SupplyID"),
                            rs.getString("SupplyName"),
                            rs.getString("Unit"),
                            rs.getInt("Quantity"),
                            rs.getInt("MinQuantity"),
                            rs.getDouble("UnitPrice"),
                            rs.getString("Supplier"),
                            rs.getTimestamp("LastUpdated")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Add a new medical supply.
     * @param s MedicalSupply object to add
     * @return true if successful, false otherwise
     */
    public boolean addSupply(MedicalSupply s) {
        String sql = "INSERT INTO MedicalSupplies (SupplyName, Unit, Quantity, MinQuantity, UnitPrice, Supplier, LastUpdated) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, s.getSupplyName());
            ps.setString(2, s.getUnit());
            ps.setInt(3, s.getQuantity());
            ps.setInt(4, s.getMinQuantity());
            ps.setDouble(5, s.getUnitPrice());
            ps.setString(6, s.getSupplier());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Update an existing medical supply.
     * @param s MedicalSupply object with updated values
     * @return true if successful, false otherwise
     */
    public boolean updateSupply(MedicalSupply s) {
        String sql = "UPDATE MedicalSupplies SET SupplyName = ?, Unit = ?, Quantity = ?, MinQuantity = ?, UnitPrice = ?, Supplier = ?, LastUpdated = GETDATE() WHERE SupplyID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, s.getSupplyName());
            ps.setString(2, s.getUnit());
            ps.setInt(3, s.getQuantity());
            ps.setInt(4, s.getMinQuantity());
            ps.setDouble(5, s.getUnitPrice());
            ps.setString(6, s.getSupplier());
            ps.setInt(7, s.getSupplyID());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Delete a medical supply by ID.
     * @param supplyID The ID of the supply to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteSupply(int supplyID) {
        String sql = "DELETE FROM MedicalSupplies WHERE SupplyID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplyID);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Search medical supplies by name.
     * @param txt Search query
     * @return List of matching supplies
     */
    public List<MedicalSupply> searchSuppliesByName(String txt) {
        List<MedicalSupply> list = new ArrayList<>();
        String sql = "SELECT SupplyID, SupplyName, Unit, Quantity, MinQuantity, UnitPrice, Supplier, LastUpdated FROM MedicalSupplies WHERE SupplyName LIKE ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + txt + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalSupply s = new MedicalSupply(
                            rs.getInt("SupplyID"),
                            rs.getString("SupplyName"),
                            rs.getString("Unit"),
                            rs.getInt("Quantity"),
                            rs.getInt("MinQuantity"),
                            rs.getDouble("UnitPrice"),
                            rs.getString("Supplier"),
                            rs.getTimestamp("LastUpdated")
                    );
                    list.add(s);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicalSupplyDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
