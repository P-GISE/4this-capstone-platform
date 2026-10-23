package com.example.test.config;

import org.junit.Test;
import static org.junit.Assert.*;

public class AdminBootstrapEmailTest {
    @Test public void acceptsOrdinaryAddressAndRejectsWhitespaceAndBackslashes() {
        assertTrue(AdminBootstrap.isValidEmail("admin@example.invalid"));
        assertFalse(AdminBootstrap.isValidEmail("ad min@example.invalid"));
        assertFalse(AdminBootstrap.isValidEmail("admin@example. invalid"));
        assertFalse(AdminBootstrap.isValidEmail("ad\\min@example.invalid"));
        assertFalse(AdminBootstrap.isValidEmail("admin@example\\.invalid"));
    }
}
