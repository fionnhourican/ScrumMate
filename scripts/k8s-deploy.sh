#!/bin/bash
# Kubernetes deployment script for ScrumMate

set -e

# Configuration
NAMESPACE=${1:-scrummate-dev}
ENVIRONMENT=${2:-dev}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying ScrumMate to Kubernetes...${NC}"
echo -e "${YELLOW}Namespace: ${NAMESPACE}${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace...${NC}"
kubectl apply -f infrastructure/k8s/namespaces/${ENVIRONMENT}-namespace.yaml

# Apply storage resources
echo -e "${YELLOW}Creating storage resources...${NC}"
kubectl apply -f infrastructure/k8s/storage/ -n ${NAMESPACE}

# Apply secrets
echo -e "${YELLOW}Creating secrets...${NC}"
kubectl apply -f infrastructure/k8s/secrets/ -n ${NAMESPACE}

# Apply ConfigMaps
echo -e "${YELLOW}Creating ConfigMaps...${NC}"
kubectl apply -f infrastructure/k8s/configmaps/ -n ${NAMESPACE}

# Apply services
echo -e "${YELLOW}Creating services...${NC}"
kubectl apply -f infrastructure/k8s/services/ -n ${NAMESPACE}

# Apply deployments
echo -e "${YELLOW}Creating deployments...${NC}"
kubectl apply -f infrastructure/k8s/deployments/ -n ${NAMESPACE}

# Wait for deployments to be ready
echo -e "${YELLOW}Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/scrummate-backend -n ${NAMESPACE}
kubectl wait --for=condition=available --timeout=300s deployment/scrummate-frontend -n ${NAMESPACE}
kubectl wait --for=condition=ready --timeout=300s statefulset/scrummate-db -n ${NAMESPACE}

# Show deployment status
echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${YELLOW}Checking status...${NC}"
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}

echo -e "${GREEN}ScrumMate deployed successfully to ${NAMESPACE}!${NC}"
