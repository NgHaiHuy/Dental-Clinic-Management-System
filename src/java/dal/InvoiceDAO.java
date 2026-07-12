package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Invoice;
import model.InvoiceDetail;
import model.MedicalRecord;
import model.Payment;
import model.Service;
import model.Medicine;

/**
 * Data Access Object for Invoices and billing operations.
 */
public class InvoiceDAO extends DBContext {

    /**
     * Get all completed medical records that do not have a PAID invoice.
     * @return List of medical records requiring billing
     */
    public List<MedicalRecord> getBillingQueue() {
        List<MedicalRecord> list = new ArrayList<>();
        // Records that don't have any invoice, or have an unpaid invoice
        String sql = "SELECT r.RecordID, r.AppointmentID, r.DoctorID, r.Diagnosis, r.TreatmentPlan, r.CreatedAt, " +
                     "u.FullName AS DoctorName, c.FullName AS CustomerName " +
                     "FROM MedicalRecords r " +
                     "INNER JOIN Users u ON r.DoctorID = u.UserID " +
                     "INNER JOIN Appointments a ON r.AppointmentID = a.AppointmentID " +
                     "INNER JOIN Users c ON a.CustomerID = c.UserID " +
                     "WHERE r.RecordID NOT IN (SELECT RecordID FROM Invoices WHERE Status = 'Paid')";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MedicalRecord r = new MedicalRecord();
                r.setRecordID(rs.getInt("RecordID"));
                r.setAppointmentID(rs.getInt("AppointmentID"));
                r.setDoctorID(rs.getInt("DoctorID"));
                r.setDiagnosis(rs.getString("Diagnosis"));
                r.setTreatmentPlan(rs.getString("TreatmentPlan"));
                r.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                // Set temporary UI rendering helper values using getters/setters if they exist, 
                // or we can pass them in request attributes. Since the model might not have doctorName/customerName fields:
                // Let's check MedicalRecord.java properties to see if it has doctorName and customerName.
                // If not, we can save them in map or extend them. Let's check MedicalRecord.java.
                list.add(r);
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get a medical record by ID along with Doctor and Customer Names.
     */
    public MedicalRecord getBillingRecordDetails(int recordID) {
        String sql = "SELECT r.RecordID, r.AppointmentID, r.DoctorID, r.Diagnosis, r.TreatmentPlan, r.CreatedAt, " +
                     "u.FullName AS DoctorName, c.FullName AS CustomerName " +
                     "FROM MedicalRecords r " +
                     "INNER JOIN Users u ON r.DoctorID = u.UserID " +
                     "INNER JOIN Appointments a ON r.AppointmentID = a.AppointmentID " +
                     "INNER JOIN Users c ON a.CustomerID = c.UserID " +
                     "WHERE r.RecordID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, recordID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MedicalRecord r = new MedicalRecord();
                    r.setRecordID(rs.getInt("RecordID"));
                    r.setAppointmentID(rs.getInt("AppointmentID"));
                    r.setDoctorID(rs.getInt("DoctorID"));
                    r.setDiagnosis(rs.getString("Diagnosis"));
                    r.setTreatmentPlan(rs.getString("TreatmentPlan"));
                    r.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    return r;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Get Doctor Full Name and Customer Full Name for a Medical Record.
     */
    public String[] getDoctorAndCustomerNames(int recordID) {
        String[] names = new String[2]; // [DoctorName, CustomerName]
        String sql = "SELECT u.FullName AS DoctorName, c.FullName AS CustomerName " +
                     "FROM MedicalRecords r " +
                     "INNER JOIN Users u ON r.DoctorID = u.UserID " +
                     "INNER JOIN Appointments a ON r.AppointmentID = a.AppointmentID " +
                     "INNER JOIN Users c ON a.CustomerID = c.UserID " +
                     "WHERE r.RecordID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, recordID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    names[0] = rs.getString("DoctorName");
                    names[1] = rs.getString("CustomerName");
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return names;
    }

    /**
     * Get services chosen during the appointment.
     */
    public List<Service> getServicesByAppointment(int appointmentID) {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT s.ServiceID, s.ServiceName, s.Price, s.Description, s.Status " +
                     "FROM Services s " +
                     "INNER JOIN AppointmentServices aserv ON s.ServiceID = aserv.ServiceID " +
                     "WHERE aserv.AppointmentID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, appointmentID);
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
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get medicines prescribed in the medical record.
     */
    public List<InvoiceDetail> getPrescribedMedicines(int recordID) {
        List<InvoiceDetail> list = new ArrayList<>();
        String sql = "SELECT m.MedicineID, m.MedicineName, m.Price, m.Unit, pd.Quantity " +
                     "FROM PrescriptionDetails pd " +
                     "INNER JOIN Medicines m ON pd.MedicineID = m.MedicineID " +
                     "INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID " +
                     "WHERE p.RecordID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, recordID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceDetail detail = new InvoiceDetail();
                    detail.setItemType("MEDICINE");
                    detail.setItemID(rs.getInt("MedicineID"));
                    detail.setItemName(rs.getString("MedicineName") + " (" + rs.getString("Unit") + ")");
                    detail.setQuantity(rs.getInt("Quantity"));
                    detail.setPrice(rs.getDouble("Price"));
                    list.add(detail);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Perform the transaction of creating an Invoice, its Details, and the corresponding Payment.
     * @return true if transaction completes successfully, false otherwise
     */
    public boolean processBilling(Invoice invoice, List<InvoiceDetail> details, Payment payment) {
        String sqlInvoice = "INSERT INTO Invoices (RecordID, StaffID, TotalAmount, CreatedAt, Status) VALUES (?, ?, ?, GETDATE(), ?)";
        String sqlDetail = "INSERT INTO InvoiceDetails (InvoiceID, ItemType, ItemID, Quantity, Price) VALUES (?, ?, ?, ?, ?)";
        String sqlPayment = "INSERT INTO Payments (InvoiceID, PaymentMethod, PaymentDate, AmountPaid, Status) VALUES (?, ?, GETDATE(), ?, ?)";

        try {
            connection.setAutoCommit(false);

            // 1. Insert Invoice
            int invoiceID = -1;
            try (PreparedStatement ps = connection.prepareStatement(sqlInvoice, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, invoice.getRecordID());
                ps.setInt(2, invoice.getStaffID());
                ps.setDouble(3, invoice.getTotalAmount());
                ps.setString(4, invoice.getStatus());
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        invoiceID = rs.getInt(1);
                    }
                }
            }

            if (invoiceID == -1) {
                connection.rollback();
                return false;
            }

            // 2. Insert Invoice Details
            try (PreparedStatement ps = connection.prepareStatement(sqlDetail)) {
                for (InvoiceDetail d : details) {
                    ps.setInt(1, invoiceID);
                    ps.setString(2, d.getItemType());
                    ps.setInt(3, d.getItemID());
                    ps.setInt(4, d.getQuantity());
                    ps.setDouble(5, d.getPrice());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // 3. Insert Payment (if provided)
            if (payment != null) {
                try (PreparedStatement ps = connection.prepareStatement(sqlPayment)) {
                    ps.setInt(1, invoiceID);
                    ps.setString(2, payment.getPaymentMethod());
                    ps.setDouble(3, payment.getAmountPaid());
                    ps.setString(4, payment.getStatus());
                    ps.executeUpdate();
                }
            }

            connection.commit();
            return true;
        } catch (SQLException ex) {
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, rollbackEx);
            }
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException ex) {
                Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return false;
    }

    /**
     * Get invoice details for invoice preview / printing.
     */
    public Invoice getInvoiceByRecordID(int recordID) {
        String sql = "SELECT InvoiceID, RecordID, StaffID, TotalAmount, CreatedAt, Status FROM Invoices WHERE RecordID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, recordID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Invoice(
                            rs.getInt("InvoiceID"),
                            rs.getInt("RecordID"),
                            rs.getInt("StaffID"),
                            rs.getDouble("TotalAmount"),
                            rs.getTimestamp("CreatedAt"),
                            rs.getString("Status")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Get Invoice details list.
     */
    public List<InvoiceDetail> getInvoiceDetails(int invoiceID) {
        List<InvoiceDetail> list = new ArrayList<>();
        String sql = "SELECT InvoiceDetailID, InvoiceID, ItemType, ItemID, Quantity, Price FROM InvoiceDetails WHERE InvoiceID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, invoiceID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceDetail d = new InvoiceDetail(
                            rs.getInt("InvoiceDetailID"),
                            rs.getInt("InvoiceID"),
                            rs.getString("ItemType"),
                            rs.getInt("ItemID"),
                            rs.getInt("Quantity"),
                            rs.getDouble("Price")
                    );
                    list.add(d);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(InvoiceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
