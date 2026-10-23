package com.example.test.config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
public class HealthController {
    @Autowired private JdbcTemplate jdbc;
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        try {
            Integer result = jdbc.queryForObject("SELECT 1", Integer.class);
            return Integer.valueOf(1).equals(result) ? ResponseEntity.ok("ok")
                    : ResponseEntity.status(503).body("unavailable");
        } catch (RuntimeException failure) {
            return ResponseEntity.status(503).body("unavailable");
        }
    }
}
