<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Appointment, model.Service, model.Medicine, model.MedicalRecord, model.PrescriptionDetail"%>
<%
    List<Appointment> queue = (List<Appointment>) request.getAttribute("queue");
    Appointment app = (Appointment) request.getAttribute("appointment");
    List<Service> selectedServices = (List<Service>) request.getAttribute("selectedServices");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<MedicalRecord> history = (List<MedicalRecord>) request.getAttribute("history");
    
    String successMessage = (String) request.getSession().getAttribute("successMessage");
    String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    
    if (successMessage != null) request.getSession().removeAttribute("successMessage");
    if (errorMessage != null) request.getSession().removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bác Sĩ - Khám Bệnh & Kê Đơn - SmileCare</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            .suggestion-item {
                transition: background-color 0.2s ease;
            }
            .suggestion-item:hover {
                background-color: #f1f5f9 !important;
            }
        </style>
    </head>
    <body>
        <!-- NAVBAR -->
        <nav class="navbar">
            <a href="<%= request.getContextPath() %>/" class="navbar-brand">
                🦷 SmileCare<span>+</span>
            </a>
            <div class="navbar-menu">
                <a href="<%= request.getContextPath() %>/">Trang Chủ</a>
                <a href="<%= request.getContextPath() %>/doctor/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-secondary" style="padding: 6px 14px;">Đăng xuất</a>
            </div>
        </nav>

        <!-- CONTAINER -->
        <div class="dashboard-container">
            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
            <% } %>
            
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
            <% } %>
            
            <% if (app == null) { %>
                <!-- QUEUE MODE: List checked-in patients -->
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 35px;">
                    🩺 Hàng chờ khám bệnh của Bác sĩ
                </h1>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Mã Lịch Hẹn</th>
                                <th>Bệnh Nhân</th>
                                <th>Ngày Hẹn</th>
                                <th>Giờ Hẹn</th>
                                <th>Ghi Chú Triệu Chứng</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (queue == null || queue.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" align="center" style="color: var(--text-muted); padding: 30px 0;">Không có bệnh nhân nào đang chờ khám.</td>
                                </tr>
                            <% } else {
                                for (Appointment q : queue) { %>
                                    <tr>
                                        <td>#<%= q.getAppointmentID() %></td>
                                        <td><strong><%= q.getCustomerName() %></strong></td>
                                        <td><%= q.getAppointmentDate() %></td>
                                        <td><%= q.getAppointmentTime() %></td>
                                        <td style="font-size: 0.85rem; color: var(--text-secondary);"><%= q.getNotes() != null ? q.getNotes() : "" %></td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/doctor/checkup?appointmentID=<%= q.getAppointmentID() %>" class="btn btn-primary" style="padding: 6px 12px; font-size: 0.8rem;">
                                                🩺 Tiến hành khám
                                            </a>
                                        </td>
                                    </tr>
                                <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <!-- FORM MODE: Fill medical record and prescription -->
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); margin-bottom: 35px;">
                    📝 Lập bệnh án & Đơn thuốc
                </h1>
                
                <div class="dashboard-grid">
                    <!-- Left: Form -->
                    <div class="glass-card">
                        <h2 style="font-family: var(--font-outfit); font-size: 1.4rem; font-weight: 700; color: var(--accent-navy); margin-bottom: 20px;">
                            Bệnh nhân: <%= app.getCustomerName() %> (Mã hẹn: #<%= app.getAppointmentID() %>)
                        </h2>
                        
                        <form action="<%= request.getContextPath() %>/doctor/checkup" method="POST">
                            <input type="hidden" name="appointmentID" value="<%= app.getAppointmentID() %>">
                            
                            <div class="form-group">
                                <label class="form-label">Chẩn đoán lâm sàng (Bắt buộc)</label>
                                <textarea name="diagnosis" class="form-control" placeholder="Mô tả kết quả chuẩn đoán bệnh lý..." required></textarea>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">Kế hoạch điều trị / Hướng dẫn tiếp theo</label>
                                <textarea name="treatmentPlan" class="form-control" placeholder="Nhập phác đồ điều trị hoặc lời dặn của bác sĩ..."></textarea>
                            </div>
                            
                            <h3 style="font-family: var(--font-outfit); font-size: 1.15rem; font-weight: 700; color: var(--accent-navy); margin: 25px 0 12px 0;">
                                💊 Kê đơn thuốc ngoại trú
                            </h3>

                             <!-- Search Input with Dropdown Suggestions -->
                             <div style="position: relative; margin-bottom: 20px;">
                                 <input type="text" id="medSearchInput" class="form-control" placeholder="🔍 Nhập tên thuốc để tìm kiếm và thêm vào đơn..." style="padding: 12px 16px; font-size: 0.95rem; border-radius: 8px; border: 1px solid var(--border-color); width: 100%;" oninput="filterMedicines()">
                                 <div id="medSuggestions" style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: #ffffff; border: 1px solid var(--border-color); border-radius: 8px; max-height: 250px; overflow-y: auto; z-index: 100; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); margin-top: 5px;">
                                     <!-- Suggestions filled dynamically by JS -->
                                 </div>
                             </div>
                             
                             <!-- Dynamic Selected Medicines Table -->
                             <div class="table-responsive" style="margin-bottom: 25px;">
                                 <table class="custom-table">
                                     <thead>
                                         <tr>
                                             <th>Tên Thuốc</th>
                                             <th>Đơn vị</th>
                                             <th>Đơn giá</th>
                                             <th style="width: 110px;">Số Lượng</th>
                                             <th>Hướng Dẫn Sử Dụng</th>
                                             <th style="width: 70px; text-align: center;">Xoá</th>
                                         </tr>
                                     </thead>
                                     <tbody id="prescriptionTbody">
                                         <tr id="emptyPrescriptionRow">
                                             <td colspan="6" align="center" style="color: var(--text-muted); padding: 35px 0; font-style: italic;">
                                                 <i class="fas fa-pills" style="font-size: 1.5rem; margin-bottom: 8px; display: block; color: #cbd5e1;"></i>
                                                 Chưa có thuốc nào được chọn. Nhập tên thuốc để tìm kiếm và thêm vào đơn.
                                             </td>
                                         </tr>
                                     </tbody>
                                 </table>
                             </div>
                            
                            <div style="display: flex; gap: 15px;">
                                <button type="submit" class="btn btn-cta">💾 Lưu Hồ Sơ Khám & Gửi Thanh Toán</button>
                                <a href="<%= request.getContextPath() %>/doctor/checkup" class="btn btn-secondary">Quay lại</a>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Right: Info Summary & Medical History -->
                    <div>
                        <div class="glass-card" style="position: sticky; top: 100px; display: flex; flex-direction: column; gap: 20px;">
                            <div>
                                <h3 style="font-family: var(--font-outfit); font-size: 1.2rem; font-weight: 700; color: var(--accent-navy); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-bottom: 15px;">
                                    Yêu cầu dịch vụ ban đầu
                                </h3>
                                <ul style="padding-left: 20px; font-size: 0.92rem; color: var(--text-secondary); line-height: 1.8;">
                                    <% if (selectedServices == null || selectedServices.isEmpty()) { %>
                                        <li>Khách không đăng ký dịch vụ trước. Khám tổng quát.</li>
                                    <% } else {
                                        for (Service s : selectedServices) { %>
                                            <li><%= s.getServiceName() %> (<code><%= String.format("%,.0f", s.getPrice()) %> đ</code>)</li>
                                        <% }
                                    } %>
                                </ul>
                            </div>
                            
                            <div style="border-top: 1px solid var(--border-color); padding-top: 20px;">
                                <h3 style="font-family: var(--font-outfit); font-size: 1.2rem; font-weight: 700; color: var(--accent-navy); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-bottom: 15px;">
                                    📜 Lịch sử khám bệnh
                                </h3>
                                <div style="max-height: 350px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; padding-right: 5px;">
                                    <% if (history == null || history.isEmpty()) { %>
                                        <p style="font-size: 0.88rem; color: var(--text-muted); font-style: italic;">Chưa có lịch sử khám bệnh nào trước đó.</p>
                                    <% } else {
                                        for (MedicalRecord mr : history) { %>
                                            <div style="background: #f8fafc; border: 1px solid var(--border-color); border-radius: 8px; padding: 12px; font-size: 0.88rem;">
                                                <div style="font-weight: 600; color: var(--accent-navy); margin-bottom: 4px; line-height: 1.4;">
                                                    Chẩn đoán: <%= mr.getDiagnosis() %>
                                                </div>
                                                <div style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 6px;">
                                                    <i class="far fa-calendar-alt"></i> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(mr.getCreatedAt()) %> 
                                                    | <i class="fas fa-user-md"></i> BS. <%= mr.getDoctorName() %>
                                                </div>
                                                <% if (mr.getTreatmentPlan() != null && !mr.getTreatmentPlan().trim().isEmpty()) { %>
                                                    <div style="margin-top: 4px; font-size: 0.85rem; color: var(--text-secondary);">
                                                        <strong>Lời dặn:</strong> <%= mr.getTreatmentPlan() %>
                                                    </div>
                                                <% } %>
                                                <% if (mr.getMedicines() != null && !mr.getMedicines().isEmpty()) { %>
                                                    <div style="margin-top: 6px; padding-top: 6px; border-top: 1px dashed var(--border-color); font-size: 0.8rem; color: var(--text-secondary);">
                                                        <strong>Thuốc đã kê:</strong>
                                                        <ul style="padding-left: 15px; margin: 2px 0 0 0; list-style-type: disc;">
                                                            <% for (PrescriptionDetail pd : mr.getMedicines()) { %>
                                                                <li><%= pd.getMedicineName() %> - SL: <%= pd.getQuantity() %> (<%= pd.getDosage() %>)</li>
                                                            <% } %>
                                                        </ul>
                                                    </div>
                                                <% } %>
                                            </div>
                                        <% }
                                    } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>

        <script>
            // Populate list of all medicines from server database safely
            const allMedicines = [
                <% if (medicines != null) {
                    for (int i = 0; i < medicines.size(); i++) {
                        Medicine m = medicines.get(i); %>
                        {
                            id: <%= m.getMedicineID() %>,
                            name: "<%= m.getMedicineName().replace("\"", "\\\"") %>",
                            unit: "<%= m.getUnit() %>",
                            price: <%= m.getPrice() %>,
                            image: "<%= m.getImagePath() != null ? request.getContextPath() + m.getImagePath() : "" %>"
                        }<%= i < medicines.size() - 1 ? "," : "" %>
                    <% }
                } %>
            ];

            function removeDiacritics(str) {
                if (!str) return '';
                return str.normalize("NFD")
                          .replace(/[\u0300-\u036f]/g, "")
                          .replace(/đ/g, "d")
                          .replace(/Đ/g, "D");
            }

            function filterMedicines() {
                const query = removeDiacritics(document.getElementById('medSearchInput').value.toLowerCase().trim());
                const suggestions = document.getElementById('medSuggestions');
                suggestions.innerHTML = '';
                
                if (!query) {
                    suggestions.style.display = 'none';
                    return;
                }
                
                const matches = allMedicines.filter(m => removeDiacritics(m.name.toLowerCase()).includes(query));
                
                if (matches.length === 0) {
                    suggestions.innerHTML = '<div style="padding: 12px; color: var(--text-muted); font-style: italic; font-size: 0.9rem;">Không tìm thấy thuốc nào</div>';
                    suggestions.style.display = 'block';
                    return;
                }
                
                matches.forEach(m => {
                    const item = document.createElement('div');
                    item.style.padding = '10px 16px';
                    item.style.cursor = 'pointer';
                    item.style.display = 'flex';
                    item.style.alignItems = 'center';
                    item.style.gap = '12px';
                    item.style.borderBottom = '1px solid #f1f5f9';
                    item.className = 'suggestion-item';
                    
                    let imgHtml = '';
                    if (m.image) {
                        imgHtml = '<img src="' + m.image + '" style="width: 32px; height: 32px; object-fit: contain; border-radius: 4px; border: 1px solid #e2e8f0; background: #fff; padding: 2px;">';
                    } else {
                        imgHtml = '<div style="width: 32px; height: 32px; border: 1px solid #e2e8f0; border-radius: 4px; background: #f1f5f9; display: flex; align-items: center; justify-content: center; font-size: 1rem;">💊</div>';
                    }

                    item.innerHTML = 
                        imgHtml +
                        '<div style="flex-grow: 1;">' +
                        '    <div style="font-weight: 600; font-size: 0.92rem; color: var(--accent-navy);">' + m.name + '</div>' +
                        '    <div style="font-size: 0.8rem; color: var(--text-muted);">' + m.unit + ' | ' + m.price.toLocaleString('vi-VN') + ' đ</div>' +
                        '</div>' +
                        '<span style="font-size: 0.8rem; background: #e0f2fe; color: #0369a1; padding: 4px 8px; border-radius: 12px; font-weight: 600;">Chọn</span>';
                    
                    item.onclick = function() {
                        addMedicineToTable(m);
                        document.getElementById('medSearchInput').value = '';
                        suggestions.style.display = 'none';
                    };
                    
                    suggestions.appendChild(item);
                });
                
                suggestions.style.display = 'block';
            }

            // Close suggestions dropdown when clicking outside
            document.addEventListener('click', function(e) {
                const searchInput = document.getElementById('medSearchInput');
                const suggestions = document.getElementById('medSuggestions');
                if (searchInput && suggestions && e.target !== searchInput && !suggestions.contains(e.target)) {
                    suggestions.style.display = 'none';
                }
            });

            const addedMedicineIds = new Set();

            function addMedicineToTable(m) {
                if (addedMedicineIds.has(m.id)) {
                    alert("Thuốc này đã được chọn trong đơn!");
                    return;
                }
                
                const tbody = document.getElementById('prescriptionTbody');
                const placeholder = document.getElementById('emptyPrescriptionRow');
                if (placeholder) {
                    placeholder.remove();
                }
                
                addedMedicineIds.add(m.id);
                
                const tr = document.createElement('tr');
                tr.id = 'med-row-' + m.id;
                
                let imgHtml = '';
                if (m.image) {
                    imgHtml = '<img src="' + m.image + '" alt="' + m.name + '" style="width: 40px; height: 40px; object-fit: contain; border: 1px solid var(--border-color); border-radius: var(--border-radius-md); padding: 2px; background: white; margin-right: 10px;">';
                } else {
                    imgHtml = '<div style="width: 40px; height: 40px; border: 1px solid var(--border-color); border-radius: var(--border-radius-md); background: #f1f5f9; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; margin-right: 10px;">💊</div>';
                }

                tr.innerHTML = 
                    '<td>' +
                    '    <div style="display: flex; align-items: center;">' +
                             imgHtml +
                    '        <div>' +
                    '            <strong>' + m.name + '</strong>' +
                    '            <input type="hidden" name="medicineIDs" value="' + m.id + '">' +
                    '        </div>' +
                    '    </div>' +
                    '</td>' +
                    '<td>' + m.unit + '</td>' +
                    '<td>' + m.price.toLocaleString('vi-VN') + ' đ</td>' +
                    '<td>' +
                    '    <input type="number" name="quantities" min="1" value="1" class="form-control" style="padding: 6px 10px; width: 80px;" required>' +
                    '</td>' +
                    '<td>' +
                    '    <input type="text" name="dosages" class="form-control" placeholder="VD: Ngày uống 2 lần sau ăn" style="padding: 6px 10px;" required>' +
                    '</td>' +
                    '<td align="center">' +
                    '    <button type="button" class="btn" onclick="removeMedicineRow(' + m.id + ')" style="padding: 6px 10px; color: #ef4444; border: 1px solid #fee2e2; background: #fef2f2; border-radius: 6px; cursor: pointer; transition: all 0.2s;"><i class="fas fa-trash-alt"></i></button>' +
                    '</td>';

                tbody.appendChild(tr);
            }

            function removeMedicineRow(medId) {
                const tr = document.getElementById('med-row-' + medId);
                if (tr) {
                    tr.remove();
                    addedMedicineIds.delete(medId);
                }
                
                const tbody = document.getElementById('prescriptionTbody');
                if (tbody.children.length === 0) {
                    tbody.innerHTML = 
                        '<tr id="emptyPrescriptionRow">' +
                        '    <td colspan="6" align="center" style="color: var(--text-muted); padding: 35px 0; font-style: italic;">' +
                        '        <i class="fas fa-pills" style="font-size: 1.5rem; margin-bottom: 8px; display: block; color: #cbd5e1;"></i>' +
                        '        Chưa có thuốc nào được chọn. Nhập tên thuốc để tìm kiếm và thêm vào đơn.' +
                        '    </td>' +
                        '</tr>';
                }
            }
        </script>
    </body>
</html>
