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
#   ./install.sh [OPTIONS]
#
# OPTIONS:
#   --check         Run in check mode (dry-run, no changes)
#   --tags TAGS     Run specific Ansible tags (e.g., docker,python)
#   --no-ghostty    Skip Ghostty terminal installation
#   --core          Install core developer tools (JFrog, Azure, Node.js, etc.)
#   --vm            Install VM optimizer tools
#   --rdp           Install RDP optimizer (GNOME Remote Desktop auto-resize)
#   --all           Install everything (base + core + VM + RDP)
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
ANSIBLE_SKIP_TAGS=""
ANSIBLE_EXTRA_VARS=""
GIT_BRANCH="main"
REPO_URL="https://github.com/hypersec-io/dfe-developer.git"

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
        --branch)
            GIT_BRANCH="$2"
            shift 2
            ;;
        --no-wallpaper)
            ANSIBLE_SKIP_TAGS="--skip-tags wallpaper"
            shift
            ;;
        --no-ghostty)
            ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS -e dfe_install_ghostty=false"
            shift
            ;;
        --no-fastestmirror)
            ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS -e dfe_use_fastestmirror=false"
            shift
            ;;
        --core)
            ANSIBLE_TAGS="--tags developer,base,core,advanced"
            shift
            ;;
        --vm)
            ANSIBLE_TAGS="--tags developer,base,vm,optimizer"
            shift
            ;;
        --rdp)
            ANSIBLE_TAGS="--tags developer,base,rdp,optimizer"
            shift
            ;;
        --all)
            ANSIBLE_TAGS="--tags developer,base,core,advanced,vm,optimizer,rdp"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --check              Run in check mode (dry-run, no changes)"
            echo "  --tags TAGS          Run specific Ansible tags (comma-separated)"
            echo "  --branch BRANCH      Git branch to use (default: main)"
  --no-wallpaper       Skip custom wallpaper installation
            echo "  --no-ghostty         Skip Ghostty terminal installation"
            echo "  --no-fastestmirror   Disable automatic mirror selection (use OS defaults)"
            echo "  --core               Install core developer tools (JFrog, Azure, Node.js, etc.)"
            echo "  --vm                 Install VM optimizer tools"
            echo "  --rdp                Install RDP optimizer (GNOME Remote Desktop auto-resize)"
            echo "  --all                Install everything (base + core + VM + RDP)"
            echo "  --help               Show this help message"
            echo ""
            echo "Default: Base developer environment only (Docker, K8s, Python, Git, VS Code, Chrome, Ghostty)"
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

# Install latest Ansible in temporary Python venv (isolated from OS)
# This avoids circular dependency if playbook updates system Ansible
TEMP_ANSIBLE_DIR="$HOME/.dfe-ansible-temp"
ANSIBLE_BIN="$TEMP_ANSIBLE_DIR/bin/ansible-playbook"

if [[ -f "$ANSIBLE_BIN" ]]; then
    ANSIBLE_VERSION=$("$TEMP_ANSIBLE_DIR/bin/ansible" --version | head -1 | awk '{print $2}')
    print_info "Using temporary Ansible venv (version $ANSIBLE_VERSION)"
else
    print_info "Creating temporary Ansible environment (isolated from OS)..."

    # Ensure Python 3 is installed (only prerequisite - no git needed, we use tarball)
    case "$OS_FAMILY" in
        fedora)
            if ! command -v python3 &>/dev/null; then
                sudo dnf install -y python3 python3-pip || {
                    print_error "Failed to install Python 3"
                    exit 1
                }
            fi
            ;;
        ubuntu|debian)
            # Always install prerequisites on Ubuntu/Debian (ensures venv module present)
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv || {
                print_error "Failed to install Python 3 and venv"
                exit 1
            }
            ;;
        macos)
            if ! command -v python3 &>/dev/null; then
                print_error "Python 3 not found. Install from https://www.python.org or use: brew install python3"
                exit 1
            fi
            ;;
    esac

    # Create temporary Python venv
    python3 -m venv "$TEMP_ANSIBLE_DIR" || {
        print_error "Failed to create Python venv"
        exit 1
    }

    # Install latest Ansible via pip
    print_info "Installing latest Ansible via pip (isolated venv)..."
    "$TEMP_ANSIBLE_DIR/bin/pip" install --upgrade pip setuptools wheel >/dev/null 2>&1
    "$TEMP_ANSIBLE_DIR/bin/pip" install ansible >/dev/null 2>&1 || {
        print_error "Failed to install Ansible via pip"
        exit 1
    }

    ANSIBLE_VERSION=$("$TEMP_ANSIBLE_DIR/bin/ansible" --version | head -1 | awk '{print $2}')
    print_success "Ansible $ANSIBLE_VERSION installed to temporary venv"
    print_info "Location: $TEMP_ANSIBLE_DIR (will be reused on subsequent runs)"
fi

# Determine script directory and check for ansible directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Check if ansible directory exists, download if not
if [[ ! -d "ansible" ]]; then
    print_warning "ansible/ directory not found"
    print_info "Downloading ansible directory from repository (branch: $GIT_BRANCH)..."

    # Download GitHub tarball (no git required)
    TARBALL_URL="https://github.com/hypersec-io/dfe-developer/archive/refs/heads/${GIT_BRANCH}.tar.gz"

    print_info "Downloading from $TARBALL_URL..."
    curl -fsSL "$TARBALL_URL" -o /tmp/dfe-developer.tar.gz || {
        print_error "Failed to download repository tarball from branch: $GIT_BRANCH"
        exit 1
    }

    # Extract only the ansible directory
    print_info "Extracting ansible directory..."
    tar -xzf /tmp/dfe-developer.tar.gz --strip-components=1 "dfe-developer-${GIT_BRANCH}/ansible" || {
        print_error "Failed to extract ansible directory"
        rm -f /tmp/dfe-developer.tar.gz
        exit 1
    }

    # Cleanup
    rm -f /tmp/dfe-developer.tar.gz

    print_success "Ansible directory downloaded successfully"
fi

# Run Ansible playbook using temp venv Ansible
print_info "Running Ansible playbook (using isolated venv Ansible)..."
print_info "Command: $ANSIBLE_BIN ansible/playbooks/main.yml -i ansible/inventories/localhost/inventory.yml $ANSIBLE_CHECK $ANSIBLE_CHECK $ANSIBLE_TAGS $ANSIBLE_SKIP_TAGS $ANSIBLE_EXTRA_VARS"

cd ansible || exit 1

"$ANSIBLE_BIN" \
    playbooks/main.yml \
    -i inventories/localhost/inventory.yml \
    $ANSIBLE_CHECK \
    $ANSIBLE_TAGS \
    $ANSIBLE_EXTRA_VARS || {
    print_error "Ansible playbook failed"
    exit 1
}

print_success "DFE Developer Environment installation complete!"
print_info ""
print_info "Next steps:"
print_info "1. Log out and back in for group memberships to take effect (Docker)"
print_info "2. Verify installation: docker --version, kubectl version, python3 --version"
print_info "3. Configure your tools (Git, AWS CLI, Azure CLI)"
