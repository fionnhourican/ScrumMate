package com.ericsson.scrummate.repository;

import com.ericsson.scrummate.entity.MonthlyReport;
import com.ericsson.scrummate.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MonthlyReportRepository extends JpaRepository<MonthlyReport, UUID> {
    Page<MonthlyReport> findByUserOrderByYearDescMonthDesc(User user, Pageable pageable);
    
    Optional<MonthlyReport> findByUserAndMonthAndYear(User user, Integer month, Integer year);
}
