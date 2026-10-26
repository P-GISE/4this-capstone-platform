package com.example.test.deployment;

import com.example.test.config.GlobalExceptionHandler;
import org.junit.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import static org.junit.Assert.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

public class ServletPlatformBoundaryTest {
    @RestController public static class Routes {
        @GetMapping(value="/bind", produces="text/plain;charset=UTF-8")
        public String bind(@RequestParam String name) { return name; }
        @GetMapping("/missing") public void missing() throws NoResourceFoundException {
            throw new NoResourceFoundException(HttpMethod.GET, "synthetic-missing", "/missing");
        }
        @GetMapping("/oversize") public void oversize() { throw new MaxUploadSizeExceededException(10485760); }
    }
    private MockMvc mvc() { return MockMvcBuilders.standaloneSetup(new Routes())
        .setControllerAdvice(new GlobalExceptionHandler()).build(); }
    @Test public void inferredRequestParameterNamePreservesUtf8Binding() throws Exception {
        assertEquals("합성 경계",mvc().perform(get("/bind").param("name","합성 경계"))
            .andReturn().getResponse().getContentAsString(java.nio.charset.StandardCharsets.UTF_8));
    }
    @Test public void missingStaticResourceCannotBecomeAnInternalError() throws Exception {
        assertEquals(404,mvc().perform(get("/missing")).andReturn().getResponse().getStatus());
    }
    @Test public void servletUploadLimitHasABoundedClientError() throws Exception {
        assertEquals(413,mvc().perform(get("/oversize")).andReturn().getResponse().getStatus());
    }
}
