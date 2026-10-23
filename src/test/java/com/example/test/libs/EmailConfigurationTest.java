package com.example.test.libs;

import com.example.test.config.ExternalServiceUnavailableException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import org.junit.Test;
import static org.junit.Assert.*;

public class EmailConfigurationTest {
    private Map<String, String> config(String mode, String port) {
        Map<String, String> env = new HashMap<>();
        env.put("EMAIL_ENABLED", "true"); env.put("SMTP_HOST", "smtp.naver.com");
        env.put("SMTP_USERNAME", "synthetic@example.invalid"); env.put("SMTP_PASSWORD", "synthetic-only");
        env.put("SMTP_FROM", "synthetic@example.invalid");
        env.put("SMTP_SECURITY", mode); env.put("SMTP_PORT", port); return env;
    }
    private Properties settings(Map<String, String> env) throws Exception {
        Constructor<Email> constructor;
        try { constructor = Email.class.getDeclaredConstructor(Map.class); }
        catch (NoSuchMethodException missing) { throw new AssertionError("SMTP settings must accept explicit deployment configuration", missing); }
        constructor.setAccessible(true);
        Email client = constructor.newInstance(env);
        Method method = Email.class.getDeclaredMethod("smtpProperties"); method.setAccessible(true);
        try { return (Properties) method.invoke(client); }
        catch (java.lang.reflect.InvocationTargetException failure) { throw (RuntimeException) failure.getCause(); }
    }
    @Test public void naver465UsesImplicitSslWithoutStartTls() throws Exception {
        Properties p = settings(config("ssl", "465"));
        assertEquals("true", p.getProperty("mail.smtp.ssl.enable"));
        assertEquals("false", p.getProperty("mail.smtp.starttls.enable"));
        assertEquals("false", p.getProperty("mail.smtp.starttls.required"));
        assertEquals("true", p.getProperty("mail.smtp.auth"));
        assertEquals("true", p.getProperty("mail.smtp.ssl.checkserveridentity"));
        assertEquals("465", p.getProperty("mail.smtp.port"));
        assertNull(p.getProperty("mail.smtp.ssl.trust"));
    }
    @Test public void existing587RequiresStartTlsAndCertificateValidation() throws Exception {
        Properties p = settings(config("starttls", "587"));
        assertEquals("false", p.getProperty("mail.smtp.ssl.enable"));
        assertEquals("true", p.getProperty("mail.smtp.starttls.required"));
        assertEquals("true", p.getProperty("mail.smtp.starttls.enable"));
        assertEquals("true", p.getProperty("mail.smtp.ssl.checkserveridentity"));
        assertEquals("10000", p.getProperty("mail.smtp.connectiontimeout"));
    }
    @Test public void disabledIncompleteAndInvalidConfigurationCannotCreateTransportSettings() throws Exception {
        for (String field : new String[]{"EMAIL_ENABLED", "SMTP_HOST", "SMTP_USERNAME", "SMTP_PASSWORD", "SMTP_FROM", "SMTP_SECURITY", "SMTP_PORT"}) {
            Map<String, String> env = config("ssl", "465"); env.remove(field); rejects(env);
        }
        for (String mode : new String[]{"none", "SSL", ""}) rejects(config(mode, "465"));
        for (String port : new String[]{"0", "65536", "abc", "465\n"}) rejects(config("ssl", port));
        Map<String, String> bad = config("ssl", "465"); bad.put("SMTP_HOST", "smtp.naver.com\n"); rejects(bad);
        bad = config("ssl", "465"); bad.put("SMTP_FROM", "synthetic@example.invalid, other@example.invalid"); rejects(bad);
        bad = config("ssl", "465"); bad.put("EMAIL_ENABLED", "false"); rejects(bad);
    }
    private void rejects(Map<String, String> env) throws Exception {
        try { settings(env); fail("Invalid/disabled mail configuration must be rejected"); }
        catch (ExternalServiceUnavailableException expected) { }
    }
}
