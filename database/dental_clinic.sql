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
    Status BIT DEFAULT 1, -- 1: Đang bán, 0: Ngừng bán
    ImagePath NVARCHAR(255) NULL
);

-- 3. NHÓM QUẢN LÝ LỊCH HẸN (APPOINTMENTS)

-- Bảng Appointments (Lịch hẹn khám)
CREATE TABLE Appointments (
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Users(UserID),
    DoctorID INT NULL FOREIGN KEY REFERENCES Users(UserID), -- Null nếu khám tổng quát
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME(0) NOT NULL,
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
    ItemID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
);
GO

-- 6. CÁC BẢNG BỔ SUNG THEO YÊU CẦU MỚI

-- Bảng DoctorInfo (Thông tin chi tiết Bác sĩ)
CREATE TABLE DoctorInfo (
    DoctorID INT PRIMARY KEY FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Specialization NVARCHAR(100) NULL,
    ExperienceYears INT NULL,
    Biography NVARCHAR(MAX) NULL
);

-- Bảng StaffInfo (Thông tin chi tiết Nhân viên)
CREATE TABLE StaffInfo (
    StaffID INT PRIMARY KEY FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Department NVARCHAR(100) NULL,
    Position NVARCHAR(50) NULL
);

-- Bảng CustomerInfo (Thông tin chi tiết Khách hàng/Bệnh nhân)
CREATE TABLE CustomerInfo (
    CustomerID INT PRIMARY KEY FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Address NVARCHAR(255) NULL,
    Gender NVARCHAR(10) NULL,
    DateOfBirth DATE NULL
);

-- Bảng Payments (Quản lý Thanh toán Hóa đơn)
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceID INT FOREIGN KEY REFERENCES Invoices(InvoiceID),
    PaymentMethod NVARCHAR(50) NOT NULL, -- 'Cash', 'Credit Card', 'Bank Transfer'
    PaymentDate DATETIME DEFAULT GETDATE(),
    AmountPaid DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Completed' -- 'Completed', 'Refunded'
);

