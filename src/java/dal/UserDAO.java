package dal;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * Data Access Object for Users.
 * Covers all CRUD operations needed by Member 1 (Auth) and Member 6 (Admin).
 */
public class UserDAO extends DBContext {

    /**
     * Xây dựng đối tượng User từ ResultSet.
     */
    private User mapUser(ResultSet rs) throws SQLException {
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

    // =========================================================================
    // AUTHENTICATION METHODS (Thành viên 1)
    // =========================================================================

    /**
     * Đăng nhập: tìm user theo username và password.
     *
     * @param username Tên đăng nhập
     * @param password Mật khẩu (plain text - hệ thống demo)
     * @return User nếu đúng, null nếu sai
     */
    public User login(String username, String password) {
        String sql = "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID "
                + "FROM Users WHERE Username = ? AND Password = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Đăng ký tài khoản mới (Role mặc định = 4 - Customer).
     *
     * @param username Tên đăng nhập
     * @param password Mật khẩu
     * @param fullName Họ và tên
     * @param phone    Số điện thoại
     * @param email    Email
     * @return true nếu tạo thành công
     */
    public boolean register(String username, String password,
            String fullName, String phone, String email) {
        String sql = "INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) "
                + "VALUES (?, ?, ?, ?, ?, 4)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            ps.setString(5, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Kiểm tra username đã tồn tại chưa.
     *
     * @param username Tên đăng nhập cần kiểm tra
     * @return true nếu đã tồn tại
     */
    public boolean isUsernameExists(String username) {
        String sql = "SELECT 1 FROM Users WHERE Username = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Kiểm tra email đã tồn tại chưa.
     *
     * @param email Email cần kiểm tra
     * @return true nếu đã tồn tại
     */
    public boolean isEmailExists(String email) {
        String sql = "SELECT 1 FROM Users WHERE Email = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    // =========================================================================
    // READ METHODS
    // =========================================================================

    /**
     * Lấy thông tin user theo ID.
     *
     * @param userID ID của user
     * @return User object hoặc null
     */
    public User getUserByID(int userID) {
        String sql = "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID "
                + "FROM Users WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Lấy danh sách tất cả Users (dành cho Admin).
     *
     * @return Danh sách User
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.UserID, u.Username, u.Password, u.FullName, u.Phone, u.Email, u.RoleID, "
                   + "di.Specialization, di.ExperienceYears, di.Biography, di.Education, di.CoreSkills "
                   + "FROM Users u "
                   + "LEFT JOIN DoctorInfo di ON u.UserID = di.DoctorID "
                   + "ORDER BY u.RoleID, u.FullName";
        try (PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User(
                        rs.getInt("UserID"),
                        rs.getString("Username"),
                        rs.getString("Password"),
                        rs.getString("FullName"),
                        rs.getString("Phone"),
                        rs.getString("Email"),
                        rs.getInt("RoleID")
                );
                u.setSpecialization(rs.getString("Specialization"));
                u.setExperienceYears(rs.getInt("ExperienceYears"));
                u.setBiography(rs.getString("Biography"));
                u.setEducation(rs.getString("Education"));
                u.setCoreSkills(rs.getString("CoreSkills"));
                list.add(u);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    /**
     * Lấy danh sách Users theo Role (ví dụ: chỉ lấy Doctor).
     *
     * @param roleID ID của Role
     * @return Danh sách User theo Role
     */
    public List<User> getUsersByRole(int roleID) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID "
                + "FROM Users WHERE RoleID = ? ORDER BY FullName";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, roleID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    // =========================================================================
    // WRITE METHODS (dành cho Admin - Thành viên 1 & 6 phối hợp)
    // =========================================================================

    /**
     * Admin tạo tài khoản mới (Doctor hoặc Staff).
     *
     * @param username Tên đăng nhập
     * @param password Mật khẩu
     * @param fullName Họ và tên
     * @param phone    Số điện thoại
     * @param email    Email
     * @param roleID   Role (1=Admin, 2=Doctor, 3=Staff, 4=Customer)
     * @return true nếu thành công
     */
    public boolean createUser(String username, String password,
            String fullName, String phone, String email, int roleID) {
        return createUser(username, password, fullName, phone, email, roleID, null, 0, null, null, null);
    }

    public boolean createUser(String username, String password,
            String fullName, String phone, String email, int roleID,
            String specialization, int experienceYears, String biography,
            String education, String coreSkills) {
        String sql = "INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, phone);
            ps.setString(5, email);
            ps.setInt(6, roleID);
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0 && roleID == 2) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int doctorID = generatedKeys.getInt(1);
                        String docSql = "INSERT INTO DoctorInfo (DoctorID, Specialization, ExperienceYears, Biography, Education, CoreSkills) "
                                + "VALUES (?, ?, ?, ?, ?, ?)";
                        try (PreparedStatement docPs = connection.prepareStatement(docSql)) {
                            docPs.setInt(1, doctorID);
                            docPs.setString(2, specialization);
                            docPs.setInt(3, experienceYears);
                            docPs.setString(4, biography);
                            docPs.setString(5, education);
                            docPs.setString(6, coreSkills);
                            docPs.executeUpdate();
                        }
                    }
                }
            }
            return affectedRows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Cập nhật thông tin người dùng.
     *
     * @param userID   ID user cần cập nhật
     * @param fullName Họ và tên mới
     * @param phone    Số điện thoại mới
     * @param email    Email mới
     * @param roleID   Role mới
     * @return true nếu thành công
     */
    public boolean updateUser(int userID, String fullName,
            String phone, String email, int roleID) {
        return updateUser(userID, fullName, phone, email, roleID, null, 0, null, null, null);
    }

    public boolean updateUser(int userID, String fullName,
            String phone, String email, int roleID,
            String specialization, int experienceYears, String biography,
            String education, String coreSkills) {
        String sql = "UPDATE Users SET FullName = ?, Phone = ?, Email = ?, RoleID = ? WHERE UserID = ?";
        try {
            connection.setAutoCommit(false);
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, phone);
                ps.setString(3, email);
                ps.setInt(4, roleID);
                ps.setInt(5, userID);
                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    if (roleID == 2) {
                        // Check if DoctorInfo already exists
                        String checkSql = "SELECT 1 FROM DoctorInfo WHERE DoctorID = ?";
                        boolean exists = false;
                        try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
                            checkPs.setInt(1, userID);
                            try (ResultSet rs = checkPs.executeQuery()) {
                                exists = rs.next();
                            }
                        }
                        String docSql;
                        if (exists) {
                            docSql = "UPDATE DoctorInfo SET Specialization = ?, ExperienceYears = ?, Biography = ?, Education = ?, CoreSkills = ? WHERE DoctorID = ?";
                        } else {
                            docSql = "INSERT INTO DoctorInfo (Specialization, ExperienceYears, Biography, Education, CoreSkills, DoctorID) VALUES (?, ?, ?, ?, ?, ?)";
                        }
                        try (PreparedStatement docPs = connection.prepareStatement(docSql)) {
                            docPs.setString(1, specialization);
                            docPs.setInt(2, experienceYears);
                            docPs.setString(3, biography);
                            docPs.setString(4, education);
                            docPs.setString(5, coreSkills);
                            docPs.setInt(6, userID);
                            docPs.executeUpdate();
                        }
                    } else {
                        // If changing role from Doctor to another role, delete DoctorInfo
                        String deleteSql = "DELETE FROM DoctorInfo WHERE DoctorID = ?";
                        try (PreparedStatement deletePs = connection.prepareStatement(deleteSql)) {
                            deletePs.setInt(1, userID);
                            deletePs.executeUpdate();
                        }
                    }
                }
                connection.commit();
                return affectedRows > 0;
            } catch (SQLException ex) {
                connection.rollback();
                throw ex;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Cập nhật mật khẩu người dùng.
     *
     * @param userID      ID user
     * @param newPassword Mật khẩu mới
     * @return true nếu thành công
     */
    public boolean updatePassword(int userID, String newPassword) {
        String sql = "UPDATE Users SET Password = ? WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, userID);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Xoá người dùng theo ID (chỉ Admin).
     *
     * @param userID ID user cần xoá
     * @return true nếu thành công
     */
    public boolean deleteUser(int userID) {
        String sql = "DELETE FROM Users WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userID);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Cập nhật thông tin cá nhân (Customer/Doctor/Staff tự sửa profile của mình).
     *
     * @param userID   ID user
     * @param fullName Họ và tên mới
     * @param phone    Số điện thoại mới
     * @param email    Email mới
     * @return true nếu thành công
     */
    public boolean updateProfile(int userID, String fullName, String phone, String email) {
        String sql = "UPDATE Users SET FullName = ?, Phone = ?, Email = ? WHERE UserID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setInt(4, userID);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

    /**
     * Get all doctors along with their specialization and biography from DoctorInfo.
     * @return List of Users (Doctors) with detailed information
     */
    public List<User> getDoctorsWithDetails() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.UserID, u.Username, u.Password, u.FullName, u.Phone, u.Email, u.RoleID, "
                   + "di.Specialization, di.ExperienceYears, di.Biography, di.Education, di.CoreSkills "
                   + "FROM Users u "
                   + "LEFT JOIN DoctorInfo di ON u.UserID = di.DoctorID "
                   + "WHERE u.RoleID = 2 ORDER BY u.FullName";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User(
                        rs.getInt("UserID"),
                        rs.getString("Username"),
                        rs.getString("Password"),
                        rs.getString("FullName"),
                        rs.getString("Phone"),
                        rs.getString("Email"),
                        rs.getInt("RoleID")
                );
                u.setSpecialization(rs.getString("Specialization"));
                u.setExperienceYears(rs.getInt("ExperienceYears"));
                u.setBiography(rs.getString("Biography"));
                u.setEducation(rs.getString("Education"));
                u.setCoreSkills(rs.getString("CoreSkills"));
                list.add(u);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }

    public model.CustomerInfo getCustomerInfo(int customerID) {
        String sql = "SELECT CustomerID, Address, Gender, DateOfBirth FROM CustomerInfo WHERE CustomerID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new model.CustomerInfo(
                        rs.getInt("CustomerID"),
                        rs.getString("Address"),
                        rs.getString("Gender"),
                        rs.getDate("DateOfBirth")
                    );
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        // Return default empty info if not exists
        return new model.CustomerInfo(customerID, "", "", null);
    }

    public boolean updateCustomerProfile(User user, model.CustomerInfo customer) {
        String updateUsersSql = "UPDATE Users SET FullName = ?, Phone = ?, Email = ? WHERE UserID = ?";
        String upsertCustomerInfoSql = "IF EXISTS (SELECT 1 FROM CustomerInfo WHERE CustomerID = ?)\n"
                                     + "BEGIN\n"
                                     + "    UPDATE CustomerInfo SET Address = ?, Gender = ?, DateOfBirth = ? WHERE CustomerID = ?\n"
                                     + "END\n"
                                     + "ELSE\n"
                                     + "BEGIN\n"
                                     + "    INSERT INTO CustomerInfo (CustomerID, Address, Gender, DateOfBirth) VALUES (?, ?, ?, ?)\n"
                                     + "END";
        Connection conn = null;
        try {
            conn = connection;
            conn.setAutoCommit(false);
            
            // 1. Update Users table
            try (PreparedStatement ps = conn.prepareStatement(updateUsersSql)) {
                ps.setString(1, user.getFullName());
                ps.setString(2, user.getPhone());
                ps.setString(3, user.getEmail());
                ps.setInt(4, user.getUserID());
                ps.executeUpdate();
            }
            
            // 2. Upsert CustomerInfo table
            try (PreparedStatement ps = conn.prepareStatement(upsertCustomerInfoSql)) {
                ps.setInt(1, customer.getCustomerID());
                
                ps.setString(2, customer.getAddress());
                ps.setString(3, customer.getGender());
                ps.setDate(4, customer.getDateOfBirth());
                ps.setInt(5, customer.getCustomerID());
                
                ps.setInt(6, customer.getCustomerID());
                ps.setString(7, customer.getAddress());
                ps.setString(8, customer.getGender());
                ps.setDate(9, customer.getDateOfBirth());
                
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException e) {
                    Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, e);
                }
            }
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, e);
                }
            }
        }
        return false;
    }
    /**
     * Tìm khách hàng (RoleID = 4) theo số điện thoại.
     */
    public User getCustomerByPhone(String phone) {
        String sql = "SELECT UserID, Username, Password, FullName, Phone, Email, RoleID FROM Users WHERE Phone = ? AND RoleID = 4";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Tạo tài khoản mới cho khách vãng lai và trả về UserID vừa tạo.
     */
    public int createWalkInCustomer(String fullName, String phone, String email) {
        String sql = "INSERT INTO Users (Username, Password, FullName, Phone, Email, RoleID) VALUES (?, '123', ?, ?, ?, 4)";
        String username = "walkin_" + (phone != null && !phone.trim().isEmpty() ? phone.trim() : String.valueOf(System.currentTimeMillis()));
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            ps.setString(4, email);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return -1;
    }
}
