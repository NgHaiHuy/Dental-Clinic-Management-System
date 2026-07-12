# Phân tích dự án Dental Clinic Management System & Nhiệm vụ của Thành viên 1

---

## 1. Tổng quan Dự án (Project Overview)
**Dental Clinic Management System** là một hệ thống quản lý phòng khám nha khoa dựa trên nền tảng Web Java (JSP/Servlet). Dự án hướng tới việc chuyển đổi số, tối ưu hoá vận hành phòng khám.

**Công nghệ:**
- **Kiến trúc:** JSP (View) → Servlet (Controller) → DAO (Data Access) → SQL Server (DB)
- **Kết nối DB:** `DBContext.java` sử dụng JDBC + file `ConnectDB.properties`
- **Quản lý mã nguồn:** Git/GitHub, quy tắc tạo branch riêng cho từng feature/bugfix, tạo Pull Request (PR) để Leader review trước khi Merge.

**Các Role trong hệ thống (bảng `roles`):**

| RoleID | RoleName    | Mô tả                 |
|--------|-------------|------------------------|
| 1      | Admin       | Quản trị viên          |
| 2      | Doctor      | Bác sĩ                |
| 3      | Staff       | Nhân viên tiếp đón (Lễ tân) |
| 4      | Customer    | Khách hàng             |

---

## 2. Cấu trúc dự án hiện tại (liên quan đến Thành viên 1)

```
src/java/
├── context/
│   └── DBContext.java              ✅ Đã hoàn thành
├── model/
│   ├── User.java                   ✅ Đã hoàn thành
│   └── Role.java                   ✅ Đã hoàn thành (có constants + helper methods)
├── dal/
│   └── UserDAO.java                ✅ Đã hoàn thành (login, register, CRUD)
├── filter/
│   ├── AuthenticationFilter.java   ✅ Đã hoàn thành
│   └── AuthorizationFilter.java    ✅ Đã hoàn thành
└── controller/auth/
    ├── LoginController.java        ✅ Đã hoàn thành
    ├── RegisterController.java     ✅ Đã hoàn thành
    └── LogoutController.java       ✅ Đã hoàn thành

web/
├── auth/
│   ├── login.jsp                   ✅ Đã hoàn thành
│   └── register.jsp                ✅ Đã hoàn thành
├── error/
│   ├── 403.jsp                     ✅ Đã hoàn thành
│   └── 404.jsp                     ✅ Đã hoàn thành
└── WEB-INF/
    └── web.xml                     ✅ Đã hoàn thành (filter + servlet mappings)
```

---

## 3. Kiểm tra Validation hiện tại & Phân tích những gì còn thiếu

### 3.1. Đăng nhập (LoginController + login.jsp)

#### ✅ Validate hiện có:
| #  | Validate                                    | Phía        | Vị trí                    |
|----|---------------------------------------------|-------------|---------------------------|
| 1  | Username/Password không được để trống       | Server-side | `LoginController.doPost()` dòng 59-65 |
| 2  | Kiểm tra Username + Password khớp trong DB  | Server-side | `UserDAO.login()` dòng 45-60 |
| 3  | Nếu đã đăng nhập rồi → redirect về dashboard | Server-side | `LoginController.doGet()` dòng 35-40 |
| 4  | Client-side: chặn submit nếu trống          | Client-side | `login.jsp` dòng 408-415 |
| 5  | Giữ lại username đã nhập khi lỗi            | Server-side | `LoginController.doPost()` dòng 62, 73 |
| 6  | Hiển thị thông báo đăng ký thành công       | JSP         | `login.jsp` dòng 300-305 |
| 7  | Hiển thị thông báo đăng xuất thành công     | JSP         | `login.jsp` dòng 292-297 |