-- Bảng PatientProfiles (Hồ sơ sức khỏe nền & Lịch sử bệnh án)
CREATE TABLE PatientProfiles (
    ProfileID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Allergies NVARCHAR(MAX) NULL,
    BloodType VARCHAR(5) NULL,
    MedicalHistory NVARCHAR(MAX) NULL,
    DentalHistory NVARCHAR(MAX) NULL,
    Notes NVARCHAR(MAX) NULL,
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng LabOrders (Quản lý gửi Labo làm răng giả/sứ)
CREATE TABLE LabOrders (
    LabOrderID INT IDENTITY(1,1) PRIMARY KEY,
    RecordID INT FOREIGN KEY REFERENCES MedicalRecords(RecordID),
    LabName NVARCHAR(150) NOT NULL,
    Material NVARCHAR(100) NOT NULL,
    Cost DECIMAL(18,2) NOT NULL,
    OrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE NULL,
    ActualDeliveryDate DATE NULL,
    Status NVARCHAR(50) DEFAULT 'Ordered' -- 'Ordered', 'Completed', 'Cancelled'
);

-- Bảng DoctorSchedules (Lịch làm việc của Bác sĩ)
CREATE TABLE DoctorSchedules (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    DoctorID INT FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    WorkDate DATE NOT NULL,
    ShiftName NVARCHAR(50) NOT NULL, -- 'Morning', 'Afternoon', 'FullDay'
    Status NVARCHAR(50) DEFAULT 'Active' -- 'Active', 'Off'
);

-- Bảng MedicalSupplies (Quản lý Kho vật tư y tế)
CREATE TABLE MedicalSupplies (
    SupplyID INT IDENTITY(1,1) PRIMARY KEY,
    SupplyName NVARCHAR(150) NOT NULL,
    Unit NVARCHAR(30) NOT NULL,
    Quantity INT DEFAULT 0,
    MinQuantity INT DEFAULT 5,
    UnitPrice DECIMAL(18,2) NOT NULL,
    Supplier NVARCHAR(150) NULL,
    LastUpdated DATETIME DEFAULT GETDATE()
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

-- 2. Thêm Users gốc (Admin, Doctors, Staff)
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('admin', '123', N'Quản trị viên', '0900000001', 'admin@dental.com', 1),
('doctor01', '123', N'Bác sĩ Triệu Xuân Bắc', '0900000002', 'minh.nv@dental.com', 2),
('doctor02', '123', N'Bác sĩ Trần Thị Lan', '0900000003', 'lan.tt@dental.com', 2),
('staff01', '123', N'Lễ tân Nguyễn Ngọc Ánh', '0900000004', 'anh.nn@dental.com', 3),
('staff02', '123', N'Lễ tân Lê Quang Hải', '0900000005', 'hai.lq@dental.com', 3);
GO

-- 3. Thêm DoctorInfo mẫu cho Doctors gốc
INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography) VALUES
(2, N'Răng Hàm Mặt', 8, N'Bác sĩ chuyên khoa I, 8 năm kinh nghiệm trong lĩnh vực Chỉnh nha & Niềng răng.'),
(3, N'Nha khoa Thẩm mỹ', 5, N'Tốt nghiệp Đại học Y Dược, chuyên gia phục hình sứ và tẩy trắng răng thẩm mỹ.');

-- 4. Thêm StaffInfo mẫu cho Staff gốc
INSERT INTO StaffInfo (StaffID, Department, Position) VALUES
(4, N'Bộ phận Tiếp đón', N'Trưởng nhóm Lễ tân'),
(5, N'Bộ phận Thu ngân & Kế toán', N'Nhân viên Thu ngân chính');
GO

-- 5. Thêm 20 Khách hàng (Customers) mẫu (RoleID = 4, các ID tự tăng sẽ từ 6 đến 25)
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

-- 6. Thêm CustomerInfo mẫu
INSERT INTO CustomerInfo (CustomerID, Address, Gender, DateOfBirth) VALUES
(6, N'123 Cầu Giấy, Hà Nội', N'Nam', '1995-04-12'),
(7, N'456 Lạch Tray, Hải Phòng', N'Nữ', '1998-09-23'),
(8, N'789 Nguyễn Văn Linh, Đà Nẵng', N'Nam', '1990-11-05');
GO

-- 7. Thêm 12 Services mẫu (Gồm 6 dịch vụ cũ và 6 dịch vụ nha khoa mới)
INSERT INTO Services (ServiceName, Price, Description, Status) VALUES
(N'Răng sứ Cercon', 5000000, N'Răng sứ không kim loại cao cấp Cercon CAD/CAM', 1),
(N'Tẩy trắng răng LumaCool', 1500000, N'Tẩy trắng răng công nghệ ánh sáng xanh LumaCool', 1),
(N'Trám răng Composite', 300000, N'Trám thẩm mỹ bằng vật liệu Composite', 1),
(N'Nhổ răng khôn (Răng số 8)', 1000000, N'Nhổ răng khôn mọc lệch/ngầm sử dụng thuốc tê', 1),
(N'Niềng răng kim loại chuẩn', 30000000, N'Chỉnh nha mắc cài kim loại không tự buộc', 1),
(N'Trồng răng Implant', 12500000, N'Phục hình răng đã mất bằng công nghệ Implant hiện đại, giúp ăn nhai như răng thật.', 1),
(N'Lấy cao răng & Đánh bóng', 200000, N'Vệ sinh răng miệng sạch sẽ, lấy sạch mảng bám tích tụ dưới nướu.', 1),
(N'Điều trị tủy răng (Nội nha)', 1500000, N'Điều trị tủy răng bằng công nghệ WaveOne hiện đại, không đau đớn.', 1),
(N'Mặt dán sứ Veneer siêu mỏng', 8000000, N'Dán sứ Veneer thẩm mỹ cao cấp, phục hình răng tối thiểu bảo tồn răng thật.', 1),
(N'Niềng răng trong suốt Invisalign', 80000000, N'Chỉnh nha thẩm mỹ khay trong suốt công nghệ Hoa Kỳ, thẩm mỹ tối đa.', 1),
(N'Điều trị viêm nha chu toàn diện', 2000000, N'Điều trị sâu túi nha chu, phẫu thuật tái tạo nướu thẩm mỹ lành thương nhanh.', 1),
(N'Nha khoa Trẻ em chuyên sâu', 150000, N'Nhổ răng sữa, trám răng sâu và tư vấn chăm sóc răng miệng tâm lý cho trẻ.', 1);
GO

-- 8. Thêm 21 Medicines mẫu (Gồm 6 thuốc cũ và 15 thuốc nha khoa mới với đường dẫn hình ảnh chuẩn)
INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath) VALUES
(N'Amoxicillin 500mg', N'Viên', 5000, 500, 1, '/img/amoxicillin.png'),
(N'Paracetamol 500mg', N'Viên', 2000, 1000, 1, '/img/paracetamol.png'),
(N'Ibuprofen 400mg', N'Viên', 3000, 300, 1, '/img/ibuprofen.png'),
(N'Nước súc miệng sát khuẩn Kin', N'Chai', 120000, 50, 1, '/img/listerine_regular.png'),
(N'Kem đánh răng chuyên dụng Sensodyne', N'Hộp', 85000, 120, 1, '/img/sensodyne_regular.png'),
(N'Chỉ nha khoa bảo vệ nướu Oral-B', N'Hộp', 55000, 200, 1, '/img/oralb_floss.png'),
(N'Nước súc miệng trị viêm nướu Chlorhexidine 0.12%', N'Chai', 150000, 80, 1, '/img/chlorhexidine.png'),
(N'Kháng sinh răng miệng Clindamycin 300mg', N'Hộp', 120000, 100, 1, '/img/clindamycin.png'),
(N'Kháng sinh viêm nha chu Metronidazole 250mg', N'Hộp', 45000, 200, 1, '/img/metronidazole.png'),
(N'Kem đánh răng Sensodyne Repair & Protect', N'Tuýp', 95000, 150, 1, '/img/sensodyne_repair.png'),
(N'Kem đánh răng cho răng niềng Colgate Ortho', N'Tuýp', 75000, 100, 1, '/img/colgate_ortho.png'),
(N'Nước súc miệng ngừa viêm nướu Kin Gingival', N'Chai', 135000, 90, 1, '/img/kin_gingival.png'),
(N'Nước súc miệng diệt khuẩn Listerine Cool Mint', N'Chai', 80000, 300, 1, '/img/listerine_coolmint.png'),
(N'Gel bôi trị nhiệt miệng loét nướu Aloclair Plus', N'Tuýp', 165000, 50, 1, '/img/aloclair_plus.png'),
(N'Gel gây tê giảm đau miệng Kamistad Gel N', N'Tuýp', 90000, 120, 1, '/img/kamistad_gel.png'),
(N'Gel đặc trị ê buốt cổ chân răng Emofluor', N'Tuýp', 220000, 40, 1, '/img/emofluor.png'),
(N'Chỉ tơ nha khoa làm sạch kẽ răng Dentana', N'Cuộn', 35000, 250, 1, '/img/dentana_floss.png'),
(N'Đầu phun máy tăm nước Waterpik Jet Tip', N'Cái', 150000, 60, 1, '/img/waterpik_jettip.png'),
(N'Bàn chải chuyên dụng răng niềng TePe Ortho', N'Cái', 75000, 110, 1, '/img/tepe_ortho.png'),
(N'Bàn chải siêu mềm bảo vệ nướu Curaprox CS 5460', N'Cái', 115000, 180, 1, '/img/curaprox.png'),
(N'Kem bôi tái khoáng ngừa sâu răng GC Tooth Mousse', N'Tuýp', 320000, 30, 1, '/img/tooth_mousse.png');
GO

