package com.ericsson.scrummate.service;

import com.ericsson.scrummate.entity.DailyEntry;
import com.ericsson.scrummate.entity.User;
import com.ericsson.scrummate.entity.WeeklySummary;
import com.ericsson.scrummate.repository.DailyEntryRepository;
import com.ericsson.scrummate.repository.UserRepository;
import com.ericsson.scrummate.repository.WeeklySummaryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.List;
import java.util.Locale;

@Service
public class WeeklySummaryService {
    
    @Autowired
    private WeeklySummaryRepository weeklySummaryRepository;
    
    @Autowired
    private DailyEntryRepository dailyEntryRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    public WeeklySummary generateWeeklySummary(String userEmail, LocalDate weekStart) {
        User user = getUserByEmail(userEmail);
        LocalDate weekEnd = weekStart.plusDays(6);
        
        List<DailyEntry> entries = dailyEntryRepository
            .findByUserAndEntryDateBetweenOrderByEntryDateAsc(user, weekStart, weekEnd);
        
        StringBuilder summary = new StringBuilder();
        summary.append("Week Summary (").append(weekStart).append(" to ").append(weekEnd).append("):\n\n");
        
        for (DailyEntry entry : entries) {
            summary.append("Date: ").append(entry.getEntryDate()).append("\n");
            if (entry.getYesterdayWork() != null) {
                summary.append("Work Done: ").append(entry.getYesterdayWork()).append("\n");
            }
            if (entry.getBlockers() != null) {
                summary.append("Blockers: ").append(entry.getBlockers()).append("\n");
            }
            summary.append("\n");
        }
        
        WeeklySummary weeklySummary = new WeeklySummary(user, weekStart, weekEnd, summary.toString());
        return weeklySummaryRepository.save(weeklySummary);
    }
    
    public Page<WeeklySummary> getWeeklySummaries(String userEmail, Pageable pageable) {
        User user = getUserByEmail(userEmail);
        return weeklySummaryRepository.findByUserOrderByWeekStartDesc(user, pageable);
    }
    
    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
