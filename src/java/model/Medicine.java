package model;

/**
 * Model class for Medicines.
 */
public class Medicine {
    private int medicineID;
    private String medicineName;
    private String unit;
    private double price;
    private int stockQuantity;
    private boolean status; // 1: Selling, 0: Discontinued

    // Constructors
    public Medicine() {
    }

    public Medicine(int medicineID, String medicineName, String unit, double price, int stockQuantity, boolean status) {
        this.medicineID = medicineID;
        this.medicineName = medicineName;
        this.unit = unit;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.status = status;
    }

    // Getters and Setters
    public int getMedicineID() {
        return medicineID;
    }

    public void setMedicineID(int medicineID) {
        this.medicineID = medicineID;
    }

    public String getMedicineName() {
        return medicineName;
    }

    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Medicine{" +
                "medicineID=" + medicineID +
                ", medicineName='" + medicineName + '\'' +
                ", unit='" + unit + '\'' +
                ", price=" + price +
                ", stockQuantity=" + stockQuantity +
                ", status=" + status +
                '}';
    }
}