#### ❌ Validate còn thiếu cần bổ sung:
| #  | Validate cần thêm                                      | Mức độ      | Chi tiết                        |
|----|--------------------------------------------------------|-------------|----------------------------------|
| 1  | **Chống Brute Force (giới hạn số lần đăng nhập sai)**  | Server-side | Sau 5 lần sai → khoá tạm 15 phút. Dùng `session` hoặc `Map<IP, failCount>` để theo dõi |
| 2  | **Trim input trước khi validate trống**                 | Server-side | Hiện đã `trim()` khi gọi DAO, nhưng validate trống chưa `trim()` trước khi kiểm tra. Ví dụ: user nhập toàn dấu cách vẫn qua validate |
| 3  | **Chống XSS cho username hiển thị lại**                 | JSP         | `login.jsp` dòng 323: `value="${not empty username ? username : ''}"` → nên dùng `<c:out>` hoặc `fn:escapeXml()` để tránh chèn script |
| 4  | **Giới hạn độ dài input từ phía server**                | Server-side | Không kiểm tra username > 50 ký tự hay password quá dài trước khi query DB |
| 5  | **Chức năng "Quên mật khẩu"**                           | Tính năng mới | Hiện link "Quên mật khẩu?" trên `login.jsp` chỉ trỏ `href="#"` → **CẦN PHÁT TRIỂN** (xem Mục 4) |
| 6  | **Chức năng "Ghi nhớ đăng nhập" (Remember Me)**         | Tính năng mới | Hiện checkbox "Ghi nhớ đăng nhập" có trên UI nhưng server chưa xử lý → cần dùng Cookie |
| 7  | **Set HTTP response header chống cache trang login**    | Server-side | Sau khi đăng nhập, nếu bấm nút Back trên trình duyệt vẫn có thể thấy trang login từ cache |

---

### 3.2. Đăng ký (RegisterController + register.jsp)

#### ✅ Validate hiện có:
| #  | Validate                                         | Phía        | Vị trí                          |
|----|--------------------------------------------------|-------------|-----------------------------------|
| 1  | Username không được để trống                     | Server-side | `validateRegisterInput()` dòng 110-112 |
| 2  | Username phải từ 4-50 ký tự                      | Server-side | dòng 113-115 |
| 3  | Username chỉ chứa chữ cái, số, dấu gạch dưới   | Server-side | dòng 116-118 (regex `[a-zA-Z0-9_]+`) |
| 4  | Password không được để trống                     | Server-side | dòng 120-122 |
| 5  | Password tối thiểu 3 ký tự                      | Server-side | dòng 123-125 |
| 6  | Confirm password phải trùng khớp                 | Server-side | dòng 127-129 |
| 7  | FullName không được để trống                     | Server-side | dòng 131-133 |
| 8  | Phone không được để trống                        | Server-side | dòng 135-137 |
| 9  | Phone đúng định dạng VN (`0` hoặc `+84` + 9-10 số) | Server-side | dòng 138-140 (regex) |
| 10 | Email đúng định dạng (nếu có nhập)              | Server-side | dòng 142-146 (regex) |
| 11 | Kiểm tra username đã tồn tại trong DB           | Server-side | `RegisterController.doPost()` dòng 63-71 |
| 12 | Kiểm tra email đã tồn tại trong DB              | Server-side | dòng 74-82 |
| 13 | Giữ lại tất cả dữ liệu đã nhập khi lỗi         | Server-side | dòng 54-57, 65-68, 76-79 |
| 14 | Client-side: chặn submit nếu trống bắt buộc     | Client-side | `register.jsp` dòng 327-349 |
| 15 | Client-side: kiểm tra confirm password           | Client-side | `register.jsp` dòng 340-343 |
| 16 | Client-side: checkbox đồng ý điều khoản          | Client-side | `register.jsp` dòng 345-348 |
| 17 | Thanh đo độ mạnh mật khẩu (password strength)    | Client-side | `register.jsp` dòng 300-324 |

