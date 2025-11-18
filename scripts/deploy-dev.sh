#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Development Environment Deployment Script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="dev"

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

# Deploy to development environment
deploy_dev() {
    log_info "Starting deployment to development environment..."
    
    cd "$PROJECT_ROOT"
    
    # Sync helmfile for dev environment
    helmfile -e dev sync --skip-deps
    
    log_info "Development deployment completed successfully"
}

# Validate deployment
validate_deployment() {
    log_info "Validating development deployment..."
    
    # Run validation script
    if [ -f "$SCRIPT_DIR/validate-deployment.sh" ]; then
        bash "$SCRIPT_DIR/validate-deployment.sh" dev
    else
        log_warn "Validation script not found, skipping validation"
    fi
}

# Main execution
main() {
    log_info "ScrumMate Development Deployment"
    log_info "================================"
    
    check_prerequisites
    deploy_dev
    validate_deployment
    
    log_info "Development deployment process completed"
}

main "$@"
