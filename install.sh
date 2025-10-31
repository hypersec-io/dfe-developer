#!/bin/bash
# ============================================================================
# install.sh - DFE Developer Environment Bootstrap Script
# ============================================================================
# This script bootstraps the DFE developer environment by:
# 1. Detecting the operating system
# 2. Installing Ansible using the native package manager
# 3. Running the Ansible playbook to configure the system
#
# USAGE:
#   ./install.sh [--check] [--tags TAGS]
#
# OPTIONS:
#   --check    Run in check mode (dry-run, no changes)
#   --tags     Run specific Ansible tags (e.g., docker,python)
#
# SUPPORTED PLATFORMS:
#   - Ubuntu 24.04 LTS and later
#   - Fedora 42 and later
#   - macOS (Homebrew)
#
# LICENSE:
#   Licensed under the Apache License, Version 2.0
#   See LICENSE file for full license text
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Output functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_info() { echo -e "[INFO] $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Parse arguments
ANSIBLE_CHECK=""
ANSIBLE_TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            ANSIBLE_CHECK="--check"
            shift
            ;;
        --tags)
            ANSIBLE_TAGS="--tags $2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--check] [--tags TAGS]"
            echo ""
            echo "Options:"
            echo "  --check         Run in check mode (dry-run, no changes)"
            echo "  --tags TAGS     Run specific Ansible tags (comma-separated)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Detect operating system
print_info "Detecting operating system..."

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME="$ID"
    OS_VERSION="$VERSION_ID"
    OS_FAMILY=""

    case "$ID" in
        fedora)
            OS_FAMILY="fedora"
            print_info "Detected: Fedora $VERSION_ID"
            ;;
        ubuntu)
            OS_FAMILY="ubuntu"
            print_info "Detected: Ubuntu $VERSION_ID"
            ;;
        debian)
            OS_FAMILY="debian"
            print_info "Detected: Debian $VERSION_ID"
            ;;
        *)
            print_error "Unsupported Linux distribution: $ID"
            print_info "Supported: Ubuntu 24.04+, Fedora 42+, Debian"
            exit 1
            ;;
    esac
elif [[ "$(uname)" == "Darwin" ]]; then
    OS_NAME="macos"
    OS_VERSION=$(sw_vers -productVersion)
    OS_FAMILY="macos"
    print_info "Detected: macOS $OS_VERSION"
else
    print_error "Unable to detect operating system"
    exit 1
fi

# Check for sudo access
print_info "Verifying sudo access..."
if ! sudo -n true 2>/dev/null; then
    print_warning "Passwordless sudo not configured"
    print_info "You will be prompted for your password when needed"
    sudo -v || {
        print_error "Sudo access required"
        exit 1
    }
fi
print_success "Sudo access verified"

# Check if Ansible is installed
if command -v ansible-playbook &>/dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -1 | awk '{print $2}')
    print_success "Ansible already installed (version $ANSIBLE_VERSION)"
else
    print_info "Installing Ansible..."

    case "$OS_FAMILY" in
        fedora)
            sudo dnf install -y ansible || {
                print_error "Failed to install Ansible via dnf"
                exit 1
            }
            ;;
        ubuntu|debian)
            sudo apt update
            sudo apt install -y ansible || {
                print_error "Failed to install Ansible via apt"
                exit 1
            }
            ;;
        macos)
            if ! command -v brew &>/dev/null; then
                print_error "Homebrew not installed. Install from https://brew.sh"
                exit 1
            fi
            brew install ansible || {
                print_error "Failed to install Ansible via Homebrew"
                exit 1
            }
            ;;
    esac

    print_success "Ansible installed successfully"
fi

# Verify we're in the repo directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Check if ansible directory exists
if [[ ! -d "ansible" ]]; then
    print_error "ansible/ directory not found in repository"
    print_info "Expected location: $SCRIPT_DIR/ansible"
    exit 1
fi

# Run Ansible playbook
print_info "Running Ansible playbook..."
print_info "Command: ansible-playbook ansible/playbooks/main.yml -i ansible/inventories/localhost/inventory.yml $ANSIBLE_CHECK $ANSIBLE_TAGS"

cd ansible || exit 1

ansible-playbook \
    playbooks/main.yml \
    -i inventories/localhost/inventory.yml \
    $ANSIBLE_CHECK \
    $ANSIBLE_TAGS || {
    print_error "Ansible playbook failed"
    exit 1
}

print_success "DFE Developer Environment installation complete!"
print_info ""
print_info "Next steps:"
print_info "1. Log out and back in for group memberships to take effect (Docker)"
print_info "2. Verify installation: docker --version, kubectl version, python3 --version"
print_info "3. Configure your tools (Git, AWS CLI, Azure CLI)"
