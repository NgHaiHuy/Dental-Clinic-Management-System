package model;

import java.sql.Date;

/**
 * Model class for DoctorSchedules.
 */
public class DoctorSchedule {
    private int scheduleID;
    private int doctorID;
    private Date workDate;
    private String shiftName; // Morning, Afternoon, FullDay
    private String status; // Active, Off

    // Constructors
    public DoctorSchedule() {
    }

    public DoctorSchedule(int scheduleID, int doctorID, Date workDate, String shiftName, String status) {
        this.scheduleID = scheduleID;
        this.doctorID = doctorID;
        this.workDate = workDate;
        this.shiftName = shiftName;
        this.status = status;
    }

    // Getters and Setters
    public int getScheduleID() {
        return scheduleID;
    }

    public void setScheduleID(int scheduleID) {
        this.scheduleID = scheduleID;
    }

    public int getDoctorID() {
        return doctorID;
    }

    public void setDoctorID(int doctorID) {
        this.doctorID = doctorID;
    }

    public Date getWorkDate() {
        return workDate;
    }

    public void setWorkDate(Date workDate) {
        this.workDate = workDate;
    }

    public String getShiftName() {
        return shiftName;
    }

    public void setShiftName(String shiftName) {
        this.shiftName = shiftName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "DoctorSchedule{" +
                "scheduleID=" + scheduleID +
                ", doctorID=" + doctorID +
                ", workDate=" + workDate +
                ", shiftName='" + shiftName + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
