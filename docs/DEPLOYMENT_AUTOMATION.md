# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson

# ScrumMate - Deployment Automation Guide

## Overview

This guide covers the comprehensive deployment automation system implemented for ScrumMate, including deployment scripts, rollback strategies, validation, notifications, and monitoring capabilities.

## Architecture

The deployment automation system consists of several interconnected components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Deployment    │    │   Validation    │    │   Monitoring    │
│    Scripts      │───►│   & Testing     │───►│  & Analytics    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Rollback      │    │  Notifications  │    │   Audit &       │
│   Strategies    │    │   & Alerting    │    │   Logging       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Deployment Scripts

### Environment-Specific Deployment

#### Development Environment
```bash
# Basic deployment with minimal validation
./scripts/deploy-dev.sh
```

#### Staging Environment
```bash
# Deployment with approval gates and enhanced validation
./scripts/deploy-staging.sh
```

#### Production Environment
```bash
# Strict deployment with backup, comprehensive validation, and monitoring
./scripts/deploy-prod.sh
```

### Script Features

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| Prerequisites Check | ✅ | ✅ | ✅ |
| Approval Gates | ❌ | ✅ | ✅ (Strict) |
| Pre-deployment Backup | ❌ | ❌ | ✅ |
| Enhanced Validation | ❌ | ✅ | ✅ |
| Rollout Status Check | ✅ | ✅ | ✅ |
| Notification Integration | ❌ | ✅ | ✅ |

## Validation System

### Enhanced Validation Script
```bash
# Run comprehensive validation
./scripts/validate-deployment-enhanced.sh <environment>
```

#### Validation Components
- **Health Checks**: Pod status, readiness probes, liveness probes
- **Functional Testing**: API endpoint testing, service connectivity
- **Performance Validation**: Resource usage monitoring, response time checks
- **Security Validation**: Non-root user verification, secret validation
- **Integration Testing**: Service-to-service communication, database connectivity

### Deployment Status Monitoring
```bash
# Check overall deployment status
./scripts/check-deployment-status.sh <environment>

# Check specific components
./scripts/check-deployment-status.sh <environment> pods
./scripts/check-deployment-status.sh <environment> services
./scripts/check-deployment-status.sh <environment> resources
```

## Rollback Strategies

### Automatic Rollback Triggers
The system automatically triggers rollback when:
- Pod failure rate exceeds 50%
- Deployments fail to reach desired replica count within 5 minutes
- Excessive pod restarts (>10 restarts)

### Manual Rollback
```bash
# Manual rollback with reason
./scripts/rollback-deployment.sh <environment> "Reason for rollback"

# Test rollback procedure (dry-run)
./scripts/rollback-deployment.sh <environment> "" test

# Check rollback triggers
./scripts/rollback-deployment.sh <environment> "" check
```

### Rollback Features
- **Automatic Detection**: Monitors deployment health and triggers rollback
- **Manual Override**: Supports manual rollback with confirmation
- **Validation**: Post-rollback validation ensures system stability
- **Notification**: Sends rollback notifications to configured channels
- **Audit Trail**: Logs all rollback activities for compliance

## Notification System

### Configuration
Set environment variables for notification channels:

```bash
# Slack notifications
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
export URGENT_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."

# Email notifications
export NOTIFICATION_EMAIL="team@company.com"

# Webhook notifications
export WEBHOOK_URL="https://api.company.com/webhooks/deployment"

# Dashboard integration
export DASHBOARD_API_URL="https://dashboard.company.com/api"
export DASHBOARD_API_TOKEN="your-api-token"

# On-call system
export ONCALL_WEBHOOK_URL="https://oncall.company.com/api/alerts"
```

### Notification Types
```bash
# Send specific notification types
./scripts/notify-deployment.sh <environment> <status> <message> slack
./scripts/notify-deployment.sh <environment> <status> <message> email
./scripts/notify-deployment.sh <environment> <status> <message> webhook
./scripts/notify-deployment.sh <environment> <status> <message> dashboard
```

#### Status Types
- `success`: Successful deployment
- `failure`: Deployment failure (triggers urgent alerts)
- `warning`: Deployment warnings
- `info`: Informational updates
- `rollback`: Rollback notifications

## Monitoring and Analytics

### Deployment Monitoring
```bash
# Start comprehensive monitoring
./scripts/monitor-deployment.sh <environment> <duration_seconds>

# Monitor specific aspects
./scripts/monitor-deployment.sh <environment> 300 metrics
./scripts/monitor-deployment.sh <environment> 300 logs
./scripts/monitor-deployment.sh <environment> 300 trace
./scripts/monitor-deployment.sh <environment> 300 audit
./scripts/monitor-deployment.sh <environment> 300 analytics
```

