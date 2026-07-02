package model;

/**
 * Model class for StaffInfo (Specific details for Staff).
 */
public class StaffInfo {
    private int staffID;
    private String department;
    private String position;

    // Constructors
    public StaffInfo() {
    }

    public StaffInfo(int staffID, String department, String position) {
        this.staffID = staffID;
        this.department = department;
        this.position = position;
    }

    // Getters and Setters
    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    @Override
    public String toString() {
        return "StaffInfo{" +
                "staffID=" + staffID +
                ", department='" + department + '\'' +
                ", position='" + position + '\'' +
                '}';
    }
}
