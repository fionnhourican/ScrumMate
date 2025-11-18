# ScrumMate

A cloud-native Agile work tracking application designed for microservices architecture with comprehensive DevOps automation.

## Overview

ScrumMate is a daily work tracking application designed for Agile teams to capture, organize, and report on daily activities, enabling efficient weekly and monthly reporting.

## Features

- **Daily Entry Management**: Record daily accomplishments, plans, and blockers
- **Weekly Summarization**: Automated weekly report generation
- **Monthly Reporting**: Consolidated monthly reports with trend analysis
- **Export Capabilities**: PDF and JSON export functionality
- **Search & Filter**: Advanced search and filtering capabilities

## Technology Stack

- **Frontend**: React.js with TypeScript
- **Backend**: Java 17 with Spring Boot 3.x
- **Database**: PostgreSQL 15+
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Package Management**: Helm
- **Deployment**: Helmfile
- **GitOps**: Flux
- **CI/CD**: Spinnaker

## Architecture

ScrumMate follows a microservices architecture deployed on Kubernetes with GitOps practices.

```
Frontend (React) ◄──► Backend API (Java/Spring) ◄──► Database (PostgreSQL)
```

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Kubernetes cluster
- Helm 3.x
- Node.js 18+
- Java 17+
- Maven 3.9+

### Development Setup

1. Clone the repository
2. Set up development environment with Docker Compose
3. Run database migrations
4. Start the application services

## Project Structure

```
ScrumMate/
├── backend/          # Spring Boot application
├── frontend/         # React application
├── infrastructure/   # Kubernetes manifests
├── helm/            # Helm charts
├── docs/            # Documentation
└── specs/           # System specifications
```

## Contributing

Please read our contributing guidelines and follow the established coding standards.

## License

Copyright (c) 2025 Telefonaktiebolaget LM Ericsson