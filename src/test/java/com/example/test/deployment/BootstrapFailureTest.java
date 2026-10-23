package com.example.test.deployment;

import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;
import org.junit.Test;
import static org.junit.Assert.*;

public class BootstrapFailureTest {
    @Test public void malformedPrivateInputNeverAppearsInErrorOutput() throws Exception {
        ProcessBuilder builder = new ProcessBuilder(
                Paths.get(System.getProperty("java.home"), "bin", "java").toString(),
                "-cp", System.getProperty("java.class.path"),
                "com.example.test.config.AdminBootstrap");
        builder.redirectErrorStream(true);
        Process process = builder.start();
        process.getOutputStream().write("{password:synthetic-private-sentinel".getBytes(StandardCharsets.UTF_8));
        process.getOutputStream().close();
        assertTrue(process.waitFor(10, TimeUnit.SECONDS));
        String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        assertEquals(1, process.exitValue());
        assertEquals("administrator_created=false reason=bootstrap_failed", output.trim());
        assertFalse(output.contains("synthetic-private-sentinel"));
    }
}
