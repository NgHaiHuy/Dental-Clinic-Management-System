/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import context.DBContext;
import java.sql.*;
import model.MedicalRecord;

/**
 *
 * @author hachi
 */
public class MedicalRecordDAO extends DBContext {

    public int insertMedicalRecord(MedicalRecord record) {

        String sql = "INSERT INTO MedicalRecord (appointmentID, doctorID, diagnosis, treatmentPlan, createdAt) "
                + "VALUES (?, ? , ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, record.getAppointmentID());
            ps.setInt(2, record.getDoctorID());
            ps.setString(3, record.getDiagnosis());
            ps.setString(4, record.getTreatmentPlan());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1); // Trả về RecordID
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return -1;
    }
}
