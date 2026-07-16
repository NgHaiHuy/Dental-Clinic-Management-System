package dal;

import context.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.MedicalRecord;
import model.PrescriptionDetail;
import model.Service;

public class MedicalRecordDAO extends DBContext {

    /**
     * Inserts a MedicalRecord, associated Prescription, and PrescriptionDetails inside a transaction.
     */
    public boolean addMedicalRecord(MedicalRecord record, List<PrescriptionDetail> medicines) {
        String insertRecordSql = "INSERT INTO MedicalRecords (AppointmentID, DoctorID, Diagnosis, TreatmentPlan) "
                               + "VALUES (?, ?, ?, ?)";
        String insertPrescriptionSql = "INSERT INTO Prescriptions (RecordID) VALUES (?)";
        String insertPrescriptionDetailSql = "INSERT INTO PrescriptionDetails (PrescriptionID, MedicineID, Quantity, Dosage) "
                                           + "VALUES (?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement psRecord = null;
        PreparedStatement psPres = null;
        PreparedStatement psDetail = null;
        ResultSet rsRecordKeys = null;
        ResultSet rsPresKeys = null;
        
        try {
            conn = connection;
            conn.setAutoCommit(false);
            
            // 1. Insert Medical Record
            psRecord = conn.prepareStatement(insertRecordSql, Statement.RETURN_GENERATED_KEYS);
            psRecord.setInt(1, record.getAppointmentID());
            psRecord.setInt(2, record.getDoctorID());
            psRecord.setString(3, record.getDiagnosis());
            psRecord.setString(4, record.getTreatmentPlan());
            
            int affected = psRecord.executeUpdate();
            if (affected == 0) {
                conn.rollback();
                return false;
            }
            
            rsRecordKeys = psRecord.getGeneratedKeys();
            int recordID = 0;
            if (rsRecordKeys.next()) {
                recordID = rsRecordKeys.getInt(1);
            } else {
                conn.rollback();
                return false;
            }
            
            // 2. If there are medicines, insert Prescription and details
            if (medicines != null && !medicines.isEmpty()) {
                psPres = conn.prepareStatement(insertPrescriptionSql, Statement.RETURN_GENERATED_KEYS);
                psPres.setInt(1, recordID);
                affected = psPres.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                
                rsPresKeys = psPres.getGeneratedKeys();
                int prescriptionID = 0;
                if (rsPresKeys.next()) {
                    prescriptionID = rsPresKeys.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
                
                psDetail = conn.prepareStatement(insertPrescriptionDetailSql);
                for (PrescriptionDetail m : medicines) {
                    psDetail.setInt(1, prescriptionID);
                    psDetail.setInt(2, m.getMedicineID());
                    psDetail.setInt(3, m.getQuantity());
                    psDetail.setString(4, m.getDosage() != null ? m.getDosage() : "As directed");
                    psDetail.addBatch();
                }
                psDetail.executeBatch();
            }
            
            conn.commit();
            return true;
        } catch (SQLException ex) {
            Logger.getLogger(MedicalRecordDAO.class.getName()).log(Level.SEVERE, null, ex);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException e) {
                    Logger.getLogger(MedicalRecordDAO.class.getName()).log(Level.SEVERE, null, e);
                }
            }
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
                if (rsRecordKeys != null) rsRecordKeys.close();
                if (rsPresKeys != null) rsPresKeys.close();
                if (psRecord != null) psRecord.close();
                if (psPres != null) psPres.close();
                if (psDetail != null) psDetail.close();
            } catch (SQLException e) {
                Logger.getLogger(MedicalRecordDAO.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    }

    /**
     * Get complete medical record history for a patient.
     */
    public List<MedicalRecord> getMedicalRecordsByCustomerID(int customerID) {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT mr.RecordID, mr.AppointmentID, mr.DoctorID, mr.Diagnosis, mr.TreatmentPlan, mr.CreatedAt, "
                   + "ud.FullName AS DoctorName "
                   + "FROM MedicalRecords mr "
                   + "INNER JOIN Appointments a ON mr.AppointmentID = a.AppointmentID "
                   + "INNER JOIN Users ud ON mr.DoctorID = ud.UserID "
                   + "WHERE a.CustomerID = ? "
                   + "ORDER BY mr.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalRecord mr = new MedicalRecord();
                    mr.setRecordID(rs.getInt("RecordID"));
                    mr.setAppointmentID(rs.getInt("AppointmentID"));
                    mr.setDoctorID(rs.getInt("DoctorID"));
                    mr.setDiagnosis(rs.getString("Diagnosis"));
                    mr.setTreatmentPlan(rs.getString("TreatmentPlan"));
                    mr.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    mr.setDoctorName(rs.getString("DoctorName"));
                    list.add(mr);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicalRecordDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Get medicines for a medical record.
     */
    public List<PrescriptionDetail> getMedicinesByRecordID(int recordID) {
        List<PrescriptionDetail> list = new ArrayList<>();
        String sql = "SELECT pd.MedicineID, pd.Quantity, pd.Dosage, m.MedicineName, m.Unit, m.Price "
                   + "FROM PrescriptionDetails pd "
                   + "INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID "
                   + "INNER JOIN Medicines m ON pd.MedicineID = m.MedicineID "
                   + "WHERE p.RecordID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, recordID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PrescriptionDetail pd = new PrescriptionDetail();
                    pd.setMedicineID(rs.getInt("MedicineID"));
                    pd.setQuantity(rs.getInt("Quantity"));
                    pd.setDosage(rs.getString("Dosage"));
                    pd.setMedicineName(rs.getString("MedicineName"));
                    pd.setUnit(rs.getString("Unit"));
                    pd.setPrice(rs.getDouble("Price"));
                    list.add(pd);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(MedicalRecordDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
