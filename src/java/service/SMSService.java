package service;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service to handle SMS notifications.
 * In a real-world setting, this integrates with SMS APIs (like Twilio, eSMS, etc.).
 */
public class SMSService {
    private static final Logger LOGGER = Logger.getLogger(SMSService.class.getName());

    /**
     * Send SMS to a phone number.
     * @param phone The recipient's phone number
     * @param message The SMS text content
     * @return true if sent successfully, false otherwise
     */
    public static boolean sendSMS(String phone, String message) {
        System.out.println("==================================================");
        System.out.println("[SMS GATEWAY] THÔNG BÁO TỪ NHA KHOA SMILECARE");
        System.out.println("Gửi đến SĐT: " + phone);
        System.out.println("Nội dung: " + message);
        System.out.println("==================================================");
        
        LOGGER.log(Level.INFO, "SMS successfully sent to {0}: {1}", new Object[]{phone, message});
        return true;
    }
}
