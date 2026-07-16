-- SQL Script to insert 4 new Doctors and 3 new Staff members

-- 1. Add Doctors
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'doctor03')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('doctor03', '123', N'BS. CKII. Lê Hoàng Nam', '0911222333', 'nam.lh@dental.com', 2);
    
    DECLARE @doc3_id INT = @@IDENTITY;
    INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography)
    VALUES (@doc3_id, N'Phẫu thuật & Cấy ghép Implant', 15, N'Bác sĩ Chuyên khoa II, hơn 15 năm kinh nghiệm phục hình răng mất bằng công nghệ Implant.');
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'doctor04')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('doctor04', '123', N'ThS. BS. Phạm Thủy Tiên', '0922333444', 'tien.pt@dental.com', 2);
    
    DECLARE @doc4_id INT = @@IDENTITY;
    INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography)
    VALUES (@doc4_id, N'Nha khoa Trẻ em & Nội nha', 7, N'Thạc sĩ Răng Hàm Mặt, chuyên sâu điều trị tủy răng và nha khoa thẩm mỹ trẻ em.');
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'doctor05')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('doctor05', '123', N'BS. Nguyễn Minh Đức', '0933444555', 'duc.nm@dental.com', 2);
    
    DECLARE @doc5_id INT = @@IDENTITY;
    INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography)
    VALUES (@doc5_id, N'Nha chu & Điều trị Hôi miệng', 6, N'Bác sĩ Răng Hàm Mặt, tốt nghiệp loại Giỏi Đại học Y Dược TP.HCM, chuyên điều trị viêm nha chu.');
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'doctor06')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('doctor06', '123', N'BS. Hoàng Anh Tuấn', '0944555666', 'tuan.ha@dental.com', 2);
    
    DECLARE @doc6_id INT = @@IDENTITY;
    INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography)
    VALUES (@doc6_id, N'Nha khoa Tổng quát & Tiểu phẫu', 8, N'Chuyên khoa Răng Hàm Mặt, thế mạnh tiểu phẫu răng khôn mọc lệch bằng công nghệ Piezotome không đau.');
END


-- 2. Add Staff (Lễ tân)
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'staff03')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('staff03', '123', N'Lễ tân Bùi Phương Thảo', '0955666777', 'thao.bp@dental.com', 3);
    
    DECLARE @staff3_id INT = @@IDENTITY;
    INSERT INTO StaffInfo (StaffID, Department, Position)
    VALUES (@staff3_id, N'Bộ phận CSKH & Tiếp đón', N'Nhân viên CSKH');
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'staff04')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('staff04', '123', N'Lễ tân Vũ Minh Hoàng', '0966777888', 'hoang.vm@dental.com', 3);
    
    DECLARE @staff4_id INT = @@IDENTITY;
    INSERT INTO StaffInfo (StaffID, Department, Position)
    VALUES (@staff4_id, N'Bộ phận Tiếp đón', N'Nhân viên Tiếp đón');
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'staff05')
BEGIN
    INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
    VALUES ('staff05', '123', N'Lễ tân Đỗ Thùy Trang', '0977888999', 'trang.dt@dental.com', 3);
    
    DECLARE @staff5_id INT = @@IDENTITY;
    INSERT INTO StaffInfo (StaffID, Department, Position)
    VALUES (@staff5_id, N'Bộ phận Tiếp đón & Thu ngân', N'Nhân viên Thu ngân');
END
GO
