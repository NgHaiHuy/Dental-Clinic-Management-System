package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Medicine;

/**
 * Data Access Object for Medicines.
 */
public class MedicineDAO extends DBContext {

    /**
     * Get all medicines from the database.
     * @return List of medicines
     */
    public List<Medicine> getAllMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT MedicineID, MedicineName, Unit, Price, StockQuantity, Status FROM Medicines";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Medicine m = new Medicine(
                        rs.getInt("MedicineID"),
                        rs.getString("MedicineName"),
                        rs.getString("Unit"),
                        rs.getDouble("Price"),
                        rs.getInt("StockQuantity"),
                        rs.getBoolean("Status")
                );
                list.add(m);
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get medicine by its ID.
     * @param medicineID The ID of the medicine
     * @return The Medicine object, or null if not found
     */
    public Medicine getMedicineByID(int medicineID) {
        String sql = "SELECT MedicineID, MedicineName, Unit, Price, StockQuantity, Status FROM Medicines WHERE MedicineID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, medicineID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Medicine(
                            rs.getInt("MedicineID"),
                            rs.getString("MedicineName"),
                            rs.getString("Unit"),
                            rs.getDouble("Price"),
                            rs.getInt("StockQuantity"),
                            rs.getBoolean("Status")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Add a new medicine.
     * @param m Medicine object to add
     * @return true if successful, false otherwise
     */
    public boolean addMedicine(Medicine m) {
        String sql = "INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, m.getMedicineName());
            ps.setString(2, m.getUnit());
            ps.setDouble(3, m.getPrice());
            ps.setInt(4, m.getStockQuantity());
            ps.setBoolean(5, m.isStatus());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Update an existing medicine.
     * @param m Medicine object with updated values
     * @return true if successful, false otherwise
     */
    public boolean updateMedicine(Medicine m) {
        String sql = "UPDATE Medicines SET MedicineName = ?, Unit = ?, Price = ?, StockQuantity = ?, Status = ? WHERE MedicineID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, m.getMedicineName());
            ps.setString(2, m.getUnit());
            ps.setDouble(3, m.getPrice());
            ps.setInt(4, m.getStockQuantity());
            ps.setBoolean(5, m.isStatus());
            ps.setInt(6, m.getMedicineID());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Delete a medicine by ID. Fallback to deactivating (status = 0) if referenced elsewhere.
     * @param medicineID The ID of the medicine to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteMedicine(int medicineID) {
        String sqlDelete = "DELETE FROM Medicines WHERE MedicineID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sqlDelete)) {
            ps.setInt(1, medicineID);
            int rows = ps.executeUpdate();
            if (rows > 0) return true;
        } catch (SQLException ex) {
            // Fallback: deactivate medicine if references exist
            String sqlUpdate = "UPDATE Medicines SET Status = 0 WHERE MedicineID = ?";
            try (PreparedStatement ps = connection.prepareStatement(sqlUpdate)) {
                ps.setInt(1, medicineID);
                int rows = ps.executeUpdate();
                return rows > 0;
            } catch (SQLException ex2) {
                Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex2);
            }
        }
        return false;
    }

    /**
     * Search medicines by name.
     * @param txt Search query
     * @return List of matching medicines
     */
    public List<Medicine> searchMedicinesByName(String txt) {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT MedicineID, MedicineName, Unit, Price, StockQuantity, Status FROM Medicines WHERE MedicineName LIKE ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + txt + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Medicine m = new Medicine(
                            rs.getInt("MedicineID"),
                            rs.getString("MedicineName"),
                            rs.getString("Unit"),
                            rs.getDouble("Price"),
                            rs.getInt("StockQuantity"),
                            rs.getBoolean("Status")
                    );
                    list.add(m);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicineDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
