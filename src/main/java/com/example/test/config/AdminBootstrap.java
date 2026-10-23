package com.example.test.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public final class AdminBootstrap {
    private AdminBootstrap() { }

    public static void main(String[] args) throws Exception {
        JsonNode input = new ObjectMapper().readTree(System.in);
        String username = input.path("username").asText();
        String password = input.path("password").asText();
        String email = input.path("email").asText();
        if (!"fresh-fourthis".equals(input.path("confirmation").asText())
                || !username.matches("[A-Za-z0-9_-]{3,64}") || password.length() < 20
                || !email.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) {
            throw new IllegalArgumentException("Invalid bootstrap input");
        }
        String url = System.getenv("DB_URL");
        if (url == null || !url.startsWith("jdbc:mariadb://db:3306/fourthis?")) {
            throw new IllegalArgumentException("Bootstrap is restricted to the isolated fourthis database");
        }
        try (Connection connection = DriverManager.getConnection(url,
                System.getenv("DB_USERNAME"), System.getenv("DB_PASSWORD"))) {
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            connection.setAutoCommit(false);
            try {
                try (ResultSet count = connection.createStatement().executeQuery("SELECT COUNT(*) FROM users FOR UPDATE")) {
                    count.next();
                    if (count.getLong(1) != 0) throw new IllegalStateException("Bootstrap requires an empty user table");
                }
                long id;
                try (PreparedStatement insert = connection.prepareStatement(
                        "INSERT INTO users (username,password,name,email,role,is_email_verified,status) VALUES (?,?,?,?, 'ADMIN',true,true)",
                        java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    insert.setString(1, username);
                    insert.setString(2, new BCryptPasswordEncoder(12).encode(password));
                    insert.setString(3, "관리자");
                    insert.setString(4, email);
                    insert.executeUpdate();
                    try (ResultSet keys = insert.getGeneratedKeys()) {
                        if (!keys.next()) throw new IllegalStateException("No administrator identifier returned");
                        id = keys.getLong(1);
                    }
                }
                try (PreparedStatement profile = connection.prepareStatement("INSERT INTO admin_profiles (user_id,admin_id) VALUES (?,?)")) {
                    profile.setLong(1, id); profile.setString(2, username); profile.executeUpdate();
                }
                connection.commit();
            } catch (Exception failure) {
                connection.rollback();
                throw new IllegalStateException("Bootstrap failed; transaction rolled back");
            }
        }
        System.out.println("administrator_created=true");
    }
}
