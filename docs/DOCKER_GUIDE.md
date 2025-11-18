# Docker Development Guide

## Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+

### Run the Application
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Database**: localhost:5432

## Development Workflow

### Building Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build backend

# Build with no cache
docker-compose build --no-cache
```

### Managing Services
```bash
# Start specific service
docker-compose up backend

# Restart service
docker-compose restart frontend

# View service logs
docker-compose logs backend
```

### Database Operations
```bash
# Access database
docker-compose exec database psql -U scrummate -d scrummate

# Run backup
docker-compose exec database /usr/local/bin/backup.sh

# Restore from backup
docker-compose exec database psql -U scrummate -d scrummate < backup.sql
```

## Production Deployment

### Build Production Images
```bash
# Build and tag images
./scripts/docker-build.sh v1.0.0

# Build and push to registry
./scripts/docker-build.sh v1.0.0 push
```

### Environment Variables
Create `.env` file:
```
DB_USERNAME=scrummate
DB_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_key
POSTGRES_PASSWORD=your_secure_password
```

## Troubleshooting

### Common Issues
1. **Port conflicts**: Change ports in docker-compose.yml
2. **Permission issues**: Check file ownership and Docker daemon
3. **Build failures**: Clear Docker cache with `docker system prune`

### Health Checks
```bash
# Check service health
docker-compose ps

# View health check logs
docker inspect scrummate-backend --format='{{.State.Health}}'
```
