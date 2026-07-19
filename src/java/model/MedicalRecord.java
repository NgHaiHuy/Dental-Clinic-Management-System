package model;

import java.sql.Timestamp;
import java.util.List;

/**
 * Model đại diện bản ghi khám bệnh (bảng MedicalRecords trong DB).
 * Do bác sĩ tạo sau khi khám xong, là cơ sở để xuất hóa đơn.
 */
public class MedicalRecord {
    private int recordID;           // Mã bản ghi khám
    private int appointmentID;      // Liịch hẹn tương ứng
    private int doctorID;           // Bác sĩ điều trị
    private String diagnosis;       // Chẩn đoán
    private String treatmentPlan;   // Phác đồ điều trị
    private Timestamp createdAt;    // Thời điểm tạo bản ghi
    
    // Field hỗ trợ hiển thị, không lưu vào DB
    private String patientName;     // Tên bệnh nhân (để hiển thị)
    private String doctorName;      // Tên bác sĩ (để hiển thị)
    private List<PrescriptionDetail> medicines; // Danh sách thuốc kê đơn

    // Constructors
    public MedicalRecord() {
    }

    public MedicalRecord(int recordID, int appointmentID, int doctorID, String diagnosis, String treatmentPlan, Timestamp createdAt) {
        this.recordID = recordID;
        this.appointmentID = appointmentID;
        this.doctorID = doctorID;
        this.diagnosis = diagnosis;
        this.treatmentPlan = treatmentPlan;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getRecordID() {
        return recordID;
    }

    public void setRecordID(int recordID) {
        this.recordID = recordID;
    }

    public int getAppointmentID() {
        return appointmentID;
    }

    public void setAppointmentID(int appointmentID) {
        this.appointmentID = appointmentID;
    }

    public int getDoctorID() {
        return doctorID;
    }

    public void setDoctorID(int doctorID) {
        this.doctorID = doctorID;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getTreatmentPlan() {
        return treatmentPlan;
    }

    public void setTreatmentPlan(String treatmentPlan) {
        this.treatmentPlan = treatmentPlan;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public List<PrescriptionDetail> getMedicines() {
        return medicines;
    }

    public void setMedicines(List<PrescriptionDetail> medicines) {
        this.medicines = medicines;
    }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "recordID=" + recordID +
                ", appointmentID=" + appointmentID +
                ", doctorID=" + doctorID +
                ", diagnosis='" + diagnosis + '\'' +
                ", treatmentPlan='" + treatmentPlan + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
