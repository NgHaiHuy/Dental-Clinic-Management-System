package controller.customer;

import java.io.IOException;
import java.sql.Date;
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
    "/customer/booking/cancel"
})
public class BookingController extends HttpServlet {

    private static final String BOOKING_VIEW = "/customer/booking.jsp";
    private static final String HISTORY_VIEW = "/customer/history.jsp";
    private static final String HISTORY_PATH = "/customer/history";
    private static final String CANCEL_PATH = "/customer/booking/cancel";

    private static final String SESSION_APPOINTMENTS = "customerAppointments";
    private static final String SESSION_NEXT_APPOINTMENT_ID = "customerNextAppointmentId";
    private static final String FLASH_SUCCESS = "bookingSuccessMessage";
    private static final String FLASH_ERROR = "bookingErrorMessage";

    private static final int MOCK_CUSTOMER_ID = 1;
    private static final int MAX_NOTES_LENGTH = 500;
    private static final String STATUS_PENDING = "Pending";
    private static final String STATUS_CANCELLED = "Cancelled";
    private static final LocalTime OPEN_TIME = LocalTime.of(8, 0);
    private static final LocalTime CLOSE_TIME = LocalTime.of(17, 0);

    private static final Map<Integer, String> DOCTOR_OPTIONS = createDoctorOptions();
    private static final Map<Integer, String> SERVICE_OPTIONS = createServiceOptions();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (HISTORY_PATH.equals(request.getServletPath())) {
            showHistoryPage(request, response);
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

        createAppointment(request, response);
    }

    private void createAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> form = captureBookingForm(request);
        List<String> errors = new ArrayList<>();

        Integer doctorId = parseOption(
                form.get("doctorId"),
                DOCTOR_OPTIONS,
                "Vui lòng chọn bác sĩ.",
                "Bác sĩ được chọn không hợp lệ.",
                errors
        );
        LocalDate appointmentDate = parseAppointmentDate(form.get("appointmentDate"), errors);
        LocalTime appointmentTime = parseAppointmentTime(form.get("appointmentTime"), errors);
        Set<Integer> selectedServiceIds = parseSelectedServiceIds(request.getParameterValues("serviceIds"), errors);
        String notes = form.get("notes");

        if (notes.length() > MAX_NOTES_LENGTH) {
            errors.add("Ghi chú không được vượt quá " + MAX_NOTES_LENGTH + " ký tự.");
        }

        if (!errors.isEmpty()) {
            showBookingPage(request, response, form, selectedServiceIds, errors);
            return;
        }

        HttpSession session = request.getSession();
        List<Appointment> appointments = getCustomerAppointments(session);

        Appointment appointment = new Appointment(
                nextAppointmentId(session, appointments),
                MOCK_CUSTOMER_ID,
                doctorId,
                Date.valueOf(appointmentDate),
                Time.valueOf(appointmentTime),
                STATUS_PENDING,
                notes
        );
        appointment.setServiceIds(new ArrayList<>(selectedServiceIds));

        appointments.add(appointment);
        session.setAttribute(SESSION_APPOINTMENTS, appointments);
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

        Appointment appointment = findAppointment(getCustomerAppointments(session), appointmentId);
        if (appointment == null) {
            setFlash(session, FLASH_ERROR, "Lịch hẹn không tồn tại trong phiên hiện tại.");
        } else if (!STATUS_PENDING.equals(appointment.getStatus())) {
            setFlash(session, FLASH_ERROR, "Chỉ có thể hủy lịch đang chờ xác nhận.");
        } else {
            appointment.setStatus(STATUS_CANCELLED);
            setFlash(session, FLASH_SUCCESS, "Đã hủy lịch hẹn.");
        }

