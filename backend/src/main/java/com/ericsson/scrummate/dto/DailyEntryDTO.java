package com.ericsson.scrummate.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public class DailyEntryDTO {
    private UUID id;
    
    @NotNull
    private LocalDate entryDate;
    
    private String yesterdayWork;
    private String todayPlan;
    private String blockers;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public DailyEntryDTO() {}

    public DailyEntryDTO(UUID id, LocalDate entryDate, String yesterdayWork, 
                        String todayPlan, String blockers, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.entryDate = entryDate;
        this.yesterdayWork = yesterdayWork;
        this.todayPlan = todayPlan;
        this.blockers = blockers;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public LocalDate getEntryDate() { return entryDate; }
    public void setEntryDate(LocalDate entryDate) { this.entryDate = entryDate; }

    public String getYesterdayWork() { return yesterdayWork; }
    public void setYesterdayWork(String yesterdayWork) { this.yesterdayWork = yesterdayWork; }

    public String getTodayPlan() { return todayPlan; }
    public void setTodayPlan(String todayPlan) { this.todayPlan = todayPlan; }

    public String getBlockers() { return blockers; }
    public void setBlockers(String blockers) { this.blockers = blockers; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
