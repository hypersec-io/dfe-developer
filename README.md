# DFE Developer Environment

Standardised complete developer environment setup for HyperSec DFE developers on Fedora Linux and Windows 11.

## Platform Support

- **[Fedora Linux](#fedora-linux-quick-start)** - Complete development environment for Fedora 42+
- **[Windows 11](#windows-11-soe)** - Productivity and VM host setup with Hyper-V

## Fedora Linux Quick Start

To be installed onto Fedora Linux 42+

```bash
# Clone the repository
git clone https://github.com/hypersec-io/dfe-developer
cd dfe-developer/fedora

# Complete installation (recommended)
./install-all.sh 2>&1 | tee install.log

# OR install components individually:
./install-dfe-developer.sh      # Base developer tools (includes Ghostty terminal)
./install-dfe-developer-core.sh # Core DFE tools
./install-vm-optimizer.sh       # VM optimizations
./install-rdp-optimizer.sh      # RDP optimizations

# Optional: Enable passwordless sudo (development machines only)
./install-dfe-developer.sh --sudoers
```

**Note:** Passwordless sudo is NOT configured by default for security. The scripts will prompt for your password when needed. Use `--sudoers` flag only on development machines (NOT on admin, bastion, or production systems).

## What Gets Installed

### Standard Developer Tools
- Docker CE and Docker Compose
- Python development (UV, pyenv)
- Cloud tools (AWS CLI, kubectl, Helm + Dashboard, Terraform)
- Kubernetes tools (K9s, Freelens, Minikube, ArgoCD)
- Git extensions and GitHub CLI
- Development utilities (jq, yq, bat, fzf, ripgrep)
- VS Code configuration

### DFE Core Developer Tools
- JFrog CLI
- Azure CLI
- Node.js and semantic-release
- AI coding assistants (Claude Code CLI)
- Advanced Python tools (Nox, UV)
- Slack (Flatpak)

## System Requirements

- Fedora 42 or later
- 4GB RAM minimum (8GB recommended)
- 20GB available disk space
- Internet connection

## Testing

The project includes comprehensive testing:

```bash
cd fedora/tests

# Run all tests
bash 01-shellcheck.sh      # Static analysis
bats *.bats                # Unit and integration tests
```

## Project Structure

- `fedora/` - Fedora Linux installation scripts and tests
- `windows/` - Windows 11 SOE setup scripts and documentation
- `claude/` - Claude Code utilities
- `VERSION` - Version tracking
- `CHANGELOG.md` - Release history
- `TODO.md` - Task tracking

## Claude Contributor Fix Script

The `claude/claude-contrib-fix.sh` script removes Claude Code from GitHub contributors when it autonomously adds itself without permission.

### Problem

Claude Code sometimes adds "Co-Authored-By: Claude" attribution to commits without explicit user consent, causing Claude to appear as a repository contributor on GitHub.

### Solution

This script removes Claude attribution from commits and forces GitHub to reindex contributors.

### Usage

```bash
# Use current repository with default branch
cd dfe-developer
./claude/claude-contrib-fix.sh

# Specify repository URL
./claude/claude-contrib-fix.sh https://github.com/owner/repo.git

# Specify repository and branch
./claude/claude-contrib-fix.sh https://github.com/owner/repo.git develop

# Clean a non-default branch (no GitHub reindex)
./claude/claude-contrib-fix.sh https://github.com/owner/repo.git feature-branch
```

### Features

- Removes "Co-Authored-By: Claude" and "Generated with Claude Code" from commit messages
- Auto-detects repository default branch (main, master, etc.)
- Optional branch parameter to clean specific branches
- For default branch: forces GitHub contributor reindex
- For non-default branches: only cleans commits (no gh CLI required)
- Comprehensive error handling and automatic cleanup

### Requirements

- git (required)
- gh (GitHub CLI) - only required when working on default branch
- Push access to the repository

### Help

```bash
./claude/claude-contrib-fix.sh --help
```

## Windows 11 SOE

Automated Windows 11 Standard Operating Environment setup for HyperSec DFE developers.

### Overview

Automated Windows 11 configuration for development teams. Installs essential software, enables Hyper-V with full security stack (VBS, Credential Guard, HVCI), removes bloatware, disables telemetry, and configures Australian English locale. Security-first approach using Windows 11's native hypervisor - actual development work happens in Linux VMs while Windows serves as the productivity and VM host platform.

### Quick Start

```powershell
# Run as Administrator in PowerShell
cd windows
.\hypersec-windows.ps1                    # Complete SOE with Hyper-V
.\hypersec-windows.ps1 -SkipVSCode       # Skip VSCode (if running from VSCode)
.\hypersec-windows.ps1 -IncludeM365      # Include Microsoft 365 installation
.\hypersec-windows.ps1 -ShowHelp         # Display detailed help
```

### Software Installation

- **Development Tools** - Git, PowerShell 7, Visual Studio Code, GitHub Desktop, WinMerge
- **Browsers** - Firefox, Chrome (manual default setting required)
- **Office Suite** - Microsoft 365 Business (optional with -IncludeM365)
- **Network Tools** - PuTTY, WinSCP, OpenVPN GUI, Royal TS, TigerVNC
- **Media & Utilities** - VLC, 7-Zip, OBS Studio, Paint.NET, PDFGear
- **Communication** - Slack, Microsoft Teams (with M365)

### System Configuration

- **Privacy** - Telemetry disabled, bloatware removed
- **Regional Settings** - Australian English locale, timezone, date/currency formats
- **Power Management** - Laptop/desktop detection with appropriate settings
- **Desktop** - Clean appearance, no unnecessary shortcuts
- **Custom Wallpaper** - Optional SVG wallpaper support

### Hyper-V Virtualization

- **Native hypervisor** - Uses Windows 11's built-in Hyper-V
- **C:\VM structure** - Automatic directory creation and configuration
- **Default Switch** - Automatic network switch assignment for new VMs
- **Security intact** - All Windows security features remain enabled
- **Linux VM Setup** - See `windows/HYPERV-LINUX.md` for detailed guide

### Security Configuration

- **Virtualization-Based Security (VBS)** - Hardware-backed protection enabled
- **Credential Guard** - Credential isolation via hypervisor
- **HVCI** - Hypervisor-enforced kernel code integrity
- **Core Isolation** - Memory integrity protection
- **Defender ATP** - Optional automated onboarding (drop package in directory)

### Requirements

- **Windows 11 Pro** (24H2 or later recommended, Build 26100+)
- **Administrator privileges**
- **Internet connection**
- **TPM 2.0** (for VBS/Credential Guard)
- **UEFI firmware** (for modern security features)

### Additional Documentation

- **windows/QUICKSTART.md** - Fast setup guide with Hyper-V configuration
- **windows/HYPERV-LINUX.md** - Step-by-step guide for creating Linux VMs in Hyper-V
- **windows/CHANGELOG.md** - Windows SOE version history and release notes

### Why Hyper-V Instead of VMware?

VMware Workstation delivers better Linux VM performance, but requires disabling Windows security features (VBS, Credential Guard, HVCI, Core Isolation). We prioritize security over marginal performance gains. For legacy VMware users, `hypersec-windows-vmware.ps1` exists but is deprecated and unmaintained.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to submit pull requests
- Code standards and style guidelines
- Testing requirements
- Development workflow

## License

Apache License 2.0 - See [LICENSE](LICENSE) file for details.
