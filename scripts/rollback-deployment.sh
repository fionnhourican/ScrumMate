#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Deployment Rollback Script

set -euo pipefail

ENVIRONMENT=${1:-dev}
NAMESPACE="scrummate-${ENVIRONMENT}"
ROLLBACK_REASON=${2:-"Manual rollback"}

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

# Check if automatic rollback is triggered
check_automatic_rollback_triggers() {
    log_info "Checking automatic rollback triggers..."
    
    local trigger_rollback=false
    local trigger_reasons=()
    
    # Check pod failure rate
    local total_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | wc -l)
    local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | grep -v Completed | wc -l)
    
    if [ "$total_pods" -gt 0 ]; then
        local failure_rate=$((failed_pods * 100 / total_pods))
        if [ "$failure_rate" -gt 50 ]; then
            trigger_rollback=true
            trigger_reasons+=("Pod failure rate: ${failure_rate}% (threshold: 50%)")
        fi
    fi
    
    # Check deployment status
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for deployment in $deployments; do
        local ready_replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' || echo "0")
        local desired_replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
        
        if [ "$ready_replicas" -lt "$desired_replicas" ]; then
            # Wait 5 minutes for deployment to stabilize
            log_warn "Deployment $deployment not ready. Waiting 5 minutes..."
            sleep 300
            
            ready_replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' || echo "0")
            if [ "$ready_replicas" -lt "$desired_replicas" ]; then
                trigger_rollback=true
                trigger_reasons+=("Deployment $deployment failed: $ready_replicas/$desired_replicas ready")
            fi
        fi
    done
    
    # Check for excessive restarts
    local restart_count=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.status.containerStatuses[*].restartCount}{"\n"}{end}' | awk '{sum+=$1} END {print sum+0}')
    if [ "$restart_count" -gt 10 ]; then
        trigger_rollback=true
        trigger_reasons+=("Excessive pod restarts: $restart_count (threshold: 10)")
    fi
    
    if [ "$trigger_rollback" = true ]; then
        log_error "Automatic rollback triggered!"
        for reason in "${trigger_reasons[@]}"; do
            log_error "  - $reason"
        done
        return 0
    else
        log_info "No automatic rollback triggers detected"
        return 1
    fi
}

# Manual rollback confirmation
confirm_manual_rollback() {
    if [[ "${AUTO_ROLLBACK:-false}" == "true" ]]; then
        log_warn "Auto rollback mode enabled, skipping confirmation"
        return 0
    fi
    
    log_warn "Manual rollback requested for $ENVIRONMENT environment"
    log_warn "Reason: $ROLLBACK_REASON"
    
    read -p "Do you want to proceed with rollback? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Rollback cancelled by user"
        exit 0
    fi
}

# Get previous revision
get_previous_revision() {
    log_info "Identifying previous revision..."
    
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for deployment in $deployments; do
        local current_revision=$(kubectl rollout history deployment/"$deployment" -n "$NAMESPACE" | tail -n 1 | awk '{print $1}')
        local previous_revision=$((current_revision - 1))
        
        if [ "$previous_revision" -gt 0 ]; then
            log_info "Previous revision for $deployment: $previous_revision"
        else
            log_error "No previous revision found for $deployment"
            return 1
        fi
    done
}

# Perform rollback
perform_rollback() {
    log_header "Performing Rollback"
    echo "==================="
    
    # Create rollback timestamp
    local rollback_timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Rollback deployments
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for deployment in $deployments; do
        log_info "Rolling back deployment: $deployment"
        
        if kubectl rollout undo deployment/"$deployment" -n "$NAMESPACE"; then
            log_info "Rollback initiated for $deployment"
            
            # Wait for rollback to complete
            if kubectl rollout status deployment/"$deployment" -n "$NAMESPACE" --timeout=300s; then
                log_info "Rollback completed for $deployment"
            else
                log_error "Rollback failed for $deployment"
                return 1
            fi
        else
            log_error "Failed to initiate rollback for $deployment"
            return 1
        fi
    done
    
    # Log rollback event
    echo "$(date): Rollback performed for $ENVIRONMENT - Reason: $ROLLBACK_REASON" >> "/tmp/scrummate-rollback-log-${rollback_timestamp}.txt"
}

