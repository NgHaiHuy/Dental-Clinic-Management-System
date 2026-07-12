package model;

/**
 * Model class for Roles.
 * RoleID mapping:
 *  1 = Admin
 *  2 = Doctor
 *  3 = Staff (Receptionist)
 *  4 = Customer
 */
public class Role {

    // Constants cho dễ sử dụng trong code
    public static final int ADMIN    = 1;
    public static final int DOCTOR   = 2;
    public static final int STAFF    = 3;
    public static final int CUSTOMER = 4;

    private int roleID;
    private String roleName;

    public Role() {
    }

    public Role(int roleID, String roleName) {
        this.roleID = roleID;
        this.roleName = roleName;
    }

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    /**
     * Trả về tên tiếng Việt của Role.
     */
    public static String getRoleNameVi(int roleID) {
        switch (roleID) {
            case ADMIN:    return "Quản trị viên";
            case DOCTOR:   return "Bác sĩ";
            case STAFF:    return "Nhân viên tiếp đón";
            case CUSTOMER: return "Khách hàng";
            default:       return "Không xác định";
        }
    }

    /**
     * Trả về URL dashboard tương ứng với Role.
     */
    public static String getDashboardUrl(int roleID) {
        switch (roleID) {
            case ADMIN:    return "/admin/dashboard";
            case DOCTOR:   return "/doctor/dashboard";
            case STAFF:    return "/receptionist/dashboard";
            case CUSTOMER: return "/customer/dashboard";
            default:       return "/auth/login";
        }
    }

    @Override
    public String toString() {
        return "Role{roleID=" + roleID + ", roleName='" + roleName + "'}";
    }
}
