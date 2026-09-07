package com.example.test.ai;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class AnthropicApiConfig {
    private static final String CONFIG_PATH = "/config/anthropic.properties"; // src/main/resources/config/

    private static final Properties properties = loadProperties();

    private static Properties loadProperties() {
        Properties props = new Properties();
        try (InputStream input = AnthropicApiConfig.class.getResourceAsStream(CONFIG_PATH)) {
            if (input != null) {
                props.load(input);
            } else {
                System.err.println("Anthropic 설정 파일을 찾을 수 없습니다: " + CONFIG_PATH);
            }
        } catch (IOException e) {
            System.err.println("Anthropic 설정 파일 로딩 실패: " + e.getMessage());
        }
        return props;
    }

    public static String getApiKey() {
        String envApiKey = System.getenv("ANTHROPIC_API_KEY");
        if (envApiKey != null && !envApiKey.isBlank()) {
            return envApiKey;
        }
        return properties.getProperty("anthropic.api.key", "");
    }
}
