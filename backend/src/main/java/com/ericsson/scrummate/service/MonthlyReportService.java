package com.ericsson.scrummate.service;

import com.ericsson.scrummate.entity.MonthlyReport;
import com.ericsson.scrummate.entity.User;
import com.ericsson.scrummate.entity.WeeklySummary;
import com.ericsson.scrummate.repository.MonthlyReportRepository;
import com.ericsson.scrummate.repository.UserRepository;
import com.ericsson.scrummate.repository.WeeklySummaryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MonthlyReportService {
    
    @Autowired
    private MonthlyReportRepository monthlyReportRepository;
    
    @Autowired
    private WeeklySummaryRepository weeklySummaryRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    public MonthlyReport generateMonthlyReport(String userEmail, int month, int year) {
        User user = getUserByEmail(userEmail);
        
        LocalDate monthStart = LocalDate.of(year, month, 1);
        LocalDate monthEnd = monthStart.withDayOfMonth(monthStart.lengthOfMonth());
        
        List<WeeklySummary> weeklySummaries = weeklySummaryRepository
            .findByUserAndWeekStartBetweenOrderByWeekStartAsc(user, monthStart, monthEnd);
        
        Map<String, Object> reportData = new HashMap<>();
        reportData.put("month", month);
        reportData.put("year", year);
        reportData.put("totalWeeks", weeklySummaries.size());
        reportData.put("weeklySummaries", weeklySummaries.stream()
            .map(ws -> Map.of(
                "weekStart", ws.getWeekStart(),
                "weekEnd", ws.getWeekEnd(),
                "summary", ws.getSummaryText()
            )).toList());
        
        MonthlyReport monthlyReport = new MonthlyReport(user, month, year, reportData);
        return monthlyReportRepository.save(monthlyReport);
    }
    
    public Page<MonthlyReport> getMonthlyReports(String userEmail, Pageable pageable) {
        User user = getUserByEmail(userEmail);
        return monthlyReportRepository.findByUserOrderByYearDescMonthDesc(user, pageable);
    }
    
    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
