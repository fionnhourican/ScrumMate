# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - System Architecture

## Architecture Overview

ScrumMate follows a microservices architecture deployed on Kubernetes with GitOps practices.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Database      │
│   (React)       │◄──►│ (Java/Spring)   │◄──►│   (PostgreSQL)  │
│   Port: 3000    │    │   Port: 8080    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Kubernetes    │
                    │   Cluster       │
                    └─────────────────┘
```

## Component Architecture

### 1. Frontend Service (scrummate-frontend)
- **Technology**: React.js with TypeScript
- **Responsibilities**: User interface, state management, API communication
- **Key Features**: Responsive design, real-time updates, offline capability

### 2. Backend Service (scrummate-backend)
- **Technology**: Java 17 with Spring Boot 3.x
- **Framework Components**: Spring Web, Spring Data JPA, Spring Security, Spring Actuator
- **Build Tool**: Maven 3.9+
- **Responsibilities**: Business logic, API endpoints, data validation, ORM management
- **Key Features**: RESTful API, JWT authentication, automated report generation, JPA/Hibernate ORM, health monitoring

### 3. Database Service (scrummate-db)
- **Technology**: PostgreSQL
- **Responsibilities**: Data persistence, query optimization
- **Key Features**: ACID compliance, backup automation, connection pooling

## Data Flow Architecture

### Daily Entry Flow
```
User Input → Frontend → API Validation → Database → Response → UI Update
```

### Weekly Summary Generation
```
Scheduler → Backend Service → Query Daily Entries → Generate Summary → Store → Notify User
```

### Monthly Report Flow
```
User Request → Backend → Aggregate Weekly Data → Generate Report → Export → Download
```

## Deployment Architecture

### Kubernetes Resources
- **Namespaces**: scrummate-dev, scrummate-staging, scrummate-prod
- **Deployments**: frontend, backend, database
- **Services**: LoadBalancer (frontend), ClusterIP (backend, db)
- **ConfigMaps**: Application configuration
- **Secrets**: Database credentials, JWT keys

### GitOps Workflow
```
Code Push → GitHub → Flux → Kubernetes → Spinnaker → Production
```

## Security Architecture

### Authentication & Authorization
- JWT-based authentication
- Role-based access control (RBAC)
- API rate limiting
- HTTPS/TLS encryption

### Data Security
- Database encryption at rest
- Secrets management with Kubernetes Secrets
- Network policies for pod-to-pod communication
- Regular security scanning

## Scalability Design

### Horizontal Scaling
- Frontend: Multiple replicas behind load balancer
- Backend: Auto-scaling based on CPU/memory usage
- Database: Read replicas for query optimization

### Performance Optimization
- Redis caching layer for frequent queries
- CDN for static assets
- Database indexing strategy
- API response compression

## Monitoring & Observability

### Metrics Collection
- Prometheus for metrics collection
- Grafana for visualization
- Custom business metrics (daily entries, report generation)

### Logging Strategy
- Centralized logging with ELK stack
- Structured logging format
- Log retention policies

### Health Checks
- Kubernetes liveness/readiness probes
- Database connection monitoring
- API endpoint health checks
