# 📋 PHÂN TÍCH CHI TIẾT TOÀN BỘ PHẦN THÀNH VIÊN 4 (Q.HUY)
# Receptionist Module (Nhân viên Tiếp đón) — Dental Clinic Management System

> File này phân tích cặn kẽ từng chức năng, luồng hoạt động, cách validate,
> test case, và mối liên kết giữa các file trong phần của Thành viên 4.

---

# MỤC LỤC

1. [Sơ đồ tổng quan Module Receptionist](#1-sơ-đồ-tổng-quan-module-receptionist)
2. [Bảng Database liên quan](#2-bảng-database-liên-quan)
3. [CHỨC NĂNG 1: Giao diện tiếp đón - Check-in lịch hẹn](#3-chức-năng-1-giao-diện-tiếp-đón---check-in-lịch-hẹn)
4. [CHỨC NĂNG 2: Cập nhật trạng thái lịch hẹn (Attended)](#4-chức-năng-2-cập-nhật-trạng-thái-lịch-hẹn)
5. [CHỨC NĂNG 3: Đặt lịch hẹn trực tiếp tại quầy (Walk-in)](#5-chức-năng-3-đặt-lịch-hẹn-trực-tiếp-tại-quầy-walk-in)
6. [Danh sách File cần tạo / sửa](#6-danh-sách-file-cần-tạo--sửa)
7. [AppointmentDAO — Các hàm cần code](#7-appointmentdao--các-hàm-cần-code)
8. [Bảng tổng hợp Validate toàn bộ Module](#8-bảng-tổng-hợp-validate-toàn-bộ-module)
9. [Bảng tổng hợp liên kết File ↔ File](#9-bảng-tổng-hợp-liên-kết-file--file)
10. [Tổng kết số liệu](#10-tổng-kết-số-liệu)

---

# 1. SƠ ĐỒ TỔNG QUAN MODULE RECEPTIONIST

## 1.1. Vị trí Module trong hệ thống

```
┌──────────────────────────────────────────────────────────────────────┐
│                         HỆ THỐNG DENTAL CLINIC                      │
│                                                                      │
│  ┌────────────┐  ┌────────────────┐  ┌───────────────────────────┐  │
│  │ Thành viên │  │ Thành viên 2+3 │  │     THÀNH VIÊN 4 (Q.HUY) │  │
│  │ 1 (Nghị)   │  │ (Customer +    │  │  ┌─────────────────────┐  │  │
│  │            │  │  Admin Module) │  │  │ RECEPTIONIST MODULE │  │  │
│  │ Auth &     │  │                │  │  │  • Check-in         │  │  │
│  │ Filter     │  │ Đặt lịch hẹn  │  │  │  • Update Status    │  │  │
│  │            │  │ online         │  │  │  • Walk-in Booking  │  │  │
│  └──────┬─────┘  └───────┬────────┘  │  └──────────┬──────────┘  │  │
│         │                │           └─────────────┼─────────────┘  │
│         │                │                         │                │
│         └────────────────┼─────────────────────────┘                │
│                          │                                           │
│                    ┌─────▼──────┐                                    │
│                    │  Database  │    Bảng chính: Appointments,       │
│                    │  SQL Server│    AppointmentServices, Users,     │
│                    │            │    Services, DoctorSchedules       │
│                    └────────────┘                                    │
│                                                                      │
│  ┌────────────────┐  ┌────────────────┐                             │
│  │ Thành viên 5   │  │ Thành viên 6   │                             │
│  │ Doctor Module  │  │ Admin Module   │                             │
│  │ (Nhận bệnh nhân│  │ (CRUD Users,   │                             │
│  │  sau Check-in) │  │  Services)     │                             │
│  └────────────────┘  └────────────────┘                             │
└──────────────────────────────────────────────────────────────────────┘
```

## 1.2. Sơ đồ luồng tổng quan Module Receptionist

```
┌─────────────────────────────────────────────────────────────────────┐
│                     TRÌNH DUYỆT (Browser)                           │
│   Lễ tân (Staff - RoleID=3) đăng nhập → vào /receptionist/*        │
└───────────────┬─────────────────────────────────────────────────────┘
                │ HTTP Request
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FILTER CHAIN (Thành viên 1)                    │
│  AuthenticationFilter → Kiểm tra đã đăng nhập?                     │
│  AuthorizationFilter  → /receptionist/* chỉ cho RoleID=3 (Staff)   │
└───────────────┬─────────────────────────────────────────────────────┘
                │ Đã xác thực + Đúng quyền ✓
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│               SERVLET CONTROLLER (Thành viên 4 code)                │
│                                                                     │
│  ┌──────────────────────┐  ┌──────────────────────────────────────┐ │
│  │  CheckInController   │  │  WalkInBookingController             │ │
│  │  /receptionist/      │  │  /receptionist/walk-in-booking       │ │
│  │  check-in            │  │                                      │ │
│  │                      │  │  GET: Hiển thị form đặt lịch         │ │
│  │  GET: Danh sách      │  │  POST: Tạo lịch hẹn mới             │ │
│  │       lịch hẹn hôm   │  │                                      │ │
│  │       nay + tìm kiếm │  └──────────────────┬───────────────────┘ │
│  │                      │                      │                    │
│  │  POST: Cập nhật      │                      │                    │
│  │        trạng thái    │                      │                    │
│  │        → "Attended"  │                      │                    │
│  └──────────┬───────────┘                      │                    │
└─────────────┼──────────────────────────────────┼────────────────────┘
              │                                  │
              ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    AppointmentDAO.java (dal/)                        │
│  getTodayAppointments()   searchAppointments()                      │
│  updateStatus()           createWalkInAppointment()                 │
│  getAppointmentByID()     isTimeSlotAvailable()                     │
└──────────────────────┬──────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   SQL Server (DentalClinicDB)                        │
│  Bảng: Appointments, AppointmentServices, Users, Services,          │
│        DoctorSchedules                                              │
└─────────────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         JSP (View)                                   │
│  ┌───────────────────────┐  ┌────────────────────────────────────┐  │
│  │ check-in.jsp          │  │ walk-in-booking.jsp                │  │
│  │ (Danh sách + tìm kiếm│  │ (Form đặt lịch tại quầy)          │  │
│  │  + nút Check-in)     │  │                                    │  │
│  └───────────────────────┘  └────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## 1.3. Sơ đồ liên kết File → File (chi tiết)

```
Appointment.java ◄────── AppointmentDAO.java (tạo đối tượng Appointment từ ResultSet)
User.java ◄───────────── AppointmentDAO.java (JOIN bảng Users lấy tên khách/bác sĩ)
Service.java ◄────────── AppointmentDAO.java (JOIN bảng Services lấy tên dịch vụ)
DoctorSchedule.java ◄─── AppointmentDAO.java (kiểm tra lịch làm việc bác sĩ)
DBContext.java ◄───────── AppointmentDAO.java (extends DBContext, dùng connection)

AppointmentDAO.java ◄─── CheckInController.java (gọi getTodayAppointments, updateStatus...)
AppointmentDAO.java ◄─── WalkInBookingController.java (gọi createWalkInAppointment...)
UserDAO.java ◄────────── WalkInBookingController.java (gọi getUsersByRole lấy DS bác sĩ)
ServiceDAO.java ◄──────── WalkInBookingController.java (gọi getAllServices lấy DS dịch vụ)

check-in.jsp ◄────────── CheckInController.java (forward request đến)
walk-in-booking.jsp ◄─── WalkInBookingController.java (forward request đến)

web.xml ────────────►── CheckInController + WalkInBookingController (định nghĩa mapping)
```

---

# 2. BẢNG DATABASE LIÊN QUAN

## 2.1. Bảng Appointments (Lịch hẹn khám) — BẢNG CHÍNH

```sql
CREATE TABLE Appointments (
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Users(UserID),
    DoctorID INT NULL FOREIGN KEY REFERENCES Users(UserID),
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME(0) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    -- Các giá trị Status: 'Pending', 'Confirmed', 'Attended', 'Cancelled'
    Notes NVARCHAR(MAX) NULL
);
```

### Giải thích từng cột:

| Cột | Kiểu | Ý nghĩa | Liên quan ThanhVien4 |
|-----|------|---------|---------------------|
| `AppointmentID` | INT PK | Mã lịch hẹn (tự tăng) | Dùng để xác định lịch hẹn cần check-in |
| `CustomerID` | INT FK → Users | Khách hàng đặt lịch | Hiển thị tên khách trên danh sách check-in |
| `DoctorID` | INT FK → Users (NULL) | Bác sĩ phụ trách | Lễ tân chọn bác sĩ khi đặt walk-in |
| `AppointmentDate` | DATE | Ngày hẹn khám | Lọc lịch hẹn trong ngày để check-in |
| `AppointmentTime` | TIME(0) | Giờ hẹn khám | Sắp xếp + kiểm tra slot trống |
| `Status` | NVARCHAR(50) | Trạng thái lịch hẹn | ThanhVien4 đổi từ Pending/Confirmed → **Attended** |
| `Notes` | NVARCHAR(MAX) | Ghi chú | Lễ tân có thể thêm ghi chú khi walk-in |

### Các giá trị Status và ý nghĩa:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Pending    │────→│  Confirmed   │────→│   Attended   │
│ (Chờ xác nhận)│    │(Đã xác nhận) │     │  (Đã đến)    │
└──────┬───────┘     └──────────────┘     └──────────────┘
       │                                        ▲
       │        ┌──────────────┐                │
       └───────→│  Cancelled   │     ThanhVien4 đổi Status
                │  (Đã huỷ)   │     thành "Attended" tại bước này
                └──────────────┘
```

**QUAN TRỌNG cho ThanhVien4:**
- Lễ tân chỉ check-in (đổi sang `Attended`) cho các lịch hẹn có Status = `Pending` hoặc `Confirmed`
- KHÔNG được check-in cho lịch đã `Cancelled` hoặc đã `Attended`

## 2.2. Bảng AppointmentServices (Dịch vụ đã chọn)

```sql
CREATE TABLE AppointmentServices (
    AppointmentID INT FK → Appointments,
    ServiceID INT FK → Services,
    PRIMARY KEY (AppointmentID, ServiceID) -- Khóa chính phức hợp
);
```

**Ý nghĩa:** Mỗi lịch hẹn có thể chọn nhiều dịch vụ (quan hệ N-N).
- Khi walk-in booking, lễ tân chọn dịch vụ → INSERT vào bảng này.
- Khi hiển thị danh sách check-in, JOIN bảng này để hiện dịch vụ đã đặt.

## 2.3. Bảng DoctorSchedules (Lịch làm việc bác sĩ)

```sql
CREATE TABLE DoctorSchedules (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    DoctorID INT FK → Users,
    WorkDate DATE NOT NULL,
    ShiftName NVARCHAR(50) NOT NULL, -- 'Morning', 'Afternoon', 'FullDay'
    Status NVARCHAR(50) DEFAULT 'Active' -- 'Active', 'Off'
);
```

**Ý nghĩa cho ThanhVien4:** Khi đặt walk-in booking:
- Cần kiểm tra bác sĩ CÓ lịch làm việc ngày hôm nay không
- Nếu bác sĩ `Off` hoặc không có record → không cho đặt
- Nếu ShiftName = `Morning` → chỉ đặt trước 12:00
- Nếu ShiftName = `Afternoon` → chỉ đặt từ 12:00 trở đi
- Nếu ShiftName = `FullDay` → đặt bất kỳ giờ nào

## 2.4. Bảng Users (lấy thông tin khách hàng + bác sĩ)

```sql
-- Truy vấn JOIN phổ biến trong module này:
SELECT a.*, 
       c.FullName AS CustomerName, c.Phone AS CustomerPhone,
       d.FullName AS DoctorName
FROM Appointments a
JOIN Users c ON a.CustomerID = c.UserID
LEFT JOIN Users d ON a.DoctorID = d.UserID
WHERE a.AppointmentDate = CAST(GETDATE() AS DATE)
```

## 2.5. Bảng Services (danh sách dịch vụ khám)

```sql
-- Lấy dịch vụ đang hoạt động cho form walk-in booking:
SELECT ServiceID, ServiceName, Price FROM Services WHERE Status = 1
```

---

# 3. CHỨC NĂNG 1: GIAO DIỆN TIẾP ĐÓN - CHECK-IN LỊCH HẸN

## 3.1. Mô tả tổng quan

Đây là trang chính mà Lễ tân (Staff) sử dụng khi mở đầu ca làm việc. Trang hiển thị **danh sách tất cả lịch hẹn trong ngày hôm nay**, cho phép tìm kiếm theo tên/SĐT khách hàng, và thực hiện check-in khi khách đến phòng khám.

## 3.2. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `check-in.jsp` | `web/receptionist/check-in.jsp` | **[NEW]** Giao diện danh sách lịch hẹn + tìm kiếm + nút check-in (View) |
| `CheckInController.java` | `src/java/controller/receptionist/CheckInController.java` | **[MODIFY]** Xử lý logic hiển thị + tìm kiếm + cập nhật status (Controller) |
| `AppointmentDAO.java` | `src/java/dal/AppointmentDAO.java` | **[MODIFY]** Truy vấn DB: lấy danh sách, tìm kiếm, cập nhật (Model/DAO) |
| `Appointment.java` | `src/java/model/Appointment.java` | **[MODIFY]** Đối tượng lưu thông tin lịch hẹn (Model) — cần bổ sung đầy đủ thuộc tính |
| `web.xml` | `web/WEB-INF/web.xml` | **[MODIFY]** Thêm servlet mapping cho `/receptionist/check-in` |

## 3.3. Model Appointment.java — Cần bổ sung đầy đủ

**Hiện tại:** File `Appointment.java` chỉ là class rỗng (chưa có thuộc tính nào).

**Cần bổ sung:**

```
Thuộc tính (khớp 1:1 với cột trong bảng Appointments + JOIN):
  - int appointmentID       ← Appointments.AppointmentID (PK, IDENTITY)
  - int customerID          ← Appointments.CustomerID (FK → Users)
  - int doctorID            ← Appointments.DoctorID (FK → Users, nullable)
  - Date appointmentDate    ← Appointments.AppointmentDate (DATE)
  - Time appointmentTime    ← Appointments.AppointmentTime (TIME)
  - String status           ← Appointments.Status (NVARCHAR 50)
  - String notes            ← Appointments.Notes (NVARCHAR MAX)
  
  // Thuộc tính bổ sung từ JOIN (để hiển thị trên View):
  - String customerName     ← Users.FullName (JOIN qua CustomerID)
  - String customerPhone    ← Users.Phone (JOIN qua CustomerID)
  - String doctorName       ← Users.FullName (JOIN qua DoctorID)
  - String serviceName      ← Nối tên các dịch vụ từ AppointmentServices

Constructor:
  - Appointment()            ← constructor trống (JavaBean)
  - Appointment(đầy đủ)     ← tất cả thuộc tính

Getter/Setter: Đầy đủ cho tất cả thuộc tính
toString(): In thông tin appointment
```

## 3.4. Luồng hoạt động chi tiết (Flow)

### Luồng GET — Hiển thị danh sách lịch hẹn trong ngày:

```
Bước 1: Lễ tân đăng nhập (staff01/123) → Redirect đến /receptionist/dashboard
        │ (Dashboard do ThanhVien1 tạo sẵn)
        │
        │ Lễ tân nhấn link "Quản lý lịch hẹn" hoặc gõ URL:
        │ http://localhost:8080/DentalClinic/receptionist/check-in
        │
Bước 2: │ Request đến web.xml → tìm servlet-mapping cho /receptionist/check-in
        │ → Tìm thấy: CheckInController.java
        │
        │ (Trước khi đến Servlet, request đi qua Filter chain)
        │
Bước 3: │ AuthenticationFilter nhận request
        │ → Kiểm tra: URL "/receptionist/check-in" có trong PUBLIC_URL không?
        │ → KHÔNG → kiểm tra session có "loggedInUser"?
        │ → CÓ (đã đăng nhập) → chain.doFilter() → cho đi tiếp
        │
Bước 4: │ AuthorizationFilter nhận request
        │ → URL bắt đầu bằng "/receptionist/" → kiểm tra roleID == 3 (Staff)?
        │ → ĐÚNG → chain.doFilter() → cho đi tiếp
        │ → SAI → forward 403.jsp (nếu Doctor/Customer/Admin cố vào)
        │
Bước 5: │ CheckInController.doGet() được gọi
        │ → Lấy ngày hôm nay: Date today = new Date(System.currentTimeMillis())
        │
        │ → Kiểm tra có tham số tìm kiếm không:
        │   String searchKeyword = request.getParameter("search")
        │   String filterStatus = request.getParameter("status")
        │
        │   ├─ NẾU CÓ searchKeyword (tìm kiếm theo tên/SĐT):
        │   │   → Gọi: List<Appointment> list = appointmentDAO
        │   │           .searchTodayAppointments(today, searchKeyword.trim())
        │   │
        │   ├─ NẾU CÓ filterStatus (lọc theo trạng thái):
        │   │   → Gọi: List<Appointment> list = appointmentDAO
        │   │           .getTodayAppointmentsByStatus(today, filterStatus)
        │   │
        │   └─ NẾU KHÔNG CÓ tham số (hiển thị tất cả):
        │       → Gọi: List<Appointment> list = appointmentDAO
        │               .getTodayAppointments(today)
        │
Bước 6: │ Đếm thống kê:
        │ → int totalToday = list.size()
        │ → int totalPending = đếm status == "Pending" || "Confirmed"
        │ → int totalAttended = đếm status == "Attended"
        │ → int totalCancelled = đếm status == "Cancelled"
        │
Bước 7: │ Set attributes cho JSP:
        │ → request.setAttribute("appointmentList", list)
        │ → request.setAttribute("totalToday", totalToday)
        │ → request.setAttribute("totalPending", totalPending)
        │ → request.setAttribute("totalAttended", totalAttended)
        │ → request.setAttribute("totalCancelled", totalCancelled)
        │ → request.setAttribute("searchKeyword", searchKeyword)
        │ → request.setAttribute("filterStatus", filterStatus)
        │ → request.setAttribute("today", today)
        │
Bước 8: │ Forward đến view:
        │ → request.getRequestDispatcher("/receptionist/check-in.jsp")
        │          .forward(request, response)
        │
Bước 9: │ check-in.jsp render HTML:
        │ → Thanh tiêu đề: "Check-in Lịch hẹn — [Ngày hôm nay]"
        │ → Khung thống kê nhanh:
        │   ├─ Tổng lịch hẹn hôm nay: [totalToday]
        │   ├─ Chờ check-in: [totalPending] (badge vàng)
        │   ├─ Đã đến: [totalAttended] (badge xanh)
        │   └─ Đã huỷ: [totalCancelled] (badge đỏ)
        │ → Form tìm kiếm:
        │   ├─ Input text: "Tìm theo tên hoặc SĐT khách hàng..."
        │   ├─ Dropdown lọc status: Tất cả / Chờ check-in / Đã đến / Đã huỷ
        │   └─ Nút "Tìm kiếm"
        │ → Bảng danh sách lịch hẹn:
        │   ├─ Cột: STT | Tên KH | SĐT | Bác sĩ | Giờ hẹn | Dịch vụ | Trạng thái | Hành động
        │   ├─ Nếu Status = "Pending" hoặc "Confirmed":
        │   │   → Hiển thị nút "Check-in" (màu xanh, icon ✓)
        │   ├─ Nếu Status = "Attended":
        │   │   → Hiển thị badge "Đã đến" (không có nút)
        │   └─ Nếu Status = "Cancelled":
        │       → Hiển thị badge "Đã huỷ" (không có nút, màu đỏ)
        │ → Nút "Đặt lịch tại quầy" (link đến /receptionist/walk-in-booking)
        │ → Nếu danh sách rỗng → Hiển thị "Không có lịch hẹn nào hôm nay"
        │ → Nếu có attribute "successMessage" → Hiển thị alert xanh
        │ → Nếu có attribute "errorMessage" → Hiển thị alert đỏ
```

### Luồng POST — Check-in (cập nhật trạng thái):

> **Lưu ý:** Luồng POST này chính là **Chức năng 2** (Cập nhật trạng thái). 
> Được mô tả chi tiết ở [Mục 4](#4-chức-năng-2-cập-nhật-trạng-thái-lịch-hẹn).

## 3.5. Bảng Validate cho Chức năng Check-in (Hiển thị + Tìm kiếm)

| # | Validate | Phía | Vị trí code | Điều kiện kiểm tra | Kết quả nếu lỗi |
|---|----------|------|-------------|---------------------|-----------------|
| 1 | Kiểm tra đã đăng nhập | Server | Filter chain | `session.getAttribute("loggedInUser") == null` | Redirect → `/auth/login` |
| 2 | Kiểm tra đúng quyền Staff | Server | Filter chain | `user.getRoleID() != 3` | Forward → `/error/403.jsp` |
| 3 | Trim keyword tìm kiếm | Server | `CheckInController.doGet()` | `searchKeyword.trim()` | Loại bỏ khoảng trắng thừa |
| 4 | Chống XSS keyword tìm kiếm | Server | `CheckInController.doGet()` | Kiểm tra ký tự `< > " '` trong keyword | Trả lỗi hoặc encode |
| 5 | Giới hạn độ dài keyword (max 100) | Server | `CheckInController.doGet()` | `searchKeyword.length() > 100` | Trả lỗi "Từ khoá quá dài" |
| 6 | Validate filterStatus hợp lệ | Server | `CheckInController.doGet()` | Status chỉ được là: `Pending`, `Confirmed`, `Attended`, `Cancelled` hoặc rỗng | Bỏ qua filter nếu không hợp lệ |
| 7 | Hiển thị keyword giữ lại trên form | Client | `check-in.jsp` | Dùng `<c:out value="${searchKeyword}"/>` | Chống XSS khi hiển thị lại |
| 8 | Xử lý SQL Injection cho keyword | Server | `AppointmentDAO` | Dùng `PreparedStatement` với `?` | Không dùng nối chuỗi SQL |

## 3.6. Test Cases cho Check-in (Hiển thị + Tìm kiếm)

### TC-CI01: Hiển thị danh sách lịch hẹn hôm nay (không tìm kiếm)
```
Tiền điều kiện: 
  - Đã đăng nhập staff01/123
  - DB có 3 lịch hẹn ngày hôm nay (1 Pending, 1 Confirmed, 1 Attended)
Bước thực hiện:
  1. Vào /receptionist/check-in
Kết quả mong đợi:
  - Hiển thị bảng 3 dòng lịch hẹn
  - Thống kê: Tổng=3, Chờ check-in=2, Đã đến=1, Đã huỷ=0
  - 2 dòng Pending/Confirmed có nút "Check-in"
  - 1 dòng Attended hiện badge "Đã đến"
Luồng code:
  Filter OK → CheckInController.doGet() → appointmentDAO.getTodayAppointments()
  → setAttribute("appointmentList", list) → forward check-in.jsp
```

### TC-CI02: Tìm kiếm theo tên khách hàng
```
Bước: Nhập "Nguyễn" vào ô tìm kiếm → nhấn "Tìm kiếm"
Kết quả: 
  - Chỉ hiển thị các lịch hẹn của khách có tên chứa "Nguyễn"
  - Ô tìm kiếm vẫn giữ giá trị "Nguyễn"
Luồng: GET /receptionist/check-in?search=Nguyễn
  → CheckInController nhận param "search" = "Nguyễn"
  → appointmentDAO.searchTodayAppointments(today, "Nguyễn")
  → SQL: WHERE ... AND (c.FullName LIKE '%Nguyễn%' OR c.Phone LIKE '%Nguyễn%')
```

### TC-CI03: Tìm kiếm theo số điện thoại
```
Bước: Nhập "0912" vào ô tìm kiếm → nhấn "Tìm kiếm"
Kết quả: Hiển thị các lịch hẹn của khách có SĐT chứa "0912"
Luồng: appointmentDAO.searchTodayAppointments(today, "0912")
  → SQL LIKE '%0912%' trên cột Phone
```

### TC-CI04: Tìm kiếm không có kết quả
```
Bước: Nhập "XYZ999" → Tìm kiếm
Kết quả: 
  - Bảng rỗng
  - Hiển thị thông báo "Không tìm thấy lịch hẹn nào phù hợp"
  - Ô tìm kiếm vẫn giữ "XYZ999"
```

### TC-CI05: Lọc theo trạng thái "Chờ check-in"
```
Bước: Chọn dropdown "Chờ check-in" → Tìm kiếm
Kết quả: Chỉ hiển thị lịch hẹn có Status = "Pending" hoặc "Confirmed"
Luồng: GET /receptionist/check-in?status=Pending
  → appointmentDAO.getTodayAppointmentsByStatus(today, "Pending")
```

### TC-CI06: Truy cập bằng tài khoản Doctor (sai quyền)
```
Tiền điều kiện: Đăng nhập doctor01/123
Bước: Gõ URL /receptionist/check-in
Kết quả: 
  - AuthorizationFilter chặn: roleID=2 ≠ STAFF(3)
  - Forward đến 403.jsp
  - Hiện: "Vai trò: Bác sĩ" + "Trang yêu cầu: /receptionist/check-in"
```

### TC-CI07: Truy cập khi chưa đăng nhập
```
Bước: Gõ URL /receptionist/check-in (không đăng nhập)
Kết quả:
  - AuthenticationFilter chặn
  - Lưu redirectAfterLogin = "/receptionist/check-in"
  - Redirect về /auth/login
  - Sau đăng nhập staff01/123 → tự động quay về /receptionist/check-in
```

### TC-CI08: Tìm kiếm với ký tự đặc biệt (chống XSS)
```
Bước: Nhập "<script>alert('xss')</script>" vào ô tìm kiếm → Tìm
Kết quả:
  - Ô tìm kiếm hiển thị text thuần (không chạy script)
  - Không có kết quả tìm kiếm
  - Dùng <c:out> hoặc fn:escapeXml() để encode
```

## 3.7. Liên kết File ↔ File trong chức năng Check-in

```
check-in.jsp
  ├── [form action] ──────────→ CheckInController (/receptionist/check-in GET + POST)
  ├── [link "Đặt lịch tại quầy"] → WalkInBookingController (/receptionist/walk-in-booking GET)
  ├── [link "Dashboard"] ─────→ dashboard.jsp (/receptionist/dashboard)
  ├── [link "Đăng xuất"] ─────→ LogoutController (/auth/logout)
  ├── [attr "appointmentList"] → List<Appointment> từ CheckInController
  ├── [attr "totalToday"] ────→ int từ CheckInController
  ├── [attr "searchKeyword"] ──→ String từ CheckInController (giữ lại keyword)
  ├── [attr "successMessage"] → String từ CheckInController (sau check-in OK)
  └── [attr "errorMessage"] ──→ String từ CheckInController (lỗi)

CheckInController.java
  ├── [import] ──────→ AppointmentDAO.java (gọi getTodayAppointments, searchTodayAppointments, updateStatus)
  ├── [import] ──────→ Appointment.java (nhận List<Appointment> từ DAO)
  ├── [import] ──────→ User.java (lấy thông tin lễ tân từ session)
  ├── [forward] ─────→ check-in.jsp (hiển thị danh sách)
  └── [redirect] ────→ check-in.jsp (sau khi check-in thành công, redirect để tránh resubmit)

AppointmentDAO.java
  ├── [extends] ─────→ DBContext.java (kế thừa, dùng biến connection)
  ├── [import] ──────→ Appointment.java (tạo object từ ResultSet)
  └── [SQL query] ───→ SQL Server: bảng Appointments, Users (JOIN)
```

---

# 4. CHỨC NĂNG 2: CẬP NHẬT TRẠNG THÁI LỊCH HẸN (ATTENDED)

## 4.1. Mô tả tổng quan

Khi khách hàng đến phòng khám, Lễ tân nhấn nút **"Check-in"** trên danh sách lịch hẹn. Hệ thống sẽ cập nhật trạng thái lịch hẹn từ `Pending`/`Confirmed` → **`Attended`** (Đã đến).

Sau khi check-in thành công, khách hàng được điều hướng vào phòng khám gặp Bác sĩ (thuộc module của Thành viên 5).

## 4.2. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `check-in.jsp` | `web/receptionist/check-in.jsp` | Nút "Check-in" gửi POST |
| `CheckInController.java` | `src/java/controller/receptionist/CheckInController.java` | Xử lý POST cập nhật status |
| `AppointmentDAO.java` | `src/java/dal/AppointmentDAO.java` | Hàm `updateStatus()` + `getAppointmentByID()` |
| `Appointment.java` | `src/java/model/Appointment.java` | Đối tượng Appointment |

## 4.3. Luồng hoạt động chi tiết (Flow)

### Luồng POST — Cập nhật trạng thái → "Attended":

```
Bước 1: Lễ tân đang xem danh sách check-in (check-in.jsp)
        │ → Thấy khách hàng "Nguyễn Hoàng Nam" với lịch hẹn 09:00
        │ → Lịch hẹn đang ở trạng thái "Pending" (Chờ xác nhận)
        │ → Nhấn nút "Check-in" bên cạnh dòng đó
        │
Bước 2: │ HÀNH ĐỘNG TRÊN JSP:
        │ → Nút Check-in nằm trong một <form> ẩn:
        │   <form method="POST" action="/receptionist/check-in">
        │     <input type="hidden" name="action" value="checkin">
        │     <input type="hidden" name="appointmentId" value="1">
        │     <button type="submit">Check-in</button>
        │   </form>
        │
        │ → HOẶC sử dụng JavaScript confirm trước khi submit:
        │   onclick="return confirm('Xác nhận check-in cho Nguyễn Hoàng Nam?')"
        │
Bước 3: │ Request POST đi qua Filter chain (giống GET - đã đăng nhập + đúng quyền)
        │
Bước 4: │ CheckInController.doPost() được gọi
        │ → request.setCharacterEncoding("UTF-8")
        │ → Lấy tham số:
        │     String action = request.getParameter("action")
        │     String appointmentIdStr = request.getParameter("appointmentId")
        │
Bước 5: │ SERVER-SIDE VALIDATION #1: Kiểm tra action hợp lệ
        │ → action == null || !action.equals("checkin")
        │ → NẾU SAI:
        │   ├─ setAttribute("errorMessage", "Hành động không hợp lệ.")
        │   ├─ doGet(request, response) — hiển thị lại danh sách
        │   └─ RETURN
        │
Bước 6: │ SERVER-SIDE VALIDATION #2: Kiểm tra appointmentId
        │ → appointmentIdStr == null || appointmentIdStr.trim().isEmpty()
        │ → NẾU TRỐNG:
        │   ├─ setAttribute("errorMessage", "Không tìm thấy mã lịch hẹn.")
        │   ├─ doGet(request, response)
        │   └─ RETURN
        │
        │ → TRY parse: int appointmentId = Integer.parseInt(appointmentIdStr.trim())
        │ → CATCH NumberFormatException:
        │   ├─ setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ.")
        │   ├─ doGet(request, response)
        │   └─ RETURN
        │
Bước 7: │ SERVER-SIDE VALIDATION #3: Kiểm tra lịch hẹn tồn tại
        │ → Appointment apt = appointmentDAO.getAppointmentByID(appointmentId)
        │
        │   BÊN TRONG appointmentDAO.getAppointmentByID():
        │   ├─ SQL: SELECT * FROM Appointments WHERE AppointmentID = ?
        │   ├─ NẾU CÓ → return Appointment object
        │   └─ NẾU KHÔNG → return null
        │
        │ → NẾU apt == null:
        │   ├─ setAttribute("errorMessage", "Lịch hẹn không tồn tại trong hệ thống.")
        │   ├─ doGet(request, response)
        │   └─ RETURN
        │
Bước 8: │ SERVER-SIDE VALIDATION #4: Kiểm tra trạng thái hợp lệ để check-in
        │ → String currentStatus = apt.getStatus()
        │ → NẾU currentStatus KHÔNG PHẢI "Pending" VÀ KHÔNG PHẢI "Confirmed":
        │   ├─ NẾU currentStatus == "Attended":
        │   │   → errorMessage = "Khách hàng này đã được check-in trước đó."
        │   ├─ NẾU currentStatus == "Cancelled":
        │   │   → errorMessage = "Lịch hẹn này đã bị huỷ, không thể check-in."
        │   ├─ KHÁC:
        │   │   → errorMessage = "Trạng thái lịch hẹn không hợp lệ để check-in."
        │   ├─ doGet(request, response)
        │   └─ RETURN
        │
Bước 9: │ SERVER-SIDE VALIDATION #5: Kiểm tra ngày hẹn = ngày hôm nay
        │ → Date today = new Date(System.currentTimeMillis())
        │ → NẾU apt.getAppointmentDate() KHÔNG BẰNG today:
        │   ├─ errorMessage = "Chỉ có thể check-in lịch hẹn trong ngày hôm nay."
        │   ├─ doGet(request, response)
        │   └─ RETURN
        │
Bước 10: │ CẬP NHẬT TRẠNG THÁI:
         │ → boolean success = appointmentDAO.updateStatus(appointmentId, "Attended")
         │
         │   BÊN TRONG appointmentDAO.updateStatus():
         │   ├─ SQL: UPDATE Appointments SET Status = ? WHERE AppointmentID = ?
         │   ├─ ps.setString(1, "Attended")
         │   ├─ ps.setInt(2, appointmentId)
         │   ├─ executeUpdate() > 0 → return true
         │   └─ executeUpdate() ≤ 0 hoặc SQLException → return false
         │
Bước 11: │ XỬ LÝ KẾT QUẢ:
         │ ├─ NẾU success = true:
         │ │   → session.setAttribute("successMessage", 
         │ │         "Check-in thành công cho khách hàng [tên khách]!")
         │ │   → sendRedirect(contextPath + "/receptionist/check-in")
         │ │     (Dùng redirect thay vì forward để tránh resubmit khi F5)
         │ │
         │ └─ NẾU success = false:
         │     → setAttribute("errorMessage", "Lỗi hệ thống: Không thể cập nhật trạng thái.")
         │     → doGet(request, response)
```

## 4.4. Bảng Validate đầy đủ cho Check-in (Cập nhật Status)

| # | Validate | Phía | Vị trí code | Điều kiện kiểm tra | Kết quả nếu lỗi |
|---|----------|------|-------------|---------------------|-----------------|
| 1 | Xác nhận trước khi check-in | Client | `check-in.jsp` JS | `confirm('Xác nhận check-in?')` | Huỷ nếu user nhấn Cancel |
| 2 | Action phải = "checkin" | Server | `CheckInController.doPost()` | `!action.equals("checkin")` | "Hành động không hợp lệ." |
| 3 | appointmentId không trống | Server | `CheckInController.doPost()` | `appointmentIdStr == null \|\| isEmpty()` | "Không tìm thấy mã lịch hẹn." |
| 4 | appointmentId là số nguyên | Server | `CheckInController.doPost()` | `Integer.parseInt()` throws `NumberFormatException` | "Mã lịch hẹn không hợp lệ." |
| 5 | appointmentId > 0 | Server | `CheckInController.doPost()` | `appointmentId <= 0` | "Mã lịch hẹn không hợp lệ." |
| 6 | Lịch hẹn tồn tại trong DB | Server | `AppointmentDAO.getAppointmentByID()` | `apt == null` (SQL trả về rỗng) | "Lịch hẹn không tồn tại." |
| 7 | Status hiện tại = Pending hoặc Confirmed | Server | `CheckInController.doPost()` | `status != "Pending" && status != "Confirmed"` | Thông báo lỗi tương ứng |
| 8 | Ngày hẹn = ngày hôm nay | Server | `CheckInController.doPost()` | `apt.getAppointmentDate() != today` | "Chỉ check-in lịch hẹn hôm nay." |
| 9 | Cập nhật DB thành công | Server | `AppointmentDAO.updateStatus()` | `executeUpdate() <= 0` | "Lỗi hệ thống..." |
| 10 | Chống resubmit (F5) | Server | `CheckInController.doPost()` | Dùng `sendRedirect()` thay `forward()` | Tránh POST lại khi refresh |
| 11 | Chống CSRF (tuỳ chọn) | Server | `CheckInController.doPost()` | Kiểm tra CSRF token trong form | Chặn form giả mạo |

## 4.5. Test Cases cho Check-in (Cập nhật Status)

### TC-CK01: Check-in thành công từ trạng thái Pending
```
Tiền điều kiện:
  - Đã đăng nhập staff01/123
  - DB có Appointment ID=3, Status="Pending", Date=ngày hôm nay
Bước thực hiện:
  1. Vào /receptionist/check-in
  2. Tìm dòng lịch hẹn ID=3 (Phạm Minh Đức, 14:00)
  3. Nhấn nút "Check-in"
  4. Confirm dialog → Nhấn OK
Kết quả mong đợi:
  - Redirect lại /receptionist/check-in
  - Hiện alert xanh: "Check-in thành công cho khách hàng Phạm Minh Đức!"
  - Dòng ID=3 đổi badge thành "Đã đến" (xanh), nút Check-in biến mất
  - Thống kê cập nhật: Chờ check-in giảm 1, Đã đến tăng 1
Kiểm tra DB: SELECT Status FROM Appointments WHERE AppointmentID = 3
  → Status = 'Attended'
Luồng code:
  check-in.jsp → POST → CheckInController.doPost()
  → action="checkin", appointmentId=3
  → getAppointmentByID(3) → apt (Status="Pending") → hợp lệ
  → updateStatus(3, "Attended") → true
  → redirect /receptionist/check-in + session successMessage
```

### TC-CK02: Check-in thành công từ trạng thái Confirmed
```
Tiền điều kiện: Appointment ID=X, Status="Confirmed", Date=hôm nay
Bước: Nhấn Check-in cho lịch hẹn đã Confirmed
Kết quả: Check-in thành công, Status đổi thành "Attended"
Luồng: Giống TC-CK01, currentStatus="Confirmed" → hợp lệ → update
```

### TC-CK03: Check-in lịch hẹn đã Attended (lỗi)
```
Tiền điều kiện: Appointment ID=1, Status="Attended"
Bước: Cố gắng POST check-in cho ID=1
Kết quả: 
  - Hiện alert đỏ: "Khách hàng này đã được check-in trước đó."
  - KHÔNG cập nhật DB
Luồng: getAppointmentByID(1) → status="Attended" → validation #4 fail → errorMessage
```

### TC-CK04: Check-in lịch hẹn đã Cancelled (lỗi)
```
Tiền điều kiện: Appointment có Status="Cancelled"
Bước: POST check-in
Kết quả: "Lịch hẹn này đã bị huỷ, không thể check-in."
```

### TC-CK05: Check-in với appointmentId không tồn tại
```
Bước: POST với appointmentId=999 (không tồn tại trong DB)
Kết quả: "Lịch hẹn không tồn tại trong hệ thống."
Luồng: getAppointmentByID(999) → return null → errorMessage
```

### TC-CK06: Check-in với appointmentId không phải số
```
Bước: POST với appointmentId="abc"
Kết quả: "Mã lịch hẹn không hợp lệ."
Luồng: Integer.parseInt("abc") → NumberFormatException → errorMessage
```

### TC-CK07: Check-in lịch hẹn ngày khác (không phải hôm nay)
```
Tiền điều kiện: Appointment Date = ngày mai, Status="Pending"
Bước: POST check-in
Kết quả: "Chỉ có thể check-in lịch hẹn trong ngày hôm nay."
```

### TC-CK08: Nhấn F5 sau khi check-in (chống resubmit)
```
Bước:
  1. Check-in thành công cho 1 lịch hẹn
  2. Nhấn F5 (Refresh trang)
Kết quả: 
  - KHÔNG gửi lại POST (vì dùng sendRedirect, browser gửi GET mới)
  - Trang hiển thị danh sách bình thường, không check-in lại
```

## 4.6. Liên kết File ↔ File cho Check-in (Update Status)

```
check-in.jsp
  ├── [form POST action] ─────→ CheckInController (/receptionist/check-in POST)
  ├── [hidden input "action"] → value="checkin"
  ├── [hidden input "appointmentId"] → value="${appointment.appointmentID}"
  └── [JS confirm()] ────────→ Xác nhận trước submit

CheckInController.doPost()
  ├── [import] ──────→ AppointmentDAO.java (gọi getAppointmentByID, updateStatus)
  ├── [import] ──────→ Appointment.java (nhận object, kiểm tra status/date)
  ├── [redirect] ────→ /receptionist/check-in (sau khi thành công)
  └── [forward] ─────→ check-in.jsp (khi có lỗi, hiển thị lại + errorMessage)
```

---

# 5. CHỨC NĂNG 3: ĐẶT LỊCH HẸN TRỰC TIẾP TẠI QUẦY (WALK-IN BOOKING)

## 5.1. Mô tả tổng quan

Chức năng này dành cho **khách hàng vãng lai** (walk-in) — tức là khách đến phòng khám trực tiếp mà **không đặt lịch trước qua mạng**. Lễ tân sẽ:
1. Tìm kiếm xem khách đã có tài khoản trong hệ thống chưa (theo SĐT hoặc tên)
2. Nếu chưa có → tạo tài khoản khách hàng nhanh
3. Chọn bác sĩ (dựa trên lịch làm việc ngày hôm nay)
4. Chọn dịch vụ khám
5. Chọn thời gian trống
6. Tạo lịch hẹn với trạng thái **"Attended"** (vì khách đã ở đây rồi)

## 5.2. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `walk-in-booking.jsp` | `web/receptionist/walk-in-booking.jsp` | **[NEW]** Giao diện form đặt lịch tại quầy (View) |
| `WalkInBookingController.java` | `src/java/controller/receptionist/WalkInBookingController.java` | **[NEW]** Xử lý logic đặt lịch walk-in (Controller) |
| `AppointmentDAO.java` | `src/java/dal/AppointmentDAO.java` | **[MODIFY]** Thêm hàm `createWalkInAppointment()`, `isTimeSlotAvailable()` |
| `UserDAO.java` | `src/java/dal/UserDAO.java` | Dùng hàm `getUsersByRole()` (lấy DS bác sĩ), `searchUsers()` (tìm khách) |
| `ServiceDAO.java` | `src/java/dal/ServiceDAO.java` | Dùng hàm lấy danh sách dịch vụ đang hoạt động |
| `Appointment.java` | `src/java/model/Appointment.java` | Đối tượng Appointment |
| `web.xml` | `web/WEB-INF/web.xml` | **[MODIFY]** Thêm servlet mapping cho `/receptionist/walk-in-booking` |

## 5.3. Luồng hoạt động chi tiết (Flow)

### Luồng GET — Hiển thị form đặt lịch tại quầy:

```
Bước 1: Lễ tân nhấn nút "Đặt lịch tại quầy" trên trang check-in
        │ → GET /receptionist/walk-in-booking
        │
Bước 2: │ Filter chain: Kiểm tra đăng nhập + quyền Staff → OK
        │
Bước 3: │ WalkInBookingController.doGet() được gọi
        │ → Chuẩn bị dữ liệu cho form:
        │
        │ ┌─── Bước 3a: Lấy danh sách Bác sĩ đang làm việc hôm nay
        │ │    → Date today = new Date(System.currentTimeMillis())
        │ │    → List<User> doctors = userDAO.getUsersByRole(2)  // RoleID=2 = Doctor
        │ │    → Lọc: chỉ lấy bác sĩ CÓ lịch trong DoctorSchedules ngày hôm nay
        │ │      VÀ Status = 'Active'
        │ │    → HOẶC: dùng hàm riêng appointmentDAO.getAvailableDoctorsToday()
        │ │
        │ ├─── Bước 3b: Lấy danh sách Dịch vụ đang hoạt động
        │ │    → List<Service> services = serviceDAO.getActiveServices()
        │ │    → SQL: SELECT * FROM Services WHERE Status = 1
        │ │
        │ └─── Bước 3c: Tạo danh sách khung giờ (Time Slots)
        │      → Ví dụ: 08:00, 08:30, 09:00, 09:30, ..., 17:00
        │      → Hoặc để user nhập giờ tự do
        │
Bước 4: │ Set attributes cho JSP:
        │ → request.setAttribute("doctorList", doctors)
        │ → request.setAttribute("serviceList", services)
        │ → request.setAttribute("today", today)
        │
Bước 5: │ Forward đến view:
        │ → request.getRequestDispatcher("/receptionist/walk-in-booking.jsp")
        │          .forward(request, response)
        │
Bước 6: │ walk-in-booking.jsp render HTML:
        │ → Tiêu đề: "Đặt lịch tại quầy (Walk-in Booking)"
        │ → Form gồm các trường:
        │
        │   ┌─── NHÓM 1: Thông tin khách hàng ──────────────────────┐
        │   │ ▸ Ô tìm kiếm: "Nhập SĐT hoặc tên khách hàng..."     │
        │   │   (Có nút "Tìm" → AJAX tìm khách trong DB)            │
        │   │ ▸ Nếu tìm thấy → Tự động điền: Tên, SĐT, Email       │
        │   │ ▸ Nếu không tìm thấy → Hiện form nhập mới:            │
        │   │   - Họ và tên (bắt buộc)                               │
        │   │   - Số điện thoại (bắt buộc)                           │
        │   │   - Email (tuỳ chọn)                                   │
        │   │ ▸ Hidden input: customerID (nếu đã tìm thấy)          │
        │   └────────────────────────────────────────────────────────┘
        │
        │   ┌─── NHÓM 2: Chọn bác sĩ ──────────────────────────────┐
        │   │ ▸ Dropdown: Chọn bác sĩ (từ doctorList)               │
        │   │   Option format: "BS. Nguyễn Văn Minh (Răng Hàm Mặt)" │
        │   │ ▸ Nếu không chọn → DoctorID = NULL (khám tổng quát)   │
        │   └────────────────────────────────────────────────────────┘
        │
        │   ┌─── NHÓM 3: Chọn dịch vụ ─────────────────────────────┐
        │   │ ▸ Checkbox list: Danh sách dịch vụ (từ serviceList)   │
        │   │   Format: "☐ Răng sứ Cercon — 5,000,000₫"             │
        │   │ ▸ Cho phép chọn nhiều dịch vụ                         │
        │   │ ▸ Ít nhất phải chọn 1 dịch vụ                         │
        │   └────────────────────────────────────────────────────────┘
        │
        │   ┌─── NHÓM 4: Thời gian khám ───────────────────────────┐
        │   │ ▸ Ngày hẹn: Hiện ngày hôm nay (readonly, vì walk-in) │
        │   │ ▸ Giờ hẹn: Input time hoặc dropdown khung giờ         │
        │   └────────────────────────────────────────────────────────┘
        │
        │   ┌─── NHÓM 5: Ghi chú ──────────────────────────────────┐
        │   │ ▸ Textarea: Ghi chú (tuỳ chọn)                       │
        │   └────────────────────────────────────────────────────────┘
        │
        │ → Nút "Tạo lịch hẹn" (submit form POST)
        │ → Nút "Quay lại" (link về /receptionist/check-in)
```

### Luồng POST — Xử lý tạo lịch hẹn walk-in:

```
Bước 1: Lễ tân điền form → nhấn "Tạo lịch hẹn"
        │
Bước 2: │ CLIENT-SIDE VALIDATION (JavaScript walk-in-booking.jsp):
        │ ├─ Kiểm tra: Đã chọn/nhập thông tin khách hàng chưa?
        │ │   → customerID có giá trị HOẶC các trường (tên, SĐT) đã điền?
        │ │   → Nếu chưa → alert("Vui lòng nhập thông tin khách hàng.") → chặn
        │ │
        │ ├─ Kiểm tra: Họ tên khách (nếu nhập mới) không rỗng?
        │ │   → Nếu rỗng → alert + chặn
        │ │
        │ ├─ Kiểm tra: SĐT khách (nếu nhập mới) không rỗng?
        │ │   → Nếu rỗng → alert + chặn
        │ │
        │ ├─ Kiểm tra: SĐT đúng format VN?
        │ │   → regex: /^(0|\+84)[0-9]{9,10}$/
        │ │   → Nếu sai → alert("Số điện thoại không hợp lệ.") → chặn
        │ │
        │ ├─ Kiểm tra: Đã chọn ít nhất 1 dịch vụ?
        │ │   → document.querySelectorAll('input[name="serviceIds"]:checked').length == 0
        │ │   → Nếu chưa → alert("Vui lòng chọn ít nhất 1 dịch vụ.") → chặn
        │ │
        │ ├─ Kiểm tra: Đã chọn giờ hẹn?
        │ │   → Nếu chưa → alert + chặn
        │ │
        │ └─ Kiểm tra: Email (nếu nhập) đúng format?
        │     → regex: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        │     → Nếu sai → alert + chặn
        │
Bước 3: │ POST /receptionist/walk-in-booking → qua Filter chain → WalkInBookingController.doPost()
        │
Bước 4: │ Đọc tham số từ request:
        │ → String customerIdStr = request.getParameter("customerId")     // null nếu khách mới
        │ → String customerName = request.getParameter("customerName")
        │ → String customerPhone = request.getParameter("customerPhone")
        │ → String customerEmail = request.getParameter("customerEmail")
        │ → String doctorIdStr = request.getParameter("doctorId")
        │ → String[] serviceIdStrs = request.getParameterValues("serviceIds")
        │ → String appointmentTime = request.getParameter("appointmentTime")
        │ → String notes = request.getParameter("notes")
        │
Bước 5: │ SERVER-SIDE VALIDATION (tuần tự, dừng ở lỗi đầu tiên):
        │
        │ ┌─── Validate #1: Xác định khách hàng (mới hay đã có)
        │ │    NẾU customerIdStr != null && !customerIdStr.isEmpty():
        │ │      → int customerId = Integer.parseInt(customerIdStr)
        │ │      → Kiểm tra user tồn tại: userDAO.getUserByID(customerId)
        │ │      → NẾU null → lỗi "Khách hàng không tồn tại."
        │ │    
        │ │    NẾU customerIdStr rỗng (khách mới):
        │ │      → Phải validate customerName + customerPhone
        │ │
        │ ├─── Validate #2: Tên khách (nếu khách mới) không trống
        │ │    customerName == null || customerName.trim().isEmpty()
        │ │    → "Họ và tên khách hàng không được để trống."
        │ │
        │ ├─── Validate #3: Tên khách dài 2-100 ký tự
        │ │    customerName.trim().length() < 2 || > 100
        │ │    → "Họ và tên phải từ 2 đến 100 ký tự."
        │ │
        │ ├─── Validate #4: Tên khách không chứa ký tự nguy hiểm
        │ │    Chặn: < > " ' & để chống XSS
        │ │    → "Họ và tên chứa ký tự không hợp lệ."
        │ │
        │ ├─── Validate #5: SĐT khách (nếu khách mới) không trống
        │ │    customerPhone == null || customerPhone.trim().isEmpty()
        │ │    → "Số điện thoại không được để trống."
        │ │
        │ ├─── Validate #6: SĐT đúng format VN
        │ │    !customerPhone.trim().matches("^(0|\\+84)[0-9]{9,10}$")
        │ │    → "Số điện thoại không hợp lệ (ví dụ: 0912345678)."
        │ │
        │ ├─── Validate #7: Email đúng format (nếu có nhập)
        │ │    email != null && !email.isEmpty()
        │ │    && !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
        │ │    → "Địa chỉ email không hợp lệ."
        │ │
        │ ├─── Validate #8: Đã chọn ít nhất 1 dịch vụ
        │ │    serviceIdStrs == null || serviceIdStrs.length == 0
        │ │    → "Vui lòng chọn ít nhất 1 dịch vụ."
        │ │
        │ ├─── Validate #9: Mỗi serviceId là số hợp lệ + tồn tại trong DB
        │ │    → Vòng lặp: Integer.parseInt(serviceIdStr)
        │ │    → Kiểm tra tồn tại trong bảng Services
        │ │    → Kiểm tra Status = 1 (đang hoạt động)
        │ │    → "Dịch vụ không hợp lệ hoặc đã ngừng cung cấp."
        │ │
        │ ├─── Validate #10: Giờ hẹn không trống
        │ │    appointmentTime == null || appointmentTime.trim().isEmpty()
        │ │    → "Vui lòng chọn giờ hẹn."
        │ │
        │ ├─── Validate #11: Giờ hẹn đúng format (HH:mm)
        │ │    → Try parse: Time.valueOf(appointmentTime + ":00")
        │ │    → Catch: "Giờ hẹn không đúng định dạng."
        │ │
        │ ├─── Validate #12: Giờ hẹn trong giờ làm việc (08:00 - 17:00)
        │ │    → time < 08:00 || time > 17:00
        │ │    → "Giờ hẹn phải nằm trong khung giờ làm việc (08:00 - 17:00)."
        │ │
        │ ├─── Validate #13: DoctorID hợp lệ (nếu có chọn)
        │ │    doctorIdStr != null && !doctorIdStr.isEmpty():
        │ │    → int doctorId = Integer.parseInt(doctorIdStr)
        │ │    → Kiểm tra user tồn tại + roleID == 2 (Doctor)
        │ │    → "Bác sĩ không hợp lệ."
        │ │
        │ ├─── Validate #14: Bác sĩ có lịch làm việc hôm nay
        │ │    → Kiểm tra DoctorSchedules: có record DoctorID + WorkDate = today + Status='Active'?
        │ │    → NẾU KHÔNG → "Bác sĩ [tên] không có lịch làm việc hôm nay."
        │ │
        │ ├─── Validate #15: Bác sĩ có trống slot giờ đó không (chống trùng)
        │ │    → appointmentDAO.isTimeSlotAvailable(doctorId, today, time)
        │ │    → SQL: SELECT COUNT(*) FROM Appointments 
        │ │           WHERE DoctorID = ? AND AppointmentDate = ? AND AppointmentTime = ?
        │ │           AND Status != 'Cancelled'
        │ │    → NẾU count > 0 → "Bác sĩ [tên] đã có lịch hẹn lúc [giờ]. Vui lòng chọn giờ khác."
        │ │
        │ └─── Validate #16: Ghi chú dài tối đa 500 ký tự
        │      notes != null && notes.trim().length() > 500
        │      → "Ghi chú không được vượt quá 500 ký tự."
        │
        │ NẾU CÓ LỖI VALIDATE:
        │   → setAttribute("errorMessage", lỗi)
        │   → Giữ lại dữ liệu đã nhập (setAttribute cho từng trường)
        │   → Load lại doctorList, serviceList
        │   → forward → walk-in-booking.jsp
        │   → RETURN
        │
Bước 6: │ TẠO KHÁCH HÀNG MỚI (nếu cần):
        │ NẾU customerIdStr rỗng (khách mới):
        │   → userDAO.register(generateUsername(customerPhone), 
        │         defaultPassword, customerName, customerPhone, customerEmail)
        │     Giải thích:
        │     - generateUsername: tạo username từ SĐT, ví dụ "kh_0912345678"
        │     - defaultPassword: mật khẩu mặc định, ví dụ "123456"
        │     - RoleID = 4 (Customer) được hardcode trong register()
        │   → NẾU thất bại → errorMessage + forward
        │   → NẾU thành công → Lấy lại UserID vừa tạo
        │
Bước 7: │ TẠO LỊCH HẸN:
        │ → boolean success = appointmentDAO.createWalkInAppointment(
        │     customerId, doctorId, today, time, "Attended", notes, serviceIds)
        │
        │   BÊN TRONG createWalkInAppointment():
        │   ├─ Bắt đầu Transaction
        │   │
        │   ├─ SQL 1: INSERT INTO Appointments 
        │   │   (CustomerID, DoctorID, AppointmentDate, AppointmentTime, Status, Notes)
        │   │   VALUES (?, ?, ?, ?, 'Attended', ?)
        │   │   → Lấy AppointmentID vừa tạo (SCOPE_IDENTITY() hoặc Statement.RETURN_GENERATED_KEYS)
        │   │
        │   ├─ SQL 2: INSERT INTO AppointmentServices (AppointmentID, ServiceID)
        │   │   → Vòng lặp cho mỗi ServiceID đã chọn
        │   │   → VALUES (newAppointmentId, serviceId)
        │   │
        │   ├─ Commit Transaction
        │   │
        │   ├─ Thành công → return true
        │   └─ Lỗi → Rollback Transaction → return false
        │
Bước 8: │ XỬ LÝ KẾT QUẢ:
        │ ├─ NẾU success = true:
        │ │   → session.setAttribute("successMessage", 
        │ │         "Đặt lịch thành công! Khách hàng [tên] đã được check-in.")
        │ │   → sendRedirect(contextPath + "/receptionist/check-in")
        │ │   → (Quay về trang check-in, hiện thông báo thành công)
        │ │
        │ └─ NẾU success = false:
        │     → setAttribute("errorMessage", "Lỗi hệ thống: Không thể tạo lịch hẹn.")
        │     → Load lại doctorList, serviceList
        │     → forward walk-in-booking.jsp
```

## 5.4. Bảng Validate đầy đủ cho Walk-in Booking

| # | Validate | Phía | Code | Regex/Điều kiện | Lỗi trả về |
|---|----------|------|------|-----------------|-------------|
| 1 | CustomerID hợp lệ (nếu có) | Server | Controller | `getUserByID() == null` | "Khách hàng không tồn tại." |
| 2 | Tên khách trống (nếu mới) | Client | JS | `!customerName.trim()` | alert + chặn |
| 3 | Tên khách trống (nếu mới) | Server | Controller | `isEmpty()` | "Họ và tên không được để trống." |
| 4 | Tên khách 2-100 ký tự | Server | Controller | `length < 2 \|\| > 100` | "...phải từ 2 đến 100 ký tự." |
| 5 | Tên khách chống ký tự nguy hiểm | Server | Controller | Chặn `< > " ' &` | "...chứa ký tự không hợp lệ." |
| 6 | SĐT trống (nếu mới) | Client | JS | `!phone.trim()` | alert + chặn |
| 7 | SĐT trống (nếu mới) | Server | Controller | `isEmpty()` | "SĐT không được để trống." |
| 8 | SĐT đúng format VN | Client | JS | `/^(0\|\+84)[0-9]{9,10}$/` | alert |
| 9 | SĐT đúng format VN | Server | Controller | `^(0\|\\+84)[0-9]{9,10}$` | "SĐT không hợp lệ." |
| 10 | Email format (nếu nhập) | Client | JS | regex email | alert |
| 11 | Email format (nếu nhập) | Server | Controller | regex email | "Email không hợp lệ." |
| 12 | Ít nhất 1 dịch vụ | Client | JS | `checked.length == 0` | alert |
| 13 | Ít nhất 1 dịch vụ | Server | Controller | `serviceIds == null \|\| length == 0` | "Chọn ít nhất 1 dịch vụ." |
| 14 | ServiceID là số hợp lệ | Server | Controller | `parseInt()` throws | "Dịch vụ không hợp lệ." |
| 15 | Service tồn tại + đang hoạt động | Server | Controller/DAO | Kiểm tra DB | "Dịch vụ đã ngừng cung cấp." |
| 16 | Giờ hẹn trống | Client | JS | `!time` | alert |
| 17 | Giờ hẹn trống | Server | Controller | `isEmpty()` | "Chọn giờ hẹn." |
| 18 | Giờ hẹn đúng format | Server | Controller | `Time.valueOf()` throws | "Giờ hẹn sai định dạng." |
| 19 | Giờ hẹn trong 08:00-17:00 | Server | Controller | So sánh Time | "Ngoài giờ làm việc." |
| 20 | DoctorID hợp lệ (nếu chọn) | Server | Controller | `getUserByID() + roleID==2` | "Bác sĩ không hợp lệ." |
| 21 | Bác sĩ có lịch làm việc hôm nay | Server | DAO | Query DoctorSchedules | "Bác sĩ không có lịch." |
| 22 | Slot giờ chưa bị trùng | Server | DAO | `isTimeSlotAvailable()` | "Bác sĩ đã có lịch lúc..." |
| 23 | Ghi chú ≤ 500 ký tự | Server | Controller | `length > 500` | "Ghi chú quá dài." |
| 24 | Ghi chú chống XSS | Server | Controller | Encode `< > " '` | Encode trước khi lưu DB |
| 25 | Chống resubmit (F5) | Server | Controller | Dùng `sendRedirect()` | Không tạo lịch trùng |
| 26 | Giữ lại dữ liệu khi lỗi | Server | Controller | `setAttribute()` cho mỗi trường | Form điền sẵn dữ liệu cũ |

## 5.5. Test Cases cho Walk-in Booking

### TC-WI01: Đặt lịch walk-in thành công cho khách CŨ (đã có tài khoản)
```
Tiền điều kiện:
  - Đăng nhập staff01/123
  - DB có customer01 (UserID=6, SĐT: 0912345678)
  - doctor01 có lịch làm việc hôm nay
Bước thực hiện:
  1. Vào /receptionist/walk-in-booking
  2. Tìm khách: nhập "0912345678" → nhấn "Tìm"
  3. Hệ thống tự điền: Nguyễn Hoàng Nam, 0912345678, nam.nh@gmail.com
  4. Chọn bác sĩ: BS. Nguyễn Văn Minh
  5. Chọn dịch vụ: ☑ Trám răng Composite
  6. Giờ hẹn: 10:00
  7. Ghi chú: "Khách đến trực tiếp, đau răng cấp"
  8. Nhấn "Tạo lịch hẹn"
Kết quả mong đợi:
  - Redirect về /receptionist/check-in
  - Thông báo xanh: "Đặt lịch thành công! Khách hàng Nguyễn Hoàng Nam đã được check-in."
  - Lịch hẹn mới xuất hiện trên danh sách với Status = "Attended"
Kiểm tra DB:
  - Appointments: có row mới (CustomerID=6, DoctorID=2, Time=10:00, Status='Attended')
  - AppointmentServices: có row mới (AppointmentID=new, ServiceID=3)
```

### TC-WI02: Đặt lịch walk-in cho khách MỚI (chưa có tài khoản)
```
Bước:
  1. Tìm khách: nhập "0999888777" → Không tìm thấy
  2. Điền form khách mới: Tên="Lê Văn Test", SĐT="0999888777", Email=""
  3. Chọn bác sĩ + dịch vụ + giờ
  4. Nhấn "Tạo lịch hẹn"
Kết quả:
  - Tạo user mới: username="kh_0999888777", RoleID=4
  - Tạo appointment mới với CustomerID = userID vừa tạo
  - Status = "Attended"
Kiểm tra DB:
  - Users: có row mới (Username='kh_0999888777', FullName='Lê Văn Test')
  - Appointments: có row mới liên kết với user mới
```

### TC-WI03: Không chọn dịch vụ (lỗi)
```
Bước: Điền đủ thông tin khách + bác sĩ + giờ, KHÔNG tick dịch vụ → Submit
Kết quả: 
  - Client: alert "Vui lòng chọn ít nhất 1 dịch vụ." → chặn submit
  - Nếu JS tắt → Server: errorMessage + forward lại form
```

### TC-WI04: Chọn giờ đã bị bác sĩ bận (trùng slot)
```
Tiền điều kiện: doctor01 đã có lịch hẹn lúc 09:00 hôm nay
Bước: Chọn doctor01, giờ 09:00 → Submit
Kết quả: "Bác sĩ Nguyễn Văn Minh đã có lịch hẹn lúc 09:00. Vui lòng chọn giờ khác."
Luồng: isTimeSlotAvailable(doctorId=2, today, 09:00) → false → errorMessage
```

### TC-WI05: Chọn giờ ngoài giờ làm việc
```
Bước: Nhập giờ = "06:00" → Submit
Kết quả: "Giờ hẹn phải nằm trong khung giờ làm việc (08:00 - 17:00)."
```

### TC-WI06: SĐT khách mới sai format
```
Bước: Nhập SĐT = "12345" → Submit
Kết quả: 
  - Client: alert "Số điện thoại không hợp lệ"
  - Server: "Số điện thoại không hợp lệ (ví dụ: 0912345678)."
```

### TC-WI07: Bác sĩ không có lịch làm việc hôm nay
```
Tiền điều kiện: doctor02 không có record trong DoctorSchedules ngày hôm nay
Bước: Chọn doctor02 → Submit
Kết quả: "Bác sĩ Trần Thị Lan không có lịch làm việc hôm nay."
```

### TC-WI08: Tên khách chứa ký tự nguy hiểm (XSS)
```
Bước: Nhập tên = "<script>alert(1)</script>" → Submit
Kết quả: "Họ và tên chứa ký tự không hợp lệ."
```

### TC-WI09: Nhấn F5 sau khi đặt lịch (chống resubmit)
```
Bước:
  1. Đặt lịch thành công → redirect về /receptionist/check-in
  2. Nhấn F5
Kết quả: Trang check-in load lại bình thường (GET), KHÔNG tạo lịch hẹn mới
```

### TC-WI10: Giữ lại dữ liệu khi có lỗi validate
```
Bước:
  1. Điền đầy đủ form nhưng SĐT sai format
  2. Submit → lỗi validate SĐT
Kết quả:
  - Ở lại trang walk-in-booking.jsp
  - Tất cả dữ liệu đã nhập (tên, email, bác sĩ, dịch vụ, giờ, ghi chú) được giữ lại
  - Hiển thị alert đỏ: "Số điện thoại không hợp lệ."
```

## 5.6. Liên kết File ↔ File cho Walk-in Booking

```
walk-in-booking.jsp
  ├── [form action POST] ─────→ WalkInBookingController (/receptionist/walk-in-booking)
  ├── [link "Quay lại"] ──────→ CheckInController (/receptionist/check-in)
  ├── [AJAX tìm khách] ───────→ WalkInBookingController (GET ?searchCustomer=xxx)
  ├── [attr "doctorList"] ────→ List<User> từ WalkInBookingController
  ├── [attr "serviceList"] ───→ List<Service> từ WalkInBookingController
  ├── [attr "errorMessage"] ──→ String từ WalkInBookingController
  └── [attr "regXxx"] ────────→ Dữ liệu giữ lại khi lỗi

WalkInBookingController.java
  ├── [import] ──────→ AppointmentDAO.java (gọi createWalkInAppointment, isTimeSlotAvailable)
  ├── [import] ──────→ UserDAO.java (gọi getUsersByRole, getUserByID, register)
  ├── [import] ──────→ ServiceDAO.java (gọi getActiveServices)
  ├── [import] ──────→ Appointment.java (tạo object)
  ├── [import] ──────→ User.java, Service.java (nhận list)
  ├── [forward] ─────→ walk-in-booking.jsp (khi lỗi hoặc hiển thị form)
  └── [redirect] ────→ /receptionist/check-in (sau khi đặt lịch thành công)

AppointmentDAO.java
  ├── [extends] ─────→ DBContext.java
  ├── [import] ──────→ Appointment.java
  ├── [SQL INSERT] ──→ bảng Appointments
  ├── [SQL INSERT] ──→ bảng AppointmentServices
  └── [SQL SELECT] ──→ bảng DoctorSchedules (kiểm tra lịch BS)
```

---

# 6. DANH SÁCH FILE CẦN TẠO / SỬA

## 6.1. File cần TẠO MỚI [NEW]

| # | Loại | File | Đường dẫn | Mô tả |
|---|------|------|-----------|-------|
| 1 | JSP | `check-in.jsp` | `web/receptionist/check-in.jsp` | Giao diện danh sách lịch hẹn + tìm kiếm + nút check-in |
| 2 | JSP | `walk-in-booking.jsp` | `web/receptionist/walk-in-booking.jsp` | Form đặt lịch tại quầy cho khách vãng lai |
| 3 | Java | `WalkInBookingController.java` | `src/java/controller/receptionist/WalkInBookingController.java` | Servlet xử lý logic đặt lịch walk-in |

## 6.2. File cần SỬA [MODIFY]

| # | File | Đường dẫn | Nội dung cần sửa |
|---|------|-----------|------------------|
| 1 | `Appointment.java` | `src/java/model/Appointment.java` | Bổ sung toàn bộ thuộc tính, constructor, getter/setter (hiện đang rỗng) |
| 2 | `AppointmentDAO.java` | `src/java/dal/AppointmentDAO.java` | Bổ sung các hàm: `getTodayAppointments()`, `searchTodayAppointments()`, `updateStatus()`, `getAppointmentByID()`, `createWalkInAppointment()`, `isTimeSlotAvailable()`, v.v. (hiện đang rỗng) |
| 3 | `CheckInController.java` | `src/java/controller/receptionist/CheckInController.java` | Chuyển từ class thường → HttpServlet, thêm logic doGet/doPost (hiện đang rỗng) |
| 4 | `web.xml` | `web/WEB-INF/web.xml` | Thêm servlet mapping cho `/receptionist/check-in` và `/receptionist/walk-in-booking` |
| 5 | `dashboard.jsp` | `web/receptionist/dashboard.jsp` | Cập nhật link menu trỏ đến trang check-in và walk-in-booking |

---

# 7. APPOINTMENTDAO — CÁC HÀM CẦN CODE

## 7.1. Tổng quan các hàm

| # | Hàm | Mục đích | Dùng bởi |
|---|------|---------|----------|
| 1 | `mapAppointment(ResultSet rs)` | Helper: chuyển ResultSet → Appointment object | Tất cả hàm query |
| 2 | `getTodayAppointments(Date today)` | Lấy tất cả lịch hẹn ngày hôm nay | CheckInController.doGet() |
| 3 | `searchTodayAppointments(Date today, String keyword)` | Tìm kiếm theo tên/SĐT khách | CheckInController.doGet() |
| 4 | `getTodayAppointmentsByStatus(Date today, String status)` | Lọc theo trạng thái | CheckInController.doGet() |
| 5 | `getAppointmentByID(int id)` | Lấy 1 lịch hẹn theo ID | CheckInController.doPost() |
| 6 | `updateStatus(int id, String newStatus)` | Cập nhật trạng thái | CheckInController.doPost() |
| 7 | `createWalkInAppointment(...)` | Tạo lịch hẹn walk-in (Transaction) | WalkInBookingController.doPost() |
| 8 | `isTimeSlotAvailable(int doctorId, Date date, Time time)` | Kiểm tra slot trống | WalkInBookingController.doPost() |
| 9 | `isDoctorWorkingToday(int doctorId, Date today)` | Kiểm tra BS có lịch | WalkInBookingController.doPost() |

## 7.2. Chi tiết từng hàm

### Hàm `mapAppointment(ResultSet rs)` — Helper nội bộ
```
Mục đích: Chuyển 1 dòng ResultSet (JOIN nhiều bảng) thành Appointment object
Code logic:
  Appointment apt = new Appointment();
  apt.setAppointmentID(rs.getInt("AppointmentID"));
  apt.setCustomerID(rs.getInt("CustomerID"));
  apt.setDoctorID(rs.getInt("DoctorID"));
  apt.setAppointmentDate(rs.getDate("AppointmentDate"));
  apt.setAppointmentTime(rs.getTime("AppointmentTime"));
  apt.setStatus(rs.getString("Status"));
  apt.setNotes(rs.getString("Notes"));
  apt.setCustomerName(rs.getString("CustomerName"));     // FROM JOIN
  apt.setCustomerPhone(rs.getString("CustomerPhone"));   // FROM JOIN
  apt.setDoctorName(rs.getString("DoctorName"));         // FROM JOIN
  return apt;
Liên kết: Appointment.java (constructor hoặc setter)
```

### Hàm `getTodayAppointments(Date today)` → List<Appointment>
```
SQL:
  SELECT a.AppointmentID, a.CustomerID, a.DoctorID, a.AppointmentDate, 
         a.AppointmentTime, a.Status, a.Notes,
         c.FullName AS CustomerName, c.Phone AS CustomerPhone,
         d.FullName AS DoctorName
  FROM Appointments a
  INNER JOIN Users c ON a.CustomerID = c.UserID
  LEFT JOIN Users d ON a.DoctorID = d.UserID
  WHERE a.AppointmentDate = ?
  ORDER BY a.AppointmentTime ASC

Tham số: ps.setDate(1, today)
Dùng bởi: CheckInController.doGet() (không có search keyword)
Trả về: List<Appointment> sắp xếp theo giờ hẹn tăng dần
```

### Hàm `searchTodayAppointments(Date today, String keyword)` → List<Appointment>
```
SQL:
  SELECT a.*, c.FullName AS CustomerName, c.Phone AS CustomerPhone,
         d.FullName AS DoctorName
  FROM Appointments a
  INNER JOIN Users c ON a.CustomerID = c.UserID
  LEFT JOIN Users d ON a.DoctorID = d.UserID
  WHERE a.AppointmentDate = ?
    AND (c.FullName LIKE ? OR c.Phone LIKE ?)
  ORDER BY a.AppointmentTime ASC

Tham số: 
  ps.setDate(1, today)
  ps.setString(2, "%" + keyword + "%")
  ps.setString(3, "%" + keyword + "%")
Lưu ý: PHẢI dùng PreparedStatement, KHÔNG ĐƯỢC nối chuỗi (chống SQL Injection)
```

### Hàm `getAppointmentByID(int id)` → Appointment | null
```
SQL: 
  SELECT a.*, c.FullName AS CustomerName, c.Phone AS CustomerPhone,
         d.FullName AS DoctorName
  FROM Appointments a
  INNER JOIN Users c ON a.CustomerID = c.UserID
  LEFT JOIN Users d ON a.DoctorID = d.UserID
  WHERE a.AppointmentID = ?

Dùng bởi: CheckInController.doPost() (kiểm tra tồn tại trước khi update)
```

### Hàm `updateStatus(int appointmentId, String newStatus)` → boolean
```
SQL: UPDATE Appointments SET Status = ? WHERE AppointmentID = ?
Tham số:
  ps.setString(1, newStatus)    // "Attended"
  ps.setInt(2, appointmentId)
Return: executeUpdate() > 0
```

### Hàm `createWalkInAppointment(int customerId, Integer doctorId, Date date, Time time, String notes, int[] serviceIds)` → boolean
```
Logic: Dùng TRANSACTION để đảm bảo tính toàn vẹn

  connection.setAutoCommit(false);   ← BẮT ĐẦU TRANSACTION
  try {
    // SQL 1: INSERT Appointment
    PreparedStatement ps1 = connection.prepareStatement(
      "INSERT INTO Appointments (CustomerID, DoctorID, AppointmentDate, AppointmentTime, Status, Notes) " +
      "VALUES (?, ?, ?, ?, 'Attended', ?)", 
      Statement.RETURN_GENERATED_KEYS);    ← Lấy ID vừa tạo
    ps1.setInt(1, customerId);
    if (doctorId != null) ps1.setInt(2, doctorId); else ps1.setNull(2, Types.INTEGER);
    ps1.setDate(3, date);
    ps1.setTime(4, time);
    ps1.setString(5, notes);
    ps1.executeUpdate();
    
    ResultSet generatedKeys = ps1.getGeneratedKeys();
    generatedKeys.next();
    int newAppointmentId = generatedKeys.getInt(1);
    
    // SQL 2: INSERT AppointmentServices (nhiều dòng)
    PreparedStatement ps2 = connection.prepareStatement(
      "INSERT INTO AppointmentServices (AppointmentID, ServiceID) VALUES (?, ?)");
    for (int serviceId : serviceIds) {
      ps2.setInt(1, newAppointmentId);
      ps2.setInt(2, serviceId);
      ps2.addBatch();
    }
    ps2.executeBatch();
    
    connection.commit();                  ← COMMIT TRANSACTION
    return true;
  } catch (SQLException e) {
    connection.rollback();                ← ROLLBACK NẾU LỖI
    return false;
  } finally {
    connection.setAutoCommit(true);
  }

Dùng bởi: WalkInBookingController.doPost()
Lưu ý: Status được hardcode = 'Attended' vì khách walk-in đã ở phòng khám
```

### Hàm `isTimeSlotAvailable(int doctorId, Date date, Time time)` → boolean
```
SQL:
  SELECT COUNT(*) FROM Appointments
  WHERE DoctorID = ? AND AppointmentDate = ? AND AppointmentTime = ?
    AND Status != 'Cancelled'

Tham số:
  ps.setInt(1, doctorId)
  ps.setDate(2, date)
  ps.setTime(3, time)
Return: count == 0 → true (còn trống), count > 0 → false (đã bận)
```

### Hàm `isDoctorWorkingToday(int doctorId, Date today)` → boolean
```
SQL:
  SELECT COUNT(*) FROM DoctorSchedules
  WHERE DoctorID = ? AND WorkDate = ? AND Status = 'Active'

Return: count > 0 → true (có lịch), count == 0 → false (không có lịch)
```

---

# 8. BẢNG TỔNG HỢP VALIDATE TOÀN BỘ MODULE

## 8.1. Validate cho Check-in (Hiển thị + Tìm kiếm) — 8 validate

| # | Validate | Client | Server |
|---|----------|:------:|:------:|
| 1 | Đã đăng nhập | — | ✅ Filter |
| 2 | Đúng quyền Staff (RoleID=3) | — | ✅ Filter |
| 3 | Trim keyword | — | ✅ |
| 4 | Chống XSS keyword | — | ✅ |
| 5 | Giới hạn keyword ≤ 100 ký tự | — | ✅ |
| 6 | filterStatus hợp lệ | — | ✅ |
| 7 | Hiển thị keyword an toàn (escapeXml) | ✅ JSP | — |
| 8 | Chống SQL Injection | — | ✅ PreparedStatement |

## 8.2. Validate cho Check-in (Cập nhật Status) — 11 validate

| # | Validate | Client | Server |
|---|----------|:------:|:------:|
| 1 | Confirm trước check-in | ✅ JS | — |
| 2 | Action = "checkin" | — | ✅ |
| 3 | appointmentId không trống | — | ✅ |
| 4 | appointmentId là số | — | ✅ |
| 5 | appointmentId > 0 | — | ✅ |
| 6 | Lịch hẹn tồn tại trong DB | — | ✅ |
| 7 | Status = Pending/Confirmed | — | ✅ |
| 8 | Ngày hẹn = hôm nay | — | ✅ |
| 9 | Update DB thành công | — | ✅ |
| 10 | Chống resubmit (redirect) | — | ✅ |
| 11 | Chống CSRF (tuỳ chọn) | — | ✅ |

## 8.3. Validate cho Walk-in Booking — 26 validate

| # | Validate | Client | Server |
|---|----------|:------:|:------:|
| 1 | CustomerID hợp lệ | — | ✅ |
| 2-3 | Tên khách trống | ✅ JS | ✅ |
| 4 | Tên khách 2-100 ký tự | — | ✅ |
| 5 | Tên khách chống XSS | — | ✅ |
| 6-7 | SĐT trống | ✅ JS | ✅ |
| 8-9 | SĐT format VN | ✅ JS | ✅ |
| 10-11 | Email format | ✅ JS | ✅ |
| 12-13 | Ít nhất 1 dịch vụ | ✅ JS | ✅ |
| 14 | ServiceID là số | — | ✅ |
| 15 | Service tồn tại + active | — | ✅ |
| 16-17 | Giờ hẹn trống | ✅ JS | ✅ |
| 18 | Giờ hẹn format đúng | — | ✅ |
| 19 | Giờ trong khung 08:00-17:00 | — | ✅ |
| 20 | DoctorID hợp lệ | — | ✅ |
| 21 | BS có lịch làm việc | — | ✅ |
| 22 | Slot giờ chưa trùng | — | ✅ |
| 23 | Ghi chú ≤ 500 ký tự | — | ✅ |
| 24 | Ghi chú chống XSS | — | ✅ |
| 25 | Chống resubmit | — | ✅ |
| 26 | Giữ lại dữ liệu khi lỗi | — | ✅ |

### **TỔNG: 45 validate** (Client-side: ~12, Server-side: ~40, chồng lặp client+server)

---

# 9. BẢNG TỔNG HỢP LIÊN KẾT FILE ↔ FILE

| File nguồn | Liên kết đến | Loại liên kết | Mục đích |
|------------|-------------|---------------|----------|
| `check-in.jsp` | `CheckInController` | form action GET+POST | Tìm kiếm + Check-in |
| `check-in.jsp` | `WalkInBookingController` | link href | Nút "Đặt lịch tại quầy" |
| `check-in.jsp` | `LogoutController` | link href | Đăng xuất |
| `check-in.jsp` | `dashboard.jsp` | link href | Về Dashboard |
| `CheckInController` | `AppointmentDAO` | method call | Gọi getTodayAppointments, searchTodayAppointments, getAppointmentByID, updateStatus |
| `CheckInController` | `Appointment` | object | Nhận List<Appointment> từ DAO |
| `CheckInController` | `User` | session read | Lấy thông tin lễ tân đăng nhập |
| `CheckInController` | `check-in.jsp` | forward | Hiển thị danh sách/lỗi |
| `CheckInController` | `check-in.jsp` | redirect | Sau check-in thành công |
| `walk-in-booking.jsp` | `WalkInBookingController` | form action POST | Gửi dữ liệu đặt lịch |
| `walk-in-booking.jsp` | `CheckInController` | link href | Nút "Quay lại" |
| `WalkInBookingController` | `AppointmentDAO` | method call | Gọi createWalkInAppointment, isTimeSlotAvailable |
| `WalkInBookingController` | `UserDAO` | method call | Gọi getUsersByRole, getUserByID, register |
| `WalkInBookingController` | `ServiceDAO` | method call | Gọi getActiveServices |
| `WalkInBookingController` | `walk-in-booking.jsp` | forward | Hiển thị form/lỗi |
| `WalkInBookingController` | `check-in.jsp` | redirect | Sau đặt lịch thành công |
| `AppointmentDAO` | `DBContext` | extends | Kế thừa connection |
| `AppointmentDAO` | `Appointment` | object create | Tạo từ ResultSet |
| `AppointmentDAO` | SQL Server | JDBC | Bảng Appointments, AppointmentServices, DoctorSchedules |
| `dashboard.jsp` | `CheckInController` | link href | Menu "Check-in lịch hẹn" |
| `dashboard.jsp` | `WalkInBookingController` | link href | Menu "Đặt lịch tại quầy" |
| `web.xml` | `CheckInController` | servlet mapping | `/receptionist/check-in` |
| `web.xml` | `WalkInBookingController` | servlet mapping | `/receptionist/walk-in-booking` |
| `AuthorizationFilter` | `Role.STAFF` | constant | Phân quyền `/receptionist/*` cho RoleID=3 |

---

# 10. TỔNG KẾT SỐ LIỆU

| Thống kê | Số lượng |
|----------|----------|
| Tổng số chức năng chính | 3 (Check-in, Update Status, Walk-in Booking) |
| File Java cần tạo mới | 1 (WalkInBookingController) |
| File Java cần sửa | 3 (CheckInController, AppointmentDAO, Appointment) |
| File JSP cần tạo mới | 2 (check-in.jsp, walk-in-booking.jsp) |
| File JSP cần sửa | 1 (dashboard.jsp — thêm link menu) |
| File config cần sửa | 1 (web.xml — thêm servlet mapping) |
| Tổng hàm DAO cần code | 9 hàm (trong AppointmentDAO) |
| Tổng Validate (Check-in hiển thị) | 8 |
| Tổng Validate (Check-in update) | 11 |
| Tổng Validate (Walk-in Booking) | 26 |
| **TỔNG VALIDATE** | **45 validate** |
| Tổng Test Case đã liệt kê | 25 test cases |
| Bảng DB liên quan | 5 (Appointments, AppointmentServices, Users, Services, DoctorSchedules) |

---

# 11. QUY TRÌNH CODE THEO THỨ TỰ (KHUYẾN NGHỊ)

### Bước 1: Bổ sung Model `Appointment.java` (nền tảng)
→ Thêm thuộc tính, constructor, getter/setter

### Bước 2: Code `AppointmentDAO.java` (tầng dữ liệu)
→ Code từng hàm: `mapAppointment` → `getTodayAppointments` → `searchTodayAppointments` → `getAppointmentByID` → `updateStatus` → `isTimeSlotAvailable` → `isDoctorWorkingToday` → `createWalkInAppointment`

### Bước 3: Code `CheckInController.java` (chức năng 1 + 2)
→ extends HttpServlet, doGet (hiển thị + tìm kiếm), doPost (check-in)

### Bước 4: Code `check-in.jsp` (giao diện check-in)
→ Bảng danh sách, form tìm kiếm, nút check-in, thống kê

### Bước 5: Code `WalkInBookingController.java` (chức năng 3)
→ doGet (load form), doPost (tạo lịch hẹn)

### Bước 6: Code `walk-in-booking.jsp` (giao diện walk-in)
→ Form đầy đủ, tìm khách, chọn BS, chọn DV, chọn giờ

### Bước 7: Cập nhật `web.xml` + `dashboard.jsp`
→ Thêm servlet mapping + link menu

### Bước 8: Test toàn bộ
→ Chạy từng test case đã liệt kê
