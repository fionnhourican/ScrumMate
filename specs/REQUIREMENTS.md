# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - System Requirements Document

## Business Requirements

### Purpose
ScrumMate is a daily work tracking application designed for Agile teams to capture, organize, and report on daily activities, enabling efficient weekly and monthly reporting.

### Core Functionality
1. **Daily Entry Management**
   - Record what was accomplished yesterday
   - Document current day's planned activities
   - Log issues, blockers, and impediments
   - Timestamp and user attribution

2. **Weekly Summarization**
   - Aggregate daily entries into weekly summaries
   - Generate structured weekly reports
   - Export capabilities for manager reporting

3. **Monthly Reporting**
   - Consolidate weekly summaries into monthly reports
   - Trend analysis and productivity insights
   - Manager-ready report generation

## Technical Requirements

### Functional Requirements
- **FR-001**: User authentication and authorization
- **FR-002**: Daily entry CRUD operations
- **FR-003**: Automated weekly summary generation
- **FR-004**: Monthly report compilation
- **FR-005**: Export functionality (PDF, JSON)
- **FR-006**: Search and filter capabilities

### Non-Functional Requirements
- **NFR-001**: 99.9% availability
- **NFR-002**: Sub-200ms API response times
- **NFR-003**: Support 100+ concurrent users
- **NFR-004**: Data retention for 2+ years
- **NFR-005**: GDPR compliance
- **NFR-006**: Mobile-responsive design

### Technology Stack
- **Frontend**: React.js with TypeScript
- **Backend**: Java 17 with Spring Boot 3.x
- **Database**: PostgreSQL 15+
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Package Management**: Helm
- **Deployment**: Helmfile
- **GitOps**: Flux
- **CI/CD**: Spinnaker

## Data Model

### Entities
1. **User**: id, email, name, role, created_at
2. **DailyEntry**: id, user_id, date, yesterday_work, today_plan, blockers, created_at
3. **WeeklySummary**: id, user_id, week_start, week_end, summary_text, generated_at
4. **MonthlyReport**: id, user_id, month, year, report_data, generated_at

## Success Criteria
- Reduce weekly reporting time by 80%
- Improve visibility into team blockers
- Enable data-driven productivity insights
- Seamless integration with existing Agile workflows
