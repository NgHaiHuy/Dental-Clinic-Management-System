package model;

import java.sql.Date;

/**
 * Model class for LabOrders.
 */
public class LabOrder {
    private int labOrderID;
    private int recordID;
    private String labName;
    private String material;
    private double cost;
    private Date orderDate;
    private Date expectedDeliveryDate;
    private Date actualDeliveryDate;
    private String status; // Ordered, Completed, Cancelled

    // Constructors
    public LabOrder() {
    }

    public LabOrder(int labOrderID, int recordID, String labName, String material, double cost, Date orderDate, Date expectedDeliveryDate, Date actualDeliveryDate, String status) {
        this.labOrderID = labOrderID;
        this.recordID = recordID;
        this.labName = labName;
        this.material = material;
        this.cost = cost;
        this.orderDate = orderDate;
        this.expectedDeliveryDate = expectedDeliveryDate;
        this.actualDeliveryDate = actualDeliveryDate;
        this.status = status;
    }

    // Getters and Setters
    public int getLabOrderID() {
        return labOrderID;
    }

    public void setLabOrderID(int labOrderID) {
        this.labOrderID = labOrderID;
    }

    public int getRecordID() {
        return recordID;
    }

    public void setRecordID(int recordID) {
        this.recordID = recordID;
    }

    public String getLabName() {
        return labName;
    }

    public void setLabName(String labName) {
        this.labName = labName;
    }

    public String getMaterial() {
        return material;
    }

    public void setMaterial(String material) {
        this.material = material;
    }

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public Date getExpectedDeliveryDate() {
        return expectedDeliveryDate;
    }

    public void setExpectedDeliveryDate(Date expectedDeliveryDate) {
        this.expectedDeliveryDate = expectedDeliveryDate;
    }

    public Date getActualDeliveryDate() {
        return actualDeliveryDate;
    }

    public void setActualDeliveryDate(Date actualDeliveryDate) {
        this.actualDeliveryDate = actualDeliveryDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "LabOrder{" +
                "labOrderID=" + labOrderID +
                ", recordID=" + recordID +
                ", labName='" + labName + '\'' +
                ", material='" + material + '\'' +
                ", cost=" + cost +
                ", orderDate=" + orderDate +
                ", expectedDeliveryDate=" + expectedDeliveryDate +
                ", actualDeliveryDate=" + actualDeliveryDate +
                ", status='" + status + '\'' +
                '}';
    }
}
