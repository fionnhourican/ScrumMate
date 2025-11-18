# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - Deployment Runbook

## Overview
This runbook provides step-by-step procedures for deploying ScrumMate to production environments.

## Prerequisites
- Kubernetes cluster access
- Helm 3.x installed
- kubectl configured
- Docker registry access

## Production Deployment Procedure

### 1. Pre-Deployment Checks
```bash
# Verify cluster connectivity
kubectl cluster-info

# Check namespace exists
kubectl get namespace scrummate-prod

# Verify secrets are in place
kubectl get secrets -n scrummate-prod

# Check persistent volumes
kubectl get pv,pvc -n scrummate-prod
```

### 2. Database Deployment
```bash
# Deploy PostgreSQL
helm upgrade --install scrummate-db bitnami/postgresql \
  --namespace scrummate-prod \
  --set auth.postgresPassword=<secure-password> \
  --set primary.persistence.size=100Gi \
  --set metrics.enabled=true

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n scrummate-prod --timeout=300s

# Run database migrations
kubectl apply -f infrastructure/db-migrations.yaml
```

### 3. Backend Service Deployment
```bash
# Deploy backend service
helm upgrade --install scrummate-backend ./helm/scrummate-backend \
  --namespace scrummate-prod \
  --set image.tag=v1.0.0 \
  --set database.host=scrummate-db-postgresql \
  --set replicas=2

# Verify deployment
kubectl get pods -l app=scrummate-backend -n scrummate-prod
kubectl logs -l app=scrummate-backend -n scrummate-prod --tail=50
```

### 4. Frontend Service Deployment
```bash
# Deploy frontend service
helm upgrade --install scrummate-frontend ./helm/scrummate-frontend \
  --namespace scrummate-prod \
  --set image.tag=v1.0.0 \
  --set backend.url=http://scrummate-backend:8080 \
  --set replicas=3

# Verify deployment
kubectl get pods -l app=scrummate-frontend -n scrummate-prod
```

### 5. Post-Deployment Verification
```bash
# Check all services are running
kubectl get all -n scrummate-prod

# Test health endpoints
kubectl port-forward svc/scrummate-backend 8080:8080 -n scrummate-prod &
curl http://localhost:8080/actuator/health

# Test frontend
kubectl port-forward svc/scrummate-frontend 3000:80 -n scrummate-prod &
curl http://localhost:3000/health
```

## Rollback Procedure

### Emergency Rollback
```bash
# Rollback backend
helm rollback scrummate-backend -n scrummate-prod

# Rollback frontend
helm rollback scrummate-frontend -n scrummate-prod

# Verify rollback
kubectl get pods -n scrummate-prod
```

## Monitoring Setup
```bash
# Apply monitoring configuration
kubectl apply -f infrastructure/production-monitoring.yaml

# Verify monitoring
kubectl get pods -n monitoring
```

## Common Issues

### Database Connection Issues
- Check database pod status
- Verify connection secrets
- Check network policies

### Service Discovery Issues
- Verify service names and ports
- Check DNS resolution
- Validate service selectors

### Resource Issues
- Check resource quotas
- Verify node capacity
- Monitor resource usage
