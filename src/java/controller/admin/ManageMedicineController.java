package controller.admin;

import dal.MedicineDAO;
import dal.MedicalSupplyDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Medicine;
import model.MedicalSupply;

/**
 * Admin quản lý kho thuốc và vật tư y tế (CRUD).
 * URL: /admin/manage-medicines
 *
 * Tham số tab=medicine → quản lý thuốc
 * Tham số tab=supply   → quản lý vật tư y tế
 *
 * GET  action=list   → hiển thị danh sách
 * GET  action=edit   → form sửa
 * GET  action=delete → xóa
 * POST action=add    → thêm mới
 * POST action=update → cập nhật
 */
@WebServlet(name = "ManageMedicineController", urlPatterns = {"/admin/manage-medicines"})
public class ManageMedicineController extends HttpServlet {

    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final MedicalSupplyDAO supplyDAO = new MedicalSupplyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "medicine";
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "delete":
                handleDelete(request, response, tab);
                break;
            case "edit":
                handleShowEditForm(request, response, tab);
                break;
            case "list":
            default:
                handleList(request, response, tab);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "medicine";
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                handleAdd(request, response, tab);
                break;
            case "update":
                handleUpdate(request, response, tab);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=" + tab);
                break;
        }
    }

    /** Hiển thị danh sách thuốc hoặc vật tư tùy tab, hỗ trợ tìm kiếm theo tên. */
    private void handleList(HttpServletRequest request, HttpServletResponse response, String tab)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("search");

        if ("supply".equals(tab)) {
            List<MedicalSupply> supplies;
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                supplies = supplyDAO.searchSuppliesByName(searchQuery.trim());
                request.setAttribute("searchQuery", searchQuery);
            } else {
                supplies = supplyDAO.getAllSupplies();
            }
            request.setAttribute("supplies", supplies);
        } else {
            List<Medicine> medicines;
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                medicines = medicineDAO.searchMedicinesByName(searchQuery.trim());
                request.setAttribute("searchQuery", searchQuery);
            } else {
                medicines = medicineDAO.getAllMedicines();
            }
            request.setAttribute("medicines", medicines);
        }

        request.setAttribute("activeTab", tab);
        request.getRequestDispatcher("/admin/manage-medicines.jsp").forward(request, response);
    }

    /** Lấy thông tin mục cần sửa theo ID và đặt vào request để JSP hiển thị form. */
    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response, String tab)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            if ("supply".equals(tab)) {
                MedicalSupply supply = supplyDAO.getSupplyByID(id);
                if (supply != null) {
                    request.setAttribute("supplyToEdit", supply);
                }
            } else {
                Medicine medicine = medicineDAO.getMedicineByID(id);
                if (medicine != null) {
                    request.setAttribute("medicineToEdit", medicine);
                }
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid ID format.");
        }
        handleList(request, response, tab);
    }

    /** Xóa thuốc/vật tư: nếu có ràng buộc thì vô hiệu hóa (soft delete). */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, String tab)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success;
            if ("supply".equals(tab)) {
                success = supplyDAO.deleteSupply(id);
            } else {
                success = medicineDAO.deleteMedicine(id);
            }

            if (!success) {
                request.getSession().setAttribute("errorMessage", "Cannot delete or deactivate the item.");
            } else {
                request.getSession().setAttribute("successMessage", "Item removed successfully.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid ID.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=" + tab);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, String tab)               // Thêm thuốc mới
            throws IOException, ServletException {
        if ("supply".equals(tab)) {
            String name = request.getParameter("supplyName");
            String unit = request.getParameter("unit");
            String quantityStr = request.getParameter("quantity");
            String minQuantityStr = request.getParameter("minQuantity");
            String priceStr = request.getParameter("unitPrice");
            String supplier = request.getParameter("supplier");

            if (name == null || name.trim().isEmpty() || unit == null || unit.trim().isEmpty() ||
                    quantityStr == null || priceStr == null) {
                request.setAttribute("errorMessage", "All required fields must be filled.");
                handleList(request, response, tab);
                return;
            }

            try {
                int quantity = Integer.parseInt(quantityStr);
                int minQuantity = (minQuantityStr == null || minQuantityStr.trim().isEmpty()) ? 5 : Integer.parseInt(minQuantityStr);
                double price = Double.parseDouble(priceStr);

                if (quantity < 0 || minQuantity < 0 || price <= 0) {
                    request.setAttribute("errorMessage", "Quantity/MinQuantity must be >= 0 and Price must be > 0.");
                    handleList(request, response, tab);
                    return;
                }

                MedicalSupply s = new MedicalSupply(0, name.trim(), unit.trim(), quantity, minQuantity, price, supplier != null ? supplier.trim() : null, null);
                boolean success = supplyDAO.addSupply(s);

                if (success) {
                    request.getSession().setAttribute("successMessage", "Supply added successfully.");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=supply");
                } else {
                    request.setAttribute("errorMessage", "Failed to add supply.");
                    handleList(request, response, tab);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid numeric values.");
                handleList(request, response, tab);
            }
        } else {
            String name = request.getParameter("medicineName");
            String unit = request.getParameter("unit");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String statusStr = request.getParameter("status");

            if (name == null || name.trim().isEmpty() || unit == null || unit.trim().isEmpty() ||
                    priceStr == null || stockStr == null) {
                request.setAttribute("errorMessage", "All fields are required.");
                handleList(request, response, tab);
                return;
            }

            try {
                double price = Double.parseDouble(priceStr);
                int stock = Integer.parseInt(stockStr);
                boolean status = statusStr != null && (statusStr.equals("1") || statusStr.equalsIgnoreCase("true"));

                if (price <= 0 || stock < 0) {
                    request.setAttribute("errorMessage", "Price must be > 0 and Stock must be >= 0.");
                    handleList(request, response, tab);
                    return;
                }

                Medicine m = new Medicine(0, name.trim(), unit.trim(), price, stock, status);
                boolean success = medicineDAO.addMedicine(m);

                if (success) {
                    request.getSession().setAttribute("successMessage", "Medicine added successfully.");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=medicine");
                } else {
                    request.setAttribute("errorMessage", "Failed to add medicine.");
                    handleList(request, response, tab);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid numeric values.");
                handleList(request, response, tab);
            }
        }
    }

    /** Cập nhật thông tin thuốc hoặc vật tư sau khi Admin sửa form. */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, String tab)
            throws IOException, ServletException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=" + tab);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            if ("supply".equals(tab)) {
                String name = request.getParameter("supplyName");
                String unit = request.getParameter("unit");
                String quantityStr = request.getParameter("quantity");
                String minQuantityStr = request.getParameter("minQuantity");
                String priceStr = request.getParameter("unitPrice");
                String supplier = request.getParameter("supplier");

                if (name == null || name.trim().isEmpty() || unit == null || unit.trim().isEmpty() ||
                        quantityStr == null || priceStr == null) {
                    request.setAttribute("errorMessage", "All required fields must be filled.");
                    handleList(request, response, tab);
                    return;
                }

                int quantity = Integer.parseInt(quantityStr);
                int minQuantity = (minQuantityStr == null || minQuantityStr.trim().isEmpty()) ? 5 : Integer.parseInt(minQuantityStr);
                double price = Double.parseDouble(priceStr);

                if (quantity < 0 || minQuantity < 0 || price <= 0) {
                    request.setAttribute("errorMessage", "Quantity/MinQuantity must be >= 0 and Price must be > 0.");
                    handleList(request, response, tab);
                    return;
                }

                MedicalSupply s = new MedicalSupply(id, name.trim(), unit.trim(), quantity, minQuantity, price, supplier != null ? supplier.trim() : null, null);
                boolean success = supplyDAO.updateSupply(s);

                if (success) {
                    request.getSession().setAttribute("successMessage", "Supply updated successfully.");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=supply");
                } else {
                    request.setAttribute("errorMessage", "Failed to update supply.");
                    handleList(request, response, tab);
                }
            } else {
                String name = request.getParameter("medicineName");
                String unit = request.getParameter("unit");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stockQuantity");
                String statusStr = request.getParameter("status");

                if (name == null || name.trim().isEmpty() || unit == null || unit.trim().isEmpty() ||
                        priceStr == null || stockStr == null) {
                    request.setAttribute("errorMessage", "All fields are required.");
                    handleList(request, response, tab);
                    return;
                }

                double price = Double.parseDouble(priceStr);
                int stock = Integer.parseInt(stockStr);
                boolean status = statusStr != null && (statusStr.equals("1") || statusStr.equalsIgnoreCase("true"));

                if (price <= 0 || stock < 0) {
                    request.setAttribute("errorMessage", "Price must be > 0 and Stock must be >= 0.");
                    handleList(request, response, tab);
                    return;
                }

                Medicine m = new Medicine(id, name.trim(), unit.trim(), price, stock, status);
                boolean success = medicineDAO.updateMedicine(m);

                if (success) {
                    request.getSession().setAttribute("successMessage", "Medicine updated successfully.");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-medicines?tab=medicine");
                } else {
                    request.setAttribute("errorMessage", "Failed to update medicine.");
                    handleList(request, response, tab);
                }
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid format for numeric inputs.");
            handleList(request, response, tab);
        }
    }
}
