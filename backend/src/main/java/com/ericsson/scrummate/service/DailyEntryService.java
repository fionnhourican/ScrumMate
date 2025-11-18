package com.ericsson.scrummate.service;

import com.ericsson.scrummate.dto.DailyEntryDTO;
import com.ericsson.scrummate.entity.DailyEntry;
import com.ericsson.scrummate.entity.User;
import com.ericsson.scrummate.repository.DailyEntryRepository;
import com.ericsson.scrummate.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
@Transactional
public class DailyEntryService {

    @Autowired
    private DailyEntryRepository dailyEntryRepository;

    @Autowired
    private UserRepository userRepository;

    public Page<DailyEntryDTO> getEntriesByUser(String userEmail, Pageable pageable) {
        User user = getUserByEmail(userEmail);
        return dailyEntryRepository.findByUserOrderByEntryDateDesc(user, pageable)
                .map(this::convertToDTO);
    }

    public DailyEntryDTO createEntry(String userEmail, DailyEntryDTO entryDTO) {
        User user = getUserByEmail(userEmail);
        DailyEntry entry = new DailyEntry(user, entryDTO.getEntryDate(), 
                entryDTO.getYesterdayWork(), entryDTO.getTodayPlan(), entryDTO.getBlockers());
        DailyEntry savedEntry = dailyEntryRepository.save(entry);
        return convertToDTO(savedEntry);
    }

    public DailyEntryDTO getEntryById(String userEmail, UUID id) {
        User user = getUserByEmail(userEmail);
        DailyEntry entry = dailyEntryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));
        if (!entry.getUser().equals(user)) {
            throw new RuntimeException("Access denied");
        }
        return convertToDTO(entry);
    }

    public DailyEntryDTO updateEntry(String userEmail, UUID id, DailyEntryDTO entryDTO) {
        User user = getUserByEmail(userEmail);
        DailyEntry entry = dailyEntryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));
        if (!entry.getUser().equals(user)) {
            throw new RuntimeException("Access denied");
        }
        
        entry.setYesterdayWork(entryDTO.getYesterdayWork());
        entry.setTodayPlan(entryDTO.getTodayPlan());
        entry.setBlockers(entryDTO.getBlockers());
        
        DailyEntry savedEntry = dailyEntryRepository.save(entry);
        return convertToDTO(savedEntry);
    }

    public void deleteEntry(String userEmail, UUID id) {
        User user = getUserByEmail(userEmail);
        DailyEntry entry = dailyEntryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));
        if (!entry.getUser().equals(user)) {
            throw new RuntimeException("Access denied");
        }
        dailyEntryRepository.delete(entry);
    }

    public Page<DailyEntryDTO> searchEntries(String userEmail, String query, Pageable pageable) {
        User user = getUserByEmail(userEmail);
        return dailyEntryRepository.searchByUserAndQuery(user, query, pageable)
                .map(this::convertToDTO);
    }

    public Page<DailyEntryDTO> filterEntries(String userEmail, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        User user = getUserByEmail(userEmail);
        return dailyEntryRepository.findByUserOrderByEntryDateDesc(user, pageable)
                .map(this::convertToDTO);
    }

    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private DailyEntryDTO convertToDTO(DailyEntry entry) {
        return new DailyEntryDTO(entry.getId(), entry.getEntryDate(), 
                entry.getYesterdayWork(), entry.getTodayPlan(), entry.getBlockers(),
                entry.getCreatedAt(), entry.getUpdatedAt());
    }
}
