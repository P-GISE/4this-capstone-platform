package com.example.test.config;
import java.nio.file.Paths;
public final class RuntimePaths {
    private RuntimePaths() { }
    public static String uploads(String child) {
        String base = System.getenv().getOrDefault("UPLOAD_DIR", "/app/uploads");
        return Paths.get(base, child).toString();
    }
}
