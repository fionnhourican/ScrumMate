#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Enhanced Deployment Validation Script

set -euo pipefail

ENVIRONMENT=${1:-dev}
NAMESPACE="scrummate-${ENVIRONMENT}"

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

# Health check validation
validate_health_checks() {
    log_info "Validating health checks for $ENVIRONMENT environment..."
    
    # Check pod status
    local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | wc -l)
    if [ "$failed_pods" -gt 0 ]; then
        log_error "$failed_pods pods are not in Running state"
        kubectl get pods -n "$NAMESPACE"
        return 1
    fi
    
    # Check readiness probes
    local unready_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '$2 !~ /^[0-9]+\/[0-9]+$/ || $2 ~ /0\// {print $1}' | wc -l)
    if [ "$unready_pods" -gt 0 ]; then
        log_error "$unready_pods pods are not ready"
        return 1
    fi
    
    log_info "All pods are healthy and ready"
    return 0
}

# Functional testing
validate_functional_tests() {
    log_info "Running functional tests..."
    
    # Get service endpoints
    local frontend_service=$(kubectl get svc -n "$NAMESPACE" -l app=scrummate-frontend -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    local backend_service=$(kubectl get svc -n "$NAMESPACE" -l app=scrummate-backend -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null || echo "")
    
    if [ -z "$backend_service" ]; then
        log_error "Backend service not found"
        return 1
    fi
    
    # Test backend health endpoint
    if kubectl run test-pod --rm -i --restart=Never --image=curlimages/curl -- curl -f "http://${backend_service}:8080/actuator/health" > /dev/null 2>&1; then
        log_info "Backend health check passed"
    else
        log_error "Backend health check failed"
        return 1
    fi
    
    # Test API endpoints
    if kubectl run test-pod --rm -i --restart=Never --image=curlimages/curl -- curl -f "http://${backend_service}:8080/api/v1/health" > /dev/null 2>&1; then
        log_info "API endpoints accessible"
    else
        log_warn "API endpoints test failed (may require authentication)"
    fi
    
    return 0
}

# Performance validation
validate_performance() {
    log_info "Running performance validation..."
    
    # Check resource usage
    local cpu_usage=$(kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{sum+=$2} END {print sum}' || echo "0")
    local memory_usage=$(kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{sum+=$3} END {print sum}' || echo "0")
    
    log_info "Current resource usage - CPU: ${cpu_usage}m, Memory: ${memory_usage}Mi"
    
    # Check if pods are within resource limits
    local pods_over_limit=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[*].restartCount}{"\n"}{end}' | awk '$2 > 0 {count++} END {print count+0}')
    
    if [ "$pods_over_limit" -gt 0 ]; then
        log_warn "$pods_over_limit pods have been restarted (possible resource issues)"
    else
        log_info "No pods have been restarted due to resource issues"
    fi
    
    return 0
}

# Security validation
validate_security() {
    log_info "Running security validation..."
    
    # Check if pods are running as non-root
    local root_pods=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.securityContext.runAsUser}{"\n"}{end}' | grep " 0$" | wc -l)
    
    if [ "$root_pods" -gt 0 ]; then
        log_warn "$root_pods pods are running as root user"
    else
        log_info "All pods are running as non-root users"
    fi
    
    # Check for required secrets
    local required_secrets=("scrummate-db-secret" "scrummate-jwt-secret")
    for secret in "${required_secrets[@]}"; do
        if kubectl get secret "$secret" -n "$NAMESPACE" > /dev/null 2>&1; then
            log_info "Secret $secret exists"
        else
            log_error "Required secret $secret is missing"
            return 1
        fi
    done
    
    return 0
}

# Integration testing
validate_integration() {
    log_info "Running integration tests..."
    
    # Check service connectivity
    local services=$(kubectl get svc -n "$NAMESPACE" --no-headers | wc -l)
    if [ "$services" -lt 3 ]; then
        log_error "Expected at least 3 services, found $services"
        return 1
    fi
    
    # Check database connectivity
    local db_pod=$(kubectl get pods -n "$NAMESPACE" -l app=postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$db_pod" ]; then
        if kubectl exec "$db_pod" -n "$NAMESPACE" -- pg_isready > /dev/null 2>&1; then
            log_info "Database connectivity verified"
        else
            log_error "Database connectivity failed"
            return 1
        fi
    else
        log_warn "Database pod not found (may be external)"
    fi
    
    return 0
}

# Main validation function
main() {
    log_info "Enhanced Deployment Validation for $ENVIRONMENT"
    log_info "=============================================="
    
    local validation_failed=0
    
    validate_health_checks || validation_failed=1
    validate_functional_tests || validation_failed=1
    validate_performance || validation_failed=1
    validate_security || validation_failed=1
    validate_integration || validation_failed=1
    
    if [ $validation_failed -eq 0 ]; then
        log_info "All validation checks passed for $ENVIRONMENT environment"
        return 0
    else
        log_error "Some validation checks failed for $ENVIRONMENT environment"
        return 1
    fi
}

main "$@"
