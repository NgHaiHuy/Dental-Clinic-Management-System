package controller.receptionist;

import dal.InvoiceDAO;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Invoice;
import model.InvoiceDetail;
import model.MedicalRecord;
import model.Payment;
import model.Service;
import model.User;

/**
 * Controller for receptionist/billing staff to process payments and invoicing.
 */
@WebServlet(name = "BillingController", urlPatterns = {"/receptionist/billing"})
public class BillingController extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "checkout":
                showCheckoutPage(request, response);
                break;
            case "invoice":
                showInvoicePrintPage(request, response);
                break;
            case "list":
            default:
                showBillingQueue(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("pay".equals(action)) {
            processPayment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/receptionist/billing");
        }
    }

    private void showBillingQueue(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<MedicalRecord> billingQueue = invoiceDAO.getBillingQueue();
        
        // Populate doctor and customer names helper map/list if needed, 
        // but we can query them dynamically or pass them in a custom payload.
        // Let's attach doctor/customer names to each billing queue item.
        // Since MedicalRecord doesn't have custom properties, we can retrieve them by query.
        // Let's pack them in a structured list to avoid database calls inside JSP.
        // We will pass the DAO itself or pre-query the names:
        List<BillingQueueItem> items = new ArrayList<>();
        for (MedicalRecord r : billingQueue) {
            String[] names = invoiceDAO.getDoctorAndCustomerNames(r.getRecordID());
            items.add(new BillingQueueItem(r, names[0], names[1]));
        }

        request.setAttribute("billingQueue", items);
        request.getRequestDispatcher("/receptionist/billing.jsp").forward(request, response);
    }

    private void showCheckoutPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int recordID = Integer.parseInt(request.getParameter("recordID"));
            MedicalRecord record = invoiceDAO.getBillingRecordDetails(recordID);
            
            if (record == null) {
                request.getSession().setAttribute("errorMessage", "Medical record not found.");
                response.sendRedirect(request.getContextPath() + "/receptionist/billing");
                return;
            }

            String[] names = invoiceDAO.getDoctorAndCustomerNames(recordID);
            List<Service> services = invoiceDAO.getServicesByAppointment(record.getAppointmentID());
            List<InvoiceDetail> medicines = invoiceDAO.getPrescribedMedicines(recordID);

            double totalAmount = 0;
            for (Service s : services) {
                totalAmount += s.getPrice();
            }
            for (InvoiceDetail m : medicines) {
                totalAmount += m.getPrice() * m.getQuantity();
            }

            request.setAttribute("record", record);
            request.setAttribute("doctorName", names[0]);
            request.setAttribute("customerName", names[1]);
            request.setAttribute("services", services);
            request.setAttribute("medicines", medicines);
            request.setAttribute("totalAmount", totalAmount);

            request.getRequestDispatcher("/receptionist/billing-checkout.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid record ID.");
            response.sendRedirect(request.getContextPath() + "/receptionist/billing");
        }
    }

    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String recordIDStr = request.getParameter("recordID");
        String paymentMethod = request.getParameter("paymentMethod");
        String totalAmountStr = request.getParameter("totalAmount");

        // Fetch staffID from session if logged in, or default to 1 (Admin/Staff)
        int staffID = 1; 
        User user = (User) request.getSession().getAttribute("user");
        if (user != null) {
            staffID = user.getUserID();
        }

        if (recordIDStr == null || paymentMethod == null || totalAmountStr == null) {
            request.getSession().setAttribute("errorMessage", "Missing parameters for billing.");
            response.sendRedirect(request.getContextPath() + "/receptionist/billing");
            return;
        }

        try {
            int recordID = Integer.parseInt(recordIDStr);
            double totalAmount = Double.parseDouble(totalAmountStr);

            MedicalRecord record = invoiceDAO.getBillingRecordDetails(recordID);
            if (record == null) {
                request.getSession().setAttribute("errorMessage", "Invalid medical record.");
                response.sendRedirect(request.getContextPath() + "/receptionist/billing");
                return;
            }

            // Create Invoice
            Invoice invoice = new Invoice();
            invoice.setRecordID(recordID);
            invoice.setStaffID(staffID);
            invoice.setTotalAmount(totalAmount);
            invoice.setStatus("Paid");

            // Re-fetch services and medicines to insert details securely
            List<Service> services = invoiceDAO.getServicesByAppointment(record.getAppointmentID());

            List<InvoiceDetail> details = new ArrayList<>();
            for (Service s : services) {
                InvoiceDetail d = new InvoiceDetail();
                d.setItemType("SERVICE");
                d.setItemID(s.getServiceID());
                d.setQuantity(1);
                d.setPrice(s.getPrice());
                details.add(d);
            }
            
            // Get selected medicines parameters
            String[] selectedMedsArr = request.getParameterValues("selectedMedicines");
            if (selectedMedsArr != null) {
                for (String medIDStr : selectedMedsArr) {
                    int medID = Integer.parseInt(medIDStr);
                    String qtyStr = request.getParameter("qty_" + medID);
                    String priceStr = request.getParameter("price_" + medID);
                    if (qtyStr != null && priceStr != null) {
                        int qty = Integer.parseInt(qtyStr);
                        double price = Double.parseDouble(priceStr);
                        if (qty > 0) {
                            InvoiceDetail d = new InvoiceDetail();
                            d.setItemType("MEDICINE");
                            d.setItemID(medID);
                            d.setQuantity(qty);
                            d.setPrice(price);
                            details.add(d);
                        }
                    }
                }
            }

            // Create Payment
            Payment payment = new Payment();
            payment.setPaymentMethod(paymentMethod);
            payment.setAmountPaid(totalAmount);
            payment.setStatus("Completed");

            boolean success = invoiceDAO.processBilling(invoice, details, payment);
            if (success) {
                request.getSession().setAttribute("successMessage", "Thanh toán thành công!");
                response.sendRedirect(request.getContextPath() + "/receptionist/billing?action=invoice&recordID=" + recordID);
            } else {
                request.getSession().setAttribute("errorMessage", "Thanh toán thất bại. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/receptionist/billing?action=checkout&recordID=" + recordID);
            }

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid billing values.");
            response.sendRedirect(request.getContextPath() + "/receptionist/billing");
        }
    }

    private void showInvoicePrintPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int recordID = Integer.parseInt(request.getParameter("recordID"));
            Invoice invoice = invoiceDAO.getInvoiceByRecordID(recordID);
            
            if (invoice == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy hóa đơn cho ca khám này.");
                response.sendRedirect(request.getContextPath() + "/receptionist/billing");
                return;
            }

            String[] names = invoiceDAO.getDoctorAndCustomerNames(recordID);
            List<InvoiceDetail> rawDetails = invoiceDAO.getInvoiceDetails(invoice.getInvoiceID());

            // Populate item names for display
            // We can query names from services/medicines tables
            List<InvoiceDetail> detailsWithNames = new ArrayList<>();
            dal.ServiceDAO sDAO = new dal.ServiceDAO();
            dal.MedicineDAO mDAO = new dal.MedicineDAO();

            for (InvoiceDetail d : rawDetails) {
                if ("SERVICE".equals(d.getItemType())) {
                    Service s = sDAO.getServiceByID(d.getItemID());
                    if (s != null) {
                        d.setItemName(s.getServiceName());
                    }
                } else if ("MEDICINE".equals(d.getItemType())) {
                    model.Medicine m = mDAO.getMedicineByID(d.getItemID());
                    if (m != null) {
                        d.setItemName(m.getMedicineName() + " (" + m.getUnit() + ")");
                    }
                }
                detailsWithNames.add(d);
            }

            request.setAttribute("invoice", invoice);
            request.setAttribute("invoiceDetails", detailsWithNames);
            request.setAttribute("doctorName", names[0]);
            request.setAttribute("customerName", names[1]);

            request.getRequestDispatcher("/receptionist/invoice-print.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Mã hóa đơn không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/receptionist/billing");
        }
    }

    /**
     * Inner helper class to represent billing queue items with names.
     */
    public static class BillingQueueItem {
        private final MedicalRecord record;
        private final String doctorName;
        private final String customerName;

        public BillingQueueItem(MedicalRecord record, String doctorName, String customerName) {
            this.record = record;
            this.doctorName = doctorName;
            this.customerName = customerName;
        }

        public MedicalRecord getRecord() {
            return record;
        }

        public String getDoctorName() {
            return doctorName;
        }

        public String getCustomerName() {
            return customerName;
        }
    }
}
