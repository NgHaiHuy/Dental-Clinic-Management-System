package model;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;

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
    private int customerID;
    private String customerPhone;
    private LocalDate appointmentDate;
    private LocalTime appointmentTime;
    private String appointmentNotes;
    private String serviceNames;

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

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public LocalDate getAppointmentDate() {
        return appointmentDate;
    }

    public void setAppointmentDate(LocalDate appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public LocalTime getAppointmentTime() {
        return appointmentTime;
    }

    public void setAppointmentTime(LocalTime appointmentTime) {
        this.appointmentTime = appointmentTime;
    }

    public String getAppointmentNotes() {
        return appointmentNotes;
    }

    public void setAppointmentNotes(String appointmentNotes) {
        this.appointmentNotes = appointmentNotes;
    }

    public String getServiceNames() {
        return serviceNames;
    }

    public void setServiceNames(String serviceNames) {
        this.serviceNames = serviceNames;
    }

    public boolean hasTreatmentPlan() {
        return treatmentPlan != null && !treatmentPlan.trim().isEmpty();
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
