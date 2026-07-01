package model;

import java.sql.Timestamp;

/**
 * Model class for MedicalRecords.
 */
public class MedicalRecord {
    private int recordID;
    private int appointmentID;
    private int doctorID;
    private String diagnosis;
    private String treatmentPlan;
    private Timestamp createdAt;
    
    // Optional helper fields for billing / UI display
    private String patientName;
    private String doctorName;

    // Constructors
    public MedicalRecord() {
    }

    public MedicalRecord(int recordID, int appointmentID, int doctorID, String diagnosis, String treatmentPlan, Timestamp createdAt) {
        this.recordID = recordID;
        this.appointmentID = appointmentID;
        this.doctorID = doctorID;
        this.diagnosis = diagnosis;
        this.treatmentPlan = treatmentPlan;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getRecordID() {
        return recordID;
    }

    public void setRecordID(int recordID) {
        this.recordID = recordID;
    }

    public int getAppointmentID() {
        return appointmentID;
    }

    public void setAppointmentID(int appointmentID) {
        this.appointmentID = appointmentID;
    }

    public int getDoctorID() {
        return doctorID;
    }

    public void setDoctorID(int doctorID) {
        this.doctorID = doctorID;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getTreatmentPlan() {
        return treatmentPlan;
    }

    public void setTreatmentPlan(String treatmentPlan) {
        this.treatmentPlan = treatmentPlan;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "recordID=" + recordID +
                ", appointmentID=" + appointmentID +
                ", doctorID=" + doctorID +
                ", diagnosis='" + diagnosis + '\'' +
                ", treatmentPlan='" + treatmentPlan + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
