package com.example.test.deployment;

import static org.junit.Assert.assertTrue;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.junit.Test;

public class RuntimeSafetyTest {
    private String source(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }

    @Test
    public void databaseRequiresDeploymentEnvironment() throws Exception {
        String config = source("src/main/webapp/WEB-INF/spring/root-context.xml");
        assertTrue("DB URL must come from deployment environment", config.contains("${DB_URL}"));
        assertTrue("DB password must come from deployment environment", config.contains("${DB_PASSWORD}"));
        assertTrue("DB username must come from deployment environment", config.contains("${DB_USERNAME}"));
    }

    @Test
    public void smtpHasNoEmbeddedCredentialAndRequiresOptIn() throws Exception {
        String code = source("src/main/java/com/example/test/libs/Email.java");
        assertTrue("SMTP must require explicit enable", code.contains("EMAIL_ENABLED"));
        assertTrue("SMTP password must come from environment", code.contains("SMTP_PASSWORD"));
        assertTrue("SMTP failures must not be silently accepted", code.contains("throw new"));
    }

    @Test
    public void aiCannotFallBackToBundledCredentials() throws Exception {
        String code = source("src/main/java/com/example/test/ai/AnthropicApiConfig.java");
        assertTrue("AI must require explicit opt-in", code.contains("AI_ENABLED"));
        assertTrue("AI must not read bundled credentials", !code.contains("getResourceAsStream"));
    }
}
