/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.List;
import model.Appointment;

/**
 *
 * @author HP
 */
public class Test {
    public static void main(String[] args) {

        AppointmentDAO dao = new AppointmentDAO();

        List<Appointment> list = dao.getTodayAppointments();

        for (Appointment a : list) {

            System.out.println(a.getAppointmentID() + "-" + a.getStatus());

        }

    }
}
