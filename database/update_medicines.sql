-- 1. Add ImagePath column if it does not exist
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Medicines') AND name = 'ImagePath'
)
BEGIN
    ALTER TABLE Medicines ADD ImagePath NVARCHAR(255) NULL;
END
GO

-- 2. Update existing medicines with correct image paths
UPDATE Medicines SET ImagePath = '/assets/images/amoxicillin.png' WHERE MedicineName LIKE '%Amoxicillin%';
UPDATE Medicines SET ImagePath = '/assets/images/paracetamol.png' WHERE MedicineName LIKE '%Paracetamol%';
UPDATE Medicines SET ImagePath = '/assets/images/ibuprofen.png' WHERE MedicineName LIKE '%Ibuprofen%';
UPDATE Medicines SET ImagePath = '/assets/images/mouthwash.png' WHERE MedicineName LIKE '%súc miệng%';
GO

-- 3. Add more medicines if they don't exist yet
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kem đánh răng chuyên dụng Sensodyne')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kem đánh răng chuyên dụng Sensodyne', N'Hộp', 85000.00, 120, 1, '/assets/images/mouthwash.png');
END

IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Chỉ nha khoa bảo vệ nướu Oral-B')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Chỉ nha khoa bảo vệ nướu Oral-B', N'Hộp', 55000.00, 200, 1, '/assets/images/mouthwash.png');
END
GO

-- Set default image for any other medicines just in case
UPDATE Medicines SET ImagePath = '/assets/images/mouthwash.png' WHERE ImagePath IS NULL;
GO
