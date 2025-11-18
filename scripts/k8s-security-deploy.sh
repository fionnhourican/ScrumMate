#!/bin/bash
# Kubernetes security deployment script for ScrumMate

set -e

# Configuration
NAMESPACE=${1:-scrummate-dev}
ENVIRONMENT=${2:-dev}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying ScrumMate security configurations...${NC}"
echo -e "${YELLOW}Namespace: ${NAMESPACE}${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"

# Apply RBAC configurations
echo -e "${YELLOW}Creating RBAC configurations...${NC}"
kubectl apply -f infrastructure/k8s/rbac/ -n ${NAMESPACE}

# Apply Network Policies
echo -e "${YELLOW}Creating Network Policies...${NC}"
kubectl apply -f infrastructure/k8s/network-policies/ -n ${NAMESPACE}

# Apply Security Policies
echo -e "${YELLOW}Creating Security Policies...${NC}"
kubectl apply -f infrastructure/k8s/security-policies/

# Apply Ingress configuration
echo -e "${YELLOW}Creating Ingress configuration...${NC}"
kubectl apply -f infrastructure/k8s/ingress/ -n ${NAMESPACE}

# Apply Autoscaling configuration
echo -e "${YELLOW}Creating Autoscaling configuration...${NC}"
kubectl apply -f infrastructure/k8s/autoscaling/ -n ${NAMESPACE}

# Verify security configurations
echo -e "${YELLOW}Verifying security configurations...${NC}"
kubectl get networkpolicies -n ${NAMESPACE}
kubectl get serviceaccounts -n ${NAMESPACE}
kubectl get roles -n ${NAMESPACE}
kubectl get rolebindings -n ${NAMESPACE}
kubectl get hpa -n ${NAMESPACE}

echo -e "${GREEN}Security configurations deployed successfully!${NC}"
