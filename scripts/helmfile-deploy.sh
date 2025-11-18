#!/bin/bash
# Helmfile deployment script for ScrumMate

set -e

# Configuration
ENVIRONMENT=${1:-dev}
ACTION=${2:-sync}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying ScrumMate with Helmfile...${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Action: ${ACTION}${NC}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Environment must be dev, staging, or prod${NC}"
    exit 1
fi

# Check if Helmfile is installed
if ! command -v helmfile &> /dev/null; then
    echo -e "${RED}Error: Helmfile is not installed${NC}"
    echo -e "${YELLOW}Install with: curl -L https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64.tar.gz | tar xz && sudo mv helmfile /usr/local/bin/${NC}"
    exit 1
fi

# Validate configuration
echo -e "${YELLOW}Validating Helmfile configuration...${NC}"
helmfile -e ${ENVIRONMENT} lint

# Show diff if not applying
if [ "$ACTION" = "diff" ]; then
    echo -e "${YELLOW}Showing deployment diff...${NC}"
    helmfile -e ${ENVIRONMENT} diff
    exit 0
fi

# Plan deployment
if [ "$ACTION" = "plan" ]; then
    echo -e "${YELLOW}Planning deployment...${NC}"
    helmfile -e ${ENVIRONMENT} template
    exit 0
fi

# Sync deployment
if [ "$ACTION" = "sync" ]; then
    echo -e "${YELLOW}Syncing deployment...${NC}"
    helmfile -e ${ENVIRONMENT} sync
elif [ "$ACTION" = "apply" ]; then
    echo -e "${YELLOW}Applying deployment...${NC}"
    helmfile -e ${ENVIRONMENT} apply
elif [ "$ACTION" = "destroy" ]; then
    echo -e "${RED}Destroying deployment...${NC}"
    read -p "Are you sure you want to destroy the ${ENVIRONMENT} environment? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        helmfile -e ${ENVIRONMENT} destroy
    else
        echo "Deployment destruction cancelled"
        exit 0
    fi
else
    echo -e "${RED}Error: Unknown action ${ACTION}${NC}"
    echo -e "${YELLOW}Available actions: sync, apply, diff, plan, destroy${NC}"
    exit 1
fi

# Show status
echo -e "${YELLOW}Deployment status:${NC}"
helmfile -e ${ENVIRONMENT} status

echo -e "${GREEN}Helmfile deployment completed!${NC}"
