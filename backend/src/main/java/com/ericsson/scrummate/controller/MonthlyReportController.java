package com.ericsson.scrummate.controller;

import com.ericsson.scrummate.entity.MonthlyReport;
import com.ericsson.scrummate.service.MonthlyReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/reports/monthly")
@CrossOrigin(origins = "*")
public class MonthlyReportController {
    
    @Autowired
    private MonthlyReportService monthlyReportService;
    
    @GetMapping
    public ResponseEntity<Page<MonthlyReport>> getMonthlyReports(
            Authentication authentication, Pageable pageable) {
        String userEmail = authentication.getName();
        Page<MonthlyReport> reports = monthlyReportService.getMonthlyReports(userEmail, pageable);
        return ResponseEntity.ok(reports);
    }
    
    @PostMapping("/generate")
    public ResponseEntity<MonthlyReport> generateMonthlyReport(
            @RequestParam int month, @RequestParam int year,
            Authentication authentication) {
        String userEmail = authentication.getName();
        MonthlyReport report = monthlyReportService.generateMonthlyReport(userEmail, month, year);
        return ResponseEntity.ok(report);
    }
    
    @GetMapping("/{id}/export")
    public ResponseEntity<String> exportMonthlyReport(
            @PathVariable UUID id, Authentication authentication) {
        // Basic JSON export - can be enhanced with PDF generation
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=monthly-report-" + id + ".json")
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"message\":\"Export functionality - to be implemented with PDF generation\"}");
    }
}
