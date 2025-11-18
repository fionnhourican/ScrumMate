# Database Schema Design

## Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     users       │       │  daily_entries  │       │weekly_summaries │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (UUID) PK    │◄─────┐│ id (UUID) PK    │       │ id (UUID) PK    │
│ email (VARCHAR) │      ││ user_id (UUID)FK├──────►│ user_id (UUID)FK│
│ password_hash   │      ││ entry_date      │       │ week_start      │
│ full_name       │      ││ yesterday_work  │       │ week_end        │
│ role (ENUM)     │      ││ today_plan      │       │ summary_text    │
│ created_at      │      ││ blockers        │       │ generated_at    │
│ updated_at      │      ││ created_at      │       └─────────────────┘
└─────────────────┘      ││ updated_at      │                │
                         │└─────────────────┘                │
                         │                                   │
                         │ ┌─────────────────┐               │
                         └─┤monthly_reports  │◄──────────────┘
                           ├─────────────────┤
                           │ id (UUID) PK    │
                           │ user_id (UUID)FK│
                           │ month (INTEGER) │
                           │ year (INTEGER)  │
                           │ report_data JSON│
                           │ generated_at    │
                           └─────────────────┘
```

## Table Definitions

### users
- **Primary Key**: id (UUID)
- **Unique Constraints**: email
- **Indexes**: email
- **Relationships**: One-to-many with daily_entries, weekly_summaries, monthly_reports

### daily_entries
- **Primary Key**: id (UUID)
- **Foreign Keys**: user_id → users.id
- **Unique Constraints**: (user_id, entry_date)
- **Indexes**: user_id, entry_date, (user_id, entry_date)

### weekly_summaries
- **Primary Key**: id (UUID)
- **Foreign Keys**: user_id → users.id
- **Unique Constraints**: (user_id, week_start, week_end)
- **Indexes**: user_id, week_start

### monthly_reports
- **Primary Key**: id (UUID)
- **Foreign Keys**: user_id → users.id
- **Unique Constraints**: (user_id, month, year)
- **Indexes**: user_id, (year, month)

## Data Retention Policies

- **Daily Entries**: 2 years active, 5 years archived
- **Weekly Summaries**: 3 years active, 7 years archived
- **Monthly Reports**: 5 years active, 10 years archived
- **User Data**: Active until account deletion + 30 days
