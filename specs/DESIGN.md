# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - System Design Document

## 1. System Overview

ScrumMate is a cloud-native Agile work tracking application designed for microservices architecture with comprehensive DevOps automation.

### 1.1 Design Principles
- **Microservices Architecture**: Loosely coupled, independently deployable services
- **Cloud-Native**: Kubernetes-first design with container orchestration
- **GitOps**: Infrastructure and application deployment through Git workflows
- **Security by Design**: Zero-trust security model with comprehensive authentication
- **Observability**: Built-in monitoring, logging, and tracing capabilities

## 2. Service Design

### 2.1 Frontend Service Design
```
┌─────────────────────────────────────┐
│           Frontend Service          │
├─────────────────────────────────────┤
│  Components:                        │
│  ├── Authentication Module          │
│  ├── Daily Entry Management         │
│  ├── Weekly Summary Dashboard       │
│  ├── Monthly Report Generator       │
│  └── User Profile Management        │
├─────────────────────────────────────┤
│  Technology Stack:                  │
│  ├── React 18 + TypeScript          │
│  ├── Material-UI Components         │
│  ├── Redux Toolkit (State Mgmt)     │
│  ├── React Query (API Caching)      │
│  └── PWA Support                    │
└─────────────────────────────────────┘
```

### 2.2 Backend Service Design
```
┌─────────────────────────────────────┐
│           Backend Service           │
├─────────────────────────────────────┤
│  Layers:                            │
│  ├── Controller Layer (REST API)    │
│  ├── Service Layer (Business Logic) │
│  ├── Repository Layer (Data Access) │
│  └── Security Layer (Auth/AuthZ)    │
├─────────────────────────────────────┤
│  Spring Boot Modules:               │
│  ├── Spring Web (REST Controllers)  │
│  ├── Spring Data JPA (ORM)          │
│  ├── Spring Security (Auth)         │
│  ├── Spring Actuator (Monitoring)   │
│  └── Spring Validation              │
└─────────────────────────────────────┘
```

### 2.3 Database Design
```
┌─────────────────────────────────────┐
│         Database Schema             │
├─────────────────────────────────────┤
│  Tables:                            │
│  ├── users                          │
│  │   ├── id (UUID, PK)              │
│  │   ├── email (VARCHAR, UNIQUE)    │
│  │   ├── password_hash (VARCHAR)    │
│  │   ├── full_name (VARCHAR)        │
│  │   ├── role (ENUM)                │
│  │   └── created_at (TIMESTAMP)     │
│  │                                  │
│  ├── daily_entries                  │
│  │   ├── id (UUID, PK)              │
│  │   ├── user_id (UUID, FK)         │
│  │   ├── entry_date (DATE)          │
│  │   ├── yesterday_work (TEXT)      │
│  │   ├── today_plan (TEXT)          │
│  │   ├── blockers (TEXT)            │
│  │   └── created_at (TIMESTAMP)     │
│  │                                  │
│  ├── weekly_summaries               │
│  │   ├── id (UUID, PK)              │
│  │   ├── user_id (UUID, FK)         │
│  │   ├── week_start (DATE)          │
│  │   ├── week_end (DATE)            │
│  │   ├── summary_text (TEXT)        │
│  │   └── generated_at (TIMESTAMP)   │
│  │                                  │
│  └── monthly_reports                │
│      ├── id (UUID, PK)              │
│      ├── user_id (UUID, FK)         │
│      ├── month (INTEGER)            │
│      ├── year (INTEGER)             │
│      ├── report_data (JSONB)        │
│      └── generated_at (TIMESTAMP)   │
└─────────────────────────────────────┘
```

## 3. API Design

### 3.1 RESTful API Endpoints
```
Authentication:
POST   /api/v1/auth/login
POST   /api/v1/auth/register
POST   /api/v1/auth/refresh
DELETE /api/v1/auth/logout

Daily Entries:
GET    /api/v1/entries
POST   /api/v1/entries
GET    /api/v1/entries/{id}
PUT    /api/v1/entries/{id}
DELETE /api/v1/entries/{id}
GET    /api/v1/entries/search?query={query}&date={date}
GET    /api/v1/entries/filter?startDate={start}&endDate={end}

Weekly Summaries:
GET    /api/v1/summaries/weekly
POST   /api/v1/summaries/weekly/generate
GET    /api/v1/summaries/weekly/{id}

Monthly Reports:
GET    /api/v1/reports/monthly
POST   /api/v1/reports/monthly/generate
GET    /api/v1/reports/monthly/{id}
GET    /api/v1/reports/monthly/{id}/export
```

