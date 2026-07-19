package model;

/**
 * Model đại diện dịch vụ nha khoa (bảng Services trong DB).
 */
public class Service {
    private int serviceID;
    private String serviceName;     // Tên dịch vụ
    private double price;           // Đơn giá
    private String description;     // Mô tả chi tiết
    private boolean status;         // true = đang hoạt động, false = đã ngưng

    // Constructors
    public Service() {
    }

    public Service(int serviceID, String serviceName, double price, String description, boolean status) {
        this.serviceID = serviceID;
        this.serviceName = serviceName;
        this.price = price;
        this.description = description;
        this.status = status;
    }

    // Getters and Setters
    public int getServiceID() {
        return serviceID;
    }

    public void setServiceID(int serviceID) {
        this.serviceID = serviceID;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Service{" +
                "serviceID=" + serviceID +
                ", serviceName='" + serviceName + '\'' +
                ", price=" + price +
                ", description='" + description + '\'' +
                ", status=" + status +
                '}';
    }
}
