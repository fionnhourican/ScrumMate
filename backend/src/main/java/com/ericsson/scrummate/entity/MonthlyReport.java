package com.ericsson.scrummate.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "monthly_reports", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id", "month", "year"})
})
@EntityListeners(AuditingEntityListener.class)
public class MonthlyReport {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotNull
    @Min(1) @Max(12)
    @Column(nullable = false)
    private Integer month;

    @NotNull
    @Column(nullable = false)
    private Integer year;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "report_data", columnDefinition = "jsonb")
    private Map<String, Object> reportData;

    @CreatedDate
    @Column(name = "generated_at", nullable = false, updatable = false)
    private LocalDateTime generatedAt;

    // Constructors
    public MonthlyReport() {}

    public MonthlyReport(User user, Integer month, Integer year, Map<String, Object> reportData) {
        this.user = user;
        this.month = month;
        this.year = year;
        this.reportData = reportData;
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Integer getMonth() { return month; }
    public void setMonth(Integer month) { this.month = month; }

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }

    public Map<String, Object> getReportData() { return reportData; }
    public void setReportData(Map<String, Object> reportData) { this.reportData = reportData; }

    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
}