#### ❌ Validate còn thiếu cần bổ sung:
| #  | Validate cần thêm                                        | Mức độ      | Chi tiết                       |
|----|----------------------------------------------------------|-------------|----------------------------------|
| 1  | **Password quá yếu - tối thiểu nên 6 ký tự**            | Server-side | Hiện chỉ yêu cầu 3 ký tự → quá yếu cho hệ thống y tế. Nên nâng lên 6 ký tự, bắt buộc có ít nhất 1 chữ hoa + 1 số |
| 2  | **Giới hạn độ dài tối đa password (255 ký tự)**          | Server-side | Chưa có kiểm tra maxLength cho password |
| 3  | **Giới hạn độ dài FullName (tối đa 100 ký tự)**         | Server-side | DB cho phép NVARCHAR(100) nhưng server không kiểm tra |
| 4  | **Giới hạn độ dài Email (tối đa 100 ký tự)**            | Server-side | DB cho phép VARCHAR(100) nhưng server không kiểm tra |
| 5  | **Giới hạn độ dài Phone (tối đa 15 ký tự)**             | Server-side | DB cho phép VARCHAR(15) nhưng chỉ validate format, chưa check maxLength |
| 6  | **FullName chống ký tự đặc biệt nguy hiểm**             | Server-side | Cho phép Unicode (tên tiếng Việt) nhưng nên chặn ký tự như `<`, `>`, `"`, `'` để chống XSS |
| 7  | **Chống XSS cho dữ liệu hiển thị lại trên form**        | JSP         | `register.jsp` sử dụng `${regUsername}` trực tiếp → cần dùng `<c:out>` hoặc `fn:escapeXml()` |
| 8  | **Client-side: validate username realtime (AJAX)**       | Client-side | Kiểm tra username tồn tại ngay khi gõ, không cần chờ submit |
| 9  | **Client-side: validate phone format realtime**          | Client-side | Regex check phone khi gõ |
| 10 | **Email nên là bắt buộc**                                | Server-side | Hiện Email là tùy chọn, nhưng cần bắt buộc nếu muốn triển khai tính năng Quên mật khẩu |
| 11 | **Chống CSRF (Cross-Site Request Forgery)**              | Server-side | Form đăng ký chưa có CSRF token → ai đó có thể tạo form giả để tự động đăng ký hàng loạt tài khoản |
| 12 | **Băm mật khẩu (Password Hashing)**                     | Server-side | Hiện lưu mật khẩu dạng **plain text** (text thường) vào DB → Rất nguy hiểm! Cần băm bằng SHA-256 hoặc BCrypt trước khi lưu |

---

### 3.3. Đăng xuất (LogoutController)

#### ✅ Validate hiện có:
| #  | Validate                                | Vị trí                    |
|----|-----------------------------------------|---------------------------|
| 1  | Kiểm tra session tồn tại trước khi invalidate | `LogoutController` dòng 37-39 |
| 2  | Xoá cookie JSESSIONID                  | dòng 43-46 |
| 3  | Hỗ trợ cả GET và POST                  | dòng 21-29 |

#### ❌ Validate còn thiếu cần bổ sung:
| # | Validate cần thêm                                   | Chi tiết |
|---|------------------------------------------------------|----------|
| 1 | **Chống cache sau logout**                           | Set header `Cache-Control: no-cache, no-store, must-revalidate` để trình duyệt không hiển thị trang cũ khi bấm Back |
| 2 | **Chỉ nên dùng POST cho logout**                    | GET `/auth/logout` có thể bị khai thác qua tag `<img src="/auth/logout">` khiến user bị đăng xuất mà không biết. Nên hạn chế chỉ dùng POST |

---

### 3.4. AuthenticationFilter

#### ✅ Đã có:
| #  | Chức năng                              | Vị trí     |
|----|----------------------------------------|------------|
| 1  | Bypass URL public (login, register, assets, error, index.jsp) | dòng 32-38 |
| 2  | Bypass file tĩnh (.css, .js, .png, .jpg...) | dòng 96-98 |
| 3  | Check session `loggedInUser`           | dòng 69-70 |
| 4  | Lưu URL redirect after login           | dòng 78 |
| 5  | Dùng `@WebFilter("/*")` + cấu hình trong web.xml | annotation + web.xml |

