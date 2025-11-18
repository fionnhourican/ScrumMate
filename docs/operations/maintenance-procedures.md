# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - Maintenance Procedures

## Scheduled Maintenance Windows

### Regular Maintenance Schedule
- **Weekly**: Sundays 02:00-04:00 UTC (Minor updates, patches)
- **Monthly**: First Sunday 01:00-05:00 UTC (Major updates, infrastructure changes)
- **Quarterly**: Planned 6-hour window (Platform upgrades, major migrations)

### Emergency Maintenance
- Can be scheduled with 2-hour notice for critical security patches
- Requires approval from Team Lead and Product Owner

## Pre-Maintenance Checklist

### 1. Planning Phase (1 week before)
```bash
# Create maintenance ticket
# Schedule maintenance window
# Notify stakeholders via email
# Update status page with scheduled maintenance
```

### 2. Preparation Phase (24 hours before)
```bash
# Verify backup completion
kubectl get jobs -l app=database-backup -n scrummate-prod

# Test rollback procedures in staging
helm rollback scrummate-backend -n scrummate-staging

# Prepare maintenance scripts
# Review change procedures
# Confirm team availability
```

### 3. Pre-Maintenance Verification
```bash
# Check system health
kubectl get pods -n scrummate-prod
curl -f http://scrummate-backend:8080/actuator/health

# Verify monitoring systems
curl -f http://prometheus:9090/-/healthy
curl -f http://grafana:3000/api/health

# Create fresh backup
kubectl create job pre-maintenance-backup --from=cronjob/database-backup -n scrummate-prod
```

## Maintenance Procedures

### Application Updates

#### Backend Service Update
```bash
# 1. Enable maintenance mode
kubectl patch ingress scrummate-ingress -n scrummate-prod \
  --patch '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/default-backend":"maintenance-page"}}}'

# 2. Scale down to single replica for zero-downtime
kubectl scale deployment scrummate-backend --replicas=1 -n scrummate-prod

# 3. Update application
helm upgrade scrummate-backend ./helm/scrummate-backend \
  --namespace scrummate-prod \
  --set image.tag=v1.1.0 \
  --wait --timeout=300s

# 4. Run database migrations if needed
kubectl apply -f infrastructure/db-migrations-v1.1.0.yaml

# 5. Scale back up
kubectl scale deployment scrummate-backend --replicas=2 -n scrummate-prod

# 6. Verify health
kubectl wait --for=condition=available deployment/scrummate-backend -n scrummate-prod --timeout=300s

# 7. Disable maintenance mode
kubectl patch ingress scrummate-ingress -n scrummate-prod \
  --patch '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/default-backend":"scrummate-frontend"}}}'
```

#### Frontend Service Update
```bash
# 1. Rolling update (no downtime needed)
helm upgrade scrummate-frontend ./helm/scrummate-frontend \
  --namespace scrummate-prod \
  --set image.tag=v1.1.0 \
  --wait --timeout=300s

# 2. Verify deployment
kubectl rollout status deployment/scrummate-frontend -n scrummate-prod
```

### Database Maintenance

#### PostgreSQL Minor Updates
```bash
# 1. Create backup
kubectl create job db-maintenance-backup --from=cronjob/database-backup -n scrummate-prod

# 2. Scale down applications
kubectl scale deployment scrummate-backend --replicas=0 -n scrummate-prod

# 3. Update PostgreSQL
helm upgrade scrummate-db bitnami/postgresql \
  --namespace scrummate-prod \
  --set image.tag=15.5 \
  --wait --timeout=600s

# 4. Verify database health
kubectl exec -it scrummate-db-0 -n scrummate-prod -- pg_isready

# 5. Scale applications back up
kubectl scale deployment scrummate-backend --replicas=2 -n scrummate-prod
```

#### Database Optimization
```bash
# 1. Analyze table statistics
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "ANALYZE;"

# 2. Reindex tables
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "REINDEX DATABASE scrummate;"

# 3. Vacuum tables
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "VACUUM ANALYZE;"

# 4. Update statistics
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "SELECT pg_stat_reset();"
```

