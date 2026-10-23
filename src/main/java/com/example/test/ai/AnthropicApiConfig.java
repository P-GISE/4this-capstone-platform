package com.example.test.ai;
public class AnthropicApiConfig {
    public static boolean isEnabled() {
        String key = System.getenv("ANTHROPIC_API_KEY");
        return "true".equalsIgnoreCase(System.getenv("AI_ENABLED"))
                && key != null && !key.trim().isEmpty();
    }
    public static String getApiKey() {
        return isEnabled() ? System.getenv("ANTHROPIC_API_KEY") : "";
    }
}
