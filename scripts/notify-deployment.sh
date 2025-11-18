#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Deployment Notification Script

set -euo pipefail

ENVIRONMENT=${1:-dev}
STATUS=${2:-success}
MESSAGE=${3:-"Deployment completed"}

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

# Get deployment status emoji
get_status_emoji() {
    case "$STATUS" in
        "success") echo "✅" ;;
        "failure") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "info") echo "ℹ️" ;;
        "rollback") echo "🔄" ;;
        *) echo "📋" ;;
    esac
}

# Send Slack notification
send_slack_notification() {
    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        log_warn "SLACK_WEBHOOK_URL not configured, skipping Slack notification"
        return 0
    fi
    
    local emoji=$(get_status_emoji)
    local color
    case "$STATUS" in
        "success") color="good" ;;
        "failure") color="danger" ;;
        "warning") color="warning" ;;
        *) color="#439FE0" ;;
    esac
    
    local payload=$(cat <<EOF
{
    "attachments": [
        {
            "color": "$color",
            "title": "$emoji ScrumMate Deployment - $ENVIRONMENT",
            "fields": [
                {
                    "title": "Environment",
                    "value": "$ENVIRONMENT",
                    "short": true
                },
                {
                    "title": "Status",
                    "value": "$STATUS",
                    "short": true
                },
                {
                    "title": "Message",
                    "value": "$MESSAGE",
                    "short": false
                },
                {
                    "title": "Timestamp",
                    "value": "$(date)",
                    "short": true
                }
            ]
        }
    ]
}
EOF
)
    
    if curl -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1; then
        log_info "Slack notification sent successfully"
    else
        log_error "Failed to send Slack notification"
    fi
}

# Send email notification
send_email_notification() {
    if [ -z "${NOTIFICATION_EMAIL:-}" ]; then
        log_warn "NOTIFICATION_EMAIL not configured, skipping email notification"
        return 0
    fi
    
    if ! command -v mail &> /dev/null; then
        log_warn "mail command not available, skipping email notification"
        return 0
    fi
    
    local subject="ScrumMate Deployment - $ENVIRONMENT - $STATUS"
    local body=$(cat <<EOF
ScrumMate Deployment Notification

Environment: $ENVIRONMENT
Status: $STATUS
Message: $MESSAGE
Timestamp: $(date)

This is an automated notification from the ScrumMate deployment system.
EOF
)
    
    if echo "$body" | mail -s "$subject" "$NOTIFICATION_EMAIL"; then
        log_info "Email notification sent successfully"
    else
        log_error "Failed to send email notification"
    fi
}

# Send webhook notification
send_webhook_notification() {
    if [ -z "${WEBHOOK_URL:-}" ]; then
        log_warn "WEBHOOK_URL not configured, skipping webhook notification"
        return 0
    fi
    
    local payload=$(cat <<EOF
{
    "environment": "$ENVIRONMENT",
    "status": "$STATUS",
    "message": "$MESSAGE",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "service": "scrummate"
}
EOF
)
    
    if curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1; then
        log_info "Webhook notification sent successfully"
    else
        log_error "Failed to send webhook notification"
    fi
}

# Send dashboard update
send_dashboard_update() {
    if [ -z "${DASHBOARD_API_URL:-}" ]; then
        log_warn "DASHBOARD_API_URL not configured, skipping dashboard update"
        return 0
    fi
    
    local payload=$(cat <<EOF
{
    "deployment": {
        "environment": "$ENVIRONMENT",
        "status": "$STATUS",
        "message": "$MESSAGE",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "service": "scrummate"
    }
}
EOF
)
    
    if curl -X POST "$DASHBOARD_API_URL/deployments" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${DASHBOARD_API_TOKEN:-}" \
        -d "$payload" > /dev/null 2>&1; then
        log_info "Dashboard update sent successfully"
    else
        log_error "Failed to send dashboard update"
    fi
}

# Setup failure alerting
setup_failure_alerting() {
    if [ "$STATUS" != "failure" ]; then
        return 0
    fi
    
    log_warn "Setting up failure alerting..."
    
    # Send urgent notifications for failures
    if [ -n "${URGENT_SLACK_WEBHOOK_URL:-}" ]; then
        local urgent_payload=$(cat <<EOF
{
    "text": "🚨 URGENT: ScrumMate deployment failed in $ENVIRONMENT environment",
    "attachments": [
        {
            "color": "danger",
            "title": "Deployment Failure Details",
            "fields": [
                {
                    "title": "Environment",
                    "value": "$ENVIRONMENT",
                    "short": true
                },
                {
                    "title": "Error",
                    "value": "$MESSAGE",
                    "short": false
                },
                {
                    "title": "Action Required",
                    "value": "Immediate investigation required",
                    "short": false
                }
            ]
        }
    ]
}
EOF
)
        
        curl -X POST "$URGENT_SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "$urgent_payload" > /dev/null 2>&1 || log_error "Failed to send urgent Slack alert"
    fi
    
    # Send to on-call system if configured
    if [ -n "${ONCALL_WEBHOOK_URL:-}" ]; then
        local oncall_payload=$(cat <<EOF
{
    "alert": {
        "service": "scrummate",
        "environment": "$ENVIRONMENT",
        "severity": "critical",
        "message": "Deployment failure: $MESSAGE",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
}
EOF
)
        
        curl -X POST "$ONCALL_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "$oncall_payload" > /dev/null 2>&1 || log_error "Failed to send on-call alert"
    fi
}

# Log notification
log_notification() {
    local log_file="/tmp/scrummate-deployment-notifications.log"
    local log_entry="$(date): $ENVIRONMENT - $STATUS - $MESSAGE"
    
    echo "$log_entry" >> "$log_file"
    log_info "Notification logged to $log_file"
}

# Main function
main() {
    log_info "Sending deployment notifications for $ENVIRONMENT ($STATUS)"
    
    send_slack_notification
    send_email_notification
    send_webhook_notification
    send_dashboard_update
    setup_failure_alerting
    log_notification
    
    log_info "All configured notifications sent"
}

# Handle different notification types
case "${4:-all}" in
    "slack")
        send_slack_notification
        ;;
    "email")
        send_email_notification
        ;;
    "webhook")
        send_webhook_notification
        ;;
    "dashboard")
        send_dashboard_update
        ;;
    "all"|"")
        main
        ;;
    *)
        echo "Usage: $0 <environment> <status> <message> [slack|email|webhook|dashboard|all]"
        echo "  environment: dev, staging, prod"
        echo "  status: success, failure, warning, info, rollback"
        echo "  message: notification message"
        echo "  type: notification type (default: all)"
        exit 1
        ;;
esac