# Validate rollback
validate_rollback() {
    log_header "Validating Rollback"
    echo "==================="
    
    # Wait for pods to stabilize
    log_info "Waiting for pods to stabilize..."
    sleep 30
    
    # Check pod status
    local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | grep -v Completed | wc -l)
    if [ "$failed_pods" -gt 0 ]; then
        log_error "Rollback validation failed: $failed_pods pods are not running"
        return 1
    fi
    
    # Run basic health checks
    if [ -f "$(dirname "$0")/validate-deployment-enhanced.sh" ]; then
        log_info "Running enhanced validation..."
        bash "$(dirname "$0")/validate-deployment-enhanced.sh" "$ENVIRONMENT"
    else
        log_warn "Enhanced validation script not found, running basic checks"
        
        # Basic connectivity test
        local backend_service=$(kubectl get svc -n "$NAMESPACE" -l app=scrummate-backend -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null || echo "")
        if [ -n "$backend_service" ]; then
            if kubectl run test-pod --rm -i --restart=Never --image=curlimages/curl -- curl -f "http://${backend_service}:8080/actuator/health" > /dev/null 2>&1; then
                log_info "Basic health check passed"
            else
                log_error "Basic health check failed"
                return 1
            fi
        fi
    fi
    
    log_info "Rollback validation completed successfully"
}

# Send rollback notification
send_rollback_notification() {
    log_info "Sending rollback notification..."
    
    local notification_message="🔄 ScrumMate Rollback Completed
Environment: $ENVIRONMENT
Reason: $ROLLBACK_REASON
Timestamp: $(date)
Status: Success"
    
    # Webhook notification (if configured)
    if [ -n "${WEBHOOK_URL:-}" ]; then
        curl -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{\"text\":\"$notification_message\"}" > /dev/null 2>&1 || log_warn "Webhook notification failed"
    fi
    
    # Email notification (if configured)
    if [ -n "${NOTIFICATION_EMAIL:-}" ] && command -v mail &> /dev/null; then
        echo "$notification_message" | mail -s "ScrumMate Rollback - $ENVIRONMENT" "$NOTIFICATION_EMAIL" || log_warn "Email notification failed"
    fi
    
    # Log notification
    echo "$notification_message" >> "/tmp/scrummate-rollback-notification.log"
    log_info "Rollback notification sent"
}

# Rollback testing procedure
test_rollback_procedure() {
    log_header "Testing Rollback Procedure"
    echo "=========================="
    
    log_info "This is a dry-run test of the rollback procedure"
    log_info "No actual rollback will be performed"
    
    # Simulate rollback checks
    check_automatic_rollback_triggers || log_info "No triggers detected (expected for test)"
    get_previous_revision
    
    log_info "Rollback procedure test completed"
    log_info "Use 'rollback' command to perform actual rollback"
}

# Main function
main() {
    local action=${3:-rollback}
    
    case "$action" in
        "test")
            test_rollback_procedure
            ;;
        "check")
            if check_automatic_rollback_triggers; then
                log_warn "Automatic rollback should be triggered"
                exit 1
            else
                log_info "No rollback triggers detected"
                exit 0
            fi
            ;;
        "rollback"|"")
            log_header "ScrumMate Deployment Rollback"
            echo "============================="
            
            # Check if automatic rollback should be triggered
            if check_automatic_rollback_triggers; then
                log_warn "Automatic rollback triggered"
                AUTO_ROLLBACK=true
            else
                confirm_manual_rollback
            fi
            
            get_previous_revision
            perform_rollback
            validate_rollback
            send_rollback_notification
            
            log_info "Rollback process completed successfully"
            ;;
        *)
            echo "Usage: $0 <environment> [reason] [rollback|test|check]"
            echo "  environment: dev, staging, prod"
            echo "  reason: reason for rollback (optional)"
            echo "  action: rollback (default), test, check"
            exit 1
            ;;
    esac
}

main "$@"
