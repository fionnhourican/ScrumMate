# Helmfile Deployment Guide

This guide explains how to use Helmfile for deploying ScrumMate across different environments.

## Prerequisites

- Kubernetes cluster access
- Helm 3.x installed
- Helmfile installed
- kubectl configured

## Installation

### Install Helmfile
```bash
# Linux
curl -L https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64.tar.gz | tar xz
sudo mv helmfile /usr/local/bin/

# macOS
brew install helmfile
```

## Environment Structure

```
environments/
├── dev/
│   ├── values.yaml      # Development configuration
│   └── secrets.yaml     # Development secrets
├── staging/
│   ├── values.yaml      # Staging configuration
│   └── secrets.yaml     # Staging secrets
└── prod/
    ├── values.yaml      # Production configuration
    └── secrets.yaml     # Production secrets
```

## Deployment Commands

### Development Environment
```bash
# Deploy to development
./scripts/helmfile-deploy.sh dev sync

# Show diff
./scripts/helmfile-deploy.sh dev diff

# Plan deployment
./scripts/helmfile-deploy.sh dev plan
```

### Staging Environment
```bash
# Deploy to staging
./scripts/helmfile-deploy.sh staging sync

# Show what would change
./scripts/helmfile-deploy.sh staging diff
```

### Production Environment
```bash
# Deploy to production
./scripts/helmfile-deploy.sh prod sync

# Destroy production (with confirmation)
./scripts/helmfile-deploy.sh prod destroy
```

## Release Dependencies

The Helmfile defines the following deployment order:

1. **cert-manager** - SSL certificate management
2. **ingress-nginx** - Ingress controller (depends on cert-manager)
3. **kube-prometheus-stack** - Monitoring (optional, parallel)
4. **scrummate** - Main application (depends on ingress-nginx)

## Environment Configurations

### Development
- Minimal resources
- Single replicas
- No ingress or monitoring
- Local database
- Debug logging

### Staging
- Production-like resources
- Moderate autoscaling
- Ingress with staging domains
- Monitoring enabled
- Backup enabled

### Production
- High availability
- Aggressive autoscaling
- Production domains with TLS
- Full monitoring and alerting
- Enhanced security contexts

## Lifecycle Hooks

### Pre-sync Hooks
- Create namespaces
- Validate configurations

### Post-sync Hooks
- Deployment validation
- Health checks
- Integration tests

## Secret Management

### Development
Secrets are stored in plain text for convenience.

### Staging/Production
**WARNING**: Update all secrets before deployment!

Use external secret management systems like:
- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes External Secrets Operator

## Troubleshooting

### Common Issues

1. **Helmfile not found**
   ```bash
   # Install Helmfile
   curl -L https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64.tar.gz | tar xz
   sudo mv helmfile /usr/local/bin/
   ```

2. **Repository not found**
   ```bash
   # Update Helm repositories
   helm repo update
   ```

3. **Timeout during deployment**
   ```bash
   # Increase timeout in helmfile.yaml
   helmDefaults:
     timeout: 1200  # 20 minutes
   ```

4. **Dependency issues**
   ```bash
   # Check release status
   helmfile -e <env> status
   
   # Force sync specific release
   helmfile -e <env> sync --selector name=scrummate
   ```

### Validation Commands

```bash
# Lint Helmfile configuration
helmfile -e dev lint

# Validate templates
helmfile -e dev template

# Check deployment status
helmfile -e dev status

# Show release history
helmfile -e dev list
```

## Best Practices

1. **Always run diff before sync**
   ```bash
   helmfile -e prod diff
   helmfile -e prod sync
   ```

2. **Use environment-specific secrets**
   - Never use development secrets in production
   - Rotate secrets regularly
   - Use external secret management

3. **Monitor deployments**
   - Check logs during deployment
   - Validate health checks
   - Monitor resource usage

4. **Backup before major changes**
   - Export current configurations
   - Create database backups
   - Document rollback procedures
