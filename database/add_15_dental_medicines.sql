-- Script to add 15 new dental-related medicines and oral care products into Medicines table

-- 1. Chlorhexidine Gluconate 0.12%
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Nước súc miệng trị viêm nướu Chlorhexidine 0.12%')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Nước súc miệng trị viêm nướu Chlorhexidine 0.12%', N'Chai', 150000.00, 80, 1, '/img/mouthwash.png');
END

-- 2. Clindamycin 300mg
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kháng sinh răng miệng Clindamycin 300mg')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kháng sinh răng miệng Clindamycin 300mg', N'Hộp', 120000.00, 100, 1, '/img/box_medicine.png');
END

-- 3. Metronidazole 250mg
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kháng sinh viêm nha chu Metronidazole 250mg')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kháng sinh viêm nha chu Metronidazole 250mg', N'Hộp', 45000.00, 200, 1, '/img/box_medicine.png');
END

-- 4. Sensodyne Repair & Protect
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kem đánh răng Sensodyne Repair & Protect')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kem đánh răng Sensodyne Repair & Protect', N'Tuýp', 95000.00, 150, 1, '/img/toothpaste.png');
END

-- 5. Colgate Ortho
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kem đánh răng cho răng niềng Colgate Ortho')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kem đánh răng cho răng niềng Colgate Ortho', N'Tuýp', 75000.00, 100, 1, '/img/toothpaste.png');
END

-- 6. Kin Gingival Mouthwash
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Nước súc miệng ngừa viêm nướu Kin Gingival')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Nước súc miệng ngừa viêm nướu Kin Gingival', N'Chai', 135000.00, 90, 1, '/img/mouthwash.png');
END

-- 7. Listerine Antiseptic Cool Mint
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Nước súc miệng diệt khuẩn Listerine Cool Mint')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Nước súc miệng diệt khuẩn Listerine Cool Mint', N'Chai', 80000.00, 300, 1, '/img/mouthwash.png');
END

-- 8. Aloclair Plus Gel
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Gel bôi trị nhiệt miệng loét nướu Aloclair Plus')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Gel bôi trị nhiệt miệng loét nướu Aloclair Plus', N'Tuýp', 165000.00, 50, 1, '/img/gel_tube.png');
END

-- 9. Kamistad Gel N
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Gel gây tê giảm đau miệng Kamistad Gel N')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Gel gây tê giảm đau miệng Kamistad Gel N', N'Tuýp', 90000.00, 120, 1, '/img/gel_tube.png');
END

-- 10. Emofluor Gel
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Gel đặc trị ê buốt cổ chân răng Emofluor')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Gel đặc trị ê buốt cổ chân răng Emofluor', N'Tuýp', 220000.00, 40, 1, '/img/gel_tube.png');
END

-- 11. Chỉ nha khoa Dentana
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Chỉ tơ nha khoa làm sạch kẽ răng Dentana')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Chỉ tơ nha khoa làm sạch kẽ răng Dentana', N'Cuộn', 35000.00, 250, 1, '/img/mouthwash.png');
END

-- 12. Tăm nước Waterpik Jet Tip
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Đầu phun máy tăm nước Waterpik Jet Tip')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Đầu phun máy tăm nước Waterpik Jet Tip', N'Cái', 150000.00, 60, 1, '/img/toothbrush.png');
END

-- 13. Bàn chải chuyên dụng TePe Ortho
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Bàn chải chuyên dụng răng niềng TePe Ortho')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Bàn chải chuyên dụng răng niềng TePe Ortho', N'Cái', 75000.00, 110, 1, '/img/toothbrush.png');
END

-- 14. Curaprox CS 5460 Soft
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Bàn chải siêu mềm bảo vệ nướu Curaprox CS 5460')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Bàn chải siêu mềm bảo vệ nướu Curaprox CS 5460', N'Cái', 115000.00, 180, 1, '/img/toothbrush.png');
END

-- 15. GC Tooth Mousse Topical Paste
IF NOT EXISTS (SELECT * FROM Medicines WHERE MedicineName = N'Kem bôi tái khoáng ngừa sâu răng GC Tooth Mousse')
BEGIN
    INSERT INTO Medicines (MedicineName, Unit, Price, StockQuantity, Status, ImagePath)
    VALUES (N'Kem bôi tái khoáng ngừa sâu răng GC Tooth Mousse', N'Tuýp', 320000.00, 30, 1, '/img/gel_tube.png');
END
GO

