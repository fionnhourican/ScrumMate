#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Staging Environment Deployment Script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="staging"

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
}

# Approval gate for staging deployment
approval_gate() {
    if [[ "${SKIP_APPROVAL:-false}" == "true" ]]; then
        log_warn "Skipping approval gate (SKIP_APPROVAL=true)"
        return 0
    fi
    
    log_warn "Staging deployment requires approval"
    read -p "Do you want to proceed with staging deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled by user"
        exit 0
    fi
}

# Deploy to staging environment
deploy_staging() {
    log_info "Starting deployment to staging environment..."
    
    cd "$PROJECT_ROOT"
    
    # Sync helmfile for staging environment
    helmfile -e staging sync --skip-deps
    
    log_info "Staging deployment completed successfully"
}

# Enhanced validation for staging
validate_deployment() {
    log_info "Validating staging deployment..."
    
    # Run validation script
    if [ -f "$SCRIPT_DIR/validate-deployment.sh" ]; then
        bash "$SCRIPT_DIR/validate-deployment.sh" staging
    else
        log_warn "Validation script not found, skipping validation"
    fi
    
    # Additional staging-specific checks
    log_info "Running staging-specific health checks..."
    kubectl get pods -n scrummate-staging --no-headers | grep -v Running && {
        log_error "Some pods are not in Running state"
        exit 1
    } || log_info "All pods are running"
}

# Main execution
main() {
    log_info "ScrumMate Staging Deployment"
    log_info "============================"
    
    check_prerequisites
    approval_gate
    deploy_staging
    validate_deployment
    
    log_info "Staging deployment process completed"
}

main "$@"