-- 9. Thêm Appointments mẫu (Lịch hẹn khám)
-- Khách hàng ID từ 6-25, Bác sĩ ID 2 và 3
INSERT INTO Appointments (CustomerID, DoctorID, AppointmentDate, AppointmentTime, Status, Notes) VALUES
(6, 2, '2026-07-01', '09:00:00', 'Attended', N'Khám định kỳ tẩy trắng răng'),
(7, 3, '2026-07-02', '10:30:00', 'Attended', N'Đau nhức răng số 6'),
(8, 2, '2026-07-02', '14:00:00', 'Pending', N'Đặt lịch tư vấn trám răng'),
(9, 3, '2026-07-03', '15:30:00', 'Pending', N'Nhổ răng khôn'),
(10, 2, '2026-07-01', '16:00:00', 'Attended', N'Khám răng sâu số 7');
GO

-- 10. Chi tiết dịch vụ hẹn trước (AppointmentServices)
INSERT INTO AppointmentServices (AppointmentID, ServiceID) VALUES
(1, 2), -- Hẹn Tẩy trắng răng
(2, 1), -- Hẹn làm Răng sứ Cercon
(5, 3); -- Hẹn Trám răng Composite
GO

-- 11. Hồ sơ bệnh án / Kết quả khám (MedicalRecords)
INSERT INTO MedicalRecords (AppointmentID, DoctorID, Diagnosis, TreatmentPlan) VALUES
(1, 2, N'Răng ố vàng nhẹ do mảng bám thức ăn', N'Thực hiện tẩy trắng răng LumaCool tại phòng khám'),
(2, 3, N'Răng sâu nặng hỏng tủy răng số 6', N'Điều trị tủy và bọc răng sứ Cercon bảo vệ răng'),
(5, 2, N'Sâu men răng số 7', N'Trám thẩm mỹ bằng Composite răng số 7');
GO