        response.sendRedirect(request.getContextPath() + HISTORY_PATH);
    }

    private void showBookingPage(HttpServletRequest request, HttpServletResponse response,
            Map<String, String> form, Set<Integer> selectedServiceIds, List<String> errors)
            throws ServletException, IOException {
        prepareCommonAttributes(request);
        request.setAttribute("form", form);
        request.setAttribute("selectedServiceIds", selectedServiceIds);
        request.setAttribute("errors", errors);
        request.getRequestDispatcher(BOOKING_VIEW).forward(request, response);
    }

    private void showHistoryPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        prepareCommonAttributes(request);
        consumeFlash(session, request, FLASH_SUCCESS, "successMessage");
        consumeFlash(session, request, FLASH_ERROR, "errorMessage");
        request.setAttribute("appointments", new ArrayList<>(getCustomerAppointments(session)));
        request.getRequestDispatcher(HISTORY_VIEW).forward(request, response);
    }

    private Map<String, String> captureBookingForm(HttpServletRequest request) {
        Map<String, String> form = new HashMap<>();
        form.put("doctorId", trimToEmpty(request.getParameter("doctorId")));
        form.put("appointmentDate", trimToEmpty(request.getParameter("appointmentDate")));
        form.put("appointmentTime", trimToEmpty(request.getParameter("appointmentTime")));
        form.put("notes", trimToEmpty(request.getParameter("notes")));
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
            return appointmentTime;
        } catch (DateTimeParseException ex) {
            errors.add("Giờ khám không hợp lệ.");
            return null;
        }
    }

    private Set<Integer> parseSelectedServiceIds(String[] values, List<String> errors) {
        Set<Integer> selectedServiceIds = new LinkedHashSet<>();
        boolean hasInvalidService = false;

        if (values != null) {
            for (String value : values) {
                Integer serviceId = parseInteger(value);
                if (serviceId == null || !SERVICE_OPTIONS.containsKey(serviceId)) {
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

    @SuppressWarnings("unchecked")
    private List<Appointment> getCustomerAppointments(HttpSession session) {
        Object appointments = session.getAttribute(SESSION_APPOINTMENTS);
        if (appointments instanceof List<?>) {
            return (List<Appointment>) appointments;
        }

        List<Appointment> newAppointments = new ArrayList<>();
        session.setAttribute(SESSION_APPOINTMENTS, newAppointments);
        return newAppointments;
    }

    private int nextAppointmentId(HttpSession session, List<Appointment> appointments) {
        Object nextIdAttribute = session.getAttribute(SESSION_NEXT_APPOINTMENT_ID);
        int nextId;

        if (nextIdAttribute instanceof Integer) {
            nextId = (Integer) nextIdAttribute;
        } else {
            nextId = 1;
            for (Appointment appointment : appointments) {
                nextId = Math.max(nextId, appointment.getAppointmentId() + 1);
            }
        }

        session.setAttribute(SESSION_NEXT_APPOINTMENT_ID, nextId + 1);
        return nextId;
    }

    private Appointment findAppointment(List<Appointment> appointments, int appointmentId) {
        for (Appointment appointment : appointments) {
            if (appointment.getAppointmentId() == appointmentId) {
                return appointment;
            }
        }
        return null;
    }

    private void prepareCommonAttributes(HttpServletRequest request) {
        request.setAttribute("doctorOptions", DOCTOR_OPTIONS);
        request.setAttribute("serviceOptions", SERVICE_OPTIONS);
        request.setAttribute("today", LocalDate.now().toString());
        request.setAttribute("clinicOpenTime", OPEN_TIME.toString());
        request.setAttribute("clinicCloseTime", CLOSE_TIME.toString());
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

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private static Map<Integer, String> createDoctorOptions() {
        Map<Integer, String> options = new LinkedHashMap<>();
        options.put(1, "BS. A");
        options.put(2, "BS. B");
        options.put(3, "BS. C");
        return Collections.unmodifiableMap(options);
    }

    private static Map<Integer, String> createServiceOptions() {
        Map<Integer, String> options = new LinkedHashMap<>();
        options.put(1, "Khám tổng quát");
        options.put(2, "Cạo vôi răng");
        options.put(3, "Trám răng");
        options.put(4, "Nhổ răng");
        return Collections.unmodifiableMap(options);
    }
}
