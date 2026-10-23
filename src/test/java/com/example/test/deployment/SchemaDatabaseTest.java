package com.example.test.deployment;

import org.junit.Test;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
import static org.junit.Assert.*;

public class SchemaDatabaseTest {
    static void initialize(Connection connection) throws Exception {
        String ddl = new String(Files.readAllBytes(Paths.get("database/schema.sql")), StandardCharsets.UTF_8);
        try (Statement statement = connection.createStatement()) {
            for (String part : ddl.replaceAll("(?m)^--.*$", "").split(";")) {
                if (!part.trim().isEmpty()) statement.execute(part);
            }
        }
    }

    @Test
    public void freshSchemaSupportsSyntheticCoreRecordsWithoutSeededAccounts() throws Exception {
        try (Connection connection = DriverManager.getConnection(
                "jdbc:h2:mem:fourthis_schema;MODE=MySQL;DATABASE_TO_LOWER=TRUE", "sa", "")) {
            initialize(connection);
            try (Statement sql = connection.createStatement()) {
                try (ResultSet rows = sql.executeQuery("SELECT COUNT(*) FROM users")) {
                    assertTrue(rows.next()); assertEquals(0, rows.getInt(1));
                }
                sql.executeUpdate("INSERT INTO users(username,password,name,email,role) VALUES('synthetic','test-only-hash','Synthetic','synthetic@example.invalid','STUDENT')");
                sql.executeUpdate("INSERT INTO projects(title,description,status,created_by) VALUES('Synthetic project','Fixture','ACTIVE',1)");
                sql.executeUpdate("INSERT INTO project_members(project_id,user_id,role,is_approved) VALUES(1,1,'LEADER',TRUE)");
                sql.executeUpdate("INSERT INTO equipment(name,asset_code,quantity,available_quantity) VALUES('Synthetic equipment','fixture-001',2,2)");
                sql.executeUpdate("INSERT INTO equipment_reservations(user_id,equipment_id,note) VALUES(1,1,'Fixture')");
                sql.executeUpdate("INSERT INTO notices(title,content,writer_id) VALUES('Synthetic notice','Fixture',1)");
                try (ResultSet rows = sql.executeQuery("SELECT COUNT(*) FROM users u JOIN project_members m ON m.user_id=u.id JOIN projects p ON p.id=m.project_id WHERE u.username='synthetic' AND m.is_approved=TRUE")) {
                    assertTrue(rows.next()); assertEquals(1, rows.getInt(1));
                }
                try (ResultSet rows = sql.executeQuery("SELECT status FROM equipment_reservations WHERE id=1")) {
                    assertTrue(rows.next()); assertEquals("WAITING", rows.getString(1));
                }
                try (ResultSet rows = connection.getMetaData().getTables(null, "public", "%", new String[]{"TABLE"})) {
                    int count=0; while(rows.next()) count++; assertEquals(50,count);
                }
            }
        }
    }
}
