package controller.admin;

import dal.ServiceDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Service;

/**
 * Admin quản lý danh mục dịch vụ nha khoa (CRUD).
 * URL: /admin/manage-services
 *
 * GET  action=list   → hiển thị danh sách
 * GET  action=edit   → form sửa dịch vụ
 * GET  action=delete → xóa dịch vụ
 * GET  action=toggle → bật/tắt trạng thái
 * POST action=add    → thêm dịch vụ mới
 * POST action=update → cập nhật dịch vụ
 */
@WebServlet(name = "ManageServiceController", urlPatterns = {"/admin/manage-services"})
public class ManageServiceController extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();

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
            case "delete":
                handleDelete(request, response);
                break;
            case "edit":
                handleShowEditForm(request, response);
                break;
            case "toggle":
                handleToggleStatus(request, response);
                break;
            case "list":
            default:
                handleListServices(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                handleAddService(request, response);
                break;
            case "update":
                handleUpdateService(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/manage-services");
                break;
        }
    }

    /** Đọc danh sách dịch vụ, hỗ trợ tìm kiếm theo tên nếu có query. */
    private void handleListServices(HttpServletRequest request, HttpServletResponse response)             // Đọc danh sách dịch vụ
            throws ServletException, IOException {
        String searchQuery = request.getParameter("search");
        List<Service> services;

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            services = serviceDAO.searchServicesByName(searchQuery.trim());
            request.setAttribute("searchQuery", searchQuery);
        } else {
            services = serviceDAO.getAllServices();
        }

        request.setAttribute("services", services);
        request.getRequestDispatcher("/admin/manage-services.jsp").forward(request, response);
    }

    /** Lấy thông tin dịch vụ theo ID và đặt vào request để JSP hiển thị form sửa. */
    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Service service = serviceDAO.getServiceByID(id);
            if (service != null) {
                request.setAttribute("serviceToEdit", service);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid service ID format.");
        }
        handleListServices(request, response);
    }

    /** Đảo trạng thái Active/Inactive của dịch vụ (không xóa hẳn). */
    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Service service = serviceDAO.getServiceByID(id);
            if (service != null) {
                service.setStatus(!service.isStatus());
                serviceDAO.updateService(service);
            }
        } catch (NumberFormatException e) {
            // Ignore format errors
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-services");
    }

    /** Xóa dịch vụ: nếu có ràng buộc FK thì tự động chuyển sang vô hiệu hóa (soft delete). */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = serviceDAO.deleteService(id);
            if (!success) {
                request.getSession().setAttribute("errorMessage", "Cannot delete or deactivate service.");
            } else {
                request.getSession().setAttribute("successMessage", "Service removed/deactivated successfully.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid service ID.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-services");
    }

    private void handleAddService(HttpServletRequest request, HttpServletResponse response)              // Thêm dịch vụ mới
            throws IOException, ServletException {
        String name = request.getParameter("name");
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Service name and price are required.");
            handleListServices(request, response);
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                handleListServices(request, response);
                return;
            }

            boolean status = statusStr != null && (statusStr.equals("1") || statusStr.equalsIgnoreCase("true"));
            Service s = new Service(0, name.trim(), price, description, status);
            boolean success = serviceDAO.addService(s);

            if (success) {
                request.getSession().setAttribute("successMessage", "New service added successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/manage-services");
            } else {
                request.setAttribute("errorMessage", "Failed to add service. Please try again.");
                handleListServices(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Price must be a valid number.");
            handleListServices(request, response);
        }
    }

    private void handleUpdateService(HttpServletRequest request, HttpServletResponse response)             // Sửa dịch vụ
            throws IOException, ServletException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");
        String statusStr = request.getParameter("status");

        if (idStr == null || name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required to update.");
            handleListServices(request, response);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            double price = Double.parseDouble(priceStr);
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                handleListServices(request, response);
                return;
            }

            boolean status = statusStr != null && (statusStr.equals("1") || statusStr.equalsIgnoreCase("true"));
            Service s = new Service(id, name.trim(), price, description, status);
            boolean success = serviceDAO.updateService(s);

            if (success) {
                request.getSession().setAttribute("successMessage", "Service updated successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/manage-services");
            } else {
                request.setAttribute("errorMessage", "Failed to update service.");
                handleListServices(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid numeric values provided.");
            handleListServices(request, response);
        }
    }
}
