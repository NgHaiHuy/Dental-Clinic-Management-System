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

-- THÊM DỮ LIỆU KHỞI TẠO MẪU (DATA SEEDING)

-- 1. Thêm Roles mẫu
INSERT INTO Roles (RoleName) VALUES 
('Admin'), 
('Doctor'), 
('Staff'), 
('Customer');
GO

-- 2. Thêm Users mẫu (Admin, Doctors, Staff)
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('admin', '123', N'Quản trị viên', '0900000001', 'admin@dental.com', 1),
('doctor01', '123', N'Bác sĩ Nguyễn Văn Minh', '0900000002', 'minh.nv@dental.com', 2),
('doctor02', '123', N'Bác sĩ Trần Thị Lan', '0900000003', 'lan.tt@dental.com', 2),
('staff01', '123', N'Lễ tân Nguyễn Ngọc Ánh', '0900000004', 'anh.nn@dental.com', 3),
('staff02', '123', N'Lễ tân Lê Quang Hải', '0900000005', 'hai.lq@dental.com', 3);
GO

-- 3. Thêm 20 Khách hàng (Customers) mẫu (RoleID = 4)
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('customer01', '123', N'Nguyễn Hoàng Nam', '0912345678', 'nam.nh@gmail.com', 4),
('customer02', '123', N'Trần Tuyết Mai', '0987654321', 'mai.tt@gmail.com', 4),
('customer03', '123', N'Phạm Minh Đức', '0901234567', 'duc.pm@gmail.com', 4),
('customer04', '123', N'Lê Thanh Hương', '0934567890', 'huong.lt@gmail.com', 4),
('customer05', '123', N'Hoàng Quốc Khánh', '0978901234', 'khanh.hq@gmail.com', 4),
('customer06', '123', N'Phan Minh Anh', '0967890123', 'anh.pm@gmail.com', 4),
('customer07', '123', N'Vũ Hoàng Long', '0945678901', 'long.vh@gmail.com', 4),
('customer08', '123', N'Đỗ Kim Chi', '0911223344', 'chi.dk@gmail.com', 4),
('customer09', '123', N'Bùi Tiến Dũng', '0922334455', 'dung.bt@gmail.com', 4),
('customer10', '123', N'Hồ Bảo Ngọc', '0933445566', 'ngoc.hb@gmail.com', 4),
('customer11', '123', N'Ngô Thanh Tùng', '0944556677', 'tung.nt@gmail.com', 4),
('customer12', '123', N'Dương Thùy Linh', '0955667788', 'linh.dt@gmail.com', 4),
('customer13', '123', N'Lý Gia Bảo', '0966778899', 'bao.lg@gmail.com', 4),
('customer14', '123', N'Đặng Hồng Hạnh', '0977889900', 'hanh.dh@gmail.com', 4),
('customer15', '123', N'Trịnh Gia Huy', '0988990011', 'huy.tg@gmail.com', 4),
('customer16', '123', N'Vương Khánh Huyền', '0999001122', 'huyen.vk@gmail.com', 4),
('customer17', '123', N'Đinh Quang Minh', '0900112233', 'minh.dq@gmail.com', 4),
('customer18', '123', N'Lâm Quỳnh Chi', '0911335577', 'chi.lq@gmail.com', 4),
('customer19', '123', N'Mai Đức Duy', '0922446688', 'duy.md@gmail.com', 4),
('customer20', '123', N'Đoàn Thu Trang', '0933557799', 'trang.dt@gmail.com', 4);
GO

-- 4. Thêm Services mẫu
INSERT INTO Services (ServiceName, Price, Description, Status) VALUES
(N'Răng sứ Cercon', 5000000, N'Răng sứ không kim loại cao cấp Cercon CAD/CAM', 1),
(N'Tẩy trắng răng LumaCool', 1500000, N'Tẩy trắng răng công nghệ ánh sáng xanh LumaCool', 1),
(N'Trám răng Composite', 300000, N'Trám thẩm mỹ bằng vật liệu Composite', 1),
(N'Nhổ răng khôn (Răng số 8)', 1000000, N'Nhổ răng khôn mọc lệch/ngầm sử dụng thuốc tê', 1),
(N'Niềng răng kim loại chuẩn', 30000000, N'Chỉnh nha mắc cài kim loại không tự buộc', 1);
GO

-- 5. Thêm Medicines mẫu
INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status) VALUES
(N'Amoxicillin 500mg', N'Viên', 5000, 500, 1),
(N'Paracetamol 500mg', N'Viên', 2000, 1000, 1),
(N'Ibuprofen 400mg', N'Viên', 3000, 300, 1),
(N'Nước súc miệng sát khuẩn Kin', N'Chai', 120000, 50, 1);
GO