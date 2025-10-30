#!/bin/bash
# ============================================================================
# install-ghostty - Ghostty Terminal Installer for Fedora
# ============================================================================
# Simple installer for Ghostty terminal emulator on Fedora
# Assumes a clean Fedora desktop installation
#
# USAGE:
#   ./install-ghostty.sh
#
# LICENSE:
#   Licensed under the Apache License, Version 2.0
#   See ../LICENSE file for full license text
# ============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions library
if [[ -f "$SCRIPT_DIR/lib.sh" ]]; then
    source "$SCRIPT_DIR/lib.sh"
else
    echo "[ERROR] Cannot find lib.sh library" >&2
    exit 1
fi

# Initialize script with common setup
init_script "Ghostty Terminal Installation"

# Install JetBrains Mono font
print_status "Installing JetBrains Mono font..."
sudo dnf install -y jetbrains-mono-fonts || true

# Check if Flatpak is available and try to install via Flatpak first
if command -v flatpak &>/dev/null; then
    print_status "Attempting to install Ghostty via Flatpak..."

    # Add Flathub if not present
    if ! flatpak remote-list | grep -q flathub; then
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    # Try to install Ghostty from Flathub
    if FLATPAK_TTY_PROGRESS=0 flatpak install -y flathub com.mitchellh.ghostty 2>&1 | grep -v "%" || \
       FLATPAK_TTY_PROGRESS=0 flatpak install -y com.mitchellh.ghostty 2>&1 | grep -v "%"; then
        print_success "Ghostty installed via Flatpak"
        INSTALL_METHOD="flatpak"
    else
        print_info "Ghostty not available via Flatpak, will build from source"
        INSTALL_METHOD="source"
    fi
else
    INSTALL_METHOD="source"
fi

# Build from source if Flatpak installation failed or not available
if [ "$INSTALL_METHOD" = "source" ]; then
    print_status "Building Ghostty from source..."

    # Install build dependencies
    print_status "Installing build dependencies..."
    sudo dnf install -y \
        gcc \
        gcc-c++ \
        git \
        zig \
        pkg-config \
        gtk4-devel \
        libadwaita-devel \
        fontconfig-devel \
        freetype-devel \
        harfbuzz-devel \
        libpng-devel \
        zlib-devel \
        libxkbcommon-devel \
        wayland-devel \
        libX11-devel \
        libXcursor-devel \
        libXrandr-devel \
        libXinerama-devel \
        libXi-devel \
        mesa-libGL-devel \
        mesa-libEGL-devel

    # Clone and build Ghostty
    print_status "Cloning Ghostty repository..."
    cd /tmp
    rm -rf ghostty
    git clone https://github.com/ghostty-org/ghostty.git
    cd ghostty

    print_status "Building Ghostty (this may take a few minutes)..."
    zig build -Doptimize=ReleaseFast

    print_status "Installing Ghostty..."
    sudo zig build install --prefix /usr/local -Doptimize=ReleaseFast

    # Install desktop file
    if [ -f "ghostty.desktop" ]; then
        sudo cp ghostty.desktop /usr/share/applications/
    fi

    # Clean up
    cd /tmp
    rm -rf ghostty

    print_success "Ghostty built and installed from source"
fi

# Create Ghostty configuration directory
CONFIG_DIR="$HOME/.config/ghostty"
mkdir -p "$CONFIG_DIR"

# Create optimized configuration
print_status "Creating Ghostty configuration..."
cat > "$CONFIG_DIR/config" << 'EOF'
# Ghostty Configuration
# Font configuration
font-family = JetBrains Mono
font-size = 12
font-feature = -liga
font-feature = -calt

# Performance settings
gtk-single-instance = true
macos-titlebar-style = tabs

# Window settings
window-padding-x = 8
window-padding-y = 8
window-save-state = always

# Theme
theme = dark

# Scrollback
scrollback-limit = 10000

# Cursor
cursor-style = block
cursor-style-blink = true

# Shell integration
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Copy on select
copy-on-select = true

# GPU acceleration (auto-detect)
renderer = auto

# Transparency (disabled for better performance)
background-opacity = 1.0
EOF

# Detect if we're in RDP session and adjust config
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${RDP_SESSION:-}" ] || [ -n "${REMOTE_DESKTOP_SESSION:-}" ]; then
    print_info "RDP/Remote session detected - adjusting configuration..."
    sed -i 's/renderer = auto/renderer = software/' "$CONFIG_DIR/config"
    sed -i 's/gtk-single-instance = true/gtk-single-instance = false/' "$CONFIG_DIR/config"
fi

print_header "Installation Complete"

# Simple verification - check if Ghostty actually works
print_status "Verifying installation..."
echo ""
if [ "$INSTALL_METHOD" = "flatpak" ]; then
    flatpak run com.mitchellh.ghostty --version &>/dev/null && echo "  [OK] Ghostty (Flatpak)" || echo "  [FAIL] Ghostty"
else
    ghostty --version &>/dev/null && echo "  [OK] Ghostty (from source)" || echo "  [FAIL] Ghostty"
fi

# Check font installation
fc-list | grep -q "JetBrains Mono" && echo "  [OK] JetBrains Mono font" || echo "  [FAIL] JetBrains Mono font"

# Check configuration
[ -f "$CONFIG_DIR/config" ] && echo "  [OK] Configuration file created" || echo "  [FAIL] Configuration file missing"

echo ""
print_success "Ghostty terminal installed"

if [ "$INSTALL_METHOD" = "flatpak" ]; then
    print_info "Run with: flatpak run com.mitchellh.ghostty"
else
    print_info "Run with: ghostty"
fi

print_info "Configuration file: $CONFIG_DIR/config"