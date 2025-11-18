#!/bin/bash
# Docker build and push script for ScrumMate

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

echo -e "${GREEN}Building ScrumMate Docker images...${NC}"

# Build backend image
echo -e "${YELLOW}Building backend image...${NC}"
docker build -t ${REGISTRY}/${NAMESPACE}/scrummate-backend:${VERSION} ./backend
docker build -t ${REGISTRY}/${NAMESPACE}/scrummate-backend:latest ./backend

# Build frontend image
echo -e "${YELLOW}Building frontend image...${NC}"
docker build -t ${REGISTRY}/${NAMESPACE}/scrummate-frontend:${VERSION} ./frontend
docker build -t ${REGISTRY}/${NAMESPACE}/scrummate-frontend:latest ./frontend

echo -e "${GREEN}Build completed successfully!${NC}"

# Push images if requested
if [ "$2" = "push" ]; then
    echo -e "${YELLOW}Pushing images to registry...${NC}"
    
    docker push ${REGISTRY}/${NAMESPACE}/scrummate-backend:${VERSION}
    docker push ${REGISTRY}/${NAMESPACE}/scrummate-backend:latest
    
    docker push ${REGISTRY}/${NAMESPACE}/scrummate-frontend:${VERSION}
    docker push ${REGISTRY}/${NAMESPACE}/scrummate-frontend:latest
    
    echo -e "${GREEN}Images pushed successfully!${NC}"
fi

# Security scan if trivy is available
if command -v trivy &> /dev/null; then
    echo -e "${YELLOW}Running security scans...${NC}"
    trivy image ${REGISTRY}/${NAMESPACE}/scrummate-backend:${VERSION}
    trivy image ${REGISTRY}/${NAMESPACE}/scrummate-frontend:${VERSION}
fi

echo -e "${GREEN}Docker build process completed!${NC}"
