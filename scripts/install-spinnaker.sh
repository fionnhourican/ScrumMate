#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Spinnaker Installation Script

set -euo pipefail

NAMESPACE=${SPINNAKER_NAMESPACE:-spinnaker}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
    
    if ! command -v helm &> /dev/null; then
        log_error "Helm is not installed"
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

# Create namespace
create_namespace() {
    log_info "Creating Spinnaker namespace..."
    
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    kubectl label namespace "$NAMESPACE" name="$NAMESPACE" --overwrite
}

# Add Spinnaker Helm repository
add_helm_repo() {
    log_info "Adding Spinnaker Helm repository..."
    
    helm repo add spinnaker https://opsmx.github.io/spinnaker-helm/
    helm repo update
}

# Deploy Spinnaker
deploy_spinnaker() {
    log_info "Deploying Spinnaker..."
    
    helm upgrade --install spinnaker spinnaker/spinnaker \
        --namespace "$NAMESPACE" \
        --values "$PROJECT_ROOT/spinnaker/values.yaml" \
        --timeout 10m \
        --wait
}

# Wait for services
wait_for_services() {
    log_info "Waiting for Spinnaker services to be ready..."
    
    kubectl wait --for=condition=ready pod -l app=spin-gate -n "$NAMESPACE" --timeout=600s
    kubectl wait --for=condition=ready pod -l app=spin-deck -n "$NAMESPACE" --timeout=600s
    kubectl wait --for=condition=ready pod -l app=spin-orca -n "$NAMESPACE" --timeout=600s
    kubectl wait --for=condition=ready pod -l app=spin-clouddriver -n "$NAMESPACE" --timeout=600s
}

# Configure access
configure_access() {
    log_info "Configuring Spinnaker access..."
    
    # Get LoadBalancer IPs
    local gate_ip=$(kubectl get svc spin-gate -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    local deck_ip=$(kubectl get svc spin-deck -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    log_info "Spinnaker UI will be available at: http://$deck_ip:9000"
    log_info "Spinnaker API will be available at: http://$gate_ip:8084"
    
    if [[ "$deck_ip" == "pending" || "$gate_ip" == "pending" ]]; then
        log_warn "LoadBalancer IPs are still pending. Check service status with:"
        log_warn "kubectl get svc -n $NAMESPACE"
    fi
}

# Main function
main() {
    log_info "ScrumMate Spinnaker Installation"
    log_info "================================"
    
    check_prerequisites
    create_namespace
    add_helm_repo
    deploy_spinnaker
    wait_for_services
    configure_access
    
    log_info "Spinnaker installation completed"
}

main "$@"
