-- Script to correct Vietnamese font encoding issues for medicines
UPDATE Medicines SET MedicineName = N'Kem đánh răng chuyên dụng Sensodyne' WHERE MedicineID = 5;
UPDATE Medicines SET MedicineName = N'Chỉ nha khoa bảo vệ nướu Oral-B' WHERE MedicineID = 6;
GO
