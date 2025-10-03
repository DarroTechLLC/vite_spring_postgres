package com.example.app.health;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
@RequiredArgsConstructor
public class HealthController {
    
    private final JdbcTemplate jdbcTemplate;
    
    @GetMapping("/db")
    public HealthResponse checkDatabase() {
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return new HealthResponse(true, "Database connection successful");
        } catch (Exception e) {
            return new HealthResponse(false, "Database connection failed: " + e.getMessage());
        }
    }
}
