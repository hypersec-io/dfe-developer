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
#   --check              Run in check mode (dry-run, no changes)
#   --tags TAGS          Include specific tags (alias for --tags-include)
#   --tags-include TAGS  Include specific tags to run (comma-separated)
#   --tags-exclude TAGS  Exclude specific tags from running (comma-separated)
#   --core               Install core developer tools (JFrog, Azure, Node.js, etc.)
#   --all                Install everything (base + core + VM + RDP + winlike)
#   --help               Show this help message
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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output functions
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_info() { echo -e "[INFO] $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

show_help() {
    cat << 'EOF'
Usage: ./install.sh [OPTIONS]

OPTIONS:
  --check              Run in check mode (dry-run, no changes)
  --tags TAGS          Include specific tags (alias for --tags-include)
  --tags-include TAGS  Include specific tags to run (comma-separated)
  --tags-exclude TAGS  Exclude specific tags from running (comma-separated)
  --branch BRANCH      Git branch to use (default: main)
  --core               Shortcut for: --tags developer,base,core,advanced
  --all                Shortcut for: --tags developer,base,core,advanced,vm,optimizer,rdp,winlike
  --force-gnome        Force GNOME configuration even if no GNOME session is running
                       (for headless/template builds where GNOME is installed but inactive)
  --help               Show this help message

AVAILABLE TAGS:

  Base Tags (included by default):
    developer       Base DFE developer role
    base            Base tools (Docker, Git, K8s, Python, VS Code, Chrome)

  Feature Tags (opt-in, require explicit --tags or --all):
    winlike         Windows-style GNOME taskbar (Dash to Panel, bottom panel)
    maclike         macOS-style GNOME dock (Dash to Dock, Logo Menu, Magic Lamp)
    core            Core developer tools (JFrog, Azure CLI, Node.js, Linear CLI)
    advanced        Advanced tools (included with --core)
    vm              VM guest optimizations (QEMU guest agent, SPICE agent)
    optimizer       VM optimizer role (included with --vm)
    rdp             GNOME Remote Desktop configuration (RDP server on port 3389)

  Optional Tags (included by default, can be excluded):
    ghostty         Ghostty terminal emulator (included by default)
    fastestmirror   DNF/APT performance optimizations (included by default)
    wallpaper       Custom DFE wallpaper (included by default)

EXAMPLES:

  Default installation (base tools only):
    ./install.sh

  Include Windows-style GNOME desktop:
    ./install.sh --tags developer,base,winlike

  Include macOS-style GNOME desktop:
    ./install.sh --tags developer,base,maclike

  Install core tools + winlike desktop:
    ./install.sh --tags developer,base,core,advanced,winlike

  Exclude Ghostty terminal (use system terminal):
    ./install.sh --tags-exclude ghostty

  Exclude fastestmirror (use default OS mirrors):
    ./install.sh --tags-exclude fastestmirror

  Install everything except wallpaper:
    ./install.sh --all --tags-exclude wallpaper

  Install everything with macOS-style (maclike overrides winlike):
    ./install.sh --all --tags maclike

  Install RDP support for remote desktop access:
    ./install.sh --tags developer,base,rdp

  Dry-run to see what would change:
    ./install.sh --check

NOTES:
  - If both winlike and maclike are included, maclike takes precedence
  - RDP configures GNOME Remote Desktop with default credentials (dfe/dfe)
  - ghostty, fastestmirror, and wallpaper are included by default
  - Use --tags-exclude to disable default features without specifying all tags
EOF
    exit 0
}

# Parse arguments
ANSIBLE_CHECK=""
ANSIBLE_TAGS=""
ANSIBLE_SKIP_TAGS=""
ANSIBLE_EXTRA_VARS=""
GIT_BRANCH="main"

while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            ANSIBLE_CHECK="--check"
            shift
            ;;
        --tags|--tags-include)
            if [[ -n "$ANSIBLE_TAGS" ]]; then
                # Append to existing tags
                CURRENT_TAGS="${ANSIBLE_TAGS#--tags }"
                ANSIBLE_TAGS="--tags ${CURRENT_TAGS},$2"
            else
                ANSIBLE_TAGS="--tags $2"
            fi
            shift 2
            ;;
        --tags-exclude)
            if [[ -n "$ANSIBLE_SKIP_TAGS" ]]; then
                ANSIBLE_SKIP_TAGS="$ANSIBLE_SKIP_TAGS,$2"
            else
                ANSIBLE_SKIP_TAGS="$2"
            fi
            shift 2
            ;;
        --branch)
            GIT_BRANCH="$2"
            shift 2
            ;;
        --core)
            ANSIBLE_TAGS="--tags developer,base,core,advanced"
            shift
            ;;
        --all)
            ANSIBLE_TAGS="--tags developer,base,core,advanced,vm,optimizer,rdp,winlike"
            shift
            ;;
        --force-gnome)
            # Force GNOME configuration even if gnome-shell isn't running
            # Useful for headless/template builds where GNOME is installed but not active
            ANSIBLE_EXTRA_VARS="-e dfe_force_gnome=true"
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Handle maclike/winlike priority: maclike overrides winlike
# If both are specified, remove winlike from tags
if [[ "$ANSIBLE_TAGS" == *"maclike"* ]] && [[ "$ANSIBLE_TAGS" == *"winlike"* ]]; then
    print_info "Both maclike and winlike specified - using maclike (maclike takes precedence)"
    ANSIBLE_TAGS="${ANSIBLE_TAGS//,winlike/}"
    ANSIBLE_TAGS="${ANSIBLE_TAGS//winlike,/}"
    ANSIBLE_TAGS="${ANSIBLE_TAGS//winlike/}"
