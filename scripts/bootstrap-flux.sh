#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Flux Bootstrap Script

set -euo pipefail

GITHUB_USER=${GITHUB_USER:-""}
GITHUB_TOKEN=${GITHUB_TOKEN:-""}
GITHUB_REPO=${GITHUB_REPO:-"ScrumMate"}
CLUSTER_NAME=${CLUSTER_NAME:-"scrummate-cluster"}
FLUX_NAMESPACE=${FLUX_NAMESPACE:-"flux-system"}

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
    
    if ! command -v flux &> /dev/null; then
        log_error "Flux CLI is not installed. Run ./scripts/install-flux-cli.sh first"
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
    
    if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
        log_error "GITHUB_USER and GITHUB_TOKEN environment variables must be set"
        log_info "Export these variables before running the script:"
        log_info "  export GITHUB_USER=your-github-username"
        log_info "  export GITHUB_TOKEN=your-github-token"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Pre-flight checks
run_preflight_checks() {
    log_info "Running Flux pre-flight checks..."
    
    if flux check --pre; then
        log_info "Pre-flight checks passed"
    else
        log_error "Pre-flight checks failed"
        exit 1
    fi
}

# Bootstrap Flux
bootstrap_flux() {
    log_info "Bootstrapping Flux in Kubernetes cluster..."
    log_info "Cluster: $CLUSTER_NAME"
    log_info "Repository: $GITHUB_USER/$GITHUB_REPO"
    log_info "Namespace: $FLUX_NAMESPACE"
    
    # Bootstrap Flux with GitHub
    flux bootstrap github \
        --owner="$GITHUB_USER" \
        --repository="$GITHUB_REPO" \
        --branch=main \
        --path="./gitops/clusters/$CLUSTER_NAME" \
        --personal \
        --token-auth
    
    log_info "Flux bootstrap completed"
}

# Configure Flux system namespace
configure_flux_namespace() {
    log_info "Configuring Flux system namespace..."
    
    # Add labels to flux-system namespace
    kubectl label namespace "$FLUX_NAMESPACE" \
        app.kubernetes.io/name=flux-system \
        app.kubernetes.io/instance=flux \
        app.kubernetes.io/version=v2.2.2 \
        --overwrite
    
    # Add resource quotas
    kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: flux-system-quota
  namespace: $FLUX_NAMESPACE
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "20"
EOF
    
    log_info "Flux system namespace configured"
}

# Set up controller permissions
setup_controller_permissions() {
    log_info "Setting up Flux controller permissions..."
    
    # Create additional RBAC for ScrumMate specific operations
    kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: scrummate-flux-controller
rules:
- apiGroups: [""]
  resources: ["namespaces", "secrets", "configmaps", "services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["helm.toolkit.fluxcd.io"]
  resources: ["helmreleases"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: scrummate-flux-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: scrummate-flux-controller
subjects:
- kind: ServiceAccount
  name: source-controller
  namespace: $FLUX_NAMESPACE
- kind: ServiceAccount
  name: kustomize-controller
  namespace: $FLUX_NAMESPACE
- kind: ServiceAccount
  name: helm-controller
  namespace: $FLUX_NAMESPACE
EOF
    
    log_info "Controller permissions configured"
}

# Configure webhook receivers
configure_webhook_receivers() {
    log_info "Configuring Flux webhook receivers..."
    
    # Create webhook receiver for GitHub
    kubectl apply -f - <<EOF
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Receiver
metadata:
  name: scrummate-receiver
  namespace: $FLUX_NAMESPACE
spec:
  type: github
  events:
    - "ping"
    - "push"
  secretRef:
    name: webhook-token
  resources:
    - kind: GitRepository
      name: scrummate-repo
      namespace: $FLUX_NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  name: webhook-token
  namespace: $FLUX_NAMESPACE
type: Opaque
data:
  token: $(echo -n "$(openssl rand -hex 20)" | base64 -w 0)
EOF
    
    log_info "Webhook receivers configured"
}

# Verify Flux installation
verify_flux_installation() {
    log_info "Verifying Flux installation..."
    
    # Wait for controllers to be ready
    kubectl wait --for=condition=ready pod -l app=source-controller -n "$FLUX_NAMESPACE" --timeout=300s
    kubectl wait --for=condition=ready pod -l app=kustomize-controller -n "$FLUX_NAMESPACE" --timeout=300s
    kubectl wait --for=condition=ready pod -l app=helm-controller -n "$FLUX_NAMESPACE" --timeout=300s
    kubectl wait --for=condition=ready pod -l app=notification-controller -n "$FLUX_NAMESPACE" --timeout=300s
    
    # Run Flux check
    if flux check; then
        log_info "Flux installation verified successfully"
    else
        log_error "Flux installation verification failed"
        return 1
    fi
    
    # Show Flux status
    log_info "Flux controllers status:"
    kubectl get pods -n "$FLUX_NAMESPACE"
}

# Main function
main() {
    log_info "ScrumMate Flux Bootstrap"
    log_info "========================"
    
    check_prerequisites
    run_preflight_checks
    bootstrap_flux
    configure_flux_namespace
    setup_controller_permissions
    configure_webhook_receivers
    verify_flux_installation
    
    log_info "Flux bootstrap process completed successfully"
    log_info "GitOps repository created at: https://github.com/$GITHUB_USER/$GITHUB_REPO"
    log_info "Flux dashboard: kubectl port-forward -n $FLUX_NAMESPACE svc/weave-gitops 9001:9001"
}

main "$@"
