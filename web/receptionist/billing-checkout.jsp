<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.MedicalRecord, model.Service, model.InvoiceDetail, java.text.SimpleDateFormat"%>
<%
    MedicalRecord record = (MedicalRecord) request.getAttribute("record");
    String doctorName = (String) request.getAttribute("doctorName");
    String customerName = (String) request.getAttribute("customerName");
    List<Service> services = (List<Service>) request.getAttribute("services");
    List<InvoiceDetail> medicines = (List<InvoiceDetail>) request.getAttribute("medicines");
    Double totalAmount = (Double) request.getAttribute("totalAmount");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chi tiết thanh toán bệnh án #<%= record.getRecordID() %> - Dental Clinic</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
        <style>
            .info-panel {
                background-color: var(--bg-tertiary);
                border: 1px solid var(--border-color);
                border-radius: var(--border-radius-md);
                padding: 20px;
                margin-bottom: 25px;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
            }
            .info-item {
                display: flex;
                flex-direction: column;
            }
            .info-label {
                font-size: 0.8rem;
                color: var(--text-secondary);
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 4px;
            }
            .info-value {
                font-weight: 600;
                color: var(--text-primary);
            }
            .checkout-total-box {
                background: linear-gradient(135deg, rgba(14, 165, 233, 0.15) 0%, rgba(99, 102, 241, 0.15) 100%);
                border: 1px solid rgba(14, 165, 233, 0.3);
                border-radius: var(--border-radius-md);
                padding: 25px;
                text-align: center;
                margin-bottom: 25px;
            }
            .checkout-total-label {
                font-family: var(--font-outfit);
                font-size: 1rem;
                color: var(--text-secondary);
                text-transform: uppercase;
                margin-bottom: 8px;
            }
            .checkout-total-value {
                font-family: var(--font-outfit);
                font-size: 2.2rem;
                font-weight: 800;
                color: var(--accent-blue);
            }
        </style>
    </head>
    <body>
        <div class="dashboard-container">
            <!-- Header Banner -->
            <header class="header-banner">
                <div class="header-title-section">
                    <h1>CHI TIẾT THANH TOÁN</h1>
                    <p>Hóa đơn tạm tính cho ca khám bệnh án #<%= record.getRecordID() %></p>
                </div>
                <div class="header-actions">
                    <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-secondary">
                        Quay lại hàng chờ
                    </a>
                </div>
            </header>

            <!-- Info Panel -->
            <div class="info-panel">
                <div class="info-item">
                    <span class="info-label">Bệnh Nhân (Khách Hàng)</span>
                    <span class="info-value"><%= customerName %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Bác Sĩ Thực Hiện</span>
                    <span class="info-value"><%= doctorName %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Thời Gian Hoàn Thành Khám</span>
                    <span class="info-value"><%= sdf.format(record.getCreatedAt()) %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Chẩn Đoán Lâm Sàng</span>
                    <span class="info-value"><%= record.getDiagnosis() %></span>
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/receptionist/billing" method="POST">
                <input type="hidden" name="action" value="pay">
                <input type="hidden" name="recordID" value="<%= record.getRecordID() %>">
                <input type="hidden" name="totalAmount" id="formTotalAmount" value="<%= totalAmount %>">

                <div class="dashboard-grid">
                    <!-- Left Pane: Services and Medicines lists -->
                    <main class="glass-card">
                    <!-- Services Sub-Table -->
                    <div class="card-title" style="font-size: 1.25rem; margin-bottom: 15px; color: var(--accent-blue);">
                        1. Dịch vụ nha khoa thực hiện
                    </div>
                    <div class="table-responsive" style="margin-bottom: 30px;">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Tên Dịch Vụ</th>
                                    <th>Mô Tả</th>
                                    <th style="width: 150px; text-align: right;">Đơn Giá</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (services == null || services.isEmpty()) { %>
                                    <tr>
                                        <td colspan="3" style="text-align: center; color: var(--text-secondary); padding: 15px 0;">
                                            Không có dịch vụ nào được chỉ định.
                                        </td>
                                    </tr>
                                <% } else {
                                    for (Service s : services) { %>
                                        <tr>
                                            <td class="service-name-cell"><%= s.getServiceName() %></td>
                                            <td style="color: var(--text-secondary); font-size: 0.85rem;"><%= s.getDescription() != null ? s.getDescription() : "N/A" %></td>
                                            <td class="service-price-cell" style="text-align: right;"><%= String.format("%,.0f", s.getPrice()) %> đ</td>
                                        </tr>
                                    <% }
                                } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Medicines Sub-Table -->
                    <div class="card-title" style="font-size: 1.25rem; margin-bottom: 15px; color: var(--accent-purple);">
                        2. Đơn thuốc đi kèm (Có thể chọn mua một phần hoặc toàn bộ)
                    </div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">Mua</th>
                                    <th>Tên Thuốc / Quy cách</th>
                                    <th style="width: 140px; text-align: center;">Số lượng mua</th>
                                    <th style="width: 120px; text-align: right;">Đơn Giá</th>
                                    <th style="width: 150px; text-align: right;">Thành Tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (medicines == null || medicines.isEmpty()) { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-secondary); padding: 15px 0;">
                                            Bác sĩ không kê đơn thuốc cho ca khám này.
                                        </td>
                                    </tr>
                                <% } else {
                                    for (InvoiceDetail m : medicines) { %>
                                        <tr>
                                            <td style="text-align: center;">
                                                <input type="checkbox" name="selectedMedicines" value="<%= m.getItemID() %>" checked onchange="calculateTotal()" style="width: 18px; height: 18px; cursor: pointer;">
                                            </td>
                                            <td class="service-name-cell">
                                                <%= m.getItemName() %>
                                                <input type="hidden" name="price_<%= m.getItemID() %>" value="<%= m.getPrice() %>">
                                                <% if (m.getStockQuantity() < m.getQuantity()) { %>
                                                    <span style="display: block; font-size: 0.75rem; color: #ef4444; font-weight: 600; margin-top: 3px;">
                                                        ⚠️ Thiếu hàng (Kho còn: <%= m.getStockQuantity() %>)
                                                    </span>
                                                <% } else { %>
                                                    <span style="display: block; font-size: 0.75rem; color: #10b981; font-weight: 500; margin-top: 3px;">
                                                        ✓ Đủ hàng (Kho còn: <%= m.getStockQuantity() %>)
                                                    </span>
                                                <% } %>
                                            </td>
                                            <td style="text-align: center;">
                                                <input type="number" name="qty_<%= m.getItemID() %>" id="qty_<%= m.getItemID() %>" value="<%= m.getQuantity() %>" min="1" max="<%= m.getQuantity() %>" oninput="calculateTotal()" onchange="calculateTotal()" class="form-control" style="width: 75px; display: inline-block; padding: 4px 8px; text-align: center;">
                                                <span style="font-size: 0.75rem; color: var(--text-secondary); display: block; margin-top: 2px;">Tối đa: <%= m.getQuantity() %></span>
                                            </td>
                                            <td style="color: var(--text-secondary); text-align: right;">
                                                <span id="raw_price_<%= m.getItemID() %>" style="display:none;"><%= m.getPrice() %></span>
                                                <%= String.format("%,.0f", m.getPrice()) %> đ
                                            </td>
                                            <td class="service-price-cell" style="text-align: right;">
                                                <span id="subtotal_<%= m.getItemID() %>" class="med-subtotal"><%= String.format("%,.0f", m.getPrice() * m.getQuantity()) %></span> đ
                                            </td>
                                        </tr>
                                    <% }
                                } %>
                            </tbody>
                        </table>
                    </div>
                </main>

                <!-- Right Pane: Checkout Form -->
                <aside class="glass-card">
                    <div class="checkout-total-box">
                        <div class="checkout-total-label">Tổng cộng cần thanh toán</div>
                        <div class="checkout-total-value" id="displayTotalAmount">
                            <%= String.format("%,.0f", totalAmount) %> đ
                        </div>
                    </div>

                        <div class="form-group">
                            <label class="form-label">Phương Thức Thanh Toán</label>
                            <select name="paymentMethod" id="paymentMethodSelect" class="form-select" required onchange="togglePaymentQR()">
                                <option value="Cash" selected>💵 Tiền mặt (Cash)</option>
                                <option value="Bank Transfer">🏦 Chuyển khoản ngân hàng (Bank Transfer)</option>
                                <option value="Credit Card">💳 Thẻ tín dụng (Credit Card)</option>
                            </select>
                        </div>

                        <!-- QR Code box for Bank Transfer -->
                        <div id="bankTransferQRBox" style="display: none; border: 1px solid var(--border-color); border-radius: 8px; padding: 15px; background-color: #fafafa; margin-top: 15px; text-align: center;">
                            <div style="font-weight: 600; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 10px;">Quét mã QR để chuyển khoản</div>
                            <img id="qrCodeImg" src="" style="max-width: 160px; height: auto; border: 1px solid #ddd; background: white; padding: 5px; border-radius: 4px; display: inline-block;">
                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 8px; line-height: 1.4;">
                                Techcombank - VU QUANG HUY<br>
                                Số TK: <strong>882668686688</strong><br>
                                Tổng tiền: <strong id="qrTotalAmount">0</strong> đ
                            </div>
                        </div>

                        <div class="form-group" style="margin-top: 25px;">
                            <label class="form-label" style="color: var(--text-secondary); font-size: 0.8rem;">Nhân Viên Thực Hiện</label>
                            <input type="text" class="form-control" style="background-color: transparent; border: none; padding-left: 0; font-weight: 600;" value="Lễ tân thu ngân chính" disabled>
                        </div>

                        <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 30px;">
                            <svg style="width: 20px; height: 20px; fill: currentColor; margin-right: 5px;" viewBox="0 0 24 24">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                            </svg>
                            Xác nhận Thanh toán & In hóa đơn
                        </button>
                </aside>
            </div>
        </form>
        </div>

        <script>
            // Pre-calculated services sum
            const servicesTotal = <%= services != null ? services.stream().mapToDouble(Service::getPrice).sum() : 0 %>;

            function calculateTotal() {
                let total = servicesTotal;
                
                const checkboxes = document.querySelectorAll('input[name="selectedMedicines"]');
                checkboxes.forEach(cb => {
                    const medId = cb.value;
                    const qtyInput = document.getElementById('qty_' + medId);
                    const rawPrice = parseFloat(document.getElementById('raw_price_' + medId).innerText);
                    const subtotalSpan = document.getElementById('subtotal_' + medId);
                    
                    let qty = parseInt(qtyInput.value) || 0;
                    const maxQty = parseInt(qtyInput.max);
                    
                    if (qty < 0) qty = 0;
                    if (qty > maxQty) {
                        qty = maxQty;
                        qtyInput.value = maxQty;
                    }
                    
                    const subtotal = qty * rawPrice;
                    subtotalSpan.innerText = formatNumber(subtotal);
                    
                    if (cb.checked) {
                        total += subtotal;
                        qtyInput.disabled = false;
                    } else {
                        qtyInput.disabled = true;
                    }
                });
                
                // Update text display and form input
                document.getElementById('displayTotalAmount').innerText = formatNumber(total) + " đ";
                document.getElementById('formTotalAmount').value = total;
                
                // Keep bank transfer QR updated if active
                togglePaymentQR();
            }

            function togglePaymentQR() {
                const methodSelect = document.getElementById('paymentMethodSelect');
                if (!methodSelect) return;
                const method = methodSelect.value;
                const qrBox = document.getElementById('bankTransferQRBox');
                const total = document.getElementById('formTotalAmount').value;
                
                if (method === 'Bank Transfer') {
                    const qrImg = document.getElementById('qrCodeImg');
                    const recordID = '<%= record.getRecordID() %>';
                    qrImg.src = "https://img.vietqr.io/image/TCB-882668686688-compact.png?amount=" + total + "&addInfo=Thanh%20Toan%20Record%20" + recordID;
                    document.getElementById('qrTotalAmount').innerText = formatNumber(parseFloat(total));
                    qrBox.style.display = 'block';
                } else {
                    qrBox.style.display = 'none';
                }
            }

            function formatNumber(num) {
                return num.toLocaleString('vi-VN');
            }

            // Run initial check
            window.addEventListener('DOMContentLoaded', calculateTotal);
        </script>
    </body>
</html>
