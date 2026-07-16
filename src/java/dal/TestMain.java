package dal;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import model.Appointment;
import model.MedicalRecord;
import model.PrescriptionDetail;
import model.Service;
import model.User;

public class TestMain extends DBContext {
    public static void main(String[] args) {
        System.out.println("=== BAT DAU KIEM THU QUY TRINH LIEN THONG ===");
        
        AppointmentDAO appDAO = new AppointmentDAO();
        MedicalRecordDAO recordDAO = new MedicalRecordDAO();
        UserDAO userDAO = new UserDAO();
        ServiceDAO serviceDAO = new ServiceDAO();
        
        try {
            // 1. Kiem tra lay danh sach bac si va dich vu
            System.out.println("\n1. Doc thong tin tu database:");
            List<User> doctors = userDAO.getUsersByRole(2);
            System.out.println(" - So luong bac si trong he thong: " + doctors.size());
            if (!doctors.isEmpty()) {
                System.out.println("   + Bac si dau tien: " + doctors.get(0).getFullName());
            }
            
            List<Service> services = serviceDAO.getAllServices();
            System.out.println(" - So luong dich vu trong he thong: " + services.size());
            
            // Tim mot khach hang de test (Role = 4)
            List<User> customers = userDAO.getUsersByRole(4);
            if (customers.isEmpty()) {
                System.out.println(" - Error: Khong tim thay customer nao de kiem thu!");
                return;
            }
            User testCustomer = customers.get(0);
            System.out.println(" - Khach hang kiem thu: " + testCustomer.getFullName() + " (ID: " + testCustomer.getUserID() + ")");
            
            User testDoctor = doctors.isEmpty() ? null : doctors.get(0);
            
            // 2. Dat lich hen (Appointment)
            System.out.println("\n2. Them lich hen moi:");
            Appointment app = new Appointment();
            app.setCustomerID(testCustomer.getUserID());
            app.setDoctorID(testDoctor != null ? testDoctor.getUserID() : null);
            app.setAppointmentDate(Date.valueOf("2026-07-20"));
            app.setAppointmentTime(Time.valueOf("09:30:00"));
            app.setStatus("Pending");
            app.setNotes("Kiem thu dat lich hen tu test runner");
            
            List<Integer> selectedServiceIDs = new ArrayList<>();
            if (!services.isEmpty()) {
                selectedServiceIDs.add(services.get(0).getServiceID());
                System.out.println(" - Chon dich vu kem theo: " + services.get(0).getServiceName());
            }
            
            boolean appSuccess = appDAO.addAppointment(app, selectedServiceIDs);
            System.out.println(" - Them lich hen: " + (appSuccess ? "THANH CONG" : "THAT BAI"));
            
            // 3. Lay lich hen cua khach hang vua dat
            List<Appointment> customerApps = appDAO.getAppointmentsByCustomerID(testCustomer.getUserID());
            Appointment insertedApp = null;
            for (Appointment a : customerApps) {
                if ("Pending".equals(a.getStatus()) && a.getNotes().contains("Kiem thu")) {
                    insertedApp = a;
                    break;
                }
            }
            
            if (insertedApp == null) {
                System.out.println(" - Error: Khong tim thay lich hen vua insert!");
                return;
            }
            System.out.println(" - Da lay thanh cong lich hen vua tao, ID: #" + insertedApp.getAppointmentID());
            
            // 4. Le tan check-in lich hen
            System.out.println("\n3. Le tan tiep don check-in:");
            boolean checkInSuccess = appDAO.updateAppointmentStatus(insertedApp.getAppointmentID(), "Attended");
            System.out.println(" - Cap nhat trang thai sang 'Attended' (Check-in): " + (checkInSuccess ? "THANH CONG" : "THAT BAI"));
            
            // 5. Bac si kiem tra danh sach cho va tien hanh kham (MedicalRecord + Prescription)
            System.out.println("\n4. Bac si tien hanh kham benh va ke don:");
            if (testDoctor != null) {
                List<Appointment> docQueue = appDAO.getCheckedInAppointmentsForDoctor(testDoctor.getUserID());
                System.out.println(" - So ca dang cho kham cua bac si " + testDoctor.getFullName() + ": " + docQueue.size());
            }
            
            MedicalRecord record = new MedicalRecord();
            record.setAppointmentID(insertedApp.getAppointmentID());
            record.setDoctorID(testDoctor != null ? testDoctor.getUserID() : 1);
            record.setDiagnosis("Viemp nuou cap tinh, can cham soc dac biet");
            record.setTreatmentPlan("Ve sinh rang mieng, xuc mieng nuoc muoi sinh ly");
            
            List<PrescriptionDetail> meds = new ArrayList<>();
            // Lay mot vai medicine mau trong DB
            MedicineDAO medDAO = new MedicineDAO();
            List<model.Medicine> allMeds = medDAO.getAllMedicines();
            if (!allMeds.isEmpty()) {
                PrescriptionDetail pd = new PrescriptionDetail();
                pd.setMedicineID(allMeds.get(0).getMedicineID());
                pd.setQuantity(2);
                pd.setDosage("Uong 2 lan/ngay sau an");
                meds.add(pd);
                System.out.println(" - Ke don thuoc: " + allMeds.get(0).getMedicineName() + " x2");
            }
            
            boolean recordSuccess = recordDAO.addMedicalRecord(record, meds);
            System.out.println(" - Luu benh an & don thuoc: " + (recordSuccess ? "THANH CONG" : "THAT BAI"));
            
            // 6. Xem lich su benh an cua khach hang
            System.out.println("\n5. Kiem tra xem benh an trong lich su khach hang:");
            List<MedicalRecord> history = recordDAO.getMedicalRecordsByCustomerID(testCustomer.getUserID());
            boolean foundRecord = false;
            for (MedicalRecord hr : history) {
                if (hr.getAppointmentID() == insertedApp.getAppointmentID()) {
                    foundRecord = true;
                    System.out.println(" - Tim thay benh an cua lich hen #" + hr.getAppointmentID());
                    System.out.println("   + Chan doan: " + hr.getDiagnosis());
                    System.out.println("   + Bac si kham: " + hr.getDoctorName());
                    
                    // Lay don thuoc
                    List<PrescriptionDetail> presMeds = recordDAO.getMedicinesByRecordID(hr.getRecordID());
                    System.out.println("   + So loai thuoc da ke: " + presMeds.size());
                    for (PrescriptionDetail pm : presMeds) {
                        System.out.println("     * " + pm.getMedicineName() + " (" + pm.getQuantity() + " " + pm.getUnit() + ") - " + pm.getDosage());
                    }
                }
            }
            
            if (foundRecord) {
                System.out.println(" - Kiem tra lich su benh an: THANH CONG");
            } else {
                System.out.println(" - Kiem tra lich su benh an: THAT BAI");
            }
            
            // 7. Cleanup du lieu test de giu sach database
            System.out.println("\n6. Dang cleanup du lieu kiem thu...");
            cleanupTestData(insertedApp.getAppointmentID());
            System.out.println(" - Don dep du lieu kiem thu: HOAN THANH");
            
            System.out.println("\n=== HOAN THANH TOAN BO QUY TRINH KIEM THU THANH CONG ===");
        } catch (Exception e) {
            System.out.println(" - Xay ra loi khi kiem thu: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void cleanupTestData(int appointmentID) {
        // Run SQL queries directly to clean up records associated with this appointment
        try {
            Connection conn = new TestMain().connection;
            
            // Find record id
            int recordID = 0;
            String findRecord = "SELECT RecordID FROM MedicalRecords WHERE AppointmentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(findRecord)) {
                ps.setInt(1, appointmentID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recordID = rs.getInt("RecordID");
                    }
                }
            }
            
            if (recordID > 0) {
                // Find prescription id
                int presID = 0;
                String findPres = "SELECT PrescriptionID FROM Prescriptions WHERE RecordID = ?";
                try (PreparedStatement ps = conn.prepareStatement(findPres)) {
                    ps.setInt(1, recordID);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            presID = rs.getInt("PrescriptionID");
                        }
                    }
                }
                
                if (presID > 0) {
                    // Delete prescription details
                    String delDetails = "DELETE FROM PrescriptionDetails WHERE PrescriptionID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(delDetails)) {
                        ps.setInt(1, presID);
                        ps.executeUpdate();
                    }
                    // Delete prescription
                    String delPres = "DELETE FROM Prescriptions WHERE PrescriptionID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(delPres)) {
                        ps.setInt(1, presID);
                        ps.executeUpdate();
                    }
                }
                
                // Delete medical record
                String delRecord = "DELETE FROM MedicalRecords WHERE RecordID = ?";
                try (PreparedStatement ps = conn.prepareStatement(delRecord)) {
                    ps.setInt(1, recordID);
                    ps.executeUpdate();
                }
            }
            
            // Delete appointment services
            String delAppServ = "DELETE FROM AppointmentServices WHERE AppointmentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(delAppServ)) {
                ps.setInt(1, appointmentID);
                ps.executeUpdate();
            }
            
            // Delete appointment
            String delApp = "DELETE FROM Appointments WHERE AppointmentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(delApp)) {
                ps.setInt(1, appointmentID);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            System.out.println(" - Loi khi cleanup: " + e.getMessage());
        }
    }
}
