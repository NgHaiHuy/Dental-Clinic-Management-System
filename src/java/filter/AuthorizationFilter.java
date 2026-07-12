package filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;
import model.User;

/**
 * AuthorizationFilter - Thành viên 1 (Nghị)
 *
 * Chức năng: Sau khi đã xác thực (AuthenticationFilter), kiểm tra xem Role của
 * user có đủ quyền truy cập URL hiện tại không.
 *
 * Quy tắc phân quyền:
 *  - /admin/*        → chỉ Admin    (RoleID = 1)
 *  - /doctor/*       → chỉ Doctor   (RoleID = 2)
 *  - /receptionist/* → chỉ Staff    (RoleID = 3)
 *  - /customer/*     → chỉ Customer (RoleID = 4)
 *  - Các URL khác    → cho phép tất cả user đã đăng nhập
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/*"})
public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần khởi tạo
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  httpRequest  = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String contextPath = httpRequest.getContextPath();
        String requestURI  = httpRequest.getRequestURI();
        String relativePath = requestURI.substring(contextPath.length());

        // ----------------------------------------------------------------
        // 1. Bỏ qua kiểm tra với các URL public và tài nguyên tĩnh
        // ----------------------------------------------------------------
        if (isPublicOrStaticUrl(relativePath)) {
            chain.doFilter(request, response);
            return;
        }

        // ----------------------------------------------------------------
        // 2. Lấy thông tin user từ session
        // ----------------------------------------------------------------
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            // Chưa đăng nhập → AuthenticationFilter sẽ xử lý, cho đi tiếp
            chain.doFilter(request, response);
            return;
        }

        User user   = (User) session.getAttribute("loggedInUser");
        int  roleID = user.getRoleID();

        // ----------------------------------------------------------------
        // 3. Kiểm tra quyền theo URL pattern
        // ----------------------------------------------------------------
        boolean hasPermission = checkPermission(relativePath, roleID);

        if (hasPermission) {
            chain.doFilter(request, response);
        } else {
            // Không có quyền → forward tới trang 403
            httpRequest.setAttribute("forbiddenUrl", relativePath);
            httpRequest.setAttribute("userRole", Role.getRoleNameVi(roleID));
            httpRequest.getRequestDispatcher("/error/403.jsp").forward(httpRequest, httpResponse);
        }
    }

    /**
     * Kiểm tra quyền truy cập dựa trên URL và RoleID của user.
     *
     * @param relativePath Đường dẫn tương đối
     * @param roleID       RoleID của user đang đăng nhập
     * @return true nếu có quyền
     */
    private boolean checkPermission(String relativePath, int roleID) {

        // --- /admin/** → chỉ Admin ---
        if (relativePath.startsWith("/admin/")) {
            return roleID == Role.ADMIN;
        }

        // --- /doctor/** → chỉ Doctor ---
        if (relativePath.startsWith("/doctor/")) {
            return roleID == Role.DOCTOR;
        }

        // --- /receptionist/** → chỉ Staff (Tiếp đón) ---
        if (relativePath.startsWith("/receptionist/")) {
            return roleID == Role.STAFF;
        }

        // --- /customer/** → chỉ Customer ---
        if (relativePath.startsWith("/customer/")) {
            return roleID == Role.CUSTOMER;
        }

        // Các URL khác (auth/logout, v.v.) → cho phép nếu đã đăng nhập
        return true;
    }

    /**
     * Kiểm tra URL có phải public hoặc tài nguyên tĩnh không.
     * Những URL này đã được AuthenticationFilter xử lý, không cần authorize.
     */
    private boolean isPublicOrStaticUrl(String relativePath) {
        return relativePath.startsWith("/auth/login")
                || relativePath.startsWith("/auth/register")
                || relativePath.startsWith("/assets/")
                || relativePath.startsWith("/error/")
                || relativePath.equals("/index.jsp")
                || relativePath.equals("/")
                || relativePath.matches(".+\\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|ttf|svg|map)$");
    }

    @Override
    public void destroy() {
        // Không cần cleanup
    }
}
