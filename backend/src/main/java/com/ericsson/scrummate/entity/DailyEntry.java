package com.ericsson.scrummate.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "daily_entries", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id", "entry_date"})
})
@EntityListeners(AuditingEntityListener.class)
public class DailyEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotNull
    @Column(name = "entry_date", nullable = false)
    private LocalDate entryDate;

    @Column(name = "yesterday_work", columnDefinition = "TEXT")
    private String yesterdayWork;

    @Column(name = "today_plan", columnDefinition = "TEXT")
    private String todayPlan;

    @Column(columnDefinition = "TEXT")
    private String blockers;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    // Constructors
    public DailyEntry() {}

    public DailyEntry(User user, LocalDate entryDate, String yesterdayWork, String todayPlan, String blockers) {
        this.user = user;
        this.entryDate = entryDate;
        this.yesterdayWork = yesterdayWork;
        this.todayPlan = todayPlan;
        this.blockers = blockers;
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

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
