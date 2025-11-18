#!/bin/bash
# Deployment validation script for ScrumMate

set -e

NAMESPACE=${1:-scrummate-dev}
TIMEOUT=${2:-300}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Validating deployment in namespace: ${NAMESPACE}${NC}"

# Wait for deployments to be ready
echo -e "${YELLOW}Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=${TIMEOUT}s deployment -l app.kubernetes.io/name=scrummate -n ${NAMESPACE}

# Wait for StatefulSets to be ready
echo -e "${YELLOW}Waiting for StatefulSets to be ready...${NC}"
kubectl wait --for=condition=ready --timeout=${TIMEOUT}s statefulset -l app.kubernetes.io/name=postgresql -n ${NAMESPACE} || true

# Check pod status
echo -e "${YELLOW}Checking pod status...${NC}"
kubectl get pods -n ${NAMESPACE}

# Validate services
echo -e "${YELLOW}Validating services...${NC}"
kubectl get services -n ${NAMESPACE}

# Health check validation
echo -e "${YELLOW}Performing health checks...${NC}"

# Check backend health
BACKEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/component=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ ! -z "$BACKEND_POD" ]; then
    echo "Checking backend health..."
    kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -- wget --spider --timeout=10 http://localhost:8080/health || echo "Backend health check failed"
fi

# Check frontend health
FRONTEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/component=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ ! -z "$FRONTEND_POD" ]; then
    echo "Checking frontend health..."
    kubectl exec -n ${NAMESPACE} ${FRONTEND_POD} -- wget --spider --timeout=10 http://localhost:80/health || echo "Frontend health check failed"
fi

# Check database connectivity
DB_POD=$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/component=primary -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ ! -z "$DB_POD" ]; then
    echo "Checking database connectivity..."
    kubectl exec -n ${NAMESPACE} ${DB_POD} -- pg_isready -U scrummate || echo "Database connectivity check failed"
fi

echo -e "${GREEN}Deployment validation completed!${NC}"
