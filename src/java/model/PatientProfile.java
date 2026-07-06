package model;

import java.sql.Timestamp;

/**
 * Model class for PatientProfiles.
 */
public class PatientProfile {
    private int profileID;
    private int customerID;
    private String allergies;
    private String bloodType;
    private String medicalHistory;
    private String dentalHistory;
    private String notes;
    private Timestamp updatedAt;

    // Constructors
    public PatientProfile() {
    }

    public PatientProfile(int profileID, int customerID, String allergies, String bloodType, String medicalHistory, String dentalHistory, String notes, Timestamp updatedAt) {
        this.profileID = profileID;
        this.customerID = customerID;
        this.allergies = allergies;
        this.bloodType = bloodType;
        this.medicalHistory = medicalHistory;
        this.dentalHistory = dentalHistory;
        this.notes = notes;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getProfileID() {
        return profileID;
    }

    public void setProfileID(int profileID) {
        this.profileID = profileID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public String getAllergies() {
        return allergies;
    }

    public void setAllergies(String allergies) {
        this.allergies = allergies;
    }

    public String getBloodType() {
        return bloodType;
    }

    public void setBloodType(String bloodType) {
        this.bloodType = bloodType;
    }

    public String getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory;
    }

    public String getDentalHistory() {
        return dentalHistory;
    }

    public void setDentalHistory(String dentalHistory) {
        this.dentalHistory = dentalHistory;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "PatientProfile{" +
                "profileID=" + profileID +
                ", customerID=" + customerID +
                ", allergies='" + allergies + '\'' +
                ", bloodType='" + bloodType + '\'' +
                ", medicalHistory='" + medicalHistory + '\'' +
                ", dentalHistory='" + dentalHistory + '\'' +
                ", notes='" + notes + '\'' +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