### 3.2 Data Transfer Objects (DTOs)
```
DailyEntryDTO:
├── id: UUID
├── entryDate: LocalDate
├── yesterdayWork: String
├── todayPlan: String
├── blockers: String
└── createdAt: LocalDateTime

WeeklySummaryDTO:
├── id: UUID
├── weekStart: LocalDate
├── weekEnd: LocalDate
├── summaryText: String
├── entryCount: Integer
└── generatedAt: LocalDateTime

MonthlyReportDTO:
├── id: UUID
├── month: Integer
├── year: Integer
├── totalEntries: Integer
├── weeklyBreakdown: List<WeeklySummaryDTO>
└── generatedAt: LocalDateTime
```

## 4. Security Design

### 4.1 Authentication Flow
```
User Login → JWT Token Generation → Token Validation → API Access
     ↓              ↓                      ↓              ↓
  Credentials → Access Token (15min) → Refresh Token → Protected Resources
                     ↓                      ↓
              Store in Memory        Store HttpOnly Cookie
```

### 4.2 Authorization Matrix
```
Role-Based Access Control (RBAC):

USER Role:
├── Create/Read/Update own daily entries
├── Generate own weekly summaries
├── Generate own monthly reports
└── View own profile

ADMIN Role:
├── All USER permissions
├── View all user entries (read-only)
├── Generate team reports
└── User management operations
```

## 5. Container Design

### 5.1 Docker Architecture
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  Frontend       │  │  Backend        │  │  Database       │
│  Container      │  │  Container      │  │  Container      │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ nginx:alpine    │  │ openjdk:17-jre  │  │ postgres:15     │
│ React build     │  │ Spring Boot JAR │  │ Data volume     │
│ Port: 80        │  │ Port: 8080      │  │ Port: 5432      │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### 5.2 Kubernetes Resource Design
```
Namespace: scrummate
├── Deployments:
│   ├── scrummate-frontend (3 replicas)
│   ├── scrummate-backend (2 replicas)
│   └── scrummate-db (1 replica)
├── Services:
│   ├── frontend-service (LoadBalancer)
│   ├── backend-service (ClusterIP)
│   └── db-service (ClusterIP)
├── ConfigMaps:
│   ├── frontend-config
│   └── backend-config
├── Secrets:
│   ├── db-credentials
│   └── jwt-secret
└── PersistentVolumes:
    └── postgres-data
```

## 6. DevOps Pipeline Design

### 6.1 GitOps Workflow
```
Developer Push → GitHub → Flux Sync → Kubernetes → Spinnaker Pipeline
      ↓             ↓         ↓            ↓              ↓
   Code Change → Webhook → Config Update → Deploy → Validation
```

### 6.2 Helm Chart Structure
```
helm/
├── scrummate/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-prod.yaml
│   └── templates/
│       ├── frontend/
│       ├── backend/
│       ├── database/
│       └── ingress/
```

### 6.3 Monitoring Design
```
Observability Stack:
├── Metrics: Prometheus + Grafana
├── Logging: ELK Stack (Elasticsearch, Logstash, Kibana)
├── Tracing: Jaeger
└── Alerting: AlertManager + PagerDuty
```

## 7. Performance Design

### 7.1 Scalability Targets
- **Frontend**: Auto-scale 1-10 replicas based on CPU (70% threshold)
- **Backend**: Auto-scale 2-20 replicas based on CPU/Memory (80% threshold)
- **Database**: Read replicas for query optimization
- **Response Time**: < 200ms for API calls, < 2s for report generation

### 7.2 Caching Strategy
```
Multi-Layer Caching:
├── Browser Cache (Static assets, 24h)
├── CDN Cache (Global distribution)
├── Application Cache (Redis, API responses)
└── Database Cache (Query result caching)
```

## 8. Disaster Recovery Design

### 8.1 Backup Strategy
- **Database**: Daily automated backups with 30-day retention
- **Configuration**: Git-based configuration management
- **Secrets**: Encrypted backup in secure storage

### 8.2 High Availability
- **Multi-AZ Deployment**: Services distributed across availability zones
- **Health Checks**: Kubernetes liveness/readiness probes
- **Circuit Breakers**: Resilience patterns for external dependencies
