#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Production Environment Deployment Script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="prod"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v helmfile &> /dev/null; then
        log_error "helmfile is not installed"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if staging deployment is healthy
    log_info "Verifying staging environment health..."
    if ! kubectl get pods -n scrummate-staging --no-headers | grep -q Running; then
        log_error "Staging environment is not healthy. Cannot proceed with production deployment."
        exit 1
    fi
}

# Strict approval gate for production
approval_gate() {
    log_warn "PRODUCTION DEPLOYMENT - REQUIRES EXPLICIT APPROVAL"
    log_warn "This will deploy to the production environment"
    
    read -p "Enter 'DEPLOY-TO-PRODUCTION' to confirm: " confirmation
    if [[ "$confirmation" != "DEPLOY-TO-PRODUCTION" ]]; then
        log_info "Deployment cancelled - incorrect confirmation"
        exit 0
    fi
    
    read -p "Final confirmation - Deploy to production? (yes/no): " final_confirm
    if [[ "$final_confirm" != "yes" ]]; then
        log_info "Deployment cancelled by user"
        exit 0
    fi
}

# Create backup before deployment
create_backup() {
    log_info "Creating pre-deployment backup..."
    
    BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup current Helm releases
    helm list -n scrummate-prod -o yaml > "$BACKUP_DIR/helm-releases.yaml"
    
    # Backup current configurations
    kubectl get configmaps -n scrummate-prod -o yaml > "$BACKUP_DIR/configmaps.yaml"
    kubectl get secrets -n scrummate-prod -o yaml > "$BACKUP_DIR/secrets.yaml"
    
    log_info "Backup created at: $BACKUP_DIR"
    echo "$BACKUP_DIR" > /tmp/scrummate-backup-path
}

# Deploy to production environment
deploy_production() {
    log_info "Starting deployment to production environment..."
    
    cd "$PROJECT_ROOT"
    
    # Sync helmfile for production environment
    helmfile -e prod sync --skip-deps
    
    log_info "Production deployment completed successfully"
}

# Comprehensive validation for production
validate_deployment() {
    log_info "Validating production deployment..."
    
    # Run validation script
    if [ -f "$SCRIPT_DIR/validate-deployment.sh" ]; then
        bash "$SCRIPT_DIR/validate-deployment.sh" prod
    else
        log_error "Validation script is required for production deployment"
        exit 1
    fi
    
    # Production-specific health checks
    log_info "Running production health checks..."
    
    # Check all pods are running
    if ! kubectl get pods -n scrummate-prod --no-headers | grep -v Running; then
        log_info "All pods are running"
    else
        log_error "Some pods are not in Running state"
        exit 1
    fi
    
    # Check service endpoints
    log_info "Checking service endpoints..."
    kubectl get endpoints -n scrummate-prod
    
    # Wait for rollout to complete
    kubectl rollout status deployment/scrummate-frontend -n scrummate-prod --timeout=300s
    kubectl rollout status deployment/scrummate-backend -n scrummate-prod --timeout=300s
}

# Main execution
main() {
    log_info "ScrumMate Production Deployment"
    log_info "==============================="
    
    check_prerequisites
    approval_gate
    create_backup
    deploy_production
    validate_deployment
    
    log_info "Production deployment process completed successfully"
    log_info "Backup location: $(cat /tmp/scrummate-backup-path 2>/dev/null || echo 'N/A')"
}

main "$@"
