package controller.admin;

import dal.UserDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

/**
 * AdminUserController - Thành viên 1 (Nghị) phối hợp với Thành viên 6 (Huy)
 *
 * Admin quản lý tài khoản người dùng trong hệ thống.
 * URL: /admin/manage-users
 *
 * Các action:
 *  - GET (mặc định)   → hiển thị danh sách users
 *  - POST action=create → tạo tài khoản mới (Doctor hoặc Staff)
 *  - POST action=update → cập nhật thông tin user
 *  - POST action=delete → xoá user
 */
@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/manage-users"})
public class AdminUserController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * GET: Lấy danh sách tất cả users và hiển thị.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<User> userList = userDAO.getAllUsers();
        request.setAttribute("userList", userList);
        request.getRequestDispatcher("/admin/manage-users.jsp").forward(request, response);
    }

    /**
     * POST: Xử lý các action: create, update, delete.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-users");
            return;
        }

        switch (action) {
            case "create":
                handleCreate(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/manage-users");
        }
    }

    /**
     * Tạo tài khoản mới (Admin tạo Doctor / Staff).
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String phone    = request.getParameter("phone");
        String email    = request.getParameter("email");
        String roleStr  = request.getParameter("roleID");

        // Validate cơ bản
        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || roleStr == null || roleStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin.");
            doGet(request, response);
            return;
        }

        int roleID;
        try {
            roleID = Integer.parseInt(roleStr.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Role không hợp lệ.");
            doGet(request, response);
            return;
        }

        // Kiểm tra username trùng
        if (userDAO.isUsernameExists(username.trim())) {
            request.setAttribute("errorMessage", "Tên đăng nhập \"" + username + "\" đã tồn tại.");
            doGet(request, response);
            return;
        }

        boolean success = userDAO.createUser(
                username.trim(), password.trim(), fullName.trim(),
                phone.trim(), email != null ? email.trim() : "", roleID
        );

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-users?msg=created");
        } else {
            request.setAttribute("errorMessage", "Tạo tài khoản thất bại. Vui lòng thử lại.");
            doGet(request, response);
        }
    }

    /**
     * Cập nhật thông tin user.
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String idStr    = request.getParameter("userID");
        String fullName = request.getParameter("fullName");
        String phone    = request.getParameter("phone");
        String email    = request.getParameter("email");
        String roleStr  = request.getParameter("roleID");

        try {
            int userID = Integer.parseInt(idStr);
            int roleID = Integer.parseInt(roleStr);

            boolean success = userDAO.updateUser(
                    userID, fullName.trim(), phone.trim(),
                    email != null ? email.trim() : "", roleID
            );

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-users?msg=updated");
            } else {
                request.setAttribute("errorMessage", "Cập nhật thất bại.");
                doGet(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
            doGet(request, response);
        }
    }

    /**
     * Xoá user theo ID.
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String idStr = request.getParameter("userID");
        try {
            int userID = Integer.parseInt(idStr);
            boolean success = userDAO.deleteUser(userID);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-users?msg=deleted");
            } else {
                request.setAttribute("errorMessage", "Xoá tài khoản thất bại.");
                doGet(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "ID không hợp lệ.");
            doGet(request, response);
        }
    }
}
