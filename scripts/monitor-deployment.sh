#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Deployment Monitoring Script

set -euo pipefail

ENVIRONMENT=${1:-dev}
NAMESPACE="scrummate-${ENVIRONMENT}"
MONITORING_DURATION=${2:-300} # 5 minutes default

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

# Collect deployment metrics
collect_deployment_metrics() {
    log_header "Collecting Deployment Metrics"
    echo "=============================="
    
    local metrics_file="/tmp/scrummate-deployment-metrics-${ENVIRONMENT}-$(date +%Y%m%d_%H%M%S).json"
    
    # Basic deployment info
    local deployment_info=$(cat <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "environment": "$ENVIRONMENT",
    "namespace": "$NAMESPACE",
    "metrics": {
EOF
)
    
    # Pod metrics
    local total_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | wc -l)
    local running_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep Running | wc -l)
    local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | grep -v Completed | wc -l)
    
    deployment_info+='"pods": {'
    deployment_info+='"total": '$total_pods','
    deployment_info+='"running": '$running_pods','
    deployment_info+='"failed": '$failed_pods
    deployment_info+='},'
    
    # Resource usage metrics
    if kubectl top pods -n "$NAMESPACE" > /dev/null 2>&1; then
        local cpu_usage=$(kubectl top pods -n "$NAMESPACE" --no-headers | awk '{sum+=$2} END {print sum+0}')
        local memory_usage=$(kubectl top pods -n "$NAMESPACE" --no-headers | awk '{sum+=$3} END {print sum+0}')
        
        deployment_info+='"resources": {'
        deployment_info+='"cpu_millicores": '$cpu_usage','
        deployment_info+='"memory_mb": '$memory_usage
        deployment_info+='},'
    fi
    
    # Service metrics
    local service_count=$(kubectl get services -n "$NAMESPACE" --no-headers | wc -l)
    deployment_info+='"services": '$service_count','
    
    # Deployment status
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    deployment_info+='"deployments": ['
    local first=true
    for deployment in $deployments; do
        if [ "$first" = false ]; then
            deployment_info+=','
        fi
        first=false
        
        local ready_replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' || echo "0")
        local desired_replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
        
        deployment_info+='{'
        deployment_info+='"name": "'$deployment'",'
        deployment_info+='"ready_replicas": '$ready_replicas','
        deployment_info+='"desired_replicas": '$desired_replicas
        deployment_info+='}'
    done
    deployment_info+=']'
    
    deployment_info+='}}'
    
    echo "$deployment_info" > "$metrics_file"
    log_info "Metrics collected: $metrics_file"
    
    # Send metrics to monitoring system if configured
    if [ -n "${METRICS_ENDPOINT:-}" ]; then
        curl -X POST "$METRICS_ENDPOINT" \
            -H "Content-Type: application/json" \
            -d "$deployment_info" > /dev/null 2>&1 || log_warn "Failed to send metrics to monitoring system"
    fi
}