### Monitoring Components

#### Metrics Collection
- Pod status and resource usage
- Deployment replica status
- Service endpoint availability
- Resource consumption trends

#### Logging
- Centralized log collection from all pods
- Event logging from Kubernetes
- Structured logging with correlation IDs
- Log aggregation and forwarding

#### Tracing
- Deployment timeline tracking
- Service dependency tracing
- Performance bottleneck identification
- Distributed tracing integration

#### Audit Logging
- Deployment state changes
- User actions and approvals
- Configuration modifications
- Compliance tracking

#### Analytics
- Deployment success rates
- Performance metrics
- Resource utilization trends
- Health score calculation

## Integration Points

### External Systems Configuration

```bash
# Monitoring systems
export METRICS_ENDPOINT="https://prometheus.company.com/api/v1/write"
export LOG_AGGREGATOR_URL="logs.company.com"
export JAEGER_ENDPOINT="https://jaeger.company.com"
export AUDIT_ENDPOINT="https://audit.company.com/api"
export ANALYTICS_ENDPOINT="https://analytics.company.com/api"
```

## Usage Examples

### Complete Deployment Workflow

#### Development Deployment
```bash
# 1. Deploy to development
./scripts/deploy-dev.sh

# 2. Monitor deployment
./scripts/monitor-deployment.sh dev 300

# 3. Check status
./scripts/check-deployment-status.sh dev
```

#### Production Deployment
```bash
# 1. Deploy to production (with approvals)
./scripts/deploy-prod.sh

# 2. Monitor deployment with extended duration
./scripts/monitor-deployment.sh prod 600

# 3. Validate deployment
./scripts/validate-deployment-enhanced.sh prod

# 4. Send success notification
./scripts/notify-deployment.sh prod success "Production deployment completed successfully"
```

#### Emergency Rollback
```bash
# 1. Check if rollback is needed
./scripts/rollback-deployment.sh prod "" check

# 2. Perform rollback if needed
./scripts/rollback-deployment.sh prod "Critical bug detected" rollback

# 3. Validate rollback
./scripts/validate-deployment-enhanced.sh prod
```

## Best Practices

### Deployment Best Practices
1. **Always test in development first**
2. **Use staging environment for pre-production validation**
3. **Monitor deployments actively during rollout**
4. **Have rollback plan ready before production deployment**
5. **Document deployment decisions and issues**

### Monitoring Best Practices
1. **Set up proactive monitoring before deployment**
2. **Configure appropriate alert thresholds**
3. **Monitor both technical and business metrics**
4. **Maintain audit trails for compliance**
5. **Regular review of monitoring data for optimization**

### Security Best Practices
1. **Use least privilege access for deployment scripts**
2. **Secure notification channels and webhooks**
3. **Encrypt sensitive configuration data**
4. **Regular security scanning of deployment artifacts**
5. **Audit all deployment activities**

## Troubleshooting

### Common Issues

#### Deployment Failures
```bash
# Check pod status
kubectl get pods -n scrummate-<env>

# Check deployment events
kubectl describe deployment -n scrummate-<env>

# Check logs
./scripts/check-deployment-status.sh <env> events
```

#### Validation Failures
```bash
# Run enhanced validation with detailed output
./scripts/validate-deployment-enhanced.sh <env>

# Check specific validation components
kubectl get pods -n scrummate-<env> -o wide
kubectl get services -n scrummate-<env>
```

#### Rollback Issues
```bash
# Check rollback history
kubectl rollout history deployment/<deployment-name> -n scrummate-<env>

# Test rollback procedure
./scripts/rollback-deployment.sh <env> "" test
```

### Log Locations
- Deployment logs: `/tmp/scrummate-deployment-logs-<env>/`
- Metrics: `/tmp/scrummate-deployment-metrics-<env>-*.json`
- Audit logs: `/tmp/scrummate-deployment-audit.log`
- Notification logs: `/tmp/scrummate-deployment-notifications.log`
- Rollback logs: `/tmp/scrummate-rollback-log-*.txt`

## Support and Maintenance

### Regular Maintenance Tasks
1. **Clean up old log files and metrics**
2. **Review and update notification configurations**
3. **Test rollback procedures regularly**
4. **Update monitoring thresholds based on usage patterns**
5. **Review audit logs for security compliance**

### Script Updates
All deployment automation scripts are version controlled and should be updated through the standard Git workflow with proper testing in development and staging environments before production use.

## Contact Information

For issues with deployment automation:
- **Development Team**: dev-team@company.com
- **DevOps Team**: devops@company.com
- **On-call Support**: oncall@company.com

---

*This documentation is maintained as part of the ScrumMate project and should be updated with any changes to the deployment automation system.*