fi

# Detect operating system
print_info "Detecting operating system..."

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
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
        *)
            print_error "Unsupported Linux distribution: $ID"
            print_info "Supported: Ubuntu 24.04+, Fedora 42+, macOS"
            exit 1
            ;;
    esac
elif [[ "$(uname)" == "Darwin" ]]; then
    OS_FAMILY="macos"
    print_info "Detected: macOS $(sw_vers -productVersion)"
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

    # Ensure Python 3 and curl are installed (prerequisites)
    case "$OS_FAMILY" in
        fedora)
            if ! command -v python3 &>/dev/null || ! command -v curl &>/dev/null; then
                sudo dnf install -y python3 python3-pip curl || {
                    print_error "Failed to install Python 3 or curl"
                    exit 1
                }
            fi
            ;;
        ubuntu)
            if ! command -v python3 &>/dev/null || ! command -v curl &>/dev/null; then
                sudo apt-get update -qq
                sudo apt-get install -y python3 python3-pip python3-venv curl || {
                    print_error "Failed to install Python 3 or curl"
                    exit 1
                }
            elif ! python3 -m venv --help &>/dev/null; then
                # Python exists but venv module missing
                sudo apt-get update -qq
                sudo apt-get install -y python3-venv || {
                    print_error "Failed to install python3-venv"
                    exit 1
                }
            fi
            ;;
        macos)
            if ! command -v python3 &>/dev/null; then
                print_error "Python 3 not found. Install from https://www.python.org or use: brew install python3"
                exit 1
            fi
            # curl pre-installed on macOS
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

# Check if ansible directory exists, clone if not
if [[ ! -d "ansible" ]]; then
    print_warning "ansible/ directory not found"
    print_info "Cloning ansible directory from repository (branch: $GIT_BRANCH)..."

    # Download GitHub tarball (no git required)
    TARBALL_URL="https://github.com/hypersec-io/dfe-developer/archive/refs/heads/${GIT_BRANCH}.tar.gz"

    print_info "Downloading from $TARBALL_URL..."
    curl -fsSL "$TARBALL_URL" -o /tmp/dfe-developer.tar.gz || {
        print_error "Failed to download repository tarball from branch: $GIT_BRANCH"
        exit 1
    }

    # Extract only the ansible directory
    # Note: Branch name slashes become hyphens in tarball archive directory
    ARCHIVE_DIR="dfe-developer-${GIT_BRANCH//\//-}"
    print_info "Extracting ansible directory from ${ARCHIVE_DIR}..."
    tar -xzf /tmp/dfe-developer.tar.gz --strip-components=1 "${ARCHIVE_DIR}/ansible" || {
        print_error "Failed to extract ansible directory from ${ARCHIVE_DIR}"
        rm -f /tmp/dfe-developer.tar.gz
        exit 1
    }

    # Cleanup
    rm -f /tmp/dfe-developer.tar.gz

    print_success "Ansible directory downloaded successfully"
fi

# Build skip-tags argument if any
ANSIBLE_SKIP_TAGS_ARG=""
if [[ -n "$ANSIBLE_SKIP_TAGS" ]]; then
    ANSIBLE_SKIP_TAGS_ARG="--skip-tags $ANSIBLE_SKIP_TAGS"
fi

# Run Ansible playbook using temp venv Ansible
print_info "Running Ansible playbook (using isolated venv Ansible)..."
print_info "Command: $ANSIBLE_BIN playbooks/main.yml -i inventories/localhost/inventory.yml $ANSIBLE_CHECK $ANSIBLE_TAGS $ANSIBLE_SKIP_TAGS_ARG $ANSIBLE_EXTRA_VARS"

cd ansible || exit 1

# shellcheck disable=SC2086
"$ANSIBLE_BIN" \
    playbooks/main.yml \
    -i inventories/localhost/inventory.yml \
    $ANSIBLE_CHECK \
    $ANSIBLE_TAGS \
    $ANSIBLE_SKIP_TAGS_ARG \
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
