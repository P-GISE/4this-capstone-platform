package com.example.test.deployment;

import com.example.test.ai.AnthropicApiConfig;
import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthServiceImpl;
import com.example.test.config.AuthInterceptor;
import com.example.test.config.ExternalServiceUnavailableException;
import com.example.test.config.GlobalExceptionHandler;
import com.example.test.libs.Email;
import java.lang.reflect.Field;
import org.junit.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import static org.junit.Assert.*;

public class DisabledIntegrationTest {
    @Test(expected = ExternalServiceUnavailableException.class)
    public void smtpDisabledDoesNotConnect() {
        new Email().sendNaverEmail("synthetic", "synthetic", "synthetic@example.invalid");
    }

    @Test(expected = ExternalServiceUnavailableException.class)
    public void registrationRejectsBeforeUnconfiguredDatabaseIsUsed() throws Exception {
        AuthServiceImpl service = new AuthServiceImpl();
        Field field = AuthServiceImpl.class.getDeclaredField("email");
        field.setAccessible(true);
        field.set(service, new Email());
        AuthDto applicant = new AuthDto();
        applicant.setRole("STUDENT");
        service.register(applicant);
    }

    @Test public void publicRegistrationCannotChoosePrivilegedRole() {
        for (String role : new String[]{"ADMIN", "STAFF", "PROFESSOR", "ASSISTANT"}) {
            AuthDto applicant = new AuthDto(); applicant.setRole(role);
            assertEquals(com.example.test.auth.AuthService.RegistrationResult.FAILURE,
                    new AuthServiceImpl().register(applicant));
        }
    }

    @Test public void aiDisabledCannotReachControllerOrCredits() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/ai/ask-json");
        MockHttpServletResponse response = new MockHttpServletResponse();
        assertFalse(new AuthInterceptor().preHandle(request, response, new Object()));
        assertEquals(503, response.getStatus());
        assertFalse(AnthropicApiConfig.isEnabled());
        assertEquals("", AnthropicApiConfig.getApiKey());
    }

    @Test public void healthAndLoginAssetsDoNotCreateSessions() throws Exception {
        for (String path : new String[]{"/health", "/resources/css/style.css"}) {
            MockHttpServletRequest request = new MockHttpServletRequest("GET", path);
            assertTrue(new AuthInterceptor().preHandle(request, new MockHttpServletResponse(), new Object()));
            assertNull(request.getSession(false));
        }
    }

    @Test public void unavailableExternalServiceIsNotSuccessfulHttpResponse() {
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE,
                new GlobalExceptionHandler().handleUnavailable(
                        new ExternalServiceUnavailableException("synthetic")).getStatus());
    }
}
