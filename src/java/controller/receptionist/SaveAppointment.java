/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.receptionist;

import dal.AppointmentDAO;
import dal.ServiceDAO;
import dal.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Appointment;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;

/**
 *
 * @author HP
 */
@WebServlet(name = "SaveAppointment", urlPatterns = {"/saveAppointment"})
public class SaveAppointment extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet SaveAppointment</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SaveAppointment at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        AppointmentDAO appointmentDAO = new AppointmentDAO();
        UserDAO userDAO = new UserDAO();
        ServiceDAO serviceDAO = new ServiceDAO();
        try {

            int customerID = Integer.parseInt(request.getParameter("customerID"));
            int doctorID = Integer.parseInt(request.getParameter("doctorID"));

            Date date = Date.valueOf(request.getParameter("date"));

            Time time = Time.valueOf(request.getParameter("time") + ":00");

            String notes = request.getParameter("notes");

            String[] services = request.getParameterValues("serviceID");

            // =========================
            // Validation
            // =========================
            if (date.toLocalDate().isBefore(LocalDate.now())) {

                throw new Exception("Appointment date cannot be before today.");

            }

            if (!appointmentDAO.isDoctorWorking(doctorID, date, time)) {

                throw new Exception(
                        "Doctor is off or outside working shift.");

            }

            if (!appointmentDAO.isDoctorAvailable(doctorID, date, time)) {

                throw new Exception(
                        "Doctor already has another appointment.");

            }

            if (services == null || services.length == 0) {

                throw new Exception("Please choose at least one service.");

            }

            // =========================
            // Insert Appointment
            // =========================
            Appointment a = new Appointment();

            a.setCustomerID(customerID);
            a.setDoctorID(doctorID);
            a.setAppointmentDate(date);
            a.setAppointmentTime(time);
            a.setStatus("Pending");
            a.setNotes(notes);

            int appointmentID = appointmentDAO.insertAppointment(a);

            if (appointmentID == -1) {

                throw new Exception("Cannot create appointment.");

            }

            // =========================
            // Insert Services
            // =========================
            for (String s : services) {

                appointmentDAO.addAppointmentService(
                        appointmentID,
                        Integer.parseInt(s));

            }

            request.getSession().setAttribute(
                    "message",
                    "Appointment created successfully!");

            response.sendRedirect("reception");

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("error", e.getMessage());

            request.setAttribute("customers",
                    userDAO.getAllCustomers());

            request.setAttribute("doctors",
                    userDAO.getAllDoctors());

            request.setAttribute("services",
                    serviceDAO.getAllServices());

            request.getRequestDispatcher("receptionist/newAppointment.jsp")
                    .forward(request, response);

        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
