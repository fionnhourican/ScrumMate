# Container Optimization Guide

## Health Checks

### Backend Health Endpoints
- `/health` - Overall application health
- `/health/ready` - Readiness probe endpoint
- `/health/live` - Liveness probe endpoint
- `/actuator/health` - Spring Boot actuator health

### Frontend Health
- `/health` - Nginx health endpoint
- Configured in nginx.conf

### Database Health
- PostgreSQL health checks via `pg_isready`
- Configured in docker-compose.yml

## Logging Configuration

### Structured JSON Logging
- Enabled for production and docker profiles
- Includes correlation IDs for request tracing
- Centralized logging output to stdout/stderr

### Log Levels by Environment
- **Development**: DEBUG level with console output
- **Production**: INFO level with JSON format
- **Docker**: INFO level with structured logging

### Correlation ID Tracing
- Automatic correlation ID generation
- Propagated through all requests
- Available in MDC for logging

## Environment Management

### Environment Files
- `.env.template` - Template with all variables
- `.env.dev` - Development configuration
- `.env.prod` - Production configuration (update secrets!)

### Configuration Validation
- Environment variables with defaults
- Required secrets validation
- Profile-specific configurations

## Image Optimization

### Size Reduction Techniques
- Multi-stage builds
- Distroless base images for backend
- Alpine Linux for frontend
- Minimal package installation
- Layer caching optimization

### Security Hardening
- Non-root users in all containers
- Read-only root filesystems
- No shell access in production images
- Security scanning integration
- Resource limits and reservations

## Resource Management

### CPU and Memory Limits
- **Database**: 1 CPU, 512MB memory
- **Backend**: 1 CPU, 768MB memory  
- **Frontend**: 0.5 CPU, 256MB memory

### Security Options
- `no-new-privileges:true`
- Read-only filesystems where possible
- Temporary filesystems for writable areas

## Security Scanning

### Automated Scanning
```bash
# Run security scans
./scripts/security-scan.sh

# Scan specific version
./scripts/security-scan.sh v1.0.0
```

### Tools Integration
- Trivy for vulnerability scanning
- Docker Scout for security analysis
- Hadolint for Dockerfile linting

## Best Practices

### Development
- Use `.env.dev` for local development
- Enable debug logging for troubleshooting
- Use volume mounts for hot reload

### Production
- Update all secrets in `.env.prod`
- Enable structured JSON logging
- Use read-only filesystems
- Implement proper resource limits
- Run security scans before deployment
