package model;

/**
 * Model class for Users.
 */
public class User {
    private int userID;
    private String username;
    private String password;
    private String fullName;
    private String phone;
    private String email;
    private int roleID;

    // Doctor specific info fields (optional / populated on demand)
    private String specialization;
    private int experienceYears;
    private String biography;
    private String education;
    private String coreSkills;

    // Constructors
    public User() {
    }

    public User(int userID, String username, String password, String fullName, String phone, String email, int roleID) {
        this.userID = userID;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.roleID = roleID;
    }

    // Getters and Setters
    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public String getEducation() {
        return education;
    }

    public void setEducation(String education) {
        this.education = education;
    }

    public String getCoreSkills() {
        return coreSkills;
    }

    public void setCoreSkills(String coreSkills) {
        this.coreSkills = coreSkills;
    }

    @Override
    public String toString() {
        return "User{" +
                "userID=" + userID +
                ", username='" + username + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                ", roleID=" + roleID +
                ", specialization='" + specialization + '\'' +
                ", experienceYears=" + experienceYears +
                ", biography='" + biography + '\'' +
                ", education='" + education + '\'' +
                ", coreSkills='" + coreSkills + '\'' +
                '}';
    }
}
