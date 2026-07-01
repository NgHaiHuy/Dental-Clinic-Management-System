package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * Data Access Object for Users.
 */
public class UserDAO extends DBContext {

    /**
     * Get user by username and password (Login).
     * @param username Username
     * @param password Password
     * @return User object or null if not found
     */
    public User login(String username, String password) {
        String sql = "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID " +
                     "FROM Users WHERE Username = ? AND Password = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password); // Note: ideally password should be hashed
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("UserID"),
                            rs.getString("Username"),
                            rs.getString("Password"),
                            rs.getString("FullName"),
                            rs.getString("Phone"),
                            rs.getString("Email"),
                            rs.getInt("RoleID")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}
