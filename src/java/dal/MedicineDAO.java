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
}
