# ScrumMate Helm Chart Values

This document describes the configuration values for the ScrumMate Helm chart.

## Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker registry | `""` |
| `global.imagePullSecrets` | Global image pull secrets | `[]` |
| `global.storageClass` | Global storage class | `""` |

## Backend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.enabled` | Enable backend service | `true` |
| `backend.replicaCount` | Number of backend replicas | `2` |
| `backend.image.repository` | Backend image repository | `scrummate/scrummate-backend` |
| `backend.image.tag` | Backend image tag | `""` (uses appVersion) |
| `backend.image.pullPolicy` | Image pull policy | `Always` |
| `backend.resources.requests.cpu` | CPU request | `500m` |
| `backend.resources.requests.memory` | Memory request | `512Mi` |
| `backend.resources.limits.cpu` | CPU limit | `1000m` |
| `backend.resources.limits.memory` | Memory limit | `1Gi` |
| `backend.autoscaling.enabled` | Enable HPA | `true` |
| `backend.autoscaling.minReplicas` | Minimum replicas | `2` |
| `backend.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `backend.autoscaling.targetCPUUtilizationPercentage` | CPU target | `70` |
| `backend.env.logLevel` | Log level | `INFO` |

## Frontend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frontend.enabled` | Enable frontend service | `true` |
| `frontend.replicaCount` | Number of frontend replicas | `3` |
| `frontend.image.repository` | Frontend image repository | `scrummate/scrummate-frontend` |
| `frontend.image.tag` | Frontend image tag | `""` (uses appVersion) |
| `frontend.image.pullPolicy` | Image pull policy | `Always` |
| `frontend.service.type` | Service type | `LoadBalancer` |
| `frontend.resources.requests.cpu` | CPU request | `100m` |
| `frontend.resources.requests.memory` | Memory request | `128Mi` |
| `frontend.resources.limits.cpu` | CPU limit | `500m` |
| `frontend.resources.limits.memory` | Memory limit | `256Mi` |

## Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL chart | `true` |
| `postgresql.auth.database` | Database name | `scrummate` |
| `postgresql.auth.username` | Database username | `scrummate` |
| `postgresql.auth.password` | Database password | `""` |
| `postgresql.primary.persistence.enabled` | Enable persistence | `true` |
| `postgresql.primary.persistence.size` | Storage size | `10Gi` |

## Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `true` |
| `ingress.className` | Ingress class | `nginx` |
| `ingress.hosts[0].host` | Frontend hostname | `scrummate.example.com` |
| `ingress.hosts[1].host` | Backend hostname | `api.scrummate.example.com` |
| `ingress.tls[0].secretName` | TLS secret name | `scrummate-tls-secret` |

## Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `securityContext.runAsNonRoot` | Run as non-root | `true` |
| `securityContext.runAsUser` | User ID | `65534` |
| `securityContext.readOnlyRootFilesystem` | Read-only filesystem | `true` |
| `networkPolicies.enabled` | Enable network policies | `true` |
| `rbac.create` | Create RBAC resources | `true` |

## Monitoring Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `monitoring.enabled` | Enable monitoring | `false` |
| `monitoring.serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `monitoring.serviceMonitor.interval` | Scrape interval | `30s` |

## Environment-Specific Values

### Development (`values-dev.yaml`)
- Reduced resource requirements
- Single replica deployments
- Debug logging enabled
- Network policies disabled
- Monitoring disabled

### Staging (`values-staging.yaml`)
- Production-like resources
- Moderate autoscaling
- Ingress enabled with staging domains
- Monitoring enabled
- Backup enabled

### Production (`values-prod.yaml`)
- High availability configuration
- Aggressive autoscaling
- Enhanced security contexts
- Full monitoring and alerting
- Production domains and TLS
- External secret management
