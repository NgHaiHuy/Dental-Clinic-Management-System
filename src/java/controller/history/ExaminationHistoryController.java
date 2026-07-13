package controller.history;

import dal.MedicalRecordDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.MedicalRecord;
import model.Role;
import model.Service;
import model.User;

/**
 * Shared, read-only examination history for customers, doctors and staff.
 */
@WebServlet(name = "ExaminationHistoryController", urlPatterns = {"/examination-history"})
public class ExaminationHistoryController extends HttpServlet {

    private static final String VIEW = "/customer/history.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        int roleID = user.getRoleID();
        if (roleID != Role.CUSTOMER && roleID != Role.DOCTOR && roleID != Role.STAFF) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String keyword = clean(request.getParameter("keyword"));
        if (keyword.length() > 100) {
            keyword = keyword.substring(0, 100);
        }
        String fromValue = clean(request.getParameter("fromDate"));
        String toValue = clean(request.getParameter("toDate"));
        LocalDate fromDate = parseDate(fromValue);
        LocalDate toDate = parseDate(toValue);
        Integer serviceID = parsePositiveInteger(request.getParameter("serviceId"));

        if ((!fromValue.isEmpty() && fromDate == null) || (!toValue.isEmpty() && toDate == null)) {
            request.setAttribute("filterError", "Ngày lọc không hợp lệ. Vui lòng chọn lại.");
            fromDate = null;
            toDate = null;
            fromValue = "";
            toValue = "";
        } else if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            request.setAttribute("filterError", "Ngày bắt đầu không được sau ngày kết thúc.");
            fromDate = null;
            toDate = null;
            fromValue = "";
            toValue = "";
        }

        List<MedicalRecord> records = Collections.emptyList();
        List<Service> services = Collections.emptyList();
        try (MedicalRecordDAO dao = new MedicalRecordDAO()) {
            if (dao.getConnection() == null) {
                request.setAttribute("dataError", "Không thể kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
            } else {
                records = dao.findExaminationHistory(user.getUserID(), roleID, keyword,
                        fromDate, toDate, serviceID);
                services = dao.findHistoryServices();
            }
        } catch (SQLException exception) {
            log("Cannot load examination history", exception);
            request.setAttribute("dataError", "Không thể tải lịch sử khám. Vui lòng thử lại sau.");
        }

        Set<Integer> patientIDs = records.stream()
                .map(MedicalRecord::getCustomerID).collect(Collectors.toSet());
        Set<Integer> doctorIDs = records.stream()
                .map(MedicalRecord::getDoctorID).collect(Collectors.toSet());
        YearMonth currentMonth = YearMonth.now();
        long monthCount = records.stream()
                .filter(record -> record.getAppointmentDate() != null
                && YearMonth.from(record.getAppointmentDate()).equals(currentMonth))
                .count();
        long treatmentCount = records.stream().filter(MedicalRecord::hasTreatmentPlan).count();

        request.setAttribute("records", records);
        request.setAttribute("services", services);
        request.setAttribute("currentRole", roleID);
        request.setAttribute("keyword", keyword);
        request.setAttribute("fromDate", fromValue);
        request.setAttribute("toDate", toValue);
        request.setAttribute("selectedServiceId", serviceID);
        request.setAttribute("totalCount", records.size());
        request.setAttribute("patientCount", patientIDs.size());
        request.setAttribute("doctorCount", doctorIDs.size());
        request.setAttribute("monthCount", monthCount);
        request.setAttribute("treatmentCount", treatmentCount);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException exception) {
            return null;
        }
    }

    private Integer parsePositiveInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException exception) {
            return null;
        }
    }
}
