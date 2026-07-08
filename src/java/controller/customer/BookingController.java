package controller.customer;

import dal.AppointmentDAO;
import dal.ServiceDAO;
import dal.UserDAO;
import java.io.IOException;
import java.lang.reflect.Method;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Appointment;

@WebServlet(name = "BookingController", urlPatterns = {
    "/customer/booking",
    "/customer/history",
    "/customer/booking/detail",
    "/customer/booking/edit",
    "/customer/booking/cancel"
})
public class BookingController extends HttpServlet {

    private static final String BOOKING_VIEW = "/customer/booking.jsp";
    private static final String HISTORY_VIEW = "/customer/history.jsp";
    private static final String DETAIL_VIEW = "/customer/detail.jsp";
    private static final String EDIT_VIEW = "/customer/edit.jsp";
    private static final String HISTORY_PATH = "/customer/history";
    private static final String DETAIL_PATH = "/customer/booking/detail";
    private static final String EDIT_PATH = "/customer/booking/edit";
    private static final String CANCEL_PATH = "/customer/booking/cancel";

    private static final String FLASH_SUCCESS = "bookingSuccessMessage";
    private static final String FLASH_ERROR = "bookingErrorMessage";

    private static final int FALLBACK_CUSTOMER_ID = 6;
    private static final int MAX_NOTES_LENGTH = 500;
    private static final int APPOINTMENT_DURATION_MINUTES = 30;
    private static final String STATUS_PENDING = "Pending";
    private static final String STATUS_CANCELLED = "Cancelled";
    private static final LocalTime OPEN_TIME = LocalTime.of(8, 0);
    private static final LocalTime CLOSE_TIME = LocalTime.of(17, 0);
    private static final Map<String, String> APPOINTMENT_TIME_OPTIONS = createAppointmentTimeOptions();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (HISTORY_PATH.equals(request.getServletPath())) {
            showHistoryPage(request, response);
            return;
        }
        if (DETAIL_PATH.equals(request.getServletPath())) {
            showDetailPage(request, response);
            return;
        }
        if (EDIT_PATH.equals(request.getServletPath())) {
            showEditPage(request, response);
            return;
        }

        showBookingPage(request, response, new HashMap<>(), new LinkedHashSet<>(), Collections.emptyList());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (CANCEL_PATH.equals(request.getServletPath())) {
            cancelAppointment(request, response);
            return;
        }
        if (EDIT_PATH.equals(request.getServletPath())) {
            updateAppointment(request, response);
            return;
        }

