# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - Troubleshooting Guide

## Service Down Issues

### Backend Service Not Responding
**Symptoms**: HTTP 503 errors, health check failures

**Diagnosis**:
```bash
# Check pod status
kubectl get pods -l app=scrummate-backend -n scrummate-prod

# Check logs
kubectl logs -l app=scrummate-backend -n scrummate-prod --tail=100

# Check events
kubectl get events -n scrummate-prod --sort-by='.lastTimestamp'
```

**Solutions**:
1. **Database Connection Issues**:
   ```bash
   # Check database connectivity
   kubectl exec -it scrummate-backend-xxx -n scrummate-prod -- nc -zv scrummate-db 5432
   
   # Verify database credentials
   kubectl get secret postgres-secret -n scrummate-prod -o yaml
   ```

2. **Memory/CPU Issues**:
   ```bash
   # Check resource usage
   kubectl top pods -n scrummate-prod
   
   # Scale up if needed
   kubectl scale deployment scrummate-backend --replicas=4 -n scrummate-prod
   ```

### Frontend Service Issues
**Symptoms**: 404 errors, static assets not loading

**Diagnosis**:
```bash
# Check nginx configuration
kubectl exec -it scrummate-frontend-xxx -n scrummate-prod -- nginx -t

# Check logs
kubectl logs -l app=scrummate-frontend -n scrummate-prod
```

**Solutions**:
1. **Configuration Issues**:
   ```bash
   # Update ConfigMap
   kubectl edit configmap frontend-config -n scrummate-prod
   
   # Restart pods
   kubectl rollout restart deployment/scrummate-frontend -n scrummate-prod
   ```

## Database Issues

### High Connection Count
**Symptoms**: Connection pool exhausted, slow queries

**Diagnosis**:
```bash
# Check active connections
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Check connection pool status
kubectl logs -l app=pgbouncer -n scrummate-prod
```

**Solutions**:
```bash
# Scale connection pool
kubectl patch configmap pgbouncer-config -n scrummate-prod --patch '{"data":{"pgbouncer.ini":"[databases]\nscrummate = host=scrummate-db port=5432 dbname=scrummate\n[pgbouncer]\npool_mode = transaction\ndefault_pool_size = 50\nmax_client_conn = 2000"}}'

# Restart PgBouncer
kubectl rollout restart deployment/pgbouncer -n scrummate-prod
```

### Slow Queries
**Diagnosis**:
```bash
# Check slow queries
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

**Solutions**:
```bash
# Add missing indexes
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "CREATE INDEX CONCURRENTLY idx_daily_entries_user_date ON daily_entries(user_id, entry_date);"
```

## Performance Issues

### High Response Times
**Symptoms**: API responses > 500ms, user complaints

**Diagnosis**:
```bash
# Check metrics
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
# Visit http://localhost:9090 and query: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Check resource usage
kubectl top pods -n scrummate-prod
```

**Solutions**:
1. **Scale Services**:
   ```bash
   kubectl scale deployment scrummate-backend --replicas=6 -n scrummate-prod
   ```

2. **Enable Caching**:
   ```bash
   # Deploy Redis if not already deployed
   kubectl apply -f infrastructure/redis-cache.yaml
   ```

### Memory Leaks
**Symptoms**: Increasing memory usage, OOMKilled pods

**Diagnosis**:
```bash
# Check memory trends
kubectl top pods -n scrummate-prod --sort-by=memory

# Check for OOMKilled events
kubectl get events -n scrummate-prod | grep OOMKilled
```

**Solutions**:
```bash
# Increase memory limits
kubectl patch deployment scrummate-backend -n scrummate-prod --patch '{"spec":{"template":{"spec":{"containers":[{"name":"backend","resources":{"limits":{"memory":"2Gi"}}}]}}}}'

# Enable heap dumps for analysis
kubectl patch deployment scrummate-backend -n scrummate-prod --patch '{"spec":{"template":{"spec":{"containers":[{"name":"backend","env":[{"name":"JAVA_OPTS","value":"-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp"}]}]}}}}'
```

## Network Issues

### Service Discovery Problems
**Symptoms**: Services can't reach each other

**Diagnosis**:
```bash
# Test DNS resolution
kubectl exec -it scrummate-backend-xxx -n scrummate-prod -- nslookup scrummate-db

# Check service endpoints
kubectl get endpoints -n scrummate-prod
```

**Solutions**:
```bash
# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system

# Check network policies
kubectl get networkpolicies -n scrummate-prod
```

### Ingress Issues
**Symptoms**: External access not working

**Diagnosis**:
```bash
# Check ingress status
kubectl get ingress -n scrummate-prod

# Check ingress controller logs
kubectl logs -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx
```

## Backup and Recovery Issues

### Backup Failures
**Diagnosis**:
```bash
# Check backup job status
kubectl get jobs -l app=database-backup -n scrummate-prod

# Check backup logs
kubectl logs job/database-backup-xxx -n scrummate-prod
```

**Solutions**:
```bash
# Manual backup
kubectl create job manual-backup --from=cronjob/database-backup -n scrummate-prod
```

### Recovery Procedures
```bash
# Point-in-time recovery
kubectl exec -it scrummate-db-0 -n scrummate-prod -- bash /scripts/point-in-time-recovery.sh "2025-11-18 14:00:00"
```

## Escalation Procedures

### Severity Levels
- **P1 (Critical)**: Service completely down, data loss
- **P2 (High)**: Significant performance degradation
- **P3 (Medium)**: Minor issues, workarounds available
- **P4 (Low)**: Enhancement requests

### Contact Information
- **On-call Engineer**: +46-xxx-xxx-xxxx
- **Team Lead**: scrummate-lead@ericsson.com
- **Platform Team**: platform-support@ericsson.com

### Emergency Contacts
- **Database Issues**: dba-oncall@ericsson.com
- **Infrastructure**: infra-oncall@ericsson.com
- **Security**: security-oncall@ericsson.com
