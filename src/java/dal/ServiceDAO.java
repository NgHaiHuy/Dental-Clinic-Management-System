package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Service;

public class ServiceDAO extends DBContext {

    // =========================
    // Mapping Service
    // =========================
    private Service mapService(ResultSet rs) throws Exception {

        Service s = new Service();

        s.setServiceID(rs.getInt("ServiceID"));
        s.setServiceName(rs.getString("ServiceName"));
        s.setPrice(rs.getDouble("Price"));
        s.setDescription(rs.getString("Description"));
        s.setStatus(rs.getBoolean("Status"));

        return s;
    }

    // =========================
    // Get All Active Services
    // =========================
    public List<Service> getAllServices() {

        List<Service> list = new ArrayList<>();

        String sql = """
                     SELECT *
                     FROM Services
                     WHERE Status = 1
                     ORDER BY ServiceName
                     """;

        try {

            PreparedStatement ps = connection.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                list.add(mapService(rs));

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;

    }

    // =========================
    // Get Service By ID
    // =========================
    public Service getServiceById(int id) {

        String sql = """
                     SELECT *
                     FROM Services
                     WHERE ServiceID = ?
                     """;

        try {

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return mapService(rs);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return null;

    }

    // =========================
    // Search Service
    // =========================
    public List<Service> searchService(String keyword) {

        List<Service> list = new ArrayList<>();

        String sql = """
                     SELECT *
                     FROM Services
                     WHERE Status = 1
                     AND ServiceName LIKE ?
                     ORDER BY ServiceName
                     """;

        try {

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                list.add(mapService(rs));

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;

    }

    // =========================
    // Get Number Of Services
    // =========================
    public int countServices() {

        String sql = """
                     SELECT COUNT(*)
                     FROM Services
                     WHERE Status = 1
                     """;

        try {

            PreparedStatement ps = connection.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt(1);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return 0;

    }

}