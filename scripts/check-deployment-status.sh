#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Deployment Status Checking Script

set -euo pipefail

ENVIRONMENT=${1:-dev}
NAMESPACE="scrummate-${ENVIRONMENT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Check deployment status
check_deployment_status() {
    log_header "Deployment Status for $ENVIRONMENT Environment"
    echo "=================================================="
    
    # Check if namespace exists
    if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
        log_error "Namespace $NAMESPACE does not exist"
        return 1
    fi
    
    # Check deployments
    log_info "Checking deployments..."
    kubectl get deployments -n "$NAMESPACE" -o wide
    echo
    
    # Check deployment rollout status
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for deployment in $deployments; do
        log_info "Rollout status for $deployment:"
        kubectl rollout status deployment/"$deployment" -n "$NAMESPACE" --timeout=10s || log_warn "Deployment $deployment is not ready"
    done
    echo
}

# Check pod status
check_pod_status() {
    log_header "Pod Status"
    echo "=========="
    
    kubectl get pods -n "$NAMESPACE" -o wide
    echo
    
    # Check for problematic pods
    local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | grep -v Completed || true)
    if [ -n "$failed_pods" ]; then
        log_warn "Problematic pods found:"
        echo "$failed_pods"
        echo
        
        # Show logs for failed pods
        while IFS= read -r line; do
            local pod_name=$(echo "$line" | awk '{print $1}')
            local pod_status=$(echo "$line" | awk '{print $3}')
            if [[ "$pod_status" != "Running" && "$pod_status" != "Completed" ]]; then
                log_warn "Logs for pod $pod_name:"
                kubectl logs "$pod_name" -n "$NAMESPACE" --tail=10 || log_error "Could not retrieve logs for $pod_name"
                echo
            fi
        done <<< "$failed_pods"
    else
        log_info "All pods are running successfully"
    fi
}

# Check service status
check_service_status() {
    log_header "Service Status"
    echo "=============="
    
    kubectl get services -n "$NAMESPACE" -o wide
    echo
    
    # Check endpoints
    log_info "Service endpoints:"
    kubectl get endpoints -n "$NAMESPACE"
    echo
}

# Check resource usage
check_resource_usage() {
    log_header "Resource Usage"
    echo "=============="
    
    if kubectl top pods -n "$NAMESPACE" > /dev/null 2>&1; then
        kubectl top pods -n "$NAMESPACE"
        echo
        
        # Calculate total usage
        local total_cpu=$(kubectl top pods -n "$NAMESPACE" --no-headers | awk '{sum+=$2} END {print sum+0}')
        local total_memory=$(kubectl top pods -n "$NAMESPACE" --no-headers | awk '{sum+=$3} END {print sum+0}')
        
        log_info "Total resource usage - CPU: ${total_cpu}m, Memory: ${total_memory}Mi"
    else
        log_warn "Metrics server not available - cannot show resource usage"
    fi
    echo
}

# Check ingress status
check_ingress_status() {
    log_header "Ingress Status"
    echo "=============="
    
    local ingresses=$(kubectl get ingress -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    if [ "$ingresses" -gt 0 ]; then
        kubectl get ingress -n "$NAMESPACE" -o wide
    else
        log_info "No ingress resources found"
    fi
    echo
}

# Check persistent volumes
check_storage_status() {
    log_header "Storage Status"
    echo "=============="
    
    local pvcs=$(kubectl get pvc -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    if [ "$pvcs" -gt 0 ]; then
        kubectl get pvc -n "$NAMESPACE" -o wide
        echo
        
        # Check PV status
        log_info "Related Persistent Volumes:"
        kubectl get pv | grep "$NAMESPACE" || log_info "No persistent volumes found for this namespace"
    else
        log_info "No persistent volume claims found"
    fi
    echo
}

# Check recent events
check_recent_events() {
    log_header "Recent Events"
    echo "============="
    
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -10
    echo
}

# Generate summary
generate_summary() {
    log_header "Deployment Summary"
    echo "=================="
    
    local total_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | wc -l)
    local running_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep Running | wc -l)
    local total_services=$(kubectl get services -n "$NAMESPACE" --no-headers | wc -l)
    local total_deployments=$(kubectl get deployments -n "$NAMESPACE" --no-headers | wc -l)
    
    echo "Environment: $ENVIRONMENT"
    echo "Namespace: $NAMESPACE"
    echo "Pods: $running_pods/$total_pods running"
    echo "Services: $total_services"
    echo "Deployments: $total_deployments"
    
    if [ "$running_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
        log_info "Deployment is healthy"
    else
        log_warn "Deployment may have issues"
    fi
}

# Main function
main() {
    check_deployment_status
    check_pod_status
    check_service_status
    check_resource_usage
    check_ingress_status
    check_storage_status
    check_recent_events
    generate_summary
}

# Handle command line options
case "${1:-status}" in
    "status"|"")
        main
        ;;
    "pods")
        check_pod_status
        ;;
    "services")
        check_service_status
        ;;
    "resources")
        check_resource_usage
        ;;
    "events")
        check_recent_events
        ;;
    "summary")
        generate_summary
        ;;
    *)
        echo "Usage: $0 [environment] [status|pods|services|resources|events|summary]"
        echo "Default environment: dev"
        echo "Default action: status"
        exit 1
        ;;
esac
