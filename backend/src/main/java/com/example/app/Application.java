package com.example.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

@SpringBootApplication
@ConfigurationPropertiesScan
public class Application {
    public static void main(String[] args) {
        // Load .env file manually
        loadEnvFile();
        SpringApplication.run(Application.class, args);
    }
    
    private static void loadEnvFile() {
        try {
            File envFile = new File(".env");
            if (envFile.exists()) {
                Properties props = new Properties();
                props.load(new FileReader(envFile));
                
                // Set system properties for environment variables
                props.forEach((key, value) -> {
                    System.setProperty((String) key, (String) value);
                });
                
                System.out.println("Loaded " + props.size() + " environment variables from .env file");
            } else {
                System.out.println(".env file not found, using system environment variables");
            }
        } catch (IOException e) {
            System.err.println("Error loading .env file: " + e.getMessage());
        }
    }
}