#### ❌ Còn thiếu cần bổ sung:
| # | Validate/Tính năng cần thêm                           | Chi tiết |
|---|--------------------------------------------------------|----------|
| 1 | **Thiếu bypass URL trang chủ `/`**                     | Khi truy cập root `/` (không phải `/index.jsp`), filter sẽ chặn vì `/` không có trong `PUBLIC_URL_PREFIXES`. Cần thêm `"/"` vào danh sách |
| 2 | **Thiếu bypass cho URL `/auth/forgot-password`**       | Khi thêm tính năng Quên mật khẩu, cần bổ sung URL public |
| 3 | **Thiếu bypass cho URL `/auth/reset-password`**        | Tương tự |
| 4 | **Duplicate filter registration**                      | Filter đã dùng `@WebFilter` annotation + khai báo lại trong `web.xml` → có thể chạy 2 lần. Nên chỉ dùng 1 cách |
| 5 | **Set header chống cache cho trang bảo vệ**            | Thêm `response.setHeader("Cache-Control", "no-cache, no-store")` để trình duyệt không cache trang sau khi logout |

---

### 3.5. AuthorizationFilter

#### ✅ Đã có:
| #  | Chức năng                     | Vị trí     |
|----|-------------------------------|------------|
| 1  | Phân quyền `/admin/*` → Admin only | dòng 95-97 |
| 2  | Phân quyền `/doctor/*` → Doctor only | dòng 100-102 |
| 3  | Phân quyền `/receptionist/*` → Staff only | dòng 105-107 |
| 4  | Phân quyền `/customer/*` → Customer only | dòng 110-112 |
| 5  | Bypass URL public + tĩnh     | dòng 122-130 |
| 6  | Forward đến `403.jsp` khi không có quyền | dòng 78-82 |

#### ❌ Còn thiếu cần bổ sung:
| # | Validate cần thêm                                     | Chi tiết |
|---|--------------------------------------------------------|----------|
| 1 | **Admin nên được truy cập tất cả trang**               | Hiện Admin chỉ vào được `/admin/*`. Nếu Admin muốn xem trang Doctor hoặc Customer để debug/hỗ trợ → bị chặn. Cân nhắc cho Admin bypass tất cả |
| 2 | **Log lại hành vi truy cập trái phép**                 | Khi user cố truy cập sai quyền, nên ghi log (IP, username, URL, thời gian) để audit sau này |
| 3 | **Duplicate filter registration** (giống Authentication) | Dùng cả `@WebFilter` + `web.xml` |

---

### 3.6. UserDAO

#### ✅ Đã có:
| Hàm                    | Chức năng                          |
|-------------------------|------------------------------------|
| `login()`              | Đăng nhập (query by username + password) |
| `register()`           | Đăng ký (RoleID = 4 - Customer)   |
| `isUsernameExists()`   | Kiểm tra username trùng           |
| `isEmailExists()`      | Kiểm tra email trùng              |
| `getUserByID()`        | Lấy user theo ID                  |
| `getAllUsers()`         | Lấy tất cả users (Admin)          |
| `getUsersByRole()`     | Lấy users theo role               |
| `createUser()`         | Admin tạo tài khoản mới           |
| `updateUser()`         | Admin cập nhật thông tin user      |
| `updatePassword()`     | Đổi mật khẩu                      |
| `deleteUser()`         | Xoá user                          |
| `updateProfile()`      | User tự sửa profile               |

#### ❌ Còn thiếu cần bổ sung:
| # | Hàm cần thêm                                         | Chi tiết |
|---|------------------------------------------------------|----------|
| 1 | **`getUserByEmail(String email)`**                    | Cần cho tính năng Quên mật khẩu: tìm user bằng email để gửi link reset |
| 2 | **`getUserByUsername(String username)`**               | Cần cho tính năng Quên mật khẩu + Profile: tìm user bằng username |
| 3 | **`updatePasswordByEmail(String email, String newPwd)`** | Đặt lại mật khẩu qua email |
| 4 | **`isPhoneExists(String phone)`**                     | Kiểm tra SĐT đã tồn tại chưa (tránh 1 SĐT đăng ký nhiều tài khoản) |
| 5 | **`searchUsers(String keyword)`**                     | Tìm kiếm user (cho Admin) |
| 6 | **Đóng connection**                                   | UserDAO extends `DBContext` nhưng không có `close()`. Mỗi lần `new UserDAO()` tạo 1 connection mới mà không bao giờ đóng → **rò rỉ connection nghiêm trọng** |

