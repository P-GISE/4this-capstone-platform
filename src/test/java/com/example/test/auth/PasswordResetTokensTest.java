package com.example.test.auth;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.Test;
import static org.junit.Assert.*;

public class PasswordResetTokensTest {
    static final class MutableClock extends Clock {
        long now;
        @Override public ZoneId getZone() { return ZoneOffset.UTC; }
        @Override public Clock withZone(ZoneId zone) { return this; }
        @Override public Instant instant() { return Instant.ofEpochMilli(now); }
        @Override public long millis() { return now; }
    }

    @Test public void randomTicketsAreSingleUseAndUnrelatedTokensCannotMatch() {
        PasswordResetTokens tokens = new PasswordResetTokens();
        String first = tokens.issue(1L, "synthetic@example.invalid", "synthetic-hash");
        assertTrue(first.matches("[A-Za-z0-9_-]{43}"));
        assertNull(tokens.consume("A".repeat(43)));
        assertEquals(Long.valueOf(1), tokens.consume(first).userId);
        assertNull(tokens.consume(first));
    }

    @Test public void expiryAndRestartFailClosedWithoutReusingTickets() {
        MutableClock clock = new MutableClock();
        PasswordResetTokens tokens = new PasswordResetTokens(clock);
        String first = tokens.issue(1L, "synthetic@example.invalid", "synthetic-hash");
        assertNull(new PasswordResetTokens(clock).consume(first));
        clock.now = 15 * 60 * 1000;
        assertNull(tokens.consume(first));
    }

    @Test public void newRequestInvalidatesEarlierTicketForTheSameAccount() {
        PasswordResetTokens tokens = new PasswordResetTokens();
        String first = tokens.issue(1L, "synthetic@example.invalid", "synthetic-hash");
        String second = tokens.issue(1L, "synthetic@example.invalid", "synthetic-hash");
        assertNotEquals(first, second);
        assertNull(tokens.consume(first));
        assertNotNull(tokens.consume(second));
    }

    @Test public void concurrentConsumptionSucceedsOnlyOnce() throws Exception {
        PasswordResetTokens tokens = new PasswordResetTokens();
        String raw = tokens.issue(1L, "synthetic@example.invalid", "synthetic-hash");
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            Future<Boolean> first = executor.submit(() -> { start.await(); return tokens.consume(raw) != null; });
            Future<Boolean> second = executor.submit(() -> { start.await(); return tokens.consume(raw) != null; });
            start.countDown();
            assertNotEquals(first.get(), second.get());
        } finally { executor.shutdownNow(); }
    }

    @Test public void accountAddressAndGlobalRequestLimitsAreIndependent() {
        PasswordResetTokens account = new PasswordResetTokens();
        for (int i = 0; i < 3; i++) assertTrue(account.allowRequest("same@example.invalid", "address-" + i));
        assertFalse(account.allowRequest(" SAME@example.invalid ", "new-address"));
        PasswordResetTokens address = new PasswordResetTokens();
        for (int i = 0; i < 10; i++) assertTrue(address.allowRequest("user" + i + "@example.invalid", "same-address"));
        assertFalse(address.allowRequest("new@example.invalid", "same-address"));
        PasswordResetTokens global = new PasswordResetTokens();
        for (int i = 0; i < 100; i++) assertTrue(global.allowRequest("user" + i + "@example.invalid", "address-" + i));
        assertFalse(global.allowRequest("new@example.invalid", "new-address"));
    }

    @Test public void ticketCapacityIsBoundedAndExpiredEntriesAreReclaimed() {
        MutableClock clock = new MutableClock();
        PasswordResetTokens tokens = new PasswordResetTokens(clock);
        for (long i = 1; i <= 500; i++) assertNotNull(tokens.issue(i, "synthetic@example.invalid", "hash"));
        assertNull(tokens.issue(501L, "synthetic@example.invalid", "hash"));
        clock.now = 15 * 60 * 1000;
        assertNotNull(tokens.issue(501L, "synthetic@example.invalid", "hash"));
        assertTrue(tokens.allowRequest("synthetic@example.invalid", "address"));
    }
}
