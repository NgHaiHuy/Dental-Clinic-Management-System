package filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
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

/**
 * AuthenticationFilter - Thành viên 1 (Nghị)
 *
 * Chức năng: Kiểm tra xem người dùng đã đăng nhập chưa.
 * - Nếu CHƯA đăng nhập và cố truy cập URL được bảo vệ → redirect về trang login.
 * - Nếu ĐÃ đăng nhập → cho đi tiếp.
 * - Các URL public (login, register, assets, error) được bypass tự động.
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    /**
     * Danh sách các URL prefix được phép truy cập mà không cần đăng nhập.
     */
    private static final Set<String> PUBLIC_URL_PREFIXES = new HashSet<>(Arrays.asList(
            "/auth/login",
            "/auth/register",
            "/assets/",
            "/error/",
            "/index.jsp"
    ));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần khởi tạo gì thêm
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  httpRequest  = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String contextPath  = httpRequest.getContextPath();  // e.g. "/DentalClinic"
        String requestURI   = httpRequest.getRequestURI();   // e.g. "/DentalClinic/admin/dashboard"
        
        // Lấy phần URI tương đối (bỏ context path)
        String relativePath = requestURI.substring(contextPath.length());

        // ----------------------------------------------------------------
        // 1. Cho phép các URL public đi qua mà không cần kiểm tra session
        // ----------------------------------------------------------------
        if (isPublicUrl(relativePath)) {
            chain.doFilter(request, response);
            return;
        }

        // ----------------------------------------------------------------
        // 2. Kiểm tra session - user đã đăng nhập chưa?
        // ----------------------------------------------------------------
        HttpSession session = httpRequest.getSession(false); // false = không tạo session mới
        boolean isLoggedIn  = (session != null) && (session.getAttribute("loggedInUser") != null);

        if (isLoggedIn) {
            // Đã đăng nhập → cho đi tiếp (AuthorizationFilter sẽ kiểm tra quyền)
            chain.doFilter(request, response);
        } else {
            // Chưa đăng nhập → redirect về trang login
            // Lưu URL và query parameters mà user muốn truy cập để sau khi login có thể redirect lại chính xác
            String redirectUrl = relativePath;
            String queryString = httpRequest.getQueryString();
            if (queryString != null && !queryString.isEmpty()) {
                redirectUrl += "?" + queryString;
            }
            httpRequest.getSession().setAttribute("redirectAfterLogin", redirectUrl);
            httpResponse.sendRedirect(contextPath + "/auth/login");
        }
    }

    /**
     * Kiểm tra xem URL có nằm trong danh sách public không.
     *
     * @param relativePath Đường dẫn tương đối (đã bỏ context path)
     * @return true nếu là URL public
     */
    private boolean isPublicUrl(String relativePath) {
        if (relativePath.equals("/") || relativePath.isEmpty()) {
            return true;
        }
        for (String prefix : PUBLIC_URL_PREFIXES) {
            if (relativePath.startsWith(prefix)) {
                return true;
            }
        }
        // Cho phép truy cập file tĩnh (.css, .js, .png, .jpg, .ico, .woff...)
        if (relativePath.matches(".+\\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|ttf|svg|map)$")) {
            return true;
        }
        return false;
    }

    @Override
    public void destroy() {
        // Không cần cleanup
    }
}
