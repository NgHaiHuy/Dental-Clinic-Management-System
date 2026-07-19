package model;

import java.sql.Timestamp;

/**
 * Model đại diện giao dịch thanh toán (bảng Payments trong DB).
 * Mỗi Invoice có đúng 1 Payment tương ứng.
 */
public class Payment {
    private int paymentID;
    private int invoiceID;              // Liên kết với hóa đơn
    private String paymentMethod;       // Tiền mặt, chuyển khoản...
    private Timestamp paymentDate;      // Thời điểm thanh toán
    private double amountPaid;          // Số tiền thực trả
    private String status;              // Completed, Refunded

    // Constructors
    public Payment() {
    }

    public Payment(int paymentID, int invoiceID, String paymentMethod, Timestamp paymentDate, double amountPaid, String status) {
        this.paymentID = paymentID;
        this.invoiceID = invoiceID;
        this.paymentMethod = paymentMethod;
        this.paymentDate = paymentDate;
        this.amountPaid = amountPaid;
        this.status = status;
    }

    // Getters and Setters
    public int getPaymentID() {
        return paymentID;
    }

    public void setPaymentID(int paymentID) {
        this.paymentID = paymentID;
    }

    public int getInvoiceID() {
        return invoiceID;
    }

    public void setInvoiceID(int invoiceID) {
        this.invoiceID = invoiceID;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    public double getAmountPaid() {
        return amountPaid;
    }

    public void setAmountPaid(double amountPaid) {
        this.amountPaid = amountPaid;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Payment{" +
                "paymentID=" + paymentID +
                ", invoiceID=" + invoiceID +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", paymentDate=" + paymentDate +
                ", amountPaid=" + amountPaid +
                ", status='" + status + '\'' +
                '}';
    }
}
