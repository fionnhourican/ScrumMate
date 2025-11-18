package com.ericsson.scrummate.repository;

import com.ericsson.scrummate.entity.DailyEntry;
import com.ericsson.scrummate.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DailyEntryRepository extends JpaRepository<DailyEntry, UUID> {
    Page<DailyEntry> findByUserOrderByEntryDateDesc(User user, Pageable pageable);
    
    Optional<DailyEntry> findByUserAndEntryDate(User user, LocalDate entryDate);
    
    List<DailyEntry> findByUserAndEntryDateBetweenOrderByEntryDateAsc(
        User user, LocalDate startDate, LocalDate endDate);
    
    @Query("SELECT d FROM DailyEntry d WHERE d.user = :user AND " +
           "(LOWER(d.yesterdayWork) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(d.todayPlan) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(d.blockers) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<DailyEntry> searchByUserAndQuery(@Param("user") User user, 
                                         @Param("query") String query, 
                                         Pageable pageable);
}
