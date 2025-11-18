#!/bin/bash
# Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
# ScrumMate Flux CLI Installation Script

set -euo pipefail

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

# Detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $arch in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $arch"; exit 1 ;;
    esac
    
    echo "${os}-${arch}"
}

# Install Flux CLI
install_flux_cli() {
    local platform=$(detect_platform)
    local flux_version="v2.2.2"
    local install_dir="/usr/local/bin"
    
    log_info "Installing Flux CLI version $flux_version for $platform"
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        log_warn "This script requires sudo privileges to install to $install_dir"
        read -p "Continue with sudo? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Download and install Flux CLI
    local temp_dir=$(mktemp -d)
    local download_url="https://github.com/fluxcd/flux2/releases/download/${flux_version}/flux_${flux_version#v}_${platform}.tar.gz"
    
    log_info "Downloading Flux CLI from $download_url"
    curl -sL "$download_url" | tar xz -C "$temp_dir"
    
    # Install binary
    if [[ $EUID -eq 0 ]]; then
        mv "$temp_dir/flux" "$install_dir/flux"
        chmod +x "$install_dir/flux"
    else
        sudo mv "$temp_dir/flux" "$install_dir/flux"
        sudo chmod +x "$install_dir/flux"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_info "Flux CLI installed successfully"
}

# Verify installation
verify_installation() {
    log_info "Verifying Flux CLI installation..."
    
    if command -v flux &> /dev/null; then
        local version=$(flux version --client)
        log_info "Flux CLI installed: $version"
        
        # Check prerequisites
        log_info "Checking prerequisites..."
        flux check --pre
        
        return 0
    else
        log_error "Flux CLI installation failed"
        return 1
    fi
}

# Main function
main() {
    log_info "ScrumMate Flux CLI Installation"
    log_info "==============================="
    
    # Check if already installed
    if command -v flux &> /dev/null; then
        local current_version=$(flux version --client | grep "flux version" | awk '{print $3}')
        log_warn "Flux CLI is already installed: $current_version"
        read -p "Reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation skipped"
            exit 0
        fi
    fi
    
    install_flux_cli
    verify_installation
    
    log_info "Flux CLI installation completed"
    log_info "Next step: Run ./scripts/bootstrap-flux.sh to bootstrap Flux in your cluster"
}

main "$@"
