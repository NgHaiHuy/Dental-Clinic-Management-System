package model;

import java.sql.Date;
import java.sql.Time;
import java.util.List;

/**
 * Model class for Appointments.
 */
public class Appointment {
    private int appointmentID;
    private int customerID;
    private Integer doctorID; // Nullable if general checkup
    private Date appointmentDate;
    private Time appointmentTime;
    private String status; // Pending, Confirmed, Attended, Cancelled
    private String notes;

    // Additional properties for convenient rendering (not in DB column)
    private String customerName;
    private String doctorName;
    private String customerPhone;
    private String customerEmail;
    private List<Service> chosenServices;

    // Constructors
    public Appointment() {
    }

    public Appointment(int appointmentID, int customerID, Integer doctorID, Date appointmentDate, Time appointmentTime, String status, String notes) {
        this.appointmentID = appointmentID;
        this.customerID = customerID;
        this.doctorID = doctorID;
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;
        this.status = status;
        this.notes = notes;
    }

    // Getters and Setters
    public int getAppointmentID() {
        return appointmentID;
    }

    public void setAppointmentID(int appointmentID) {
        this.appointmentID = appointmentID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public Integer getDoctorID() {
        return doctorID;
    }

    public void setDoctorID(Integer doctorID) {
        this.doctorID = doctorID;
    }

    public Date getAppointmentDate() {
        return appointmentDate;
    }

    public void setAppointmentDate(Date appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public Time getAppointmentTime() {
        return appointmentTime;
    }

    public void setAppointmentTime(Time appointmentTime) {
        this.appointmentTime = appointmentTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public List<Service> getChosenServices() {
        return chosenServices;
    }

    public void setChosenServices(List<Service> chosenServices) {
        this.chosenServices = chosenServices;
    }

    private List<MedicalRecord> patientHistory;

    public List<MedicalRecord> getPatientHistory() {
        return patientHistory;
    }

    public void setPatientHistory(List<MedicalRecord> patientHistory) {
        this.patientHistory = patientHistory;
    }
}