-- 12. Đơn thuốc mẫu (Prescriptions)
INSERT INTO Prescriptions (RecordID) VALUES
(1), -- Đơn thuốc cho bệnh án 1
(2), -- Đơn thuốc cho bệnh án 2
(3); -- Đơn thuốc cho bệnh án 3
GO

-- 13. Chi tiết đơn thuốc (PrescriptionDetails)
INSERT INTO PrescriptionDetails (PrescriptionID, MedicineID, Quantity, Dosage) VALUES
(1, 4, 1, N'Súc miệng 2 lần/ngày sau khi đánh răng'),
(2, 1, 10, N'Uống 2 viên/ngày chia 2 lần sau ăn sáng/tối'),
(2, 2, 10, N'Uống 1 viên khi đau nhức nhiều, cách nhau ít nhất 6 tiếng'),
(3, 3, 5, N'Uống 1 viên khi đau nhức sau ăn');
GO

-- 14. Thêm DoctorSchedules mẫu (Lịch làm việc bác sĩ)
INSERT INTO DoctorSchedules (DoctorID, WorkDate, ShiftName, Status) VALUES
(2, '2026-07-01', 'Morning', 'Active'),
(2, '2026-07-01', 'Afternoon', 'Active'),
(3, '2026-07-02', 'Morning', 'Active'),
(3, '2026-07-02', 'Afternoon', 'Active'),
(2, '2026-07-02', 'FullDay', 'Active');
GO

-- 15. Thêm PatientProfiles mẫu (Hồ sơ sức khỏe nền)
INSERT INTO PatientProfiles (CustomerID, Allergies, BloodType, MedicalHistory, DentalHistory, Notes) VALUES
(6, N'Dị ứng Penicillin', 'A', N'Không có tiền sử bệnh tim mạch', N'Đã từng trám răng cách đây 2 năm', N'Bệnh nhân nhạy cảm với thuốc tê nhóm Amide'),
(7, N'Không dị ứng thuốc', 'O', N'Huyết áp thấp nhẹ', N'Chưa từng can thiệp nha khoa lớn', N'Khám kỹ trước khi tiến hành bọc sứ');
GO

