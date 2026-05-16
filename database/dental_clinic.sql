/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/SQLTemplate.sql to edit this template
 */
/**
 * Author:  Nguye
 * Created: May 14, 2026
 */

-- KHỞI TẠO CƠ SỞ DỮ LIỆU
CREATE DATABASE DentalClinicDB;
GO
USE DentalClinicDB;
GO

-- 1. NHÓM QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN

-- Bảng Roles (Danh sách quyền)
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL
);

-- Bảng Users (Người dùng hệ thống)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NULL,
    RoleID INT FOREIGN KEY REFERENCES Roles(RoleID)
);

-- 2. NHÓM DANH MỤC (DỊCH VỤ & THUỐC)

-- Bảng Services (Danh mục dịch vụ nha khoa)
CREATE TABLE Services (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(150) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Status BIT DEFAULT 1 -- 1: Đang hoạt động, 0: Ngừng cung cấp
);

-- Bảng Medicines (Danh mục thuốc)
CREATE TABLE Medicines (
    MedicineID INT IDENTITY(1,1) PRIMARY KEY,
    MedicineName NVARCHAR(150) NOT NULL,
    Unit NVARCHAR(30) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    Status BIT DEFAULT 1 -- 1: Đang bán, 0: Ngừng bán
);

-- 3. NHÓM QUẢN LÝ LỊCH HẸN (APPOINTMENTS)

-- Bảng Appointments (Lịch hẹn khám)
CREATE TABLE Appointments (
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Users(UserID),
    DoctorID INT NULL FOREIGN KEY REFERENCES Users(UserID), -- Null nếu khám tổng quát
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Confirmed, Attended, Cancelled
    Notes NVARCHAR(MAX) NULL
);

-- Bảng AppointmentServices (Chi tiết dịch vụ chọn trước khi đặt lịch)
CREATE TABLE AppointmentServices (
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    ServiceID INT FOREIGN KEY REFERENCES Services(ServiceID),
    PRIMARY KEY (AppointmentID, ServiceID) -- Khóa chính phức hợp
);

-- 4. NHÓM KẾT QUẢ KHÁM & KÊ ĐƠN

-- Bảng MedicalRecords (Hồ sơ bệnh án / Kết quả khám)
CREATE TABLE MedicalRecords (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    DoctorID INT FOREIGN KEY REFERENCES Users(UserID),
    Diagnosis NVARCHAR(MAX) NOT NULL,
    TreatmentPlan NVARCHAR(MAX) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng Prescriptions (Đơn thuốc)
CREATE TABLE Prescriptions (
    PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
    RecordID INT FOREIGN KEY REFERENCES MedicalRecords(RecordID),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng PrescriptionDetails (Chi tiết đơn thuốc do Bác sĩ kê)
CREATE TABLE PrescriptionDetails (
    PrescriptionID INT FOREIGN KEY REFERENCES Prescriptions(PrescriptionID),
    MedicineID INT FOREIGN KEY REFERENCES Medicines(MedicineID),
    Quantity INT NOT NULL,
    Dosage NVARCHAR(255) NOT NULL,
    PRIMARY KEY (PrescriptionID, MedicineID) -- Khóa chính phức hợp
);

-- 5. NHÓM HÓA ĐƠN & THANH TOÁN

-- Bảng Invoices (Hóa đơn thanh toán)
CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    RecordID INT FOREIGN KEY REFERENCES MedicalRecords(RecordID),
    StaffID INT FOREIGN KEY REFERENCES Users(UserID),
    TotalAmount DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'Unpaid' -- Paid, Unpaid
);

-- Bảng InvoiceDetails (Chi tiết dòng hóa đơn)
CREATE TABLE InvoiceDetails (
    InvoiceDetailID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceID INT FOREIGN KEY REFERENCES Invoices(InvoiceID),
    ItemType VARCHAR(20) NOT NULL, -- 'SERVICE' hoặc 'MEDICINE'
    ItemID INT NOT NULL, -- Cột này không dùng khóa ngoại trực tiếp vì có thể trỏ tới cả Services hoặc Medicines
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
);
GO

-- THÊM DỮ LIỆU KHỞI TẠO MẪU CHO ROLES (DATA SEEDING)

INSERT INTO Roles (RoleName) VALUES 
('Admin'), 
('Doctor'), 
('Staff'), 
('Customer');
GO