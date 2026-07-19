<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.User, model.Service"%>
<%
    List<User> customers = (List<User>) request.getAttribute("customers");
    List<User> doctors = (List<User>) request.getAttribute("doctors");
    List<Service> services = (List<Service>) request.getAttribute("services");
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null) {
        errorMessage = (String) session.getAttribute("errorMessage");
        if (errorMessage != null) session.removeAttribute("errorMessage");
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt Lịch Tại Quầy - SmileCare</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <style>
            .booking-container {
                max-width: 800px;
                margin: 40px auto 60px auto;
            }
            .booking-card {
                background: var(--bg-secondary);
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-lg);
                padding: 45px;
                box-shadow: 0 15px 35px rgba(15, 23, 42, 0.04);
            }
            .section-title {
                font-family: var(--font-outfit);
                font-size: 1.05rem;
                font-weight: 700;
                color: var(--accent-teal);
                margin: 28px 0 16px 0;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .section-title::after {
                content: '';
                flex: 1;
                height: 1px;
                background-color: var(--border-color);
            }
            .form-grid-2 {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .form-group {
                margin-bottom: 20px;
            }
            .form-label {
                font-size: 0.9rem;
                font-weight: 600;
                color: var(--text-primary);
                margin-bottom: 8px;
                display: block;
            }
            .form-control, .form-select {
                width: 100%;
                padding: 12px 16px;
                font-size: 0.95rem;
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-md);
                background-color: var(--bg-primary);
                color: var(--text-primary);
                transition: all 0.2s ease;
            }
            .form-control:focus, .form-select:focus {
                border-color: var(--accent-teal);
                background-color: var(--bg-secondary);
                box-shadow: 0 0 0 4px rgba(30, 64, 175, 0.1);
                outline: none;
            }
            textarea.form-control {
                resize: vertical;
                min-height: 80px;
            }
            .services-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
                margin-top: 5px;
            }
            .service-card {
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-md);
                padding: 16px;
                display: flex;
                align-items: center;
                gap: 14px;
                cursor: pointer;
                transition: all 0.2s ease;
                background: var(--bg-secondary);
                position: relative;
                user-select: none;
            }
            .service-card:hover {
                border-color: var(--accent-teal);
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
            }
            .service-card-info {
                flex-grow: 1;
            }
            .service-card-title {
                font-size: 0.92rem;
                font-weight: 600;
                color: var(--accent-navy);
                margin-bottom: 3px;
                line-height: 1.3;
            }
            .service-card-price {
                font-size: 0.85rem;
                font-weight: 700;
                color: var(--text-muted);
            }
            .service-card-check {
                width: 20px;
                height: 20px;
                border-radius: 50%;
                border: 2px solid var(--border-color);
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.2s ease;
                flex-shrink: 0;
            }
            .service-card-check i {
                font-style: normal;
                font-weight: 800;
                font-size: 0.75rem;
                color: white;
                display: none;
            }
            .service-card.active {
                border-color: var(--accent-teal);
                background-color: rgba(16, 185, 129, 0.03);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.06);
            }
            .service-card.active .service-card-check {
                background-color: var(--accent-teal);
                border-color: var(--accent-teal);
            }
            .service-card.active .service-card-check i {
                display: block;
            }
            
            /* Custom radio styles */
            .radio-group-container {
                display: flex;
                gap: 24px;
                background-color: var(--bg-tertiary);
                padding: 12px 20px;
                border-radius: var(--border-radius-md);
                border: 1px dashed var(--border-color);
                margin-bottom: 20px;
            }
            
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
                <a href="<%= request.getContextPath() %>/receptionist/dashboard">Dashboard</a>
                <a href="<%= request.getContextPath() %>/receptionist/manage-booking" class="active">Quản lý lịch hẹn</a>
                <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-secondary" style="padding: 6px 14px;">Hàng chờ thanh toán</a>
            </div>
        </nav>

        <div class="booking-container">
            <div class="booking-card">
                <h1 style="font-family: var(--font-outfit); font-size: 2.2rem; font-weight: 800; color: var(--accent-navy); text-align: center; margin-bottom: 5px;">
                    📝 Đặt Lịch Khám Tại Quầy
                </h1>
                <p style="text-align: center; color: var(--text-secondary); margin-bottom: 30px;">
                    Đăng ký lịch hẹn trực tiếp cho bệnh nhân đã có tài khoản hoặc khách vãng lai
                </p>

                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger" style="margin-bottom: 25px;">
                        <i class="fas fa-exclamation-triangle" style="margin-right: 8px;"></i>
                        <%= errorMessage %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/receptionist/manage-booking" method="POST" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="create">

                    <!-- Section 1: Patient Information -->
                    <div class="section-title">Khách hàng / Bệnh nhân</div>
                    
                    <div class="form-group">
                        <label class="form-label">Phân loại khách hàng</label>
                        <div class="radio-group-container">
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500; font-size: 0.92rem;">
                                <input type="radio" name="customerType" value="existing" <%= !"walkin".equals(request.getParameter("customerType")) ? "checked" : "" %> onchange="toggleCustomerType('existing')" style="width: 18px; height: 18px; cursor: pointer;">
                                Khách đã có tài khoản
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500; font-size: 0.92rem;">
                                <input type="radio" name="customerType" value="walkin" <%= "walkin".equals(request.getParameter("customerType")) ? "checked" : "" %> onchange="toggleCustomerType('walkin')" style="width: 18px; height: 18px; cursor: pointer;">
                                Khách vãng lai (Chưa có tài khoản)
                            </label>
                        </div>
                    </div>
                    
                    <!-- Existing Customer Panel -->
                    <div id="existingCustomerPanel" class="form-group">
                        <label class="form-label">Chọn Khách Hàng <span style="color: red;">*</span></label>
                        <div style="position: relative;">
                            <input type="text" id="customerSearch" class="form-control" placeholder="🔍 Nhập Tên hoặc SĐT để lọc nhanh danh sách..." style="margin-bottom: 10px;" oninput="filterCustomers()" onfocus="filterCustomers()" autocomplete="off">
                            <div id="customerSuggestions" style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: #ffffff; border: 1px solid var(--border-color); border-radius: 8px; max-height: 250px; overflow-y: auto; z-index: 1000; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); margin-top: -8px;">
                            </div>
                        </div>
                        <select name="customerID" id="customerSelect" class="form-select" style="display: none;">
                            <option value="">-- Chọn khách hàng đã có trong hệ thống --</option>
                            <% if (customers != null) {
                                for (User c : customers) { 
                                    String reqCustId = request.getParameter("customerID");
                                    boolean isSel = reqCustId != null && reqCustId.equals(String.valueOf(c.getUserID()));
                            %>
                                    <option value="<%= c.getUserID() %>" <%= isSel ? "selected" : "" %>>
                                        <%= c.getFullName() %> (SĐT: <%= c.getPhone() != null ? c.getPhone() : "N/A" %>)
                                    </option>
                                <% }
                            } %>
                        </select>
                    </div>

                    <!-- Walk-in Customer Panel -->
                    <div id="walkInCustomerPanel" style="display: none;">
                        <div class="form-group">
                            <label class="form-label">Họ và tên khách vãng lai <span style="color: red;">*</span></label>
                            <input type="text" name="walkInName" id="walkInName" class="form-control" value="<%= request.getParameter("walkInName") != null ? request.getParameter("walkInName") : "" %>" placeholder="Nhập họ và tên bệnh nhân...">
                        </div>
                        <div class="form-grid-2">
                            <div class="form-group">
                                <label class="form-label">Số điện thoại <span style="color: red;">*</span></label>
                                <input type="text" name="walkInPhone" id="walkInPhone" class="form-control" value="<%= request.getParameter("walkInPhone") != null ? request.getParameter("walkInPhone") : "" %>" placeholder="Nhập số điện thoại...">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Email (Không bắt buộc)</label>
                                <input type="email" name="walkInEmail" class="form-control" value="<%= request.getParameter("walkInEmail") != null ? request.getParameter("walkInEmail") : "" %>" placeholder="Nhập địa chỉ email nếu có...">
                            </div>
                        </div>
                    </div>

                    <!-- Section 2: Clinical Information -->
                    <div class="section-title">Thời gian & Bác sĩ chỉ định</div>
                    
                    <div class="form-group">
                        <label class="form-label">Chọn Bác Sĩ Chỉ Định</label>
                        <select name="doctorID" class="form-select">
                            <option value="0">-- Khám tổng quát (Bác sĩ ngẫu nhiên / General Checkup) --</option>
                            <% if (doctors != null) {
                                for (User d : doctors) { 
                                    String reqDocId = request.getParameter("doctorID");
                                    boolean isSel = reqDocId != null && reqDocId.equals(String.valueOf(d.getUserID()));
                            %>
                                    <option value="<%= d.getUserID() %>" <%= isSel ? "selected" : "" %>>
                                        BS. <%= d.getFullName() %>
                                    </option>
                                <% }
                            } %>
                        </select>
                    </div>

                    <div class="form-grid-2">
                        <div class="form-group">
                            <label class="form-label">Ngày Hẹn <span style="color: red;">*</span></label>
                            <input type="date" name="date" class="form-control" required id="appointmentDate" value="<%= request.getParameter("date") != null ? request.getParameter("date") : "" %>">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Giờ Hẹn <span style="color: red;">*</span></label>
                            <select name="time" class="form-select" required>
                                <option value="">-- Chọn giờ hẹn --</option>
                                <option value="08:00">08:00</option>
                                <option value="09:00">09:00</option>
                                <option value="10:00">10:00</option>
                                <option value="11:00">11:00</option>
                                <option value="12:00">12:00</option>
                                <option value="13:00">13:00</option>
                                <option value="14:00">14:00</option>
                                <option value="15:00">15:00</option>
                                <option value="16:00">16:00</option>
                                <option value="17:00">17:00</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ghi Chú Đặt Lịch / Triệu Chứng Ban Đầu</label>
                        <textarea name="notes" class="form-control" placeholder="Mô tả triệu chứng đau nhức hoặc nhu cầu của khách hàng..."><%= request.getParameter("notes") != null ? request.getParameter("notes") : "" %></textarea>
                    </div>

                    <!-- Section 3: Services Selection -->
                    <div class="section-title">Dịch vụ điều trị (Nếu có)</div>
                    <p style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 15px;">
                        Có thể chọn trước các dịch vụ cụ thể hoặc bỏ trống để bác sĩ chỉ định sau khi khám tổng quát.
                    </p>
                    <div class="services-grid">
                        <% if (services != null) {
                            for (Service s : services) { 
                                String[] reqServices = request.getParameterValues("services");
                                boolean hasService = false;
                                if (reqServices != null) {
                                    for (String sId : reqServices) {
                                        if (sId.equals(String.valueOf(s.getServiceID()))) {
                                            hasService = true;
                                            break;
                                        }
                                    }
                                }
                        %>
                                <div class="service-card <%= hasService ? "selected" : "" %>" onclick="toggleServiceCard('s-<%= s.getServiceID() %>', this)">
                                    <input type="checkbox" name="services" value="<%= s.getServiceID() %>" id="s-<%= s.getServiceID() %>" style="display: none;" <%= hasService ? "checked" : "" %>>
                                    <div class="service-card-info">
                                        <div class="service-card-title"><%= s.getServiceName() %></div>
                                        <div class="service-card-price"><%= String.format("%,.0f", s.getPrice()) %> đ</div>
                                    </div>
                                    <div class="service-card-check">
                                        <i>✓</i>
                                    </div>
                                </div>
                            <% }
                        } %>
                    </div>

                    <!-- Action Buttons -->
                    <div style="display: flex; gap: 15px; margin-top: 45px;">
                        <button type="submit" class="btn btn-cta" style="flex: 2; font-size: 1rem; font-weight: 700; padding: 14px;">
                            Xác Nhận Đặt Lịch
                        </button>
                        <a href="<%= request.getContextPath() %>/receptionist/manage-booking" class="btn btn-secondary" style="flex: 1; text-align: center; line-height: 2.3; font-size: 1rem; font-weight: 600;">Quay Lại</a>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Set min date to today
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('appointmentDate').min = today;

            function toggleServiceCard(checkboxId, cardElement) {
                const checkbox = document.getElementById(checkboxId);
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                    if (checkbox.checked) {
                        cardElement.classList.add('active');
                    } else {
                        cardElement.classList.remove('active');
                    }
                }
            }

            // Customer selection search logic
            let allCustomers = [];
            let selectedCustomerID = '';

            window.addEventListener('DOMContentLoaded', () => {
                const select = document.getElementById('customerSelect');
                const searchInput = document.getElementById('customerSearch');
                if (select) {
                    selectedCustomerID = select.value;
                    
                    for (let i = 0; i < select.options.length; i++) {
                        const val = select.options[i].value;
                        const txt = select.options[i].text;
                        if (val !== "") {
                            allCustomers.push({
                                value: val,
                                text: txt
                            });
                        }
                    }
                    
                    // If a customer is pre-selected (e.g. after a form reload/validation fail)
                    if (selectedCustomerID !== "") {
                        const selectedCust = allCustomers.find(c => c.value === selectedCustomerID);
                        if (selectedCust && searchInput) {
                            searchInput.value = selectedCust.text;
                        }
                    }
                }
                const checkedRadio = document.querySelector('input[name="customerType"]:checked');
                if (checkedRadio) {
                    toggleCustomerType(checkedRadio.value);
                } else {
                    toggleCustomerType('existing');
                }
            });

            // Close suggestions dropdown when clicking outside
            document.addEventListener('click', (e) => {
                const searchInput = document.getElementById('customerSearch');
                const suggestions = document.getElementById('customerSuggestions');
                if (searchInput && suggestions && e.target !== searchInput && !suggestions.contains(e.target)) {
                    suggestions.style.display = 'none';
                }
            });

            function removeDiacritics(str) {
                if (!str) return '';
                return str.normalize("NFD")
                          .replace(/[\u0300-\u036f]/g, "")
                          .replace(/đ/g, "d")
                          .replace(/Đ/g, "D");
            }

            function filterCustomers() {
                const input = document.getElementById('customerSearch');
                const filter = removeDiacritics(input.value.toLowerCase().trim());
                const select = document.getElementById('customerSelect');
                const suggestions = document.getElementById('customerSuggestions');
                
                suggestions.innerHTML = '';
                
                // If user clears the input field, clear the selection in select element
                if (filter === "") {
                    selectedCustomerID = "";
                    select.value = "";
                }
                
                const matches = allCustomers.filter(c => {
                    return removeDiacritics(c.text.toLowerCase()).indexOf(filter) > -1;
                });
                
                if (matches.length === 0) {
                    suggestions.innerHTML = '<div style="padding: 12px; color: var(--text-muted); font-style: italic; font-size: 0.9rem;">Không tìm thấy khách hàng nào</div>';
                    suggestions.style.display = 'block';
                    return;
                }
                
                matches.forEach(c => {
                    const item = document.createElement('div');
                    item.style.padding = '10px 16px';
                    item.style.cursor = 'pointer';
                    item.style.borderBottom = '1px solid #f1f5f9';
                    item.className = 'suggestion-item';
                    item.textContent = c.text;
                    
                    if (c.value === selectedCustomerID) {
                        item.style.background = 'rgba(20, 184, 166, 0.08)';
                        item.style.fontWeight = 'bold';
                    }
                    
                    item.addEventListener('click', () => {
                        selectedCustomerID = c.value;
                        select.value = c.value;
                        input.value = c.text;
                        suggestions.style.display = 'none';
                    });
                    
                    suggestions.appendChild(item);
                });
                
                suggestions.style.display = 'block';
            }

            // Toggle logic for existing vs walkin
            function toggleCustomerType(type) {
                const existingPanel = document.getElementById('existingCustomerPanel');
                const walkinPanel = document.getElementById('walkInCustomerPanel');
                const customerSelect = document.getElementById('customerSelect');
                const customerSearch = document.getElementById('customerSearch');
                const walkInName = document.getElementById('walkInName');
                const walkInPhone = document.getElementById('walkInPhone');
                
                if (type === 'existing') {
                    existingPanel.style.display = 'block';
                    walkinPanel.style.display = 'none';
                    customerSearch.required = true;
                    customerSelect.required = false;
                    walkInName.required = false;
                    walkInPhone.required = false;
                } else {
                    existingPanel.style.display = 'none';
                    walkinPanel.style.display = 'block';
                    customerSearch.required = false;
                    customerSelect.required = false;
                    walkInName.required = true;
                    walkInPhone.required = true;
                }
            }

            // Form validation (Gmail & Phone requirements)
            function validateForm() {
                const customerType = document.querySelector('input[name="customerType"]:checked').value;
                if (customerType === 'walkin') {
                    const phone = document.getElementById('walkInPhone').value.trim();
                    const email = document.getElementsByName('walkInEmail')[0].value.trim();
                    
                    // Validate SĐT: exact 10 digits starting with 03, 08, 09
                    const phoneRegex = /^0(3|8|9)\d{8}$/;
                    if (!phoneRegex.test(phone)) {
                        alert('Số điện thoại không hợp lệ!\nYêu cầu: Đúng 10 chữ số và bắt đầu bằng đầu số 03, 08 hoặc 09.');
                        document.getElementById('walkInPhone').focus();
                        return false;
                    }
                    
                    // Validate Email: if filled, must be gmail.com
                    if (email !== '') {
                        const emailRegex = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
                        if (!emailRegex.test(email)) {
                            alert('Địa chỉ Email không hợp lệ!\nYêu cầu: Chỉ chấp nhận tài khoản Gmail kết thúc bằng @gmail.com (ví dụ: smilecare@gmail.com).');
                            document.getElementsByName('walkInEmail')[0].focus();
                            return false;
                        }
                    }
                } else {
                    const select = document.getElementById('customerSelect');
                    if (!select || select.value === "") {
                        alert('Vui lòng chọn một khách hàng hợp lệ từ danh sách gợi ý!');
                        document.getElementById('customerSearch').focus();
                        return false;
                    }
                }
                return true;
            }
        </script>
    </body>
</html>
