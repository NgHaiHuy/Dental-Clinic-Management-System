package model;

import java.sql.Timestamp;

/**
 * Model class for Invoices.
 */
public class Invoice {
    private int invoiceID;
    private int recordID;
    private int staffID;
    private double totalAmount;
    private Timestamp createdAt;
    private String status; // Paid, Unpaid

    // Constructors
    public Invoice() {
    }

    public Invoice(int invoiceID, int recordID, int staffID, double totalAmount, Timestamp createdAt, String status) {
        this.invoiceID = invoiceID;
        this.recordID = recordID;
        this.staffID = staffID;
        this.totalAmount = totalAmount;
        this.createdAt = createdAt;
        this.status = status;
    }

    // Getters and Setters
    public int getInvoiceID() {
        return invoiceID;
    }

    public void setInvoiceID(int invoiceID) {
        this.invoiceID = invoiceID;
    }

    public int getRecordID() {
        return recordID;
    }

    public void setRecordID(int recordID) {
        this.recordID = recordID;
    }

    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Invoice{" +
                "invoiceID=" + invoiceID +
                ", recordID=" + recordID +
                ", staffID=" + staffID +
                ", totalAmount=" + totalAmount +
                ", createdAt=" + createdAt +
                ", status='" + status + '\'' +
                '}';
    }
}
