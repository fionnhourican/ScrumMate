#!/bin/bash
# Security scanning script for Docker images

set -e

# Configuration
REGISTRY="docker.io"
NAMESPACE="scrummate"
VERSION=${1:-latest}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running security scans for ScrumMate images...${NC}"

# Function to run security scan
run_scan() {
    local image=$1
    local service=$2
    
    echo -e "${YELLOW}Scanning ${service} image: ${image}${NC}"
    
    # Trivy scan
    if command -v trivy &> /dev/null; then
        echo "Running Trivy scan..."
        trivy image --severity HIGH,CRITICAL --exit-code 1 ${image}
    else
        echo "Trivy not found, skipping vulnerability scan"
    fi
    
    # Docker Scout scan (if available)
    if command -v docker &> /dev/null && docker scout version &> /dev/null; then
        echo "Running Docker Scout scan..."
        docker scout cves ${image}
    fi
    
    # Hadolint for Dockerfile linting
    if command -v hadolint &> /dev/null; then
        echo "Running Hadolint on Dockerfile..."
        if [ "$service" = "backend" ]; then
            hadolint backend/Dockerfile
        elif [ "$service" = "frontend" ]; then
            hadolint frontend/Dockerfile
        fi
    fi
}

# Scan backend image
if docker image inspect ${REGISTRY}/${NAMESPACE}/scrummate-backend:${VERSION} &> /dev/null; then
    run_scan "${REGISTRY}/${NAMESPACE}/scrummate-backend:${VERSION}" "backend"
else
    echo -e "${RED}Backend image not found. Build it first.${NC}"
fi

# Scan frontend image
if docker image inspect ${REGISTRY}/${NAMESPACE}/scrummate-frontend:${VERSION} &> /dev/null; then
    run_scan "${REGISTRY}/${NAMESPACE}/scrummate-frontend:${VERSION}" "frontend"
else
    echo -e "${RED}Frontend image not found. Build it first.${NC}"
fi

echo -e "${GREEN}Security scanning completed!${NC}"
