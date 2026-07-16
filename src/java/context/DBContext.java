package context;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext to connect to SQL Server database for Dental Clinic Management System.
 */
public class DBContext {
    protected Connection connection;

    public DBContext() {
        try {
            Properties properties = new Properties();
            // Try loading from classpath
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("../../WEB-INF/ConnectDB.properties");
            if (inputStream == null) {
                inputStream = getClass().getClassLoader().getResourceAsStream("../ConnectDB.properties");
            }
            if (inputStream == null) {
                inputStream = getClass().getClassLoader().getResourceAsStream("ConnectDB.properties");
            }
            
            String user = "sa";
            String pass = "123";
            String url = "jdbc:sqlserver://localhost:1433;databaseName=DentalClinicDB;trustServerCertificate=true";
            
            if (inputStream != null) {
                properties.load(inputStream);
                user = properties.getProperty("userID", user);
                pass = properties.getProperty("password", pass);
                url = properties.getProperty("url", url);
            }
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException | SQLException | IOException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public Connection getConnection() {
        return connection;
    }
}
