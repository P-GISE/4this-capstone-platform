package com.example.test.auth;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

final class PasswordResetTokens {
    private static final long TTL_MILLIS = 15 * 60 * 1000;
    private final Clock clock;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, Ticket> tickets = new HashMap<>();
    private final Map<String, Window> attempts = new HashMap<>();

    PasswordResetTokens() { this(Clock.systemUTC()); }
    PasswordResetTokens(Clock clock) { this.clock = clock; }

    synchronized boolean allowRequest(String email, String clientAddress) {
        cleanup();
        String accountKey = "account:" + digest(email.trim().toLowerCase(java.util.Locale.ROOT));
        String addressKey = "address:" + digest(clientAddress);
        String[] keys = {accountKey, addressKey, "global"};
        int[] limits = {3, 10, 100};
        int absent = 0;
        for (int i = 0; i < keys.length; i++) {
            Window window = attempts.get(keys[i]);
            if (window == null) absent++;
            else if (window.count >= limits[i]) return false;
        }
        if (attempts.size() + absent > 5000) return false;
        for (String key : keys) attempts.computeIfAbsent(key, ignored -> new Window(clock.millis())).count++;
        return true;
    }

    synchronized String issue(Long userId, String email, String passwordHash) {
        cleanup();
        tickets.entrySet().removeIf(entry -> userId.equals(entry.getValue().userId));
        if (tickets.size() >= 500) return null;
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String raw = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        tickets.put(digest(raw), new Ticket(userId, email, passwordHash, clock.millis() + TTL_MILLIS));
        return raw;
    }

    synchronized Ticket consume(String raw) {
        cleanup();
        return raw != null && raw.matches("[A-Za-z0-9_-]{43}") ? tickets.remove(digest(raw)) : null;
    }

    synchronized void revoke(String raw) { tickets.remove(digest(raw)); }

    private void cleanup() {
        long now = clock.millis();
        tickets.entrySet().removeIf(entry -> entry.getValue().expiresAt <= now);
        attempts.entrySet().removeIf(entry -> entry.getValue().startedAt + TTL_MILLIS <= now);
    }

    private static String digest(String value) {
        try {
            return Base64.getEncoder().encodeToString(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException impossible) { throw new IllegalStateException("SHA-256 unavailable", impossible); }
    }

    static final class Ticket {
        final Long userId;
        final String email;
        final String passwordHash;
        final long expiresAt;
        Ticket(Long userId, String email, String passwordHash, long expiresAt) {
            this.userId = userId; this.email = email; this.passwordHash = passwordHash; this.expiresAt = expiresAt;
        }
    }

    private static final class Window {
        final long startedAt;
        int count;
        Window(long startedAt) { this.startedAt = startedAt; }
    }
}
