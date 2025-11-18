# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - Incident Response Procedures

## Incident Classification

### Severity Levels

**P1 - Critical**
- Complete service outage
- Data corruption or loss
- Security breach
- Response Time: 15 minutes
- Resolution Time: 2 hours

**P2 - High**
- Significant performance degradation (>50% slower)
- Partial service unavailability
- Authentication issues
- Response Time: 30 minutes
- Resolution Time: 4 hours

**P3 - Medium**
- Minor performance issues
- Non-critical feature failures
- Response Time: 2 hours
- Resolution Time: 24 hours

**P4 - Low**
- Cosmetic issues
- Enhancement requests
- Response Time: 24 hours
- Resolution Time: 1 week

## Incident Response Process

### 1. Detection and Alert
```bash
# Automated alerts trigger via:
# - Prometheus AlertManager
# - Health check failures
# - User reports

# Alert channels:
# - Slack: #scrummate-critical
# - Email: oncall-team@ericsson.com
# - PagerDuty: ScrumMate service
```

### 2. Initial Response (0-15 minutes)

**On-Call Engineer Actions:**
1. **Acknowledge Alert**
   ```bash
   # Acknowledge in PagerDuty/Slack
   # Update status page: https://status.scrummate.ericsson.com
   ```

2. **Initial Assessment**
   ```bash
   # Check service status
   kubectl get pods -n scrummate-prod
   
   # Check recent deployments
   kubectl rollout history deployment/scrummate-backend -n scrummate-prod
   
   # Check metrics dashboard
   # https://grafana.scrummate.ericsson.com/d/production-dashboard
   ```

3. **Escalate if P1**
   ```bash
   # Notify team lead immediately
   # Create incident channel: #incident-YYYYMMDD-HHMM
   # Page additional team members if needed
   ```

### 3. Investigation and Diagnosis (15-60 minutes)

**Diagnostic Commands:**
```bash
# Service health
kubectl get all -n scrummate-prod
kubectl describe pods -l app=scrummate-backend -n scrummate-prod

# Recent events
kubectl get events -n scrummate-prod --sort-by='.lastTimestamp' | tail -20

# Resource usage
kubectl top pods -n scrummate-prod
kubectl top nodes

# Application logs
kubectl logs -l app=scrummate-backend -n scrummate-prod --tail=100 --since=1h

# Database status
kubectl exec -it scrummate-db-0 -n scrummate-prod -- pg_isready
kubectl exec -it scrummate-db-0 -n scrummate-prod -- psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"
```

**Common Root Causes:**
- Resource exhaustion (CPU/Memory)
- Database connectivity issues
- Configuration changes
- Network problems
- External dependency failures

### 4. Immediate Mitigation

**Quick Fixes:**
```bash
# Scale up services
kubectl scale deployment scrummate-backend --replicas=4 -n scrummate-prod

# Restart problematic pods
kubectl rollout restart deployment/scrummate-backend -n scrummate-prod

# Emergency rollback
helm rollback scrummate-backend -n scrummate-prod

# Enable maintenance mode
kubectl patch ingress scrummate-ingress -n scrummate-prod --patch '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/default-backend":"maintenance-page"}}}'
```

### 5. Communication

**Status Updates:**
```bash
# Update status page every 30 minutes
# Post in incident channel every 15 minutes for P1, 30 minutes for P2
# Notify stakeholders via email for P1/P2 incidents
```

**Communication Template:**
```
INCIDENT UPDATE - [TIMESTAMP]
Severity: P1/P2/P3/P4
Status: Investigating/Mitigating/Resolved
Impact: [Description of user impact]
Next Update: [Time]

Current Actions:
- [Action 1]
- [Action 2]

ETA to Resolution: [Time estimate]
```

### 6. Resolution and Recovery

**Verification Steps:**
```bash
# Health checks pass
curl -f http://scrummate-backend:8080/actuator/health

# Performance metrics normal
# Check Grafana dashboard for 5 minutes of normal metrics

# User acceptance testing
# Run smoke tests
kubectl apply -f tests/smoke-tests.yaml
```

**Recovery Actions:**
```bash
# Remove maintenance mode
kubectl patch ingress scrummate-ingress -n scrummate-prod --patch '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/default-backend":"scrummate-frontend"}}}'

# Update status page to operational
# Notify users of resolution
```

## Post-Incident Activities

### 1. Incident Closure
- Update all stakeholders
- Close incident in tracking system
- Update status page to operational
- Document resolution in knowledge base

### 2. Post-Incident Review (Within 48 hours)

**Review Meeting Agenda:**
1. Timeline review
2. Root cause analysis
3. Response effectiveness
4. Action items identification
5. Process improvements

**Action Items Template:**
```
Action Item: [Description]
Owner: [Name]
Due Date: [Date]
Priority: High/Medium/Low
Type: Prevention/Detection/Response/Recovery
```

### 3. Documentation Updates
- Update runbooks with new procedures
- Add to troubleshooting guide
- Update monitoring/alerting if needed
- Share lessons learned with team

## Emergency Contacts

### Primary On-Call
- **Engineer**: +46-xxx-xxx-xxxx
- **Backup**: +46-xxx-xxx-xxxy
- **Team Lead**: +46-xxx-xxx-xxxz

### Escalation Contacts
- **Platform Team**: platform-oncall@ericsson.com
- **Database Team**: dba-oncall@ericsson.com
- **Security Team**: security-oncall@ericsson.com
- **Management**: scrummate-management@ericsson.com

### External Vendors
- **Cloud Provider**: [Support number]
- **Monitoring Vendor**: [Support number]

## Tools and Resources

### Monitoring and Alerting
- **Grafana**: https://grafana.scrummate.ericsson.com
- **Prometheus**: https://prometheus.scrummate.ericsson.com
- **AlertManager**: https://alertmanager.scrummate.ericsson.com
- **Status Page**: https://status.scrummate.ericsson.com

### Communication
- **Slack**: #scrummate-incidents
- **PagerDuty**: ScrumMate service
- **Email Lists**: scrummate-team@ericsson.com

### Documentation
- **Runbooks**: /docs/operations/
- **Architecture**: /docs/architecture/
- **API Docs**: https://api.scrummate.ericsson.com/docs