        createAppointment(request, response);
    }

    private void createAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = getCurrentCustomerId(request);
        Map<String, String> form = captureBookingForm(request);
        List<String> errors = new ArrayList<>();
        Map<Integer, String> doctorOptions = loadDoctorOptions(errors);
        Map<Integer, String> serviceOptions = loadServiceOptions(errors);

        Integer doctorId = parseOption(
                form.get("doctorId"),
                doctorOptions,
                "Vui lòng chọn bác sĩ.",
                "Bác sĩ được chọn không hợp lệ.",
                errors
        );
        LocalDate appointmentDate = parseAppointmentDate(form.get("appointmentDate"), errors);
        LocalTime appointmentTime = parseAppointmentTime(form.get("appointmentTime"), errors);
        Set<Integer> selectedServiceIds = parseSelectedServiceIds(
                request.getParameterValues("serviceIds"),
                serviceOptions,
                errors
        );
        String notes = form.get("notes");

        if (notes.length() > MAX_NOTES_LENGTH) {
            errors.add("Ghi chú không được vượt quá " + MAX_NOTES_LENGTH + " ký tự.");
        }

        if (doctorId != null && appointmentDate != null && appointmentTime != null) {
            try {
                boolean doctorBooked = new AppointmentDAO().hasDoctorScheduleConflict(
                        doctorId,
                        Date.valueOf(appointmentDate),
                        Time.valueOf(appointmentTime),
                        APPOINTMENT_DURATION_MINUTES
                );
                if (doctorBooked) {
                    errors.add("Bác sĩ đã có lịch hẹn trong khung giờ này. Vui lòng chọn giờ khác.");
                }
            } catch (SQLException ex) {
                errors.add("Không thể kiểm tra lịch trống của bác sĩ. Vui lòng thử lại.");
            }
        }

        if (!errors.isEmpty()) {
            showBookingPage(request, response, form, selectedServiceIds, errors, doctorOptions, serviceOptions);
            return;
        }

        Appointment appointment = new Appointment(
                customerId,
                doctorId,
                Date.valueOf(appointmentDate),
                Time.valueOf(appointmentTime),
                STATUS_PENDING,
                notes
        );
        appointment.setServiceIds(new ArrayList<>(selectedServiceIds));

        try {
            int appointmentId = new AppointmentDAO().insertAppointment(appointment);
            appointment.setAppointmentId(appointmentId);
        } catch (SQLException ex) {
            errors.add("Không thể lưu lịch hẹn vào cơ sở dữ liệu. Vui lòng kiểm tra dữ liệu khách hàng, bác sĩ và dịch vụ.");
            showBookingPage(request, response, form, selectedServiceIds, errors, doctorOptions, serviceOptions);
            return;
        }

        HttpSession session = request.getSession();
        setFlash(session, FLASH_SUCCESS, "Đặt lịch thành công. Lịch đang chờ phòng khám xác nhận.");

        response.sendRedirect(request.getContextPath() + HISTORY_PATH);
    }

    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        Integer appointmentId = parseInteger(request.getParameter("appointmentId"));

        if (appointmentId == null) {
            setFlash(session, FLASH_ERROR, "Không tìm thấy lịch hẹn cần hủy.");
            response.sendRedirect(request.getContextPath() + HISTORY_PATH);
            return;
        }

        try {
            boolean cancelled = new AppointmentDAO().cancelPendingAppointment(appointmentId, getCurrentCustomerId(request));
            if (cancelled) {
                setFlash(session, FLASH_SUCCESS, "Đã hủy lịch hẹn.");
            } else {
                setFlash(session, FLASH_ERROR, "Không tìm thấy lịch đang chờ xác nhận để hủy.");
            }
        } catch (SQLException ex) {
            setFlash(session, FLASH_ERROR, "Không thể hủy lịch hẹn trong cơ sở dữ liệu.");
        }

        response.sendRedirect(request.getContextPath() + HISTORY_PATH);
    }

    private void showBookingPage(HttpServletRequest request, HttpServletResponse response,
            Map<String, String> form, Set<Integer> selectedServiceIds, List<String> errors)
            throws ServletException, IOException {
        List<String> pageErrors = new ArrayList<>(errors);
        Map<Integer, String> doctorOptions = loadDoctorOptions(pageErrors);
        Map<Integer, String> serviceOptions = loadServiceOptions(pageErrors);
        showBookingPage(request, response, form, selectedServiceIds, pageErrors, doctorOptions, serviceOptions);
    }

    private void showBookingPage(HttpServletRequest request, HttpServletResponse response,
            Map<String, String> form, Set<Integer> selectedServiceIds, List<String> errors,
            Map<Integer, String> doctorOptions, Map<Integer, String> serviceOptions)
            throws ServletException, IOException {
        prepareCommonAttributes(request, doctorOptions, serviceOptions);
        request.setAttribute("form", form);
        request.setAttribute("selectedServiceIds", selectedServiceIds);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(BOOKING_VIEW).forward(request, response);
    }

    private void showHistoryPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        prepareCommonAttributes(request, loadDoctorOptions(null), loadServiceOptions(null));
        consumeFlash(session, request, FLASH_SUCCESS, "successMessage");
        consumeFlash(session, request, FLASH_ERROR, "errorMessage");

        try {
            request.setAttribute("appointments", new AppointmentDAO().getAppointmentsByCustomerId(getCurrentCustomerId(request)));
        } catch (SQLException ex) {
            request.setAttribute("appointments", Collections.emptyList());
            request.setAttribute("errorMessage", "Không thể tải lịch hẹn từ cơ sở dữ liệu.");
        }

        request.getRequestDispatcher(HISTORY_VIEW).forward(request, response);
    }

    private void showDetailPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        prepareCommonAttributes(request, loadDoctorOptions(null), loadServiceOptions(null));
        consumeFlash(session, request, FLASH_SUCCESS, "successMessage");
        consumeFlash(session, request, FLASH_ERROR, "errorMessage");

        Integer appointmentId = parseInteger(request.getParameter("id"));
        if (appointmentId == null) {
            request.setAttribute("errorMessage", "Không tìm thấy lịch hẹn cần xem.");
            request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
            return;
        }

        try {
            Appointment appointment = new AppointmentDAO().getAppointmentById(appointmentId, getCurrentCustomerId(request));
            if (appointment == null) {
                request.setAttribute("errorMessage", "Lịch hẹn không tồn tại hoặc không thuộc tài khoản hiện tại.");
            } else {
                request.setAttribute("appointment", appointment);
            }
        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Không thể tải chi tiết lịch hẹn từ cơ sở dữ liệu.");
        }

        request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
    }

    private void showEditPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<String> errors = new ArrayList<>();
        Map<Integer, String> doctorOptions = loadDoctorOptions(errors);
        Map<Integer, String> serviceOptions = loadServiceOptions(errors);
        Integer appointmentId = parseInteger(request.getParameter("id"));

        if (appointmentId == null) {
            errors.add("Không tìm thấy lịch hẹn cần sửa.");
            showEditPage(request, response, null, new HashMap<>(), new LinkedHashSet<>(), errors,
                    doctorOptions, serviceOptions);
            return;
        }

        try {
            Appointment appointment = new AppointmentDAO().getAppointmentById(appointmentId, getCurrentCustomerId(request));
            if (appointment == null) {
                errors.add("Lịch hẹn không tồn tại hoặc không thuộc tài khoản hiện tại.");
                showEditPage(request, response, appointmentId, new HashMap<>(), new LinkedHashSet<>(), errors,
                        doctorOptions, serviceOptions);
                return;
            }
            if (!STATUS_PENDING.equals(appointment.getStatus())) {
                errors.add("Chỉ có thể sửa lịch đang chờ xác nhận.");
                showEditPage(request, response, null, new HashMap<>(), new LinkedHashSet<>(),
                        errors, doctorOptions, serviceOptions);
                return;
            }

            showEditPage(request, response, appointmentId, appointmentToForm(appointment),
                    new LinkedHashSet<>(appointment.getServiceIds()), errors, doctorOptions, serviceOptions);
        } catch (SQLException ex) {
            errors.add("Không thể tải lịch hẹn từ cơ sở dữ liệu.");
            showEditPage(request, response, appointmentId, new HashMap<>(), new LinkedHashSet<>(), errors,
                    doctorOptions, serviceOptions);
        }
    }

    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = getCurrentCustomerId(request);
        Integer appointmentId = parseInteger(request.getParameter("appointmentId"));
        Map<String, String> form = captureBookingForm(request);
        List<String> errors = new ArrayList<>();
        Map<Integer, String> doctorOptions = loadDoctorOptions(errors);
        Map<Integer, String> serviceOptions = loadServiceOptions(errors);
        Appointment currentAppointment = null;

        if (appointmentId == null) {
            errors.add("Không tìm thấy lịch hẹn cần sửa.");
            showEditPage(request, response, null, new HashMap<>(), new LinkedHashSet<>(),
                    errors, doctorOptions, serviceOptions);
            return;
        }

        try {
            currentAppointment = new AppointmentDAO().getAppointmentById(appointmentId, customerId);
            if (currentAppointment == null) {
                errors.add("Lịch hẹn không tồn tại hoặc không thuộc tài khoản hiện tại.");
            } else if (!STATUS_PENDING.equals(currentAppointment.getStatus())) {
                errors.add("Chỉ có thể sửa lịch đang chờ xác nhận.");
            }
        } catch (SQLException ex) {
            errors.add("Không thể kiểm tra lịch hẹn cần sửa.");
        }

        Integer doctorId = parseOption(
                form.get("doctorId"),
                doctorOptions,
                "Vui lòng chọn bác sĩ.",
                "Bác sĩ được chọn không hợp lệ.",
                errors
        );
        LocalDate appointmentDate = parseAppointmentDate(form.get("appointmentDate"), errors);
        LocalTime appointmentTime = parseAppointmentTime(form.get("appointmentTime"), errors);
        Set<Integer> selectedServiceIds = parseSelectedServiceIds(
                request.getParameterValues("serviceIds"),
                serviceOptions,
                errors
        );
        String notes = form.get("notes");

        if (notes.length() > MAX_NOTES_LENGTH) {
            errors.add("Ghi chú không được vượt quá " + MAX_NOTES_LENGTH + " ký tự.");
        }

        if (currentAppointment != null && doctorId != null && appointmentDate != null && appointmentTime != null
                && isScheduleChanged(currentAppointment, doctorId, appointmentDate, appointmentTime)) {
            try {
                boolean doctorBooked = new AppointmentDAO().hasDoctorScheduleConflict(
                        doctorId,
                        Date.valueOf(appointmentDate),
                        Time.valueOf(appointmentTime),
                        APPOINTMENT_DURATION_MINUTES
                );
                if (doctorBooked) {
                    errors.add("Bác sĩ đã có lịch hẹn trong khung giờ này. Vui lòng chọn giờ khác.");
                }
            } catch (SQLException ex) {
                errors.add("Không thể kiểm tra lịch trống của bác sĩ. Vui lòng thử lại.");
            }
        }

        if (!errors.isEmpty()) {
            showEditPage(request, response, appointmentId, form, selectedServiceIds, errors, doctorOptions, serviceOptions);
            return;
        }

        Appointment appointment = new Appointment(
                appointmentId,
                customerId,
                doctorId,
                Date.valueOf(appointmentDate),
                Time.valueOf(appointmentTime),
                STATUS_PENDING,
                notes
        );
        appointment.setServiceIds(new ArrayList<>(selectedServiceIds));

        try {
            boolean updated = new AppointmentDAO().updatePendingAppointment(appointment);
            if (!updated) {
                errors.add("Không tìm thấy lịch đang chờ xác nhận để sửa.");
                showEditPage(request, response, appointmentId, form, selectedServiceIds, errors, doctorOptions, serviceOptions);
                return;
            }
        } catch (SQLException ex) {
            errors.add("Không thể cập nhật lịch hẹn trong cơ sở dữ liệu.");
            showEditPage(request, response, appointmentId, form, selectedServiceIds, errors, doctorOptions, serviceOptions);
            return;
        }

        HttpSession session = request.getSession();
        setFlash(session, FLASH_SUCCESS, "Cập nhật lịch hẹn thành công.");
        response.sendRedirect(request.getContextPath() + DETAIL_PATH + "?id=" + appointmentId);
    }

    private boolean isScheduleChanged(Appointment currentAppointment, Integer doctorId,
            LocalDate appointmentDate, LocalTime appointmentTime) {
        if (!doctorId.equals(currentAppointment.getDoctorId())) {
            return true;
        }
        if (currentAppointment.getAppointmentDate() == null
                || !appointmentDate.equals(currentAppointment.getAppointmentDate().toLocalDate())) {
            return true;
        }
        return currentAppointment.getAppointmentTime() == null
                || !appointmentTime.equals(currentAppointment.getAppointmentTime().toLocalTime());
    }

    private void showEditPage(HttpServletRequest request, HttpServletResponse response,
            Integer appointmentId, Map<String, String> form, Set<Integer> selectedServiceIds, List<String> errors,
            Map<Integer, String> doctorOptions, Map<Integer, String> serviceOptions)
            throws ServletException, IOException {
        prepareCommonAttributes(request, doctorOptions, serviceOptions);
        request.setAttribute("appointmentId", appointmentId);
        request.setAttribute("form", form);
        request.setAttribute("selectedServiceIds", selectedServiceIds);
        request.setAttribute("selectedDoctorId", parseInteger(form.get("doctorId")));
        request.setAttribute("selectedAppointmentTime", form.get("appointmentTime"));
        request.setAttribute("selectedServiceLookup", toSelectedServiceLookup(selectedServiceIds));
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
    }

    private Map<Integer, Boolean> toSelectedServiceLookup(Set<Integer> selectedServiceIds) {
        Map<Integer, Boolean> selectedServiceLookup = new HashMap<>();
        for (Integer serviceId : selectedServiceIds) {
            selectedServiceLookup.put(serviceId, Boolean.TRUE);
        }
        return selectedServiceLookup;
    }

    private Map<String, String> captureBookingForm(HttpServletRequest request) {
        Map<String, String> form = new HashMap<>();
        form.put("doctorId", trimToEmpty(request.getParameter("doctorId")));
        form.put("appointmentDate", trimToEmpty(request.getParameter("appointmentDate")));
        form.put("appointmentTime", trimToEmpty(request.getParameter("appointmentTime")));
        form.put("notes", trimToEmpty(request.getParameter("notes")));
        return form;
    }

    private Map<String, String> appointmentToForm(Appointment appointment) {
        Map<String, String> form = new HashMap<>();
        form.put("doctorId", appointment.getDoctorId() == null ? "" : String.valueOf(appointment.getDoctorId()));
        form.put("appointmentDate", appointment.getAppointmentDate() == null ? "" : appointment.getAppointmentDate().toString());
        form.put("appointmentTime", appointment.getAppointmentTime() == null
                ? "" : appointment.getAppointmentTime().toLocalTime().toString());
        form.put("notes", trimToEmpty(appointment.getNotes()));
        return form;
    }

    private Integer parseOption(String value, Map<Integer, String> options, String requiredMessage,
            String invalidMessage, List<String> errors) {
        if (value == null || value.isBlank()) {
            errors.add(requiredMessage);
            return null;
        }

        Integer optionId = parseInteger(value);
        if (optionId == null || !options.containsKey(optionId)) {
            errors.add(invalidMessage);
            return null;
        }

        return optionId;
    }

    private LocalDate parseAppointmentDate(String value, List<String> errors) {
        if (value == null || value.isBlank()) {
            errors.add("Vui lòng chọn ngày khám.");
            return null;
        }

        try {
            LocalDate appointmentDate = LocalDate.parse(value);
            if (appointmentDate.isBefore(LocalDate.now())) {
                errors.add("Ngày khám không được ở quá khứ.");
            }
            return appointmentDate;
        } catch (DateTimeParseException ex) {
            errors.add("Ngày khám không hợp lệ.");
            return null;
        }
    }

    private LocalTime parseAppointmentTime(String value, List<String> errors) {
        if (value == null || value.isBlank()) {
            errors.add("Vui lòng chọn giờ khám.");
            return null;
        }

        try {
            LocalTime appointmentTime = LocalTime.parse(value);
            if (appointmentTime.isBefore(OPEN_TIME) || appointmentTime.isAfter(CLOSE_TIME)) {
                errors.add("Giờ khám phải nằm trong khoảng " + OPEN_TIME + " - " + CLOSE_TIME + ".");
            }
            if (appointmentTime.getMinute() % APPOINTMENT_DURATION_MINUTES != 0
                    || appointmentTime.getSecond() != 0
                    || appointmentTime.getNano() != 0) {
                errors.add("Giờ khám phải theo khung 30 phút.");
            }
            if (appointmentTime.plusMinutes(APPOINTMENT_DURATION_MINUTES).isAfter(CLOSE_TIME)) {
                errors.add("Khung giờ khám phải kết thúc trước hoặc đúng " + CLOSE_TIME + ".");
            }
            return appointmentTime;
        } catch (DateTimeParseException ex) {
            errors.add("Giờ khám không hợp lệ.");
            return null;
        }
    }

    private Set<Integer> parseSelectedServiceIds(String[] values, Map<Integer, String> serviceOptions,
            List<String> errors) {
        Set<Integer> selectedServiceIds = new LinkedHashSet<>();
        boolean hasInvalidService = false;

        if (values != null) {
            for (String value : values) {
                Integer serviceId = parseInteger(value);
                if (serviceId == null || !serviceOptions.containsKey(serviceId)) {
                    hasInvalidService = true;
                } else {
                    selectedServiceIds.add(serviceId);
                }
            }
        }

        if (hasInvalidService) {
            errors.add("Dịch vụ được chọn không hợp lệ.");
        }
        if (selectedServiceIds.isEmpty()) {
            errors.add("Vui lòng chọn ít nhất một dịch vụ.");
        }

        return selectedServiceIds;
    }

    private Integer parseInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private void prepareCommonAttributes(HttpServletRequest request, Map<Integer, String> doctorOptions,
            Map<Integer, String> serviceOptions) {
        request.setAttribute("doctorOptions", doctorOptions);
        request.setAttribute("serviceOptions", serviceOptions);
        request.setAttribute("appointmentTimeOptions", APPOINTMENT_TIME_OPTIONS);
        request.setAttribute("today", LocalDate.now().toString());
        request.setAttribute("clinicOpenTime", OPEN_TIME.toString());
        request.setAttribute("clinicCloseTime", CLOSE_TIME.toString());
    }

    private Map<Integer, String> loadDoctorOptions(List<String> errors) {
        try {
            return new UserDAO().getDoctorOptions();
        } catch (SQLException ex) {
            if (errors != null) {
                errors.add("Không thể tải danh sách bác sĩ từ cơ sở dữ liệu.");
            }
            return Collections.emptyMap();
        }
    }

    private Map<Integer, String> loadServiceOptions(List<String> errors) {
        try {
            return new ServiceDAO().getActiveServiceOptions();
        } catch (SQLException ex) {
            if (errors != null) {
                errors.add("Không thể tải danh sách dịch vụ từ cơ sở dữ liệu.");
            }
            return Collections.emptyMap();
        }
    }

    private void setFlash(HttpSession session, String key, String message) {
        session.setAttribute(key, message);
    }

    private void consumeFlash(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        Object message = session.getAttribute(sessionKey);
        if (message != null) {
            request.setAttribute(requestKey, message);
            session.removeAttribute(sessionKey);
        }
    }

    private int getCurrentCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return FALLBACK_CUSTOMER_ID;
        }

        Integer directCustomerId = readIntegerAttribute(session, "customerId", "userId", "UserID");
        if (directCustomerId != null) {
            return directCustomerId;
        }

        Integer userObjectId = readUserObjectId(session, "currentUser", "user", "account");
        if (userObjectId != null) {
            return userObjectId;
        }

        return FALLBACK_CUSTOMER_ID;
    }

    private Integer readIntegerAttribute(HttpSession session, String... attributeNames) {
        for (String attributeName : attributeNames) {
            Integer value = toInteger(session.getAttribute(attributeName));
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private Integer readUserObjectId(HttpSession session, String... attributeNames) {
        for (String attributeName : attributeNames) {
            Object userObject = session.getAttribute(attributeName);
            Integer userId = readObjectId(userObject, "getUserId", "getUserID", "getId");
            if (userId != null) {
                return userId;
            }
        }
        return null;
    }

    private Integer readObjectId(Object object, String... methodNames) {
        if (object == null) {
            return null;
        }

        for (String methodName : methodNames) {
            try {
                Method method = object.getClass().getMethod(methodName);
                return toInteger(method.invoke(object));
            } catch (ReflectiveOperationException | RuntimeException ex) {
                // Try the next common session user id getter name.
            }
        }
        return null;
    }

    private Integer toInteger(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        if (value instanceof String) {
            return parseInteger((String) value);
        }
        return null;
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private static Map<String, String> createAppointmentTimeOptions() {
        Map<String, String> options = new LinkedHashMap<>();

        for (LocalTime startTime = OPEN_TIME;
                !startTime.plusMinutes(APPOINTMENT_DURATION_MINUTES).isAfter(CLOSE_TIME);
                startTime = startTime.plusMinutes(APPOINTMENT_DURATION_MINUTES)) {
            LocalTime endTime = startTime.plusMinutes(APPOINTMENT_DURATION_MINUTES);
            options.put(startTime.toString(), startTime + " - " + endTime);
        }

        return Collections.unmodifiableMap(options);
    }
}
