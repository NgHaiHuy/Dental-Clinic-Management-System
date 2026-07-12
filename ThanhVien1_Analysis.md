# 📋 PHÂN TÍCH CHI TIẾT TOÀN BỘ PHẦN THÀNH VIÊN 1 (NGHỊ)
# Authentication & Authorization — Dental Clinic Management System

> File này phân tích cặn kẽ từng chức năng, luồng hoạt động, cách validate,
> test case, và mối liên kết giữa các file trong phần của Thành viên 1.

---

# MỤC LỤC

1. [Sơ đồ tổng quan liên kết giữa các file](#1-sơ-đồ-tổng-quan-liên-kết-giữa-các-file)
2. [CHỨC NĂNG 1: Đăng nhập (Login)](#2-chức-năng-1-đăng-nhập-login)
3. [CHỨC NĂNG 2: Đăng ký (Register)](#3-chức-năng-2-đăng-ký-register)
4. [CHỨC NĂNG 3: Đăng xuất (Logout)](#4-chức-năng-3-đăng-xuất-logout)
5. [CHỨC NĂNG 4: AuthenticationFilter (Lọc xác thực)](#5-chức-năng-4-authenticationfilter)
6. [CHỨC NĂNG 5: AuthorizationFilter (Lọc phân quyền)](#6-chức-năng-5-authorizationfilter)
7. [CHỨC NĂNG 6: UserDAO (Tầng truy cập dữ liệu)](#7-chức-năng-6-userdao)
8. [CHỨC NĂNG 7: Models (User + Role)](#8-chức-năng-7-models-user--role)
9. [CHỨC NĂNG 8: Trang lỗi (403/404)](#9-chức-năng-8-trang-lỗi)
10. [CHỨC NĂNG 9: web.xml (Cấu hình triển khai)](#10-chức-năng-9-webxml)
11. [Bảng tổng hợp liên kết File ↔ File](#11-bảng-tổng-hợp-liên-kết-file--file)

---

# 1. SƠ ĐỒ TỔNG QUAN LIÊN KẾT GIỮA CÁC FILE

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TRÌNH DUYỆT (Browser)                       │
│   User gõ URL hoặc submit form                                      │
└───────────────┬─────────────────────────────────────────────────────┘
                │ HTTP Request (GET/POST)
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      web.xml (Cấu hình)                             │
│  Định nghĩa thứ tự Filter, Servlet mapping, Error pages            │
│  Filter chain: AuthenticationFilter → AuthorizationFilter → Servlet │
└───────────────┬─────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────┐    Chưa đăng nhập?
│   AuthenticationFilter.java  │──── Redirect ──→ /auth/login
│   (filter/*)                 │
│   Kiểm tra session có       │    URL public?
│   "loggedInUser" không       │──── Cho qua (bypass)
└──────────────┬───────────────┘
               │ Đã đăng nhập ✓
               ▼
┌──────────────────────────────┐    Sai quyền?
│   AuthorizationFilter.java   │──── Forward ──→ /error/403.jsp
│   (filter/*)                 │
│   Kiểm tra RoleID có khớp   │
│   với URL pattern không      │
└──────────────┬───────────────┘
               │ Đúng quyền ✓
               ▼
┌──────────────────────────────────────────────────────────────┐
│                    SERVLET (Controller)                       │
│                                                              │
│  ┌──────────────────┐  ┌───────────────────┐  ┌───────────┐ │
│  │ LoginController  │  │ RegisterController│  │ Logout    │ │
│  │ /auth/login      │  │ /auth/register    │  │ /auth/    │ │
│  │                  │  │                   │  │ logout    │ │
│  └────────┬─────────┘  └────────┬──────────┘  └─────┬─────┘ │
└───────────┼──────────────────────┼───────────────────┼───────┘
            │                      │                    │
            ▼                      ▼                    │
┌──────────────────────────────────────────────┐        │
│              UserDAO.java (dal/)              │        │
│  login()  register()  isUsernameExists()     │        │
│  isEmailExists()  getUserByID()  ...         │        │
└──────────────────┬───────────────────────────┘        │
                   │                                     │
                   ▼                                     │
┌──────────────────────────────────────────────┐        │
│          DBContext.java (context/)            │        │
│  Kết nối JDBC đến SQL Server                 │        │
│  Đọc ConnectDB.properties                   │        │
└──────────────────┬───────────────────────────┘        │
                   │                                     │
                   ▼                                     │
┌──────────────────────────────────────────────┐        │
│         SQL Server (DentalClinicDB)           │        │
│  Bảng: Users, Roles                          │        │
└──────────────────────────────────────────────┘        │
                                                         │
            ┌────────────────────────────────────────────┘
            ▼
┌──────────────────────────────────────────────────────────────┐
│                      JSP (View)                              │
│                                                              │
│  ┌─────────────┐  ┌──────────────┐  ┌──────┐  ┌──────────┐ │
│  │ login.jsp   │  │ register.jsp │  │403.jsp│  │ 404.jsp  │ │
│  └─────────────┘  └──────────────┘  └──────┘  └──────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Sơ đồ liên kết File → File (chi tiết):

```
User.java ◄──────── UserDAO.java (tạo đối tượng User từ ResultSet)
Role.java ◄──────── LoginController.java (gọi Role.getDashboardUrl())
Role.java ◄──────── AuthorizationFilter.java (dùng Role.ADMIN, Role.DOCTOR...)
Role.java ◄──────── 403.jsp (gọi Role.getRoleNameVi())
DBContext.java ◄─── UserDAO.java (extends DBContext, dùng connection)
UserDAO.java ◄───── LoginController.java (gọi userDAO.login())
UserDAO.java ◄───── RegisterController.java (gọi register, isUsernameExists...)
login.jsp ◄──────── LoginController.java (forward request đến)
register.jsp ◄───── RegisterController.java (forward request đến)
403.jsp ◄────────── AuthorizationFilter.java (forward khi không đủ quyền)
web.xml ────────►── Tất cả Filter + Servlet (định nghĩa mapping)
```

---

# 2. CHỨC NĂNG 1: ĐĂNG NHẬP (LOGIN)

## 2.1. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `login.jsp` | `web/auth/login.jsp` | Giao diện form đăng nhập (View) |
| `LoginController.java` | `src/java/controller/auth/LoginController.java` | Xử lý logic đăng nhập (Controller) |
| `UserDAO.java` | `src/java/dal/UserDAO.java` | Truy vấn DB kiểm tra tài khoản (Model/DAO) |
| `User.java` | `src/java/model/User.java` | Đối tượng lưu thông tin user (Model) |
| `Role.java` | `src/java/model/Role.java` | Hằng số Role + hàm lấy dashboard URL (Model) |
| `web.xml` | `web/WEB-INF/web.xml` | Mapping URL `/auth/login` → `LoginController` |

## 2.2. Luồng hoạt động chi tiết (Flow)

### Luồng GET — Hiển thị trang đăng nhập:

```
Bước 1: User mở trình duyệt → gõ URL: http://localhost:8080/DentalClinic/auth/login
        │
Bước 2: │ Request đến web.xml → tìm servlet-mapping cho /auth/login
        │ → Tìm thấy: LoginController.java
        │
        │ (Trước khi đến Servlet, request đi qua Filter chain)
        │
Bước 3: │ AuthenticationFilter nhận request
        │ → Kiểm tra: URL "/auth/login" có trong PUBLIC_URL_PREFIXES không?
        │ → CÓ → chain.doFilter() → cho đi tiếp
        │
Bước 4: │ AuthorizationFilter nhận request
        │ → Kiểm tra: URL "/auth/login" → isPublicOrStaticUrl() trả về TRUE
        │ → chain.doFilter() → cho đi tiếp
        │
Bước 5: │ LoginController.doGet() được gọi
        │ → Kiểm tra: session có "loggedInUser" chưa?
        │   ├─ NẾU ĐÃ ĐĂNG NHẬP (session có user):
        │   │   → Lấy RoleID từ User object
        │   │   → Gọi Role.getDashboardUrl(roleID) để lấy URL dashboard
        │   │   → response.sendRedirect(contextPath + dashboardUrl)
        │   │   → KẾT THÚC (user thấy trang dashboard tương ứng)
        │   │
        │   └─ NẾU CHƯA ĐĂNG NHẬP (session null hoặc không có user):
        │       → request.getRequestDispatcher("/auth/login.jsp").forward()
        │       → Hiển thị trang login.jsp cho user
        │
Bước 6: │ login.jsp render HTML:
        │ → Hiển thị form có 2 trường: username, password
        │ → Hiển thị nút "Đăng nhập"
        │ → Hiển thị link "Quên mật khẩu?" (hiện trỏ href="#")
        │ → Hiển thị link "Đăng ký ngay" (trỏ /auth/register)
        │ → Hiển thị bảng tài khoản demo
        │ → Nếu có param "logout=success" → hiển thị alert xanh "Đã đăng xuất"
        │ → Nếu có param "registered=success" → hiển thị alert xanh "Đăng ký thành công"
        │ → Nếu có attribute "errorMessage" → hiển thị alert đỏ với nội dung lỗi
```

### Luồng POST — Xử lý đăng nhập:

```
Bước 1: User điền username + password → nhấn nút "Đăng nhập"
        │
Bước 2: │ CLIENT-SIDE VALIDATION (JavaScript trong login.jsp):
        │ → Hàm addEventListener('submit') kiểm tra:
        │   ├─ username.trim() rỗng? → alert("Vui lòng nhập đầy đủ...") → chặn submit
        │   └─ password.trim() rỗng? → alert("Vui lòng nhập đầy đủ...") → chặn submit
        │ → Nếu cả 2 có giá trị → cho submit form POST đến /auth/login
        │
Bước 3: │ Request POST đi qua Filter chain (giống GET - bypass vì URL public)
        │
Bước 4: │ LoginController.doPost() được gọi
        │ → request.setCharacterEncoding("UTF-8") để hỗ trợ tiếng Việt
        │ → Lấy tham số: username = request.getParameter("username")
        │                 password = request.getParameter("password")
        │
Bước 5: │ SERVER-SIDE VALIDATION #1: Kiểm tra trống
        │ → username == null || username.trim().isEmpty()
        │   HOẶC password == null || password.trim().isEmpty()
        │ → NẾU TRỐNG:
        │   ├─ setAttribute("errorMessage", "Vui lòng nhập đầy đủ...")
        │   ├─ setAttribute("username", username)  ← giữ lại username đã nhập
        │   ├─ forward → /auth/login.jsp           ← hiển thị lại form + lỗi
        │   └─ RETURN (dừng xử lý)
        │
Bước 6: │ SERVER-SIDE VALIDATION #2: Xác thực với Database
        │ → Gọi: User user = userDAO.login(username.trim(), password.trim())
        │
        │   BÊN TRONG userDAO.login():
        │   ├─ Tạo PreparedStatement với SQL:
        │   │   "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID
        │   │    FROM Users WHERE Username = ? AND Password = ?"
        │   ├─ Set tham số: ps.setString(1, username), ps.setString(2, password)
        │   ├─ Thực thi query → ResultSet
        │   ├─ NẾU CÓ KẾT QUẢ (rs.next() = true):
        │   │   → Gọi mapUser(rs) để tạo object User từ ResultSet
        │   │   → RETURN User object
        │   └─ NẾU KHÔNG CÓ KẾT QUẢ:
        │       → RETURN null
        │
Bước 7: │ KIỂM TRA KẾT QUẢ TỪ DAO:
        │ → NẾU user == null (sai username hoặc password):
        │   ├─ setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng.")
        │   ├─ setAttribute("username", username)  ← giữ lại username
        │   ├─ forward → /auth/login.jsp
        │   └─ RETURN
        │
Bước 8: │ ĐĂNG NHẬP THÀNH CÔNG:
        │ → Tạo session mới: request.getSession()
        │ → Lưu vào session:
        │   ├─ session.setAttribute("loggedInUser", user)    ← object User đầy đủ
        │   ├─ session.setAttribute("userRole", user.getRoleID())  ← RoleID (int)
        │   └─ session.setAttribute("userFullName", user.getFullName()) ← tên hiển thị
        │
Bước 9: │ REDIRECT THEO ROLE:
        │ → Kiểm tra session có "redirectAfterLogin" không?
        │   (URL mà user muốn truy cập trước khi bị đá về login)
        │   ├─ NẾU CÓ (và không phải URL /auth/*):
        │   │   → removeAttribute("redirectAfterLogin")
        │   │   → sendRedirect(contextPath + redirectUrl)
        │   │   → (User được đưa đến trang họ muốn ban đầu)
        │   │
        │   └─ NẾU KHÔNG CÓ:
        │       → Gọi Role.getDashboardUrl(user.getRoleID())
        │       │   ├─ RoleID=1 (Admin)    → return "/admin/dashboard"
        │       │   ├─ RoleID=2 (Doctor)   → return "/doctor/dashboard"
        │       │   ├─ RoleID=3 (Staff)    → return "/receptionist/dashboard"
        │       │   └─ RoleID=4 (Customer) → return "/customer/dashboard"
        │       → sendRedirect(contextPath + dashboardUrl)
```

## 2.3. Bảng Validate đầy đủ cho Login

| # | Validate | Phía | Vị trí code | Điều kiện kiểm tra | Kết quả nếu lỗi |
|---|----------|------|-------------|---------------------|-----------------|
| 1 | Username không trống | Client | `login.jsp` JS dòng 409 | `username.trim() === ''` | `alert()` + chặn submit |
| 2 | Password không trống | Client | `login.jsp` JS dòng 410 | `password.trim() === ''` | `alert()` + chặn submit |
| 3 | Username không trống | Server | `LoginController` dòng 59 | `username == null \|\| username.trim().isEmpty()` | Forward login.jsp + errorMessage |
| 4 | Password không trống | Server | `LoginController` dòng 60 | `password == null \|\| password.trim().isEmpty()` | Forward login.jsp + errorMessage |
| 5 | Username + Password đúng trong DB | Server | `UserDAO.login()` dòng 45-60 | SQL query trả về null | Forward login.jsp + "Tên đăng nhập hoặc mật khẩu không đúng" |
| 6 | Đã đăng nhập → không cho vào trang login | Server | `LoginController.doGet()` dòng 35-40 | `session.getAttribute("loggedInUser") != null` | Redirect về dashboard |

## 2.4. Test Cases cho Login

### TC-L01: Đăng nhập thành công với tài khoản Admin
```
Tiền điều kiện: Chưa đăng nhập, DB có tài khoản admin/123
Bước thực hiện:
  1. Mở trình duyệt → vào /auth/login
  2. Nhập Username: "admin"
  3. Nhập Password: "123"
  4. Nhấn nút "Đăng nhập"
Kết quả mong đợi:
  - Redirect đến /admin/dashboard
  - Session có attribute "loggedInUser" chứa User(username="admin", roleID=1)
  - Session có attribute "userRole" = 1
  - Session có attribute "userFullName" = "Quản trị viên"
Luồng code:
  login.jsp → POST → LoginController.doPost() → userDAO.login("admin","123")
  → User object trả về (≠ null) → session.setAttribute() → Role.getDashboardUrl(1)
  → return "/admin/dashboard" → sendRedirect
```

### TC-L02: Đăng nhập thành công với tài khoản Doctor
```
Tiền điều kiện: Chưa đăng nhập, DB có tài khoản doctor01/123
Bước thực hiện:
  1. Vào /auth/login
  2. Nhập Username: "doctor01", Password: "123"
  3. Nhấn "Đăng nhập"
Kết quả mong đợi:
  - Redirect đến /doctor/dashboard
  - Session: loggedInUser.roleID = 2
Luồng code: Giống TC-L01, nhưng Role.getDashboardUrl(2) → "/doctor/dashboard"
```

### TC-L03: Đăng nhập thành công với tài khoản Staff (Lễ tân)
```
Tiền điều kiện: DB có tài khoản staff01/123
Bước: Nhập staff01 / 123 → Đăng nhập
Kết quả: Redirect đến /receptionist/dashboard
Luồng: Role.getDashboardUrl(3) → "/receptionist/dashboard"
```

### TC-L04: Đăng nhập thành công với tài khoản Customer
```
Tiền điều kiện: DB có tài khoản customer01/123
Bước: Nhập customer01 / 123 → Đăng nhập
Kết quả: Redirect đến /customer/dashboard
Luồng: Role.getDashboardUrl(4) → "/customer/dashboard"
```

### TC-L05: Đăng nhập với username sai
```
Bước: Nhập "khongtontai" / "123" → Đăng nhập
Kết quả mong đợi:
  - Ở lại trang login.jsp
  - Hiện alert đỏ: "Tên đăng nhập hoặc mật khẩu không đúng."
  - Ô username vẫn giữ giá trị "khongtontai"
  - Ô password bị xóa trắng
Luồng: userDAO.login("khongtontai","123") → SQL không tìm thấy → return null
  → LoginController set errorMessage → forward login.jsp
```

### TC-L06: Đăng nhập với password sai
```
Bước: Nhập "admin" / "saimatkhau" → Đăng nhập
Kết quả: Giống TC-L05, hiện lỗi "Tên đăng nhập hoặc mật khẩu không đúng."
Luồng: userDAO.login("admin","saimatkhau") → SQL WHERE Password='saimatkhau' không khớp → null
```

### TC-L07: Đăng nhập với username trống
```
Bước: Để trống username, nhập password → Đăng nhập
Kết quả mong đợi:
  - Client-side: alert("Vui lòng nhập đầy đủ...") → không gửi form
  - Nếu JS bị tắt → Server-side: hiện lỗi "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu."
Luồng client: JS addEventListener chặn → e.preventDefault()
Luồng server: LoginController dòng 59 → username.trim().isEmpty() = true → set errorMessage
```

### TC-L08: Đăng nhập với password trống
```
Bước: Nhập username, để trống password → Đăng nhập
Kết quả: Giống TC-L07
```

### TC-L09: Đăng nhập khi đã đăng nhập rồi
```
Tiền điều kiện: Đã đăng nhập với tài khoản admin (session có loggedInUser)
Bước: Gõ URL /auth/login trực tiếp
Kết quả mong đợi:
  - KHÔNG hiển thị form login
  - Tự động redirect về /admin/dashboard
Luồng: LoginController.doGet() → session có loggedInUser → lấy roleID
  → Role.getDashboardUrl() → sendRedirect
```

### TC-L10: Redirect after login (quay lại trang trước đó)
```
Tiền điều kiện: Chưa đăng nhập
Bước:
  1. Gõ URL /customer/dashboard (trang yêu cầu đăng nhập)
  2. AuthenticationFilter chặn → lưu "/customer/dashboard" vào session "redirectAfterLogin"
  3. Redirect về /auth/login
  4. Đăng nhập với customer01/123
Kết quả: Redirect đến /customer/dashboard (KHÔNG phải dashboard mặc định)
Luồng: LoginController.doPost() → session.getAttribute("redirectAfterLogin")
  → có giá trị "/customer/dashboard" → removeAttribute → sendRedirect
```

### TC-L11: Nút "Dùng" tài khoản demo
```
Bước: Nhấn nút "Dùng" bên cạnh tài khoản "admin"
Kết quả:
  - Ô username tự động điền "admin"
  - Ô password tự động điền "123"
Luồng: JS hàm fillDemo('admin','123') → set value cho 2 input
```

### TC-L12: Toggle hiện/ẩn mật khẩu
```
Bước: Nhấn icon mắt bên cạnh ô password
Kết quả:
  - Lần 1: input type đổi từ "password" → "text" (hiện mật khẩu)
  - Icon đổi từ fa-eye → fa-eye-slash
  - Lần 2: đổi ngược lại
Luồng: JS hàm togglePassword() → đổi input.type + thay icon class
```

## 2.5. Liên kết File ↔ File trong chức năng Login

```
login.jsp
  ├── [form action] ─────────→ LoginController (/auth/login POST)
  ├── [link "Đăng ký ngay"] ─→ RegisterController (/auth/register GET)
  ├── [link "Quên mật khẩu"]→ href="#" (CHƯA TRIỂN KHAI)
  ├── [param "logout"] ──────→ Được set bởi LogoutController (redirect kèm param)
  ├── [param "registered"] ──→ Được set bởi RegisterController (redirect kèm param)
  └── [attr "errorMessage"] ─→ Được set bởi LoginController (setAttribute)

LoginController.java
  ├── [import] ──────→ UserDAO.java (gọi userDAO.login())
  ├── [import] ──────→ User.java (nhận object User từ DAO)
  ├── [import] ──────→ Role.java (gọi Role.getDashboardUrl())
  ├── [forward] ─────→ login.jsp (khi cần hiển thị form hoặc lỗi)
  └── [redirect] ────→ dashboard URLs (sau đăng nhập thành công)

UserDAO.java
  ├── [extends] ─────→ DBContext.java (kế thừa, dùng biến connection)
  ├── [import] ──────→ User.java (tạo object User từ ResultSet)
  └── [SQL query] ───→ SQL Server: bảng Users
```

---

# 3. CHỨC NĂNG 2: ĐĂNG KÝ (REGISTER)

## 3.1. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `register.jsp` | `web/auth/register.jsp` | Giao diện form đăng ký |
| `RegisterController.java` | `src/java/controller/auth/RegisterController.java` | Xử lý logic đăng ký |
| `UserDAO.java` | `src/java/dal/UserDAO.java` | Kiểm tra trùng + INSERT vào DB |
| `User.java` | `src/java/model/User.java` | Đối tượng User |
| `web.xml` | `web/WEB-INF/web.xml` | Mapping `/auth/register` |

## 3.2. Luồng hoạt động chi tiết

### Luồng GET — Hiển thị form đăng ký:

```
Bước 1: User nhấn link "Đăng ký ngay" trên login.jsp
        → GET /auth/register
        │
Bước 2: │ Filter chain: bypass (URL public)
        │
Bước 3: │ RegisterController.doGet()
        │ → forward đến /auth/register.jsp
        │
Bước 4: │ register.jsp render:
        │ → Form với 6 trường:
        │   ├─ Username (bắt buộc, placeholder: "vd: nguyenvan")
        │   ├─ Họ và tên (bắt buộc)
        │   ├─ Mật khẩu (bắt buộc, có thanh đo độ mạnh)
        │   ├─ Xác nhận mật khẩu (bắt buộc)
        │   ├─ Số điện thoại (bắt buộc)
        │   └─ Email (không bắt buộc)
        │ → Checkbox "Đồng ý điều khoản"
        │ → Nút "Tạo tài khoản"
        │ → Link "Đã có tài khoản? Đăng nhập ngay"
```

### Luồng POST — Xử lý đăng ký:

```
Bước 1: User điền form → nhấn "Tạo tài khoản"
        │
Bước 2: │ CLIENT-SIDE VALIDATION (JavaScript register.jsp):
        │ ├─ Check trống: username, password, confirmPassword, fullName, phone
        │ │   → Nếu thiếu → alert("Vui lòng điền đầy đủ...") → chặn submit
        │ ├─ Check password ≠ confirmPassword
        │ │   → alert("Mật khẩu xác nhận không khớp!") → chặn submit
        │ └─ Check checkbox "agreeTerms" chưa tick
        │     → alert("Bạn phải đồng ý Điều khoản...") → chặn submit
        │
Bước 3: │ POST /auth/register → qua Filter chain (bypass) → RegisterController.doPost()
        │
Bước 4: │ Đọc 6 tham số từ request:
        │ username, password, confirmPassword, fullName, phone, email
        │
Bước 5: │ SERVER-SIDE VALIDATION (Hàm validateRegisterInput):
        │
        │ ┌─── Validate #1: Username trống?
        │ │    username == null || username.trim().isEmpty()
        │ │    → "Tên đăng nhập không được để trống."
        │ │
        │ ├─── Validate #2: Username dài 4-50 ký tự?
        │ │    username.trim().length() < 4 || > 50
        │ │    → "Tên đăng nhập phải từ 4 đến 50 ký tự."
        │ │
        │ ├─── Validate #3: Username chỉ chứa a-z, A-Z, 0-9, _?
        │ │    !username.trim().matches("[a-zA-Z0-9_]+")
        │ │    → "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới."
        │ │
        │ ├─── Validate #4: Password trống?
        │ │    password == null || password.trim().isEmpty()
        │ │    → "Mật khẩu không được để trống."
        │ │
        │ ├─── Validate #5: Password ≥ 3 ký tự?
        │ │    password.trim().length() < 3
        │ │    → "Mật khẩu phải có ít nhất 3 ký tự."
        │ │
        │ ├─── Validate #6: Password = ConfirmPassword?
        │ │    !password.equals(confirmPassword)
        │ │    → "Xác nhận mật khẩu không khớp."
        │ │
        │ ├─── Validate #7: FullName trống?
        │ │    fullName == null || fullName.trim().isEmpty()
        │ │    → "Họ và tên không được để trống."
        │ │
        │ ├─── Validate #8: Phone trống?
        │ │    phone == null || phone.trim().isEmpty()
        │ │    → "Số điện thoại không được để trống."
        │ │
        │ ├─── Validate #9: Phone đúng format VN?
        │ │    !phone.trim().matches("^(0|\\+84)[0-9]{9,10}$")
        │ │    → "Số điện thoại không hợp lệ (ví dụ: 0912345678)."
        │ │    Regex giải thích:
        │ │      ^(0|\\+84)  → bắt đầu bằng "0" hoặc "+84"
        │ │      [0-9]{9,10} → tiếp theo 9-10 chữ số
        │ │      $           → kết thúc
        │ │
        │ └─── Validate #10: Email đúng format? (chỉ check nếu có nhập)
        │      email != null && !email.trim().isEmpty()
        │      && !email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
        │      → "Địa chỉ email không hợp lệ."
        │
        │ NẾU CÓ LỖI VALIDATE:
        │   → setAttribute("errorMessage", error)
        │   → setAttribute("regUsername", username)  ← giữ lại dữ liệu
        │   → setAttribute("regFullName", fullName)
        │   → setAttribute("regPhone", phone)
        │   → setAttribute("regEmail", email)
        │   → forward → register.jsp
        │   → RETURN
        │
Bước 6: │ KIỂM TRA TRÙNG USERNAME TRONG DB:
        │ → userDAO.isUsernameExists(username.trim())
        │   ├─ SQL: "SELECT 1 FROM Users WHERE Username = ?"
        │   ├─ NẾU rs.next() = true → username đã tồn tại
        │   │   → errorMessage: "Tên đăng nhập "xxx" đã được sử dụng..."
        │   │   → forward register.jsp + giữ lại dữ liệu
        │   │   → RETURN
        │   └─ NẾU rs.next() = false → username chưa tồn tại → tiếp tục
        │
Bước 7: │ KIỂM TRA TRÙNG EMAIL TRONG DB (chỉ khi email không rỗng):
        │ → email != null && !email.trim().isEmpty() && userDAO.isEmailExists(email.trim())
        │   ├─ SQL: "SELECT 1 FROM Users WHERE Email = ?"
        │   ├─ NẾU trùng → errorMessage: "Email "xxx" đã được đăng ký..."
        │   │   → forward register.jsp + giữ lại dữ liệu
        │   │   → RETURN
        │   └─ NẾU không trùng → tiếp tục
        │
Bước 8: │ TẠO TÀI KHOẢN MỚI:
        │ → userDAO.register(username.trim(), password.trim(), fullName.trim(),
        │                     phone.trim(), email != null ? email.trim() : "")
        │   ├─ SQL: "INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
        │   │        VALUES (?, ?, ?, ?, ?, 4)"
        │   │   → RoleID = 4 (Customer) được hardcode trong SQL
        │   ├─ executeUpdate() > 0 → return true (thành công)
        │   └─ executeUpdate() ≤ 0 hoặc SQLException → return false (thất bại)
        │
Bước 9: │ XỬ LÝ KẾT QUẢ:
        │ ├─ NẾU success = true:
        │ │   → sendRedirect(contextPath + "/auth/login?registered=success")
        │ │   → User thấy trang login với thông báo xanh "Đăng ký thành công!"
        │ │
        │ └─ NẾU success = false:
        │     → setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống...")
        │     → forward register.jsp
```

## 3.3. Bảng Validate đầy đủ cho Register

| # | Validate | Phía | Code | Regex/Điều kiện | Lỗi trả về |
|---|----------|------|------|-----------------|-------------|
| 1 | Username trống | Client | JS dòng 335 | `!username` | alert |
| 2 | Password trống | Client | JS dòng 335 | `!pwd` | alert |
| 3 | ConfirmPassword trống | Client | JS dòng 335 | `!cfm` | alert |
| 4 | FullName trống | Client | JS dòng 335 | `!fullName` | alert |
| 5 | Phone trống | Client | JS dòng 335 | `!phone` | alert |
| 6 | Password ≠ Confirm | Client | JS dòng 340 | `pwd !== cfm` | alert |
| 7 | Chưa tick điều khoản | Client | JS dòng 345 | `!terms` | alert |
| 8 | Username trống | Server | RC dòng 110 | `isEmpty()` | "Tên đăng nhập không được để trống." |
| 9 | Username 4-50 ký tự | Server | RC dòng 113 | `length < 4 \|\| > 50` | "...phải từ 4 đến 50 ký tự." |
| 10 | Username chỉ a-z,0-9,_ | Server | RC dòng 116 | `[a-zA-Z0-9_]+` | "...chỉ được chứa chữ cái, số..." |
| 11 | Password trống | Server | RC dòng 120 | `isEmpty()` | "Mật khẩu không được để trống." |
| 12 | Password ≥ 3 ký tự | Server | RC dòng 123 | `length < 3` | "...ít nhất 3 ký tự." |
| 13 | Confirm khớp | Server | RC dòng 127 | `!equals()` | "Xác nhận mật khẩu không khớp." |
| 14 | FullName trống | Server | RC dòng 131 | `isEmpty()` | "Họ và tên không được để trống." |
| 15 | Phone trống | Server | RC dòng 135 | `isEmpty()` | "Số điện thoại không được để trống." |
| 16 | Phone format VN | Server | RC dòng 138 | `^(0\|\\+84)[0-9]{9,10}$` | "Số điện thoại không hợp lệ..." |
| 17 | Email format | Server | RC dòng 142 | `^[A-Za-z0-9+_.-]+@...` | "Địa chỉ email không hợp lệ." |
| 18 | Username trùng DB | Server | RC dòng 63 | `isUsernameExists()` | "...đã được sử dụng." |
| 19 | Email trùng DB | Server | RC dòng 74 | `isEmailExists()` | "...đã được đăng ký." |
| 20 | Password strength UI | Client | JS dòng 301 | Score 0-5 | Thanh màu + label |

## 3.4. Test Cases cho Register

### TC-R01: Đăng ký thành công
```
Bước:
  1. Vào /auth/register
  2. Nhập: username="testuser1", fullName="Nguyễn Test", password="123456",
     confirmPassword="123456", phone="0912345000", email="test@gmail.com"
  3. Tick "Đồng ý điều khoản"
  4. Nhấn "Tạo tài khoản"
Kết quả: Redirect đến /auth/login?registered=success
  → Trang login hiện alert xanh "Đăng ký thành công! Hãy đăng nhập bằng tài khoản vừa tạo."
Kiểm tra DB: SELECT * FROM Users WHERE Username='testuser1'
  → Có bản ghi mới với RoleID=4 (Customer)
```

### TC-R02: Username trùng
```
Bước: Nhập username="admin" (đã tồn tại) + các trường khác hợp lệ → Submit
Kết quả: Ở lại register.jsp, hiện lỗi: "Tên đăng nhập "admin" đã được sử dụng..."
  → Tất cả dữ liệu đã nhập (fullName, phone, email) vẫn được giữ lại trên form
Luồng: validateRegisterInput() → null (pass) → isUsernameExists("admin") → true → error
```

### TC-R03: Email trùng
```
Bước: Nhập email="admin@dental.com" (đã tồn tại) + các trường khác hợp lệ → Submit
Kết quả: Lỗi "Email "admin@dental.com" đã được đăng ký..."
Luồng: validateRegisterInput() → null → isUsernameExists() → false
  → isEmailExists("admin@dental.com") → true → error
```

### TC-R04: Password không khớp Confirm
```
Bước: password="abc123", confirmPassword="xyz789" → Submit
Kết quả: Client: alert "Mật khẩu xác nhận không khớp!"
  Nếu JS tắt → Server: "Xác nhận mật khẩu không khớp."
```

### TC-R05: Username quá ngắn (< 4 ký tự)
```
Bước: username="ab" → Submit
Kết quả: "Tên đăng nhập phải từ 4 đến 50 ký tự."
```

### TC-R06: Username chứa ký tự đặc biệt
```
Bước: username="user@name!" → Submit
Kết quả: "Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới."
Luồng: regex "[a-zA-Z0-9_]+" không match "user@name!" → lỗi
```

### TC-R07: Số điện thoại sai format
```
Bước: phone="12345" → Submit
Kết quả: "Số điện thoại không hợp lệ (ví dụ: 0912345678)."
Luồng: regex "^(0|\\+84)[0-9]{9,10}$" → "12345" không bắt đầu bằng 0 hoặc +84 → lỗi
```

### TC-R08: Email sai format
```
Bước: email="abc.def" → Submit
Kết quả: "Địa chỉ email không hợp lệ."
```

### TC-R09: Đăng ký không điền email (hợp lệ vì email tùy chọn)
```
Bước: Điền tất cả trường bắt buộc, để trống email → Submit
Kết quả: Đăng ký thành công
Luồng: validate email → email == null || isEmpty() → SKIP validate → tiếp tục
  → isEmailExists() cũng bị SKIP vì email rỗng → tạo tài khoản với email=""
```

### TC-R10: Chưa tick điều khoản
```
Bước: Điền đầy đủ nhưng không tick checkbox → Submit
Kết quả: Client alert "Bạn phải đồng ý Điều khoản..."
Lưu ý: Server-side KHÔNG kiểm tra checkbox → nếu tắt JS, form vẫn submit được
```

### TC-R11: Thanh đo độ mạnh mật khẩu
```
Bước: Gõ từng ký tự vào ô mật khẩu
Kết quả:
  - "a"      → Thanh 0% (chưa đủ 6 ký tự)
  - "abcdef" → Thanh 25% đỏ "Rất yếu" (≥6 ký tự, score=1)
  - "abcdefAB" → 50% vàng "Trung bình" (có hoa+thường, score=2+1)
  - "Abcdef1"  → 75% xanh nhạt "Khá mạnh"
  - "Abcdef1!" → 100% xanh đậm "Rất mạnh"
Luồng: JS checkPasswordStrength() → tính score dựa trên:
  length≥6 (+1), length≥10 (+1), có hoa+thường (+1), có số (+1), có ký tự đặc biệt (+1)
```

## 3.5. Liên kết File ↔ File trong chức năng Register

```
register.jsp
  ├── [form action] ─────────→ RegisterController (/auth/register POST)
  ├── [link "Đăng nhập ngay"]→ LoginController (/auth/login GET)
  ├── [attr "errorMessage"] ─→ Được set bởi RegisterController
  ├── [attr "regUsername"] ──→ Được set bởi RegisterController (giữ lại dữ liệu)
  ├── [attr "regFullName"] ──→ Được set bởi RegisterController
  ├── [attr "regPhone"] ────→ Được set bởi RegisterController
  └── [attr "regEmail"] ────→ Được set bởi RegisterController

RegisterController.java
  ├── [import] ──────→ UserDAO.java (gọi register, isUsernameExists, isEmailExists)
  ├── [forward] ─────→ register.jsp (khi lỗi)
  └── [redirect] ────→ LoginController (sau đăng ký thành công: /auth/login?registered=success)
```

---

# 4. CHỨC NĂNG 3: ĐĂNG XUẤT (LOGOUT)

## 4.1. Các file liên quan

| File | Đường dẫn | Vai trò |
|------|-----------|---------|
| `LogoutController.java` | `src/java/controller/auth/LogoutController.java` | Xử lý đăng xuất |
| `login.jsp` | `web/auth/login.jsp` | Hiển thị thông báo sau đăng xuất |
| `web.xml` | `web/WEB-INF/web.xml` | Mapping `/auth/logout` |

## 4.2. Luồng hoạt động chi tiết

```
Bước 1: User nhấn nút/link "Đăng xuất" trên bất kỳ trang nào
        → GET hoặc POST /auth/logout
        │
Bước 2: │ Filter chain:
        │ → AuthenticationFilter: /auth/logout KHÔNG nằm trong PUBLIC_URL_PREFIXES
        │   → Kiểm tra session: user đã đăng nhập → CÓ → chain.doFilter() → tiếp tục
        │ → AuthorizationFilter: không phải URL /admin, /doctor... → cho qua
        │
Bước 3: │ LogoutController.doGet() hoặc doPost() → đều gọi logout()
        │
Bước 4: │ Hàm logout():
        │ ├─ Lấy session: request.getSession(false)
        │ │   (false = KHÔNG tạo session mới nếu chưa có)
        │ │
        │ ├─ Kiểm tra session != null:
        │ │   → session.invalidate()
        │ │     Xóa TOÀN BỘ attribute trong session:
        │ │     ├─ "loggedInUser" (object User)
        │ │     ├─ "userRole" (int RoleID)
        │ │     ├─ "userFullName" (String tên)
        │ │     └─ Mọi attribute khác
        │ │
        │ ├─ Xóa cookie JSESSIONID:
        │ │   → new Cookie("JSESSIONID", "")
        │ │   → cookie.setMaxAge(0)         ← hết hạn ngay lập tức
        │ │   → cookie.setPath(contextPath)  ← scope của cookie
        │ │   → response.addCookie(cookie)   ← gửi lệnh xóa cho browser
        │ │
        │ └─ Redirect:
        │     → response.sendRedirect(contextPath + "/auth/login?logout=success")
        │     → Browser nhận status 302 → request mới GET /auth/login?logout=success
        │     → LoginController.doGet() → forward login.jsp
        │     → login.jsp kiểm tra param "logout" == "success"
        │     → Hiển thị alert xanh "Bạn đã đăng xuất thành công."
```

## 4.3. Test Cases cho Logout

### TC-O01: Đăng xuất thành công
```
Tiền điều kiện: Đã đăng nhập với admin/123
Bước: Nhấn link /auth/logout
Kết quả:
  - Session bị hủy (session.invalidate())
  - Cookie JSESSIONID bị xóa
  - Redirect đến /auth/login với thông báo "Bạn đã đăng xuất thành công."
  - Thử truy cập /admin/dashboard → bị AuthenticationFilter chặn → redirect login
```

### TC-O02: Đăng xuất khi chưa đăng nhập
```
Bước: Gõ URL /auth/logout khi chưa đăng nhập
Kết quả:
  - AuthenticationFilter chặn (URL không public, session không có user)
  - Redirect về /auth/login
  Lưu ý: URL /auth/logout sẽ bị lưu vào "redirectAfterLogin" → có thể gây lỗi logic nhẹ
```

## 4.4. Liên kết File ↔ File

```
LogoutController.java
  ├── [redirect] ────→ LoginController (/auth/login?logout=success)
  └── [cookie] ──────→ Browser (xóa JSESSIONID)

login.jsp
  └── [param "logout"] → Kiểm tra từ URL query string → hiển thị alert
```

---

# 5. CHỨC NĂNG 4: AUTHENTICATIONFILTER

## 5.1. Các file liên quan

| File | Vai trò |
|------|---------|
| `AuthenticationFilter.java` | Filter chính |
| `web.xml` | Khai báo filter + mapping `/*` |
| `login.jsp` | Trang redirect khi chưa đăng nhập |
| Tất cả Servlet | Đều bị filter chặn trước khi chạy |

## 5.2. Luồng hoạt động chi tiết

```
MỌI REQUEST đều đi qua AuthenticationFilter (urlPattern = /*)

Bước 1: │ Nhận request
        │ → Cast sang HttpServletRequest, HttpServletResponse
        │ → Tính relativePath = requestURI - contextPath
        │   Ví dụ: URI = "/DentalClinic/admin/dashboard"
        │          contextPath = "/DentalClinic"
        │          relativePath = "/admin/dashboard"
        │
Bước 2: │ KIỂM TRA URL PUBLIC:
        │ → Gọi isPublicUrl(relativePath)
        │   ├─ So sánh với PUBLIC_URL_PREFIXES:
        │   │   "/auth/login"    → match nếu URL bắt đầu bằng "/auth/login"
        │   │   "/auth/register" → match nếu URL bắt đầu bằng "/auth/register"
        │   │   "/assets/"       → match tất cả file trong /assets/
        │   │   "/error/"        → match tất cả trang lỗi
        │   │   "/index.jsp"     → match trang chủ
        │   │
        │   ├─ Kiểm tra file tĩnh bằng regex:
        │   │   ".+\\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|ttf|svg|map)$"
        │   │   → Match: /assets/style.css, /images/logo.png...
        │   │
        │   ├─ NẾU LÀ PUBLIC → chain.doFilter() → THOÁT (cho đi tiếp)
        │   └─ NẾU KHÔNG PUBLIC → tiếp bước 3
        │
Bước 3: │ KIỂM TRA SESSION:
        │ → session = request.getSession(false)  ← không tạo mới
        │ → isLoggedIn = (session != null) && (session.getAttribute("loggedInUser") != null)
        │
        │ NẾU ĐÃ ĐĂNG NHẬP (isLoggedIn = true):
        │   → chain.doFilter() → cho request đi tiếp đến AuthorizationFilter
        │
        │ NẾU CHƯA ĐĂNG NHẬP (isLoggedIn = false):
        │   → Lưu URL hiện tại vào session:
        │     request.getSession().setAttribute("redirectAfterLogin", relativePath)
        │     Ví dụ: relativePath = "/customer/booking" → lưu lại
        │   → sendRedirect(contextPath + "/auth/login")
        │   → User thấy trang đăng nhập
        │   → Sau khi đăng nhập → LoginController check "redirectAfterLogin"
        │     → redirect về "/customer/booking"
```

## 5.3. Bảng URL Public và URL Protected

| URL | Public? | Lý do |
|-----|---------|-------|
| `/auth/login` | ✅ Có | Trang đăng nhập |
| `/auth/login?logout=success` | ✅ Có | Prefix match `/auth/login` |
| `/auth/register` | ✅ Có | Trang đăng ký |
| `/assets/css/style.css` | ✅ Có | Prefix match `/assets/` |
| `/error/403.jsp` | ✅ Có | Prefix match `/error/` |
| `/index.jsp` | ✅ Có | Exact match |
| `/images/logo.png` | ✅ Có | Regex match `.png` |
| `/` | ❌ KHÔNG | Không nằm trong danh sách ← **BUG tiềm ẩn** |
| `/auth/logout` | ❌ KHÔNG | Không có trong public list → cần đăng nhập mới logout được |
| `/admin/dashboard` | ❌ KHÔNG | URL protected → cần đăng nhập |
| `/customer/booking` | ❌ KHÔNG | URL protected → cần đăng nhập |
| `/doctor/patients` | ❌ KHÔNG | URL protected → cần đăng nhập |

## 5.4. Test Cases cho AuthenticationFilter

### TC-AF01: Truy cập URL public khi chưa đăng nhập
```
Bước: Chưa đăng nhập → gõ /auth/login
Kết quả: Hiển thị trang login bình thường (KHÔNG redirect)
Luồng: isPublicUrl("/auth/login") → true → chain.doFilter() → LoginController.doGet()
```

### TC-AF02: Truy cập URL protected khi chưa đăng nhập
```
Bước: Chưa đăng nhập → gõ /admin/dashboard
Kết quả: Redirect về /auth/login
  → Session lưu redirectAfterLogin="/admin/dashboard"
Luồng: isPublicUrl("/admin/dashboard") → false → session null → redirect login
```

### TC-AF03: Truy cập URL protected sau khi đăng nhập
```
Bước: Đã đăng nhập admin → gõ /admin/dashboard
Kết quả: Cho đi tiếp đến AuthorizationFilter → LoginController KHÔNG bị gọi
Luồng: isPublicUrl() → false → isLoggedIn → true → chain.doFilter()
```

### TC-AF04: Truy cập file tĩnh (CSS/JS) khi chưa đăng nhập
```
Bước: Chưa đăng nhập → browser tải /assets/css/style.css
Kết quả: File CSS được tải bình thường (KHÔNG redirect)
Luồng: isPublicUrl() → regex match ".css" → true → chain.doFilter()
```

### TC-AF05: Redirect after login hoạt động
```
Bước:
  1. Chưa đăng nhập → gõ /customer/booking
  2. Bị redirect về login → session có redirectAfterLogin="/customer/booking"
  3. Đăng nhập với customer01/123
  4. LoginController check redirectAfterLogin → có → redirect /customer/booking
Kết quả: User được đưa đến /customer/booking (không phải /customer/dashboard mặc định)
```

---

# 6. CHỨC NĂNG 5: AUTHORIZATIONFILTER

## 6.1. Các file liên quan

| File | Vai trò |
|------|---------|
| `AuthorizationFilter.java` | Filter phân quyền |
| `Role.java` | Cung cấp hằng số ADMIN=1, DOCTOR=2, STAFF=3, CUSTOMER=4 |
| `User.java` | Cung cấp getRoleID() |
| `403.jsp` | Trang hiển thị khi không đủ quyền |
| `web.xml` | Khai báo filter |

## 6.2. Luồng hoạt động chi tiết

```
Request đã qua AuthenticationFilter → đến AuthorizationFilter

Bước 1: │ Tính relativePath (giống AuthenticationFilter)
        │
Bước 2: │ KIỂM TRA URL PUBLIC/STATIC:
        │ → isPublicOrStaticUrl(relativePath)
        │   Danh sách:
        │   - /auth/login, /auth/register, /assets/, /error/
        │   - /index.jsp, /
        │   - file tĩnh (.css, .js, .png...)
        │ → NẾU PUBLIC → chain.doFilter() → THOÁT
        │
Bước 3: │ LẤY USER TỪ SESSION:
        │ → session.getAttribute("loggedInUser") → cast thành User object
        │ → Lấy roleID = user.getRoleID()
        │ → NẾU session null hoặc user null → chain.doFilter() → THOÁT
        │   (AuthenticationFilter đã xử lý trường hợp này rồi)
        │
Bước 4: │ KIỂM TRA QUYỀN (Hàm checkPermission):
        │
        │ ┌─── URL bắt đầu bằng "/admin/" ?
        │ │    → Chỉ cho phép nếu roleID == Role.ADMIN (1)
        │ │    → Admin vào /admin/dashboard ✓
        │ │    → Doctor vào /admin/dashboard ✗ → 403
        │ │
        │ ├─── URL bắt đầu bằng "/doctor/" ?
        │ │    → Chỉ cho phép nếu roleID == Role.DOCTOR (2)
        │ │
        │ ├─── URL bắt đầu bằng "/receptionist/" ?
        │ │    → Chỉ cho phép nếu roleID == Role.STAFF (3)
        │ │
        │ ├─── URL bắt đầu bằng "/customer/" ?
        │ │    → Chỉ cho phép nếu roleID == Role.CUSTOMER (4)
        │ │
        │ └─── URL KHÁC (ví dụ: /auth/logout, /profile...)
        │      → return true → cho phép tất cả user đã đăng nhập
        │
Bước 5: │ KẾT QUẢ:
        │ ├─ hasPermission = true:
        │ │   → chain.doFilter() → request đến Servlet đích
        │ │
        │ └─ hasPermission = false:
        │     → setAttribute("forbiddenUrl", relativePath)
        │       Ví dụ: "/admin/dashboard"
        │     → setAttribute("userRole", Role.getRoleNameVi(roleID))
        │       Ví dụ: "Bác sĩ"
        │     → forward → /error/403.jsp
        │     → 403.jsp hiển thị:
        │       ├─ Mã lỗi 403 lớn
        │       ├─ "Không có quyền truy cập"
        │       ├─ Tài khoản hiện tại: doctor01
        │       ├─ Vai trò: Bác sĩ
        │       ├─ Trang yêu cầu: /admin/dashboard
        │       ├─ Nút "Về trang chính" → dashboard tương ứng role
        │       └─ Nút "Quay lại" → history.back()
```

## 6.3. Ma trận phân quyền (Permission Matrix)

| URL Pattern | Admin (1) | Doctor (2) | Staff (3) | Customer (4) |
|-------------|:---------:|:----------:|:---------:|:-------------:|
| `/admin/*` | ✅ | ❌ 403 | ❌ 403 | ❌ 403 |
| `/doctor/*` | ❌ 403 | ✅ | ❌ 403 | ❌ 403 |
| `/receptionist/*` | ❌ 403 | ❌ 403 | ✅ | ❌ 403 |
| `/customer/*` | ❌ 403 | ❌ 403 | ❌ 403 | ✅ |
| `/auth/logout` | ✅ | ✅ | ✅ | ✅ |
| `/auth/login` | bypass | bypass | bypass | bypass |
| `/assets/*` | bypass | bypass | bypass | bypass |

## 6.4. Test Cases cho AuthorizationFilter

### TC-AZ01: Admin truy cập /admin/dashboard
```
Bước: Đăng nhập admin → gõ /admin/dashboard
Kết quả: Hiển thị trang admin dashboard
Luồng: checkPermission("/admin/...", roleID=1) → 1 == ADMIN → true → doFilter
```

### TC-AZ02: Doctor cố truy cập /admin/dashboard
```
Bước: Đăng nhập doctor01 → gõ /admin/dashboard
Kết quả: Hiển thị trang 403.jsp
  → "Tài khoản: doctor01, Vai trò: Bác sĩ, Trang yêu cầu: /admin/dashboard"
Luồng: checkPermission("/admin/...", roleID=2) → 2 ≠ ADMIN → false → forward 403.jsp
```

### TC-AZ03: Customer cố truy cập /doctor/patients
```
Bước: Đăng nhập customer01 → gõ /doctor/patients
Kết quả: 403.jsp
Luồng: checkPermission("/doctor/...", roleID=4) → 4 ≠ DOCTOR → false
```

### TC-AZ04: Staff truy cập /receptionist/dashboard
```
Bước: Đăng nhập staff01 → gõ /receptionist/dashboard
Kết quả: Cho phép truy cập
Luồng: checkPermission("/receptionist/...", roleID=3) → 3 == STAFF → true
```

### TC-AZ05: Bất kỳ ai truy cập /auth/logout (URL không nằm trong pattern)
```
Bước: Đăng nhập bất kỳ role → gõ /auth/logout
Kết quả: Cho phép (không thuộc pattern /admin, /doctor, /receptionist, /customer)
Luồng: checkPermission("/auth/logout", any role) → không match pattern nào → return true
```

## 6.5. Liên kết File ↔ File

```
AuthorizationFilter.java
  ├── [import] ──────→ User.java (cast session attribute, gọi getRoleID())
  ├── [import] ──────→ Role.java (dùng ADMIN, DOCTOR, STAFF, CUSTOMER constants)
  ├── [import] ──────→ Role.java (gọi getRoleNameVi() cho trang 403)
  └── [forward] ─────→ 403.jsp (khi không đủ quyền)

403.jsp
  ├── [session] ─────→ User object (hiển thị username)
  ├── [import] ──────→ Role.java (gọi getDashboardUrl() cho nút "Về trang chính")
  ├── [attr] ────────→ "forbiddenUrl" (từ AuthorizationFilter)
  └── [attr] ────────→ "userRole" (từ AuthorizationFilter)
```

---

# 7. CHỨC NĂNG 6: USERDAO (Tầng truy cập dữ liệu)

## 7.1. Mối quan hệ kế thừa

```
DBContext.java (cha)
  │
  │  Thuộc tính: protected Connection connection
  │  Constructor: Đọc ConnectDB.properties → DriverManager.getConnection()
  │
  └─── UserDAO.java extends DBContext (con)
         │
         │  Khi gọi new UserDAO():
         │  1. Constructor DBContext() chạy trước
         │  2. Load driver: com.microsoft.sqlserver.jdbc.SQLServerDriver
         │  3. Mở connection đến SQL Server:
         │     jdbc:sqlserver://localhost:1434;databaseName=DentalClinicDB
         │  4. Biến connection sẵn sàng dùng trong tất cả method
         │
         │  Tất cả method của UserDAO dùng this.connection (từ DBContext)
```

## 7.2. Danh sách toàn bộ hàm + SQL + Liên kết

### Hàm `mapUser(ResultSet rs)` — Hàm helper nội bộ
```
Mục đích: Chuyển 1 dòng ResultSet thành object User
Được gọi bởi: login(), getUserByID(), getAllUsers(), getUsersByRole()
Code:
  return new User(
    rs.getInt("UserID"),
    rs.getString("Username"),
    rs.getString("Password"),
    rs.getString("FullName"),
    rs.getString("Phone"),
    rs.getString("Email"),
    rs.getInt("RoleID")
  );
Liên kết: User.java (constructor 7 tham số)
```

### Hàm `login(username, password)` → User | null
```
SQL: SELECT UserID, Username, Password, FullName, Phone, Email, RoleID
     FROM Users WHERE Username = ? AND Password = ?
Dùng bởi: LoginController.doPost()
Trả về: User object nếu tìm thấy, null nếu không
```

### Hàm `register(username, password, fullName, phone, email)` → boolean
```
SQL: INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID)
     VALUES (?, ?, ?, ?, ?, 4)
Dùng bởi: RegisterController.doPost()
RoleID=4 hardcode: Chỉ tạo tài khoản Customer
```

### Hàm `isUsernameExists(username)` → boolean
```
SQL: SELECT 1 FROM Users WHERE Username = ?
Dùng bởi: RegisterController.doPost() (kiểm tra trước khi register)
```

### Hàm `isEmailExists(email)` → boolean
```
SQL: SELECT 1 FROM Users WHERE Email = ?
Dùng bởi: RegisterController.doPost()
```

### Hàm `getUserByID(userID)` → User | null
```
SQL: SELECT ... FROM Users WHERE UserID = ?
Dùng bởi: Các module khác khi cần lấy thông tin user theo ID
```

### Hàm `getAllUsers()` → List<User>
```
SQL: SELECT ... FROM Users ORDER BY RoleID, FullName
Dùng bởi: AdminUserController (trang quản lý user cho Admin)
```

### Hàm `getUsersByRole(roleID)` → List<User>
```
SQL: SELECT ... FROM Users WHERE RoleID = ? ORDER BY FullName
Dùng bởi: Các module khác (ví dụ: lấy danh sách Doctor cho Booking)
```

### Hàm `createUser(username, password, fullName, phone, email, roleID)` → boolean
```
SQL: INSERT INTO Users (..., RoleID) VALUES (?, ?, ?, ?, ?, ?)
Dùng bởi: AdminUserController (Admin tạo tài khoản cho Doctor/Staff)
Khác với register(): Cho phép chọn bất kỳ RoleID
```

### Hàm `updateUser(userID, fullName, phone, email, roleID)` → boolean
```
SQL: UPDATE Users SET FullName=?, Phone=?, Email=?, RoleID=? WHERE UserID=?
Dùng bởi: AdminUserController (Admin sửa thông tin user)
Không đổi username và password
```

### Hàm `updatePassword(userID, newPassword)` → boolean
```
SQL: UPDATE Users SET Password = ? WHERE UserID = ?
Dùng bởi: Chức năng đổi mật khẩu (chưa có Controller riêng)
```

### Hàm `deleteUser(userID)` → boolean
```
SQL: DELETE FROM Users WHERE UserID = ?
Dùng bởi: AdminUserController (Admin xóa user)
Lưu ý: DELETE cứng, không soft delete. Có thể lỗi FK nếu user có appointments
```

### Hàm `updateProfile(userID, fullName, phone, email)` → boolean
```
SQL: UPDATE Users SET FullName=?, Phone=?, Email=? WHERE UserID=?
Dùng bởi: Trang Profile cá nhân (user tự sửa info, KHÔNG đổi role)
Khác updateUser(): Không có tham số roleID
```

---

# 8. CHỨC NĂNG 7: MODELS (USER + ROLE)

## 8.1. User.java — Đối tượng người dùng

```
Thuộc tính (khớp 1:1 với cột trong bảng Users):
  - int userID        ← Users.UserID (PK, IDENTITY)
  - String username   ← Users.Username (VARCHAR 50, UNIQUE)
  - String password   ← Users.Password (VARCHAR 255)
  - String fullName   ← Users.FullName (NVARCHAR 100)
  - String phone      ← Users.Phone (VARCHAR 15)
  - String email      ← Users.Email (VARCHAR 100, NULL)
  - int roleID        ← Users.RoleID (FK → Roles.RoleID)

Constructor:
  - User()  ← constructor trống (cho JavaBean)
  - User(userID, username, password, fullName, phone, email, roleID) ← đầy đủ

Getter/Setter: Đầy đủ cho 7 thuộc tính
toString(): In thông tin user (không in password)

File nào dùng User.java:
  - UserDAO.java (tạo object từ DB, truyền tham số)
  - LoginController.java (lưu vào session, đọc roleID)
  - AuthorizationFilter.java (lấy từ session, đọc roleID)
  - 403.jsp (hiển thị username)
```

## 8.2. Role.java — Đối tượng vai trò + Tiện ích

```
Constants (Hằng số):
  public static final int ADMIN    = 1;
  public static final int DOCTOR   = 2;
  public static final int STAFF    = 3;
  public static final int CUSTOMER = 4;

Thuộc tính:
  - int roleID
  - String roleName

Static methods (Hàm tiện ích - không cần tạo object):

  1. getRoleNameVi(int roleID) → String
     Input/Output:
       1 → "Quản trị viên"
       2 → "Bác sĩ"
       3 → "Nhân viên tiếp đón"
       4 → "Khách hàng"
     Dùng bởi: 403.jsp (hiển thị tên vai trò tiếng Việt)

  2. getDashboardUrl(int roleID) → String
     Input/Output:
       1 → "/admin/dashboard"
       2 → "/doctor/dashboard"
       3 → "/receptionist/dashboard"
       4 → "/customer/dashboard"
       khác → "/auth/login"
     Dùng bởi: LoginController (redirect sau đăng nhập), 403.jsp (nút "Về trang chính")

File nào dùng Role.java:
  - LoginController.java (gọi getDashboardUrl)
  - AuthorizationFilter.java (dùng ADMIN, DOCTOR, STAFF, CUSTOMER constants)
  - 403.jsp (gọi getRoleNameVi, getDashboardUrl)
```

---

# 9. CHỨC NĂNG 8: TRANG LỖI

## 9.1. Trang 403.jsp (Không có quyền)

```
Khi nào hiển thị: AuthorizationFilter forward đến khi user cố truy cập URL không đúng quyền
Thông tin hiển thị:
  - Icon khóa + mã lỗi "403" (gradient đỏ-cam)
  - "Không có quyền truy cập"
  - Nếu đã đăng nhập:
    ├─ Tài khoản hiện tại: <username>
    ├─ Vai trò: <role tiếng Việt>
    └─ Trang yêu cầu: <URL bị chặn>
  - Nút "Về trang chính" → dashboard URL theo role
  - Nút "Quay lại" → JavaScript history.back()

Dữ liệu nhận từ:
  - session.getAttribute("loggedInUser") → object User
  - request.getAttribute("userRole") → String tên role (từ AuthorizationFilter)
  - request.getAttribute("forbiddenUrl") → String URL bị chặn (từ AuthorizationFilter)
```

## 9.2. Trang 404.jsp (Không tìm thấy)

```
Khi nào hiển thị: web.xml error-page mapping cho HTTP status 404
Tự động hiển thị khi gõ URL không tồn tại
```

---

# 10. CHỨC NĂNG 9: WEB.XML (Cấu hình triển khai)

## 10.1. Cấu hình liên quan đến Thành viên 1

```xml
<!-- Filter Chain (thứ tự quan trọng): -->
1. AuthenticationFilter → url-pattern: /*
   → Chạy TRƯỚC, kiểm tra đăng nhập
2. AuthorizationFilter  → url-pattern: /*
   → Chạy SAU, kiểm tra quyền

<!-- Servlet Mappings: -->
LoginController     → /auth/login
LogoutController    → /auth/logout
RegisterController  → /auth/register
AdminUserController → /admin/manage-users

<!-- Cấu hình khác: -->
Session timeout: 30 phút
Welcome file: index.jsp
Error pages: 403 → /error/403.jsp, 404 → /error/404.jsp
```

## 10.2. Lưu ý: Cả Filter đều khai báo ĐÔI

```
AuthenticationFilter:
  1. @WebFilter annotation trong file Java (dòng 26)
  2. <filter> + <filter-mapping> trong web.xml (dòng 28-35)
  → Có thể chạy filter 2 lần mỗi request!

AuthorizationFilter:
  1. @WebFilter annotation trong file Java (dòng 30)
  2. <filter> + <filter-mapping> trong web.xml (dòng 38-45)
  → Tương tự, có thể chạy 2 lần!

Cách sửa: Xóa 1 trong 2. Khuyến nghị giữ web.xml (dễ kiểm soát thứ tự filter)
và xóa @WebFilter annotation.
```

---

# 11. BẢNG TỔNG HỢP LIÊN KẾT FILE ↔ FILE

| File nguồn | Liên kết đến | Loại liên kết | Mục đích |
|------------|-------------|---------------|----------|
| `login.jsp` | `LoginController` | form action POST | Gửi dữ liệu đăng nhập |
| `login.jsp` | `RegisterController` | link href | Link "Đăng ký ngay" |
| `LoginController` | `UserDAO` | method call | Gọi `login()` |
| `LoginController` | `User` | object | Nhận kết quả từ DAO, lưu vào session |
| `LoginController` | `Role` | static method | Gọi `getDashboardUrl()` để redirect |
| `LoginController` | `login.jsp` | forward | Hiển thị form hoặc lỗi |
| `register.jsp` | `RegisterController` | form action POST | Gửi dữ liệu đăng ký |
| `register.jsp` | `LoginController` | link href | Link "Đăng nhập ngay" |
| `RegisterController` | `UserDAO` | method call | Gọi `register()`, `isUsernameExists()`, `isEmailExists()` |
| `RegisterController` | `register.jsp` | forward | Hiển thị lỗi + giữ dữ liệu |
| `RegisterController` | `LoginController` | redirect | Sau đăng ký → /auth/login?registered=success |
| `LogoutController` | `LoginController` | redirect | Sau logout → /auth/login?logout=success |
| `AuthenticationFilter` | `LoginController` | redirect | Chặn → redirect /auth/login |
| `AuthenticationFilter` | `web.xml` | config | Khai báo filter mapping |
| `AuthorizationFilter` | `User` | session read | Lấy user từ session, đọc roleID |
| `AuthorizationFilter` | `Role` | constants | Dùng ADMIN, DOCTOR, STAFF, CUSTOMER |
| `AuthorizationFilter` | `Role` | static method | Gọi `getRoleNameVi()` |
| `AuthorizationFilter` | `403.jsp` | forward | Không đủ quyền → hiển thị 403 |
| `403.jsp` | `User` | session read | Hiển thị username |
| `403.jsp` | `Role` | static method | Gọi `getDashboardUrl()`, `getRoleNameVi()` |
| `UserDAO` | `DBContext` | extends | Kế thừa connection |
| `UserDAO` | `User` | object create | Tạo User từ ResultSet (mapUser) |
| `DBContext` | `ConnectDB.properties` | file read | Đọc cấu hình kết nối DB |
| `DBContext` | SQL Server | JDBC | Kết nối database DentalClinicDB |
| `web.xml` | Tất cả Filter | config | Định nghĩa thứ tự + URL pattern |
| `web.xml` | Tất cả Servlet | config | Định nghĩa URL mapping |
| `web.xml` | `403.jsp`, `404.jsp` | error-page | Cấu hình trang lỗi |

---

# 12. TỔNG KẾT SỐ LIỆU

| Thống kê | Số lượng |
|----------|----------|
| Tổng số file Java của Thành viên 1 | 7 file |
| Tổng số file JSP | 4 file (login, register, 403, 404) |
| Tổng số file cấu hình | 2 file (web.xml, ConnectDB.properties) |
| Tổng số Servlet | 3 (Login, Register, Logout) |
| Tổng số Filter | 2 (Authentication, Authorization) |
| Tổng số Model | 2 (User, Role) |
| Tổng số DAO | 1 (UserDAO với 12 hàm) |
| Tổng số Validate (Login) | 6 validate |
| Tổng số Validate (Register) | 20 validate (client + server) |
| Tổng số Test Case đã liệt kê | 26 test cases |
| Tổng số bảng DB liên quan | 2 (Users, Roles) |