-- 16. Thêm MedicalSupplies mẫu (Kho vật tư y tế)
INSERT INTO MedicalSupplies (SupplyName, Unit, Quantity, MinQuantity, UnitPrice, Supplier) VALUES
(N'Găng tay y tế Nitrile', N'Hộp', 100, 10, 150000, N'Công ty Thiết bị Y tế Phú An'),
(N'Khẩu trang y tế 4 lớp', N'Hộp', 150, 15, 50000, N'Công ty Thiết bị Y tế Phú An'),
(N'Thuốc tê Septodont (Pháp)', N'Hộp', 20, 5, 850000, N'Nha khoa Medent'),
(N'Chỉ nha khoa Oral-B', N'Cuộn', 200, 20, 45000, N'Nha khoa Medent');
GO

-- 17. Thêm Bác sĩ và Nhân viên tiếp đón bổ sung (từ add_more_users.sql)

-- Doctor 03
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('doctor03', '123', N'BS. CKII. Nguyễn Hải Huy', '0911222333', 'nam.lh@dental.com', 2);
DECLARE @doc3_id INT = @@IDENTITY;
INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography) VALUES
(@doc3_id, N'Phẫu thuật & Cấy ghép Implant', 15, N'Bác sĩ Chuyên khoa II, hơn 15 năm kinh nghiệm phục hình răng mất bằng công nghệ Implant.');

-- Doctor 04
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('doctor04', '123', N'ThS. BS. Phạm Thủy Tiên', '0922333444', 'tien.pt@dental.com', 2);
DECLARE @doc4_id INT = @@IDENTITY;
INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography) VALUES
(@doc4_id, N'Nha khoa Trẻ em & Nội nha', 7, N'Thạc sĩ Răng Hàm Mặt, chuyên sâu điều trị tủy răng và nha khoa thẩm mỹ trẻ em.');

-- Doctor 05
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('doctor05', '123', N'BS. Lê Thanh Nghị', '0933444555', 'duc.nm@dental.com', 2);
DECLARE @doc5_id INT = @@IDENTITY;
INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography) VALUES
(@doc5_id, N'Nha chu & Điều trị Hôi miệng', 6, N'Bác sĩ Răng Hàm Mặt, tốt nghiệp loại Giỏi Đại học Y Dược TP.HCM, chuyên điều trị viêm nha chu.');

-- Doctor 06
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('doctor06', '123', N'BS. Hoàng Anh Tuấn', '0944555666', 'tuan.ha@dental.com', 2);
DECLARE @doc6_id INT = @@IDENTITY;
INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography) VALUES
(@doc6_id, N'Nha khoa Tổng quát & Tiểu phẫu', 8, N'Chuyên khoa Răng Hàm Mặt, thế mạnh tiểu phẫu răng khôn mọc lệch bằng công nghệ Piezotome không đau.');

-- Staff 03
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('staff03', '123', N'Lễ tân Bùi Phương Thảo', '0955666777', 'thao.bp@dental.com', 3);
DECLARE @staff3_id INT = @@IDENTITY;
INSERT INTO StaffInfo (StaffID, Department, Position) VALUES
(@staff3_id, N'Bộ phận CSKH & Tiếp đón', N'Nhân viên CSKH');

-- Staff 04
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('staff04', '123', N'Lễ tân Vũ Minh Hoàng', '0966777888', 'hoang.vm@dental.com', 3);
DECLARE @staff4_id INT = @@IDENTITY;
INSERT INTO StaffInfo (StaffID, Department, Position) VALUES
(@staff4_id, N'Bộ phận Tiếp đón', N'Nhân viên Tiếp đón');

-- Staff 05
INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES
('staff05', '123', N'Lễ tân Đỗ Thùy Trang', '0977888999', 'trang.dt@dental.com', 3);
DECLARE @staff5_id INT = @@IDENTITY;
INSERT INTO StaffInfo (StaffID, Department, Position) VALUES
(@staff5_id, N'Bộ phận Tiếp đón & Thu ngân', N'Nhân viên Thu ngân');
GO
