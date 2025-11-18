package com.ericsson.scrummate.controller;

import com.ericsson.scrummate.dto.DailyEntryDTO;
import com.ericsson.scrummate.service.DailyEntryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/entries")
@CrossOrigin(origins = "*")
public class DailyEntryController {

    @Autowired
    private DailyEntryService dailyEntryService;

    @GetMapping
    public ResponseEntity<Page<DailyEntryDTO>> getEntries(
            Authentication authentication, Pageable pageable) {
        String userEmail = authentication.getName();
        Page<DailyEntryDTO> entries = dailyEntryService.getEntriesByUser(userEmail, pageable);
        return ResponseEntity.ok(entries);
    }

    @PostMapping
    public ResponseEntity<DailyEntryDTO> createEntry(
            @Valid @RequestBody DailyEntryDTO entryDTO, Authentication authentication) {
        String userEmail = authentication.getName();
        DailyEntryDTO createdEntry = dailyEntryService.createEntry(userEmail, entryDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdEntry);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DailyEntryDTO> getEntry(
            @PathVariable UUID id, Authentication authentication) {
        String userEmail = authentication.getName();
        DailyEntryDTO entry = dailyEntryService.getEntryById(userEmail, id);
        return ResponseEntity.ok(entry);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DailyEntryDTO> updateEntry(
            @PathVariable UUID id, @Valid @RequestBody DailyEntryDTO entryDTO, 
            Authentication authentication) {
        String userEmail = authentication.getName();
        DailyEntryDTO updatedEntry = dailyEntryService.updateEntry(userEmail, id, entryDTO);
        return ResponseEntity.ok(updatedEntry);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEntry(
            @PathVariable UUID id, Authentication authentication) {
        String userEmail = authentication.getName();
        dailyEntryService.deleteEntry(userEmail, id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public ResponseEntity<Page<DailyEntryDTO>> searchEntries(
            @RequestParam String query, Authentication authentication, Pageable pageable) {
        String userEmail = authentication.getName();
        Page<DailyEntryDTO> entries = dailyEntryService.searchEntries(userEmail, query, pageable);
        return ResponseEntity.ok(entries);
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<DailyEntryDTO>> filterEntries(
            @RequestParam LocalDate startDate, @RequestParam LocalDate endDate,
            Authentication authentication, Pageable pageable) {
        String userEmail = authentication.getName();
        Page<DailyEntryDTO> entries = dailyEntryService.filterEntries(userEmail, startDate, endDate, pageable);
        return ResponseEntity.ok(entries);
    }
}
