package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO extends DBContext {

    private User mapUser(ResultSet rs) throws Exception {

    User u = new User();

    u.setUserID(rs.getInt("UserID"));
    u.setUsername(rs.getString("Username"));
    u.setPassword(rs.getString("Password"));
    u.setFullName(rs.getString("FullName"));
    u.setPhone(rs.getString("Phone"));
    u.setEmail(rs.getString("Email"));
    u.setRoleID(rs.getInt("RoleID"));

    return u;
}
    
    public List<User> getAllCustomers() {

    List<User> list = new ArrayList<>();

    String sql = """
                 SELECT *
                 FROM Users
                 WHERE RoleID = 4
                 ORDER BY FullName
                 """;

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            list.add(mapUser(rs));

        }

    } catch (Exception e) {

        e.printStackTrace();

    }

    return list;

}
    
    public List<User> getAllDoctors() {

    List<User> list = new ArrayList<>();

    String sql = """
                 SELECT *
                 FROM Users
                 WHERE RoleID = 2
                 ORDER BY FullName
                 """;

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            list.add(mapUser(rs));

        }

    } catch (Exception e) {

        e.printStackTrace();

    }

    return list;

}
    
    public User getUserById(int id) {

    String sql = """
                 SELECT *
                 FROM Users
                 WHERE UserID = ?
                 """;

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        ps.setInt(1, id);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            return mapUser(rs);

        }

    } catch (Exception e) {

        e.printStackTrace();

    }

    return null;

}
    
    public List<User> searchCustomer(String keyword) {

    List<User> list = new ArrayList<>();

    String sql = """
                 SELECT *
                 FROM Users
                 WHERE RoleID = 4
                 AND (
                        FullName LIKE ?
                     OR Phone LIKE ?
                     )
                 ORDER BY FullName
                 """;

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        String search = "%" + keyword + "%";

        ps.setString(1, search);
        ps.setString(2, search);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            list.add(mapUser(rs));

        }

    } catch (Exception e) {

        e.printStackTrace();

    }

    return list;

}
}
