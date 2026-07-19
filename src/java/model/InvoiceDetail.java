package model;

/**
 * Model đại diện từng dòng chi tiết hóa đơn (bảng InvoiceDetails).
 * Mỗi dòng là 1 dịch vụ hoặc 1 loại thuốc được chọn.
 */
public class InvoiceDetail {
    private int invoiceDetailID;
    private int invoiceID;
    private String itemType;    // "SERVICE" hoặc "MEDICINE"
    private int itemID;         // ServiceID hoặc MedicineID tương ứng
    private int quantity;       // Số lượng
    private double price;       // Đơn giá tại thời điểm thanh toán
    
    // Field hỗ trợ hiển thị trên UI, không lưu vào DB
    private String itemName;
    private int stockQuantity;

    // Constructors
    public InvoiceDetail() {
    }

    public InvoiceDetail(int invoiceDetailID, int invoiceID, String itemType, int itemID, int quantity, double price) {
        this.invoiceDetailID = invoiceDetailID;
        this.invoiceID = invoiceID;
        this.itemType = itemType;
        this.itemID = itemID;
        this.quantity = quantity;
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    // Getters and Setters
    public int getInvoiceDetailID() {
        return invoiceDetailID;
    }

    public void setInvoiceDetailID(int invoiceDetailID) {
        this.invoiceDetailID = invoiceDetailID;
    }

    public int getInvoiceID() {
        return invoiceID;
    }

    public void setInvoiceID(int invoiceID) {
        this.invoiceID = invoiceID;
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public int getItemID() {
        return itemID;
    }

    public void setItemID(int itemID) {
        this.itemID = itemID;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    @Override
    public String toString() {
        return "InvoiceDetail{" +
                "invoiceDetailID=" + invoiceDetailID +
                ", invoiceID=" + invoiceID +
                ", itemType='" + itemType + '\'' +
                ", itemID=" + itemID +
                ", quantity=" + quantity +
                ", price=" + price +
                '}';
    }
}
