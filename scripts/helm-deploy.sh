#!/bin/bash
# Helm deployment script for ScrumMate

set -e

# Configuration
NAMESPACE=${1:-scrummate-dev}
ENVIRONMENT=${2:-dev}
RELEASE_NAME=${3:-scrummate}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying ScrumMate with Helm...${NC}"
echo -e "${YELLOW}Namespace: ${NAMESPACE}${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Release: ${RELEASE_NAME}${NC}"

# Create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Add required Helm repositories
echo -e "${YELLOW}Adding Helm repositories...${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Update chart dependencies
echo -e "${YELLOW}Updating chart dependencies...${NC}"
cd helm/scrummate
helm dependency update
cd ../..

# Deploy with Helm
echo -e "${YELLOW}Deploying ScrumMate chart...${NC}"
if [ -f "helm/scrummate/values-${ENVIRONMENT}.yaml" ]; then
    helm upgrade --install ${RELEASE_NAME} helm/scrummate \
        --namespace ${NAMESPACE} \
        --values helm/scrummate/values.yaml \
        --values helm/scrummate/values-${ENVIRONMENT}.yaml \
        --wait --timeout=10m
else
    helm upgrade --install ${RELEASE_NAME} helm/scrummate \
        --namespace ${NAMESPACE} \
        --values helm/scrummate/values.yaml \
        --wait --timeout=10m
fi

# Check deployment status
echo -e "${YELLOW}Checking deployment status...${NC}"
helm status ${RELEASE_NAME} -n ${NAMESPACE}
kubectl get pods -n ${NAMESPACE}

echo -e "${GREEN}ScrumMate deployed successfully with Helm!${NC}"
