# Phân tích nhiệm vụ của Thành viên 4 (Q.Huy) - Dental Clinic Management System

## Module phụ trách: Receptionist Module (Nhân viên tiếp đón)

Theo bảng phân công công việc của dự án, dưới đây là chi tiết các chức năng mà Thành viên 4 cần thực hiện:

### Các công việc cụ thể cần Code:
1. **Giao diện cho tiếp đón (Check-in lịch hẹn)**: 
   - Xây dựng giao diện danh sách lịch hẹn trong ngày.
   - Chức năng tìm kiếm, kiểm tra (Check) thông tin lịch hẹn của khách hàng khi họ đến phòng khám.

2. **Cập nhật trạng thái lịch hẹn**: 
   - Code chức năng cho phép đổi trạng thái lịch hẹn của khách sang **"Attended" (Đã đến)**.
   - Hỗ trợ luồng công việc điều hướng khách vào phòng khám gặp Bác sĩ (Thành viên 5).

3. **Đặt lịch hẹn trực tiếp tại quầy**: 
   - Xây dựng form đặt lịch hẹn cho Lễ tân.
   - Chức năng này dành cho các khách hàng vãng lai (không đặt lịch trước qua mạng), cho phép lễ tân chọn bác sĩ, dịch vụ và thời gian trống để tạo lịch hẹn ngay lập tức.

### Quy trình làm việc với Git/GitHub (Bắt buộc):
Để tránh xung đột code, hãy tuân thủ quy trình sau:
1. **Tuyệt đối không code trực tiếp trên nhánh `main`**.
2. Khi bắt đầu một tính năng mới (ví dụ: làm giao diện tiếp đón), hãy tạo một nhánh mới từ `main` (Ví dụ: `feature/reception-dashboard` hoặc `feature/walk-in-booking`).
3. Code từ Giao diện (JSP) -> Controller (Servlet) -> Database (DAO).
4. Code xong, đẩy (Push) nhánh đó lên GitHub và tạo **Pull Request (PR)**.
5. Chờ Leader kiểm tra code (Review), nếu ổn Leader sẽ Merge vào nhánh `main`.
