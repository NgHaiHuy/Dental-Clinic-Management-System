package model;

import java.sql.Timestamp;

/**
 * Model class for MedicalSupplies (Inventory Management).
 */
public class MedicalSupply {
    private int supplyID;
    private String supplyName;
    private String unit;
    private int quantity;
    private int minQuantity;
    private double unitPrice;
    private String supplier;
    private Timestamp lastUpdated;

    // Constructors
    public MedicalSupply() {
    }

    public MedicalSupply(int supplyID, String supplyName, String unit, int quantity, int minQuantity, double unitPrice, String supplier, Timestamp lastUpdated) {
        this.supplyID = supplyID;
        this.supplyName = supplyName;
        this.unit = unit;
        this.quantity = quantity;
        this.minQuantity = minQuantity;
        this.unitPrice = unitPrice;
        this.supplier = supplier;
        this.lastUpdated = lastUpdated;
    }

    // Getters and Setters
    public int getSupplyID() {
        return supplyID;
    }

    public void setSupplyID(int supplyID) {
        this.supplyID = supplyID;
    }

    public String getSupplyName() {
        return supplyName;
    }

    public void setSupplyName(String supplyName) {
        this.supplyName = supplyName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getMinQuantity() {
        return minQuantity;
    }

    public void setMinQuantity(int minQuantity) {
        this.minQuantity = minQuantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getSupplier() {
        return supplier;
    }

    public void setSupplier(String supplier) {
        this.supplier = supplier;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    @Override
    public String toString() {
        return "MedicalSupply{" +
                "supplyID=" + supplyID +
                ", supplyName='" + supplyName + '\'' +
                ", unit='" + unit + '\'' +
                ", quantity=" + quantity +
                ", minQuantity=" + minQuantity +
                ", unitPrice=" + unitPrice +
                ", supplier='" + supplier + '\'' +
                ", lastUpdated=" + lastUpdated +
                '}';
    }
}
