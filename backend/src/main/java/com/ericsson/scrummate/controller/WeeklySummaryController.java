package com.ericsson.scrummate.controller;

import com.ericsson.scrummate.entity.WeeklySummary;
import com.ericsson.scrummate.service.WeeklySummaryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/summaries/weekly")
@CrossOrigin(origins = "*")
public class WeeklySummaryController {
    
    @Autowired
    private WeeklySummaryService weeklySummaryService;
    
    @GetMapping
    public ResponseEntity<Page<WeeklySummary>> getWeeklySummaries(
            Authentication authentication, Pageable pageable) {
        String userEmail = authentication.getName();
        Page<WeeklySummary> summaries = weeklySummaryService.getWeeklySummaries(userEmail, pageable);
        return ResponseEntity.ok(summaries);
    }
    
    @PostMapping("/generate")
    public ResponseEntity<WeeklySummary> generateWeeklySummary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart,
            Authentication authentication) {
        String userEmail = authentication.getName();
        WeeklySummary summary = weeklySummaryService.generateWeeklySummary(userEmail, weekStart);
        return ResponseEntity.ok(summary);
    }
}