---

## 4. Tính năng mới cần phát triển: Quên mật khẩu (Forgot Password)

### 4.1. Luồng hoạt động:

```
[User nhấn "Quên mật khẩu?" trên login.jsp]
       │
       ▼
[GET /auth/forgot-password] → Hiển thị forgot-password.jsp
       │                       (Form nhập Email)
       ▼
[POST /auth/forgot-password] → ForgotPasswordController
       │
       ├─ Validate email không trống, đúng định dạng
       ├─ Tìm user trong DB bằng email (UserDAO.getUserByEmail)
       ├─ Nếu không tìm thấy → báo lỗi "Email không tồn tại"
       ├─ Nếu tìm thấy:
       │     ├─ Tạo token ngẫu nhiên (UUID) + thời gian hết hạn (30 phút)
       │     ├─ Lưu token vào DB hoặc Session
       │     └─ Gửi email cho user chứa link: /auth/reset-password?token=xxx
       └─ Hiển thị "Chúng tôi đã gửi link đặt lại mật khẩu đến email của bạn"
              │
              ▼
[User mở email → click link → GET /auth/reset-password?token=xxx]
       │
       ▼
[ResetPasswordController]
       │
       ├─ Kiểm tra token hợp lệ + chưa hết hạn
       ├─ Nếu hợp lệ → hiển thị form nhập mật khẩu mới + xác nhận mật khẩu
       ├─ Nếu không hợp lệ → báo lỗi "Link đã hết hạn"
       │
[POST /auth/reset-password]
       │
       ├─ Validate: mật khẩu mới ≥ 6 ký tự, khớp confirm
       ├─ Cập nhật password trong DB (UserDAO.updatePassword)
       ├─ Xoá token đã dùng
       └─ Redirect về login.jsp với thông báo "Đặt lại mật khẩu thành công"
```

### 4.2. Các file cần tạo/sửa:

| Loại       | File                                          | Mô tả                       |
|------------|-----------------------------------------------|------------------------------|
| **[NEW]**  | `web/auth/forgot-password.jsp`                | Form nhập email              |
| **[NEW]**  | `web/auth/reset-password.jsp`                 | Form nhập mật khẩu mới      |
| **[NEW]**  | `controller/auth/ForgotPasswordController.java` | Xử lý gửi email reset     |
| **[NEW]**  | `controller/auth/ResetPasswordController.java`  | Xử lý đặt lại mật khẩu   |
| **[NEW]**  | `database/add_password_reset_table.sql`       | Tạo bảng lưu token          |
| **[MODIFY]** | `dal/UserDAO.java`                          | Thêm hàm `getUserByEmail()` |
| **[MODIFY]** | `filter/AuthenticationFilter.java`          | Thêm bypass URL `/auth/forgot-password`, `/auth/reset-password` |
| **[MODIFY]** | `web/auth/login.jsp`                        | Sửa link "Quên mật khẩu?" trỏ đúng URL |
| **[MODIFY]** | `web/WEB-INF/web.xml`                       | Thêm servlet mapping mới    |

### 4.3. Bảng DB bổ sung cho Reset Token:

```sql
CREATE TABLE PasswordResetTokens (
    TokenID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID     INT FOREIGN KEY REFERENCES Users(UserID),
    Token      VARCHAR(255) NOT NULL UNIQUE,
    ExpiryDate DATETIME NOT NULL,
    Used       BIT DEFAULT 0
);
```

### 4.4. Validate cần có cho tính năng Quên mật khẩu:

| # | Validate                                              | Phía        |
|---|-------------------------------------------------------|-------------|
| 1 | Email không được để trống                              | Server + Client |
| 2 | Email đúng định dạng                                   | Server + Client |
| 3 | Email phải tồn tại trong DB                            | Server-side |
| 4 | Giới hạn số lần gửi request reset (chống spam)         | Server-side (rate limit) |
| 5 | Token phải hợp lệ (tồn tại trong DB)                  | Server-side |
| 6 | Token chưa hết hạn (< 30 phút)                        | Server-side |
| 7 | Token chưa được sử dụng                                | Server-side |
| 8 | Mật khẩu mới ≥ 6 ký tự, có chữ hoa + số              | Server + Client |
| 9 | Xác nhận mật khẩu mới trùng khớp                      | Server + Client |
| 10| Mật khẩu mới không được giống mật khẩu cũ             | Server-side |

