<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, model.Invoice, model.InvoiceDetail, java.text.SimpleDateFormat"%>
<%
    Invoice invoice = (Invoice) request.getAttribute("invoice");
    List<InvoiceDetail> details = (List<InvoiceDetail>) request.getAttribute("invoiceDetails");
    String doctorName = (String) request.getAttribute("doctorName");
    String customerName = (String) request.getAttribute("customerName");
    String paymentMethod = (String) request.getAttribute("paymentMethod");

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hóa đơn thanh toán #<%= invoice.getInvoiceID() %> - Dental Clinic</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Inter', sans-serif;
            }

            body {
                background-color: #f1f5f9;
                color: #1e293b;
                padding: 40px 20px;
                display: flex;
                flex-direction: column;
                align-items: center;
                min-height: 100vh;
            }

            .invoice-wrapper {
                background-color: #ffffff;
                width: 100%;
                max-width: 800px;
                padding: 50px 60px;
                border-radius: 8px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
                border: 1px solid #e2e8f0;
                position: relative;
            }

            /* Header Section */
            .invoice-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                border-bottom: 2px solid #e2e8f0;
                padding-bottom: 30px;
                margin-bottom: 35px;
            }

            .clinic-info h2 {
                font-size: 24px;
                font-weight: 700;
                color: #0f172a;
                text-transform: uppercase;
                margin-bottom: 5px;
            }

            .clinic-info p {
                font-size: 13px;
                color: #64748b;
                line-height: 1.5;
            }

            .invoice-meta {
                text-align: right;
            }

            .invoice-meta h1 {
                font-size: 28px;
                font-weight: 800;
                color: #0ea5e9;
                margin-bottom: 5px;
            }

            .invoice-meta p {
                font-size: 14px;
                color: #475569;
                font-weight: 500;
            }

            /* Customer & Details Panel */
            .details-panel {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
                margin-bottom: 40px;
            }

            .panel-section h3 {
                font-size: 13px;
                font-weight: 700;
                color: #64748b;
                text-transform: uppercase;
                margin-bottom: 12px;
                border-bottom: 1px solid #f1f5f9;
                padding-bottom: 5px;
            }

            .panel-section p {
                font-size: 14px;
                color: #1e293b;
                line-height: 1.6;
                margin-bottom: 4px;
            }

            .panel-section p strong {
                color: #0f172a;
            }

            /* Items Table */
            .items-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 40px;
            }

            .items-table th {
                background-color: #f8fafc;
                border-top: 1px solid #e2e8f0;
                border-bottom: 2px solid #e2e8f0;
                padding: 12px 16px;
                font-size: 12px;
                font-weight: 700;
                color: #475569;
                text-transform: uppercase;
                text-align: left;
            }

            .items-table td {
                padding: 16px;
                border-bottom: 1px solid #e2e8f0;
                font-size: 14px;
                color: #334155;
            }

            .text-right {
                text-align: right !important;
            }

            .text-center {
                text-align: center !important;
            }

            .total-row td {
                border-bottom: none;
                padding-top: 20px;
                font-size: 15px;
            }

            .grand-total {
                font-size: 18px;
                font-weight: 700;
                color: #0f172a;
            }

            /* Footer Signature */
            .signature-section {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 40px;
                margin-top: 50px;
                text-align: center;
            }

            .sig-box {
                display: flex;
                flex-direction: column;
                align-items: center;
            }

            .sig-title {
                font-size: 13px;
                font-weight: 600;
                color: #475569;
                margin-bottom: 80px;
            }

            .sig-line {
                width: 180px;
                border-bottom: 1px dashed #cbd5e1;
                margin-bottom: 8px;
            }

            .sig-name {
                font-size: 13px;
                color: #64748b;
            }

            /* Print & Control Buttons */
            .control-buttons {
                margin-top: 30px;
                display: flex;
                gap: 15px;
                justify-content: center;
                width: 100%;
                max-width: 800px;
            }

            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 24px;
                font-weight: 600;
                font-size: 14px;
                border-radius: 6px;
                border: none;
                cursor: pointer;
                transition: all 0.2s;
                text-decoration: none;
                gap: 8px;
            }

            .btn-print {
                background-color: #0ea5e9;
                color: #ffffff;
            }

            .btn-print:hover {
                background-color: #0284c7;
            }

            .btn-back {
                background-color: #64748b;
                color: #ffffff;
            }

            .btn-back:hover {
                background-color: #475569;
            }

            /* Print Stylesheet Overrides */
            @media print {
                body {
                    background-color: #ffffff;
                    padding: 0;
                }
                .invoice-wrapper {
                    box-shadow: none;
                    border: none;
                    padding: 0;
                    max-width: 100%;
                }
                .control-buttons {
                    display: none;
                }
            }
        </style>
    </head>
    <body>
        <div class="invoice-wrapper">
            <!-- Header -->
            <div class="invoice-header">
                <div class="clinic-info">
                    <h2>Nha Khoa Dental Clinic</h2>
                    <p>Địa chỉ: 123 Cầu Giấy, Hà Nội</p>
                    <p>Điện thoại: 0357912161 | Email: contact@dentalclinic.vn</p>
                </div>
                <div class="invoice-meta">
                    <h1>HÓA ĐƠN</h1>
                    <p>Số hóa đơn: <strong>#<%= invoice.getInvoiceID() %></strong></p>
                    <p>Ngày lập: <%= sdf.format(invoice.getCreatedAt()) %></p>
                </div>
            </div>

            <!-- Details -->
            <div class="details-panel">
                <div class="panel-section">
                    <h3>Khách hàng / Bệnh nhân</h3>
                    <p>Họ và tên: <strong><%= customerName %></strong></p>
                    <p>Đối tượng: Khách hàng vãng lai / Bảo hiểm</p>
                </div>
                <div class="panel-section">
                    <h3>Thông tin ca khám</h3>
                    <p>Bác sĩ điều trị: <strong><%= doctorName %></strong></p>
                    <p>Mã hồ sơ khám: #<%= invoice.getRecordID() %></p>
                    <p>Hình thức: <strong><%= "Cash".equals(paymentMethod) ? "💵 Tiền mặt" : ("Bank Transfer".equals(paymentMethod) ? "🏦 Chuyển khoản" : ("Credit Card".equals(paymentMethod) ? "💳 Thẻ tín dụng" : paymentMethod)) %></strong></p>
                </div>
            </div>

            <!-- Items Table -->
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Tên Dịch vụ / Thuốc</th>
                        <th style="width: 100px;" class="text-center">Số lượng</th>
                        <th style="width: 140px;" class="text-right">Đơn Giá</th>
                        <th style="width: 160px;" class="text-right">Thành Tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int index = 1;
                        for (InvoiceDetail d : details) { 
                    %>
                        <tr>
                            <td>
                                <%= d.getItemName() != null ? d.getItemName() : ("Sản phẩm #" + d.getItemID()) %>
                            </td>
                            <td class="text-center"><%= d.getQuantity() %></td>
                            <td class="text-right"><%= String.format("%,.0f", d.getPrice()) %> đ</td>
                            <td class="text-right" style="font-weight: 500;"><%= String.format("%,.0f", d.getPrice() * d.getQuantity()) %> đ</td>
                        </tr>
                    <% } %>
                    
                    <!-- Grand Total -->
                    <tr class="total-row">
                        <td colspan="2"></td>
                        <td class="text-right" style="font-weight: 600;">Tổng cộng:</td>
                        <td class="text-right grand-total"><%= String.format("%,.0f", invoice.getTotalAmount()) %> đ</td>
                    </tr>
                    <tr class="total-row" style="padding-top: 5px;">
                        <td colspan="2"></td>
                        <td class="text-right" style="color: #64748b; font-size: 13px;">Trạng thái:</td>
                        <td class="text-right" style="color: #10b981; font-weight: 600; font-size: 13px;">ĐÃ THANH TOÁN</td>
                    </tr>
                </tbody>
            </table>

            <!-- Signature Section -->
            <div class="signature-section">
                <div class="sig-box">
                    <span class="sig-title">Khách hàng / Bệnh nhân</span>
                    <div class="sig-line"></div>
                    <span class="sig-name">(Ký và ghi rõ họ tên)</span>
                </div>
                <div class="sig-box">
                    <span class="sig-title">Người lập hóa đơn</span>
                    <div class="sig-line"></div>
                    <span class="sig-name">Nhân viên thu ngân</span>
                </div>
            </div>
        </div>

        <!-- Controls -->
        <div class="control-buttons">
            <button onclick="window.print();" class="btn btn-print">
                <svg style="width: 18px; height: 18px; fill: currentColor;" viewBox="0 0 24 24">
                    <path d="M19 8H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3zm-3 11H8v-5h8v5zm3-7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm-1-9H6v4h12V3z"/>
                </svg>
                In Hóa Đơn (Print)
            </button>
            <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-back">
                Quay lại Hàng chờ
            </a>
        </div>
    </body>
</html>
