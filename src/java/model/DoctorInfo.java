package model;

/**
 * Model class for DoctorInfo (Specific details for Doctors).
 */
public class DoctorInfo {
    private int doctorID;
    private String specialization;
    private int experienceYears;
    private String biography;

    // Constructors
    public DoctorInfo() {
    }

    public DoctorInfo(int doctorID, String specialization, int experienceYears, String biography) {
        this.doctorID = doctorID;
        this.specialization = specialization;
        this.experienceYears = experienceYears;
        this.biography = biography;
    }

    // Getters and Setters
    public int getDoctorID() {
        return doctorID;
    }

    public void setDoctorID(int doctorID) {
        this.doctorID = doctorID;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    @Override
    public String toString() {
        return "DoctorInfo{" +
                "doctorID=" + doctorID +
                ", specialization='" + specialization + '\'' +
                ", experienceYears=" + experienceYears +
                ", biography='" + biography + '\'' +
                '}';
    }
}