---

## 5. Tính năng "Ghi nhớ đăng nhập" (Remember Me)

### Hiện trạng:
- UI đã có checkbox "Ghi nhớ đăng nhập" trên `login.jsp` (dòng 343)
- Server chưa xử lý giá trị này

### Cần bổ sung trong `LoginController.doPost()`:
```
1. Kiểm tra request.getParameter("remember")
2. Nếu checked:
   - Tạo Cookie "rememberUser" chứa username (đã encode)
   - Tạo Cookie "rememberToken" chứa token đã hash
   - setMaxAge = 7 ngày (604800 giây)
3. Nếu không checked:
   - Xoá cookie (setMaxAge = 0)
```

### Cần bổ sung trong `LoginController.doGet()`:
```
1. Đọc Cookie "rememberUser"
2. Nếu có → điền sẵn username vào form login
```

---

## 6. Tổng hợp Validate cần bổ sung (Checklist)

### 🔴 Ưu tiên CAO (Bảo mật):

- [ ] **Băm mật khẩu**: Thay đổi từ lưu plain text → SHA-256/BCrypt. Cần sửa `UserDAO.register()`, `UserDAO.login()`, `UserDAO.createUser()`, `UserDAO.updatePassword()`
- [ ] **Chống XSS**: Sử dụng `<c:out>` hoặc `fn:escapeXml()` thay cho `${}` trực tiếp trong `login.jsp` và `register.jsp`
- [ ] **Chống Brute Force Login**: Giới hạn 5 lần sai → khoá tạm 15 phút
- [ ] **Fix duplicate filter registration**: Xoá 1 trong 2 (bỏ `@WebFilter` hoặc bỏ khai báo trong `web.xml`)
- [ ] **Đóng DB connection**: Thêm phương thức `close()` vào `DBContext` và gọi trong `finally` block hoặc `try-with-resources`

### 🟡 Ưu tiên TRUNG BÌNH (Chất lượng):

- [ ] **Nâng yêu cầu password lên ≥ 6 ký tự** + bắt buộc có chữ hoa và số
- [ ] **Giới hạn maxLength** cho tất cả input (username ≤ 50, password ≤ 255, fullName ≤ 100, phone ≤ 15, email ≤ 100) - khớp với constraint DB
- [ ] **Validate FullName**: Chặn ký tự `< > " '` và các tag HTML
- [ ] **Thêm `isPhoneExists()`** vào UserDAO - kiểm tra SĐT trùng
- [ ] **Email bắt buộc nhập** (hiện tại tuỳ chọn - cần cho tính năng Quên mật khẩu)
- [ ] **Bypass URL `/` trong AuthenticationFilter** - trang chủ phải public
- [ ] **Header Cache-Control** cho các trang sau đăng nhập/đăng xuất

### 🟢 Ưu tiên THẤP (UX tốt hơn):

- [ ] **Remember Me**: Xử lý Cookie ghi nhớ đăng nhập
- [ ] **Client-side realtime validation**: AJAX check username tồn tại, regex phone/email khi gõ
- [ ] **Admin bypass tất cả trang**: Cho Admin truy cập `/doctor/*`, `/customer/*` để debug
- [ ] **Log hành vi truy cập trái phép**: Ghi file log khi user bị chặn bởi AuthorizationFilter
- [ ] **Chống CSRF**: Thêm CSRF token vào form

---

## 7. Tính năng đã hoàn thành (Recap)

### ✅ 7.1. Đăng nhập (Login) — HOÀN THÀNH
- Trang `login.jsp` với giao diện 2 panel (branding + form)
- `LoginController` xử lý GET/POST, validate input, check session redirect
- Điều hướng theo Role sau đăng nhập
- Tài khoản demo hiển thị sẵn trên UI

