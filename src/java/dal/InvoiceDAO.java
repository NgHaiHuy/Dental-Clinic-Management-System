package dal;

import context.DBContext;
import java.sql.*;
import model.Invoice;
import model.InvoiceDetail;

/**
 * Data Access Object for Invoices.
 */
public class InvoiceDAO extends DBContext {
    // Basic skeleton, will be fully implemented in Part 4.

    public int insertInvoice(Invoice invoice) throws SQLException {
        String sql = "INSERT INTO Invoices (RecordID, StaffID, TotalAmount, CreatedAt, Status) VALUES (?, NULL, ?, GETDATE(), 'Unpaid')";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoice.getRecordID());
            ps.setDouble(2, invoice.getTotalAmount());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public void insertInvoiceDetail(InvoiceDetail detail) throws SQLException {
        String sql = "INSERT INTO InvoiceDetails (InvoiceID, ItemType, ItemID, Quantity, Price) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, detail.getInvoiceID());
            ps.setString(2, detail.getItemType()); // 'SERVICE' hoặc 'MEDICINE'
            ps.setInt(3, detail.getItemID());
            ps.setInt(4, detail.getQuantity());
            ps.setDouble(5, detail.getPrice());
            ps.executeUpdate();
        }
    }
}
