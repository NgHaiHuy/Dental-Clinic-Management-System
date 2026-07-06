package model;

import java.sql.Date;

/**
 * Model class for CustomerInfo (Specific details for Customers/Patients).
 */
public class CustomerInfo {
    private int customerID;
    private String address;
    private String gender;
    private Date dateOfBirth;

    // Constructors
    public CustomerInfo() {
    }

    public CustomerInfo(int customerID, String address, String gender, Date dateOfBirth) {
        this.customerID = customerID;
        this.address = address;
        this.gender = gender;
        this.dateOfBirth = dateOfBirth;
    }

    // Getters and Setters
    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    @Override
    public String toString() {
        return "CustomerInfo{" +
                "customerID=" + customerID +
                ", address='" + address + '\'' +
                ", gender='" + gender + '\'' +
                ", dateOfBirth=" + dateOfBirth +
                '}';
    }
}
