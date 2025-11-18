# CI/CD Secrets Configuration

This document outlines the required secrets for CI/CD pipeline configuration.

## Required Secrets

### Docker Registry
- `DOCKER_REGISTRY_URL`: Docker registry URL
- `DOCKER_USERNAME`: Docker registry username
- `DOCKER_PASSWORD`: Docker registry password/token

### Kubernetes Cluster Access
- `KUBE_CONFIG`: Base64 encoded kubeconfig file
- `KUBE_CLUSTER_URL`: Kubernetes cluster API URL
- `KUBE_TOKEN`: Service account token for cluster access

### Database Configuration
- `DB_HOST`: Database host URL
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

### JWT Configuration
- `JWT_SECRET`: JWT signing secret key
- `JWT_EXPIRATION`: JWT token expiration time

## Security Guidelines

1. All secrets must be stored securely in the CI/CD platform
2. Secrets should be rotated regularly
3. Use least privilege principle for service accounts
4. Never commit secrets to version control
5. Use environment-specific secrets for different deployment stages

## Setup Instructions

### GitHub Actions
1. Go to repository Settings > Secrets and variables > Actions
2. Add each secret with the corresponding value
3. Ensure secrets are available to the required workflows

### Other CI/CD Platforms
Refer to platform-specific documentation for secret management.
