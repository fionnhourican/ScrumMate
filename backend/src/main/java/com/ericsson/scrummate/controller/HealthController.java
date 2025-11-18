package com.ericsson.scrummate.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", System.currentTimeMillis());
        
        // Database health check
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                health.put("database", "UP");
            } else {
                health.put("database", "DOWN");
                health.put("status", "DOWN");
            }
        } catch (Exception e) {
            health.put("database", "DOWN");
            health.put("status", "DOWN");
        }
        
        return ResponseEntity.ok(health);
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, String>> ready() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "READY");
        return ResponseEntity.ok(status);
    }

    @GetMapping("/live")
    public ResponseEntity<Map<String, String>> live() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "ALIVE");
        return ResponseEntity.ok(status);
    }
}
