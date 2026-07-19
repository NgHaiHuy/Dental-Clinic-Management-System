package model;

/**
 * Model đại diện thuốc nha khoa (bảng Medicines trong DB).
 */
public class Medicine {
    private int medicineID;
    private String medicineName;        // Tên thuốc
    private String unit;                // Đơn vị: viên, hộp, tuýp, chai...
    private double price;               // Đơn giá
    private int stockQuantity;          // Số lượng tồn kho
    private boolean status;             // true = đang bán, false = ngưng bán
    private String imagePath;           // Đường dẫn ảnh sản phẩm

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

    public Medicine(int medicineID, String medicineName, String unit, double price, int stockQuantity, boolean status, String imagePath) {
        this.medicineID = medicineID;
        this.medicineName = medicineName;
        this.unit = unit;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.status = status;
        this.imagePath = imagePath;
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

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
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
                ", imagePath='" + imagePath + '\'' +
                '}';
    }
}
