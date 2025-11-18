#!/bin/bash
# Helm chart testing and validation script

set -e

# Configuration
CHART_DIR="helm/scrummate"
ENVIRONMENT=${1:-dev}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running Helm chart tests and validation...${NC}"

# Lint the chart
echo -e "${YELLOW}Linting Helm chart...${NC}"
helm lint ${CHART_DIR}

# Validate chart with different values files
echo -e "${YELLOW}Validating chart templates...${NC}"
helm template test-release ${CHART_DIR} --debug --dry-run > /dev/null

if [ -f "${CHART_DIR}/values-${ENVIRONMENT}.yaml" ]; then
    echo -e "${YELLOW}Validating with ${ENVIRONMENT} values...${NC}"
    helm template test-release ${CHART_DIR} \
        --values ${CHART_DIR}/values.yaml \
        --values ${CHART_DIR}/values-${ENVIRONMENT}.yaml \
        --debug --dry-run > /dev/null
fi

# Validate JSON schema if available
if command -v ajv &> /dev/null && [ -f "${CHART_DIR}/values.schema.json" ]; then
    echo -e "${YELLOW}Validating values against JSON schema...${NC}"
    helm template test-release ${CHART_DIR} --show-only values > /tmp/values.yaml
    ajv validate -s ${CHART_DIR}/values.schema.json -d /tmp/values.yaml
    rm -f /tmp/values.yaml
fi

# Run unit tests if helm-unittest is available
if command -v helm &> /dev/null && helm plugin list | grep -q unittest; then
    echo -e "${YELLOW}Running unit tests...${NC}"
    helm unittest ${CHART_DIR}
else
    echo -e "${YELLOW}helm-unittest plugin not found, skipping unit tests${NC}"
    echo -e "${YELLOW}Install with: helm plugin install https://github.com/helm-unittest/helm-unittest${NC}"
fi

# Security scanning with checkov if available
if command -v checkov &> /dev/null; then
    echo -e "${YELLOW}Running security scan...${NC}"
    helm template test-release ${CHART_DIR} > /tmp/manifests.yaml
    checkov -f /tmp/manifests.yaml --framework kubernetes
    rm -f /tmp/manifests.yaml
fi

# Package the chart
echo -e "${YELLOW}Packaging chart...${NC}"
helm package ${CHART_DIR} --destination /tmp/

echo -e "${GREEN}All tests completed successfully!${NC}"