### ✅ 7.2. Đăng ký (Register) — HOÀN THÀNH
- Trang `register.jsp` với form responsive
- `RegisterController` validate 10+ điều kiện server-side
- Thanh đo độ mạnh mật khẩu (client-side)
- Kiểm tra trùng username/email trong DB

### ✅ 7.3. Đăng xuất (Logout) — HOÀN THÀNH
- `LogoutController` hỗ trợ GET + POST
- Xoá session + xoá cookie JSESSIONID
- Redirect về login kèm thông báo

### ✅ 7.4. AuthenticationFilter — HOÀN THÀNH
- Chặn tất cả URL trừ public (login, register, assets, error, index.jsp, file tĩnh)
- Lưu URL redirect after login

### ✅ 7.5. AuthorizationFilter — HOÀN THÀNH
- Phân quyền 4 role theo URL prefix
- Forward đến trang 403 khi không có quyền (kèm thông tin chi tiết)

### ✅ 7.6. UserDAO — HOÀN THÀNH (CRUD đầy đủ)
- login, register, isUsernameExists, isEmailExists
- getUserByID, getAllUsers, getUsersByRole
- createUser, updateUser, updatePassword, deleteUser, updateProfile

### ✅ 7.7. Trang lỗi — HOÀN THÀNH
- `403.jsp` hiển thị thông tin user + role + URL bị chặn
- `404.jsp` hiển thị trang không tìm thấy

### ✅ 7.8. web.xml — HOÀN THÀNH
- Filter mappings (Authentication + Authorization)
- Servlet mappings (Login, Logout, Register, AdminUser, ManageService)
- Error pages (403, 404)
- Session timeout 30 phút

---

## 8. Kế hoạch công việc tiếp theo (TODO)

### Sprint 1: Sửa lỗi bảo mật (Ưu tiên cao)
1. [ ] Fix duplicate filter registration (`@WebFilter` vs `web.xml`)
2. [ ] Thêm `close()` cho DBContext, sửa tất cả DAO dùng try-with-resources
3. [ ] Băm mật khẩu bằng SHA-256 (hoặc BCrypt) - sửa DAO + cập nhật dữ liệu mẫu SQL
4. [ ] Chống XSS: thêm JSTL `<c:out>` vào login.jsp và register.jsp
5. [ ] Thêm Cache-Control header trong filter

### Sprint 2: Bổ sung validate thiếu
6. [ ] Nâng password policy lên ≥ 6 ký tự + chữ hoa + số
7. [ ] Thêm kiểm tra maxLength cho tất cả input (khớp DB constraints)
8. [ ] Thêm `isPhoneExists()` vào UserDAO + validate trong Register
9. [ ] Validate FullName chống ký tự đặc biệt
10. [ ] Thêm bypass URL `/` trong AuthenticationFilter
11. [ ] Chuyển Email từ tuỳ chọn → bắt buộc
12. [ ] Thêm chống Brute Force login (Map đếm số lần sai)

### Sprint 3: Tính năng Quên mật khẩu
13. [ ] Tạo bảng `PasswordResetTokens` trong SQL
14. [ ] Thêm hàm `getUserByEmail()` vào UserDAO
15. [ ] Tạo `ForgotPasswordController` + `forgot-password.jsp`
16. [ ] Tạo `ResetPasswordController` + `reset-password.jsp`
17. [ ] Tích hợp gửi email (JavaMail API)
18. [ ] Sửa link "Quên mật khẩu?" trên `login.jsp`
19. [ ] Thêm bypass URL mới vào AuthenticationFilter
20. [ ] Thêm servlet mapping mới vào web.xml

### Sprint 4: Tính năng bổ trợ
21. [ ] Xử lý Remember Me (Cookie)
22. [ ] Client-side realtime validation (AJAX)
23. [ ] Log hành vi truy cập trái phép
24. [ ] Cho Admin bypass truy cập tất cả trang

### Sprint 5: Phối hợp Thành viên 6
25. [ ] Thảo luận và hoàn thiện trang Quản lý User (Admin)
26. [ ] Đảm bảo AuthorizationFilter chặn tuyệt đối tạo tài khoản nhân viên từ non-Admin
