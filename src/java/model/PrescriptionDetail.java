package model;

/**
 * Model class for PrescriptionDetails.
 */
public class PrescriptionDetail {
    private int prescriptionID;
    private int medicineID;
    private int quantity;
    private String dosage;
    
    // Optional helper fields for UI
    private String medicineName;
    private String unit;
    private double price;

    // Constructors
    public PrescriptionDetail() {
    }

    public PrescriptionDetail(int prescriptionID, int medicineID, int quantity, String dosage) {
        this.prescriptionID = prescriptionID;
        this.medicineID = medicineID;
        this.quantity = quantity;
        this.dosage = dosage;
    }

    // Getters and Setters
    public int getPrescriptionID() {
        return prescriptionID;
    }

    public void setPrescriptionID(int prescriptionID) {
        this.prescriptionID = prescriptionID;
    }

    public int getMedicineID() {
        return medicineID;
    }

    public void setMedicineID(int medicineID) {
        this.medicineID = medicineID;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
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

    @Override
    public String toString() {
        return "PrescriptionDetail{" +
                "prescriptionID=" + prescriptionID +
                ", medicineID=" + medicineID +
                ", quantity=" + quantity +
                ", dosage='" + dosage + '\'' +
                '}';
    }
}
