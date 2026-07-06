package model;

import java.sql.Timestamp;

/**
 * Model class for Prescriptions.
 */
public class Prescription {
    private int prescriptionID;
    private int recordID;
    private Timestamp createdAt;

    // Constructors
    public Prescription() {
    }

    public Prescription(int prescriptionID, int recordID, Timestamp createdAt) {
        this.prescriptionID = prescriptionID;
        this.recordID = recordID;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getPrescriptionID() {
        return prescriptionID;
    }

    public void setPrescriptionID(int prescriptionID) {
        this.prescriptionID = prescriptionID;
    }

    public int getRecordID() {
        return recordID;
    }

    public void setRecordID(int recordID) {
        this.recordID = recordID;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Prescription{" +
                "prescriptionID=" + prescriptionID +
                ", recordID=" + recordID +
                ", createdAt=" + createdAt +
                '}';
    }
}