# Setup deployment logging
setup_deployment_logging() {
    log_header "Setting up Deployment Logging"
    echo "=============================="
    
    local log_dir="/tmp/scrummate-deployment-logs-${ENVIRONMENT}"
    mkdir -p "$log_dir"
    
    # Collect logs from all pods
    local pods=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for pod in $pods; do
        log_info "Collecting logs for pod: $pod"
        kubectl logs "$pod" -n "$NAMESPACE" --previous=false > "$log_dir/${pod}.log" 2>/dev/null || log_warn "Could not collect logs for $pod"
    done
    
    # Collect events
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' > "$log_dir/events.log"
    
    log_info "Deployment logs collected in: $log_dir"
    
    # Send logs to centralized logging if configured
    if [ -n "${LOG_AGGREGATOR_URL:-}" ] && command -v rsyslog &> /dev/null; then
        for log_file in "$log_dir"/*.log; do
            logger -n "$LOG_AGGREGATOR_URL" -P 514 -t "scrummate-$ENVIRONMENT" "$(cat "$log_file")" || log_warn "Failed to send logs to aggregator"
        done
    fi
}

# Configure deployment tracing
configure_deployment_tracing() {
    log_header "Configuring Deployment Tracing"
    echo "==============================="
    
    # Create trace context
    local trace_id="scrummate-deployment-$(date +%s)"
    local trace_file="/tmp/scrummate-deployment-trace-${ENVIRONMENT}-$(date +%Y%m%d_%H%M%S).json"
    
    # Trace deployment timeline
    local trace_data=$(cat <<EOF
{
    "trace_id": "$trace_id",
    "environment": "$ENVIRONMENT",
    "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "spans": [
EOF
)
    
    # Add deployment spans
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    local first=true
    for deployment in $deployments; do
        if [ "$first" = false ]; then
            trace_data+=','
        fi
        first=false
        
        local creation_time=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.metadata.creationTimestamp}')
        
        trace_data+='{'
        trace_data+='"span_id": "'$deployment'-deployment",'
        trace_data+='"operation": "deployment",'
        trace_data+='"service": "'$deployment'",'
        trace_data+='"start_time": "'$creation_time'",'
        trace_data+='"tags": {"environment": "'$ENVIRONMENT'", "namespace": "'$NAMESPACE'"}'
        trace_data+='}'
    done
    
    trace_data+=']}'
    
    echo "$trace_data" > "$trace_file"
    log_info "Deployment trace created: $trace_file"
    
    # Send to tracing system if configured
    if [ -n "${JAEGER_ENDPOINT:-}" ]; then
        curl -X POST "$JAEGER_ENDPOINT/api/traces" \
            -H "Content-Type: application/json" \
            -d "$trace_data" > /dev/null 2>&1 || log_warn "Failed to send trace to Jaeger"
    fi
}

# Add deployment audit logging
add_deployment_audit_logging() {
    log_header "Adding Deployment Audit Logging"
    echo "================================"
    
    local audit_file="/tmp/scrummate-deployment-audit.log"
    local audit_entry=$(cat <<EOF
$(date -u +%Y-%m-%dT%H:%M:%SZ) | DEPLOYMENT_MONITOR | $ENVIRONMENT | $(whoami) | Deployment monitoring started for $NAMESPACE
EOF
)
    
    echo "$audit_entry" >> "$audit_file"
    
    # Audit current state
    local deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    for deployment in $deployments; do
        local replicas=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
        local image=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')
        
        local deployment_audit=$(cat <<EOF
$(date -u +%Y-%m-%dT%H:%M:%SZ) | DEPLOYMENT_STATE | $ENVIRONMENT | $deployment | replicas=$replicas | image=$image
EOF
)
        echo "$deployment_audit" >> "$audit_file"
    done
    
    log_info "Audit log updated: $audit_file"
    
    # Send to audit system if configured
    if [ -n "${AUDIT_ENDPOINT:-}" ]; then
        curl -X POST "$AUDIT_ENDPOINT/audit" \
            -H "Content-Type: application/json" \
            -d '{"audit_log": "'$(cat "$audit_file" | tail -10 | tr '\n' '\\n')'"}' > /dev/null 2>&1 || log_warn "Failed to send audit log"
    fi
}

# Setup deployment analytics
setup_deployment_analytics() {
    log_header "Setting up Deployment Analytics"
    echo "==============================="
    
    local analytics_file="/tmp/scrummate-deployment-analytics-${ENVIRONMENT}.json"
    
    # Calculate deployment metrics
    local deployment_start_time=$(kubectl get deployment -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.creationTimestamp}' | head -1)
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Get deployment history
    local deployment_count=$(kubectl get replicasets -n "$NAMESPACE" --no-headers | wc -l)
    local successful_deployments=$(kubectl get replicasets -n "$NAMESPACE" -o jsonpath='{.items[*].status.readyReplicas}' | wc -w)
    
    local analytics_data=$(cat <<EOF
{
    "environment": "$ENVIRONMENT",
    "analysis_time": "$current_time",
    "deployment_metrics": {
        "total_deployments": $deployment_count,
        "successful_deployments": $successful_deployments,
        "deployment_start_time": "$deployment_start_time",
        "monitoring_duration": $MONITORING_DURATION
    },
    "health_score": $(( (successful_deployments * 100) / (deployment_count > 0 ? deployment_count : 1) ))
}
EOF
)
    
    echo "$analytics_data" > "$analytics_file"
    log_info "Analytics data generated: $analytics_file"
    
    # Send to analytics platform if configured
    if [ -n "${ANALYTICS_ENDPOINT:-}" ]; then
        curl -X POST "$ANALYTICS_ENDPOINT/deployments" \
            -H "Content-Type: application/json" \
            -d "$analytics_data" > /dev/null 2>&1 || log_warn "Failed to send analytics data"
    fi
}

# Continuous monitoring loop
continuous_monitoring() {
    log_info "Starting continuous monitoring for $MONITORING_DURATION seconds..."
    
    local end_time=$(($(date +%s) + MONITORING_DURATION))
    local check_interval=30
    
    while [ $(date +%s) -lt $end_time ]; do
        log_info "Monitoring check at $(date)"
        
        # Quick health check
        local failed_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -v Running | grep -v Completed | wc -l)
        if [ "$failed_pods" -gt 0 ]; then
            log_warn "$failed_pods pods are not running"
            
            # Send alert if configured
            if [ -f "$(dirname "$0")/notify-deployment.sh" ]; then
                bash "$(dirname "$0")/notify-deployment.sh" "$ENVIRONMENT" "warning" "Monitoring detected $failed_pods failed pods"
            fi
        fi
        
        sleep $check_interval
    done
    
    log_info "Continuous monitoring completed"
}

# Main function
main() {
    log_header "ScrumMate Deployment Monitoring"
    echo "==============================="
    log_info "Environment: $ENVIRONMENT"
    log_info "Monitoring Duration: $MONITORING_DURATION seconds"
    echo
    
    collect_deployment_metrics
    setup_deployment_logging
    configure_deployment_tracing
    add_deployment_audit_logging
    setup_deployment_analytics
    
    if [ "$MONITORING_DURATION" -gt 0 ]; then
        continuous_monitoring
    fi
    
    log_info "Deployment monitoring completed"
}

# Handle command line options
case "${3:-monitor}" in
    "metrics")
        collect_deployment_metrics
        ;;
    "logs")
        setup_deployment_logging
        ;;
    "trace")
        configure_deployment_tracing
        ;;
    "audit")
        add_deployment_audit_logging
        ;;
    "analytics")
        setup_deployment_analytics
        ;;
    "monitor"|"")
        main
        ;;
    *)
        echo "Usage: $0 <environment> [duration] [metrics|logs|trace|audit|analytics|monitor]"
        echo "  environment: dev, staging, prod"
        echo "  duration: monitoring duration in seconds (default: 300)"
        echo "  action: monitoring action (default: monitor)"
        exit 1
        ;;
esac
