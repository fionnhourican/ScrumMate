package com.ericsson.scrummate.repository;

import com.ericsson.scrummate.entity.User;
import com.ericsson.scrummate.entity.WeeklySummary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WeeklySummaryRepository extends JpaRepository<WeeklySummary, UUID> {
    Page<WeeklySummary> findByUserOrderByWeekStartDesc(User user, Pageable pageable);
    
    Optional<WeeklySummary> findByUserAndWeekStartAndWeekEnd(User user, LocalDate weekStart, LocalDate weekEnd);
    
    List<WeeklySummary> findByUserAndWeekStartBetweenOrderByWeekStartAsc(
        User user, LocalDate startDate, LocalDate endDate);
}
