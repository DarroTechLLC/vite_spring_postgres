package com.example.app.controllers;

import com.example.app.dto.HealthResponse;
import com.example.app.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
@RequiredArgsConstructor
public class HealthController {
    
    private final JdbcTemplate jdbcTemplate;
    private final UserRepository userRepository;
    
    @GetMapping("/db")
    public HealthResponse checkDatabase() {
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return new HealthResponse(true, "Database connection successful");
        } catch (Exception e) {
            return new HealthResponse(false, "Database connection failed: " + e.getMessage());
        }
    }
    
    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        try {
            long userCount = userRepository.count();
            stats.put("userCount", userCount);
            stats.put("status", "success");
        } catch (Exception e) {
            stats.put("userCount", 0);
            stats.put("status", "error");
            stats.put("error", e.getMessage());
        }
        return stats;
    }
}