### Infrastructure Maintenance

#### Kubernetes Node Updates
```bash
# 1. Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# 2. Perform node maintenance (OS updates, etc.)
# This is typically handled by cloud provider or infrastructure team

# 3. Uncordon node
kubectl uncordon <node-name>

# 4. Verify pods are rescheduled
kubectl get pods -n scrummate-prod -o wide
```

#### Certificate Renewal
```bash
# 1. Check certificate expiration
kubectl get certificates -n scrummate-prod

# 2. Renew certificates (usually automated by cert-manager)
kubectl annotate certificate scrummate-tls -n scrummate-prod cert-manager.io/issue-temporary-certificate="true"

# 3. Verify new certificate
kubectl describe certificate scrummate-tls -n scrummate-prod
```

### Monitoring System Maintenance

#### Prometheus Updates
```bash
# 1. Update Prometheus
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.image.tag=v2.45.0

# 2. Verify metrics collection
curl -f http://prometheus:9090/api/v1/query?query=up
```

#### Grafana Updates
```bash
# 1. Backup dashboards
kubectl get configmaps -n monitoring -l grafana_dashboard=1 -o yaml > grafana-dashboards-backup.yaml

# 2. Update Grafana
helm upgrade grafana grafana/grafana \
  --namespace monitoring \
  --set image.tag=10.0.0

# 3. Verify dashboards
curl -f http://grafana:3000/api/health
```

## Post-Maintenance Procedures

### 1. Verification Steps
```bash
# Health checks
kubectl get pods -n scrummate-prod
curl -f http://scrummate-backend:8080/actuator/health
curl -f http://scrummate-frontend/health

# Performance verification
# Check Grafana dashboards for normal metrics
# Run smoke tests
kubectl apply -f tests/smoke-tests.yaml

# User acceptance testing
# Test critical user journeys
# Verify data integrity
```

### 2. Monitoring
```bash
# Monitor for 30 minutes post-maintenance
# Check error rates
# Monitor response times
# Verify all alerts are clear
```

### 3. Communication
```bash
# Update status page to operational
# Send completion notification to stakeholders
# Update maintenance ticket with results
# Document any issues encountered
```

## Emergency Rollback Procedures

### Application Rollback
```bash
# 1. Immediate rollback
helm rollback scrummate-backend -n scrummate-prod
helm rollback scrummate-frontend -n scrummate-prod

# 2. Database rollback (if needed)
kubectl exec -it scrummate-db-0 -n scrummate-prod -- bash /scripts/point-in-time-recovery.sh "$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S')"

# 3. Verify rollback
kubectl get pods -n scrummate-prod
curl -f http://scrummate-backend:8080/actuator/health
```

### Infrastructure Rollback
```bash
# 1. Rollback Kubernetes changes
kubectl apply -f infrastructure/previous-version/

# 2. Rollback Helm releases
helm rollback <release-name> <revision> -n <namespace>

# 3. Verify system stability
kubectl get all -n scrummate-prod
```

## Maintenance Documentation

### Change Log Template
```
Maintenance Date: YYYY-MM-DD HH:MM UTC
Duration: X hours Y minutes
Type: Application Update / Infrastructure / Database
Components Updated:
- Component 1: version X.Y.Z
- Component 2: version A.B.C

Changes Made:
- [Detailed list of changes]

Issues Encountered:
- [Any issues and resolutions]

Rollback Required: Yes/No
Post-Maintenance Actions:
- [Any follow-up actions needed]
```

### Maintenance Metrics
- **Planned Downtime**: Track against SLA targets
- **Maintenance Duration**: Actual vs. planned
- **Success Rate**: Percentage of successful maintenance windows
- **Rollback Rate**: Percentage requiring rollback

## Maintenance Tools

### Required Tools
- kubectl (configured for production cluster)
- Helm 3.x
- Database client tools
- Monitoring access (Grafana, Prometheus)
- Communication tools (Slack, email)

### Maintenance Scripts Location
- `/scripts/maintenance/` - All maintenance scripts
- `/docs/operations/` - Maintenance documentation
- `/tests/` - Smoke tests and validation scripts
