# DFE Developer Environment

[![Latest Release](https://img.shields.io/github/v/release/hypersec-io/dfe-developer)](https://github.com/hypersec-io/dfe-developer/releases/latest)
[![Release Date](https://img.shields.io/github/release-date/hypersec-io/dfe-developer)](https://github.com/hypersec-io/dfe-developer/releases/latest)
[![License](https://img.shields.io/github/license/hypersec-io/dfe-developer)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Fedora%20%7C%20macOS-blue)](#platform-support)
[![Last Commit](https://img.shields.io/github/last-commit/hypersec-io/dfe-developer)](https://github.com/hypersec-io/dfe-developer/commits/main)
[![Stars](https://img.shields.io/github/stars/hypersec-io/dfe-developer?style=social)](https://github.com/hypersec-io/dfe-developer/stargazers)

Standardised complete developer environment setup for HyperSec DFE developers across multiple platforms.

## Platform Support

- **[Multi-Platform (Recommended)](#multi-platform-quick-start)** - Ansible-based setup for Fedora, Ubuntu, and macOS
- **[Fedora Linux (Legacy)](#fedora-linux-legacy)** - Shell script-based setup (bug fixes only)
- **[Windows 11](#windows-11-soe)** - Productivity and VM host setup with Hyper-V

## Multi-Platform Quick Start

**Recommended for all new installations.** Supports Ubuntu 24.04+ (primary), Fedora 42+, and macOS.

**v2.4+**: Ubuntu is now the primary supported platform, with Fedora and macOS as secondary platforms.

```bash
# Clone the repository
git clone https://github.com/hypersec-io/dfe-developer
cd dfe-developer

# Install base developer environment (default)
./install.sh

# Install with core developer tools
./install.sh --core

# Install everything (base + core + VM + RDP optimizers)
./install.sh --all

# Other options:
./install.sh --no-ghostty      # Skip Ghostty terminal
./install.sh --vm              # Add VM optimizations (Linux only)
./install.sh --rdp             # Add RDP optimizations (Linux only)
./install.sh --check           # Dry-run (no changes)
```

The Ansible-based installer automatically detects your OS and installs the appropriate packages.

### Selective Installation (Advanced)

You can install specific components using Ansible tags. **Dependencies (init tasks) always run automatically.**

#### Using install.sh with tags:
```bash
# Install only Docker on macOS
./install.sh --tags docker

# Install only Git and GitHub CLI
./install.sh --tags git

# Install Kubernetes tools only
./install.sh --tags k8s

# Install multiple specific tools
./install.sh --tags "docker,git,k8s"
```

#### Using Ansible directly:
```bash
cd ansible

# Install only Docker (dependencies run automatically)
ansible-playbook -i inventories/localhost/inventory.yml playbooks/main.yml --tags docker

# Install Git + Cloud tools
ansible-playbook -i inventories/localhost/inventory.yml playbooks/main.yml --tags "git,cloud"

# Install everything EXCEPT Ghostty terminal
ansible-playbook -i inventories/localhost/inventory.yml playbooks/main.yml --skip-tags ghostty
```

#### Available Tags

**Base Developer Tools:**
- `docker` - Docker Desktop (macOS) or Docker CE (Linux)
- `git` - Latest Git + GitHub CLI + Git LFS
- `cloud` - AWS CLI, Helm, Terraform, Vault
- `k8s` - kubectl, k9s, kubectx, minikube, argocd, dive
- `python` - UV Python manager
- `utilities` - Development utilities (jq, bat, fzf, ripgrep, etc.)
- `vscode` - Visual Studio Code
- `chrome` - Google Chrome
- `ghostty` - Ghostty terminal emulator

**Core Developer Tools:**
- `jfrog` - JFrog CLI
- `azure` - Azure CLI
- `nodejs` - Node.js + semantic-release
- `linear` - Linear CLI
- `openvpn` - OpenVPN 3 client
- `claude` - Claude Code CLI
- `slack` - Slack (GUI)

**System:**
- `repository` - Configure package repositories (Linux only)
- `security` - Automatic security updates
- `wallpaper` - Custom wallpaper (if provided)
- `verify` - Verify all installations

#### How It Works

**Dependencies always run:**
- Init tasks (tagged `always`) run before any other tasks
- Variables, user detection, platform detection
- Ensures all prerequisites met

**Example: Install only Docker on macOS**
```bash
./install.sh --tags docker
```

This will:
1. ✅ Run init tasks (detect user, set variables)
2. ✅ Install Docker Desktop via Homebrew
3. ✅ Configure Docker
4. ⏭️  Skip all other tools (Git, K8s, etc.)

**Example: Install multiple specific tools**
```bash
./install.sh --tags "git,docker,vscode"
```

This installs only Git, Docker, and VS Code (plus their dependencies).


## Fedora Linux (Legacy)

**Fedora-only shell scripts - bug fixes only, no new features.**

```bash
# Clone the repository
git clone https://github.com/hypersec-io/dfe-developer
cd dfe-developer/fedora

# Complete installation
./install-all.sh 2>&1 | tee install.log

# OR install components individually:
./install-dfe-developer.sh      # Base developer tools
./install-dfe-developer-core.sh # Core DFE tools
./install-vm-optimizer.sh       # VM optimizations
./install-rdp-optimizer.sh      # RDP optimizations
```

**Note:** The `/fedora` scripts are maintained for bug fixes only. All new features and enhancements go into the Ansible playbooks. Use `./install.sh` (Ansible) for new installations.

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

### Multi-Platform (Ansible)
- **Ubuntu:** 24.04 LTS or later (primary)
- **Fedora:** 42 or later (secondary)
- **macOS:** Sequoia 15.3.1 or later (secondary)
- 4GB RAM minimum (8GB recommended)
- 20GB available disk space
- Internet connection

### Legacy Fedora (Shell Scripts)
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

- `ansible/` - Ansible-based multi-platform installer (Fedora, Ubuntu, macOS)
- `fedora/` - Legacy Fedora Linux installation scripts (bug fixes only)
- `windows/` - Windows 11 SOE setup scripts and documentation
- `tools/` - Developer utilities and helper scripts
  - `tools/git/` - Git-related utilities
- `docs/` - Documentation and guides
- `VERSION` - Version tracking
- `CHANGELOG.md` - Release history
- `TODO.md` - Task tracking

## Developer Utilities

### Git Data Spill Cleanup

The [git-spill-cleanup.sh](tools/git/git-spill-cleanup.sh) utility safely removes sensitive data accidentally committed to git history.

**Use cases:** Remove `.env` files, API keys, passwords, private keys, or any sensitive data from git history.

```bash
# List potentially sensitive files in history
./tools/git/git-spill-cleanup.sh --list

# Remove a specific file from all history
./tools/git/git-spill-cleanup.sh --file .env

# Remove entire directory and all contents
./tools/git/git-spill-cleanup.sh --directory .claude

# Remove all AI assistant artifacts
./tools/git/git-spill-cleanup.sh --ai

# Remove all files matching a pattern
./tools/git/git-spill-cleanup.sh --pattern "*.pem"

# Remove a specific string from all files
./tools/git/git-spill-cleanup.sh --string "sk-abc123secretkey"

# Dry run to preview changes
./tools/git/git-spill-cleanup.sh --file secrets.yml --dry-run
```

**Features:**
- Uses git-filter-repo (modern, GitHub-recommended tool)
- Automatic backups before cleanup (stored in `~/.git-spill-backups/`)
- Remove files, directories, or patterns (wildcards)
- Remove AI assistant artifacts with `--ai` option (Claude, Cursor, Aider, Continue, Copilot, Windsurf, Codeium, Tabnine, etc.)
- String/text removal from all files in history
- Dry-run mode for safe testing
- Friendly install guidance if git-filter-repo is missing
- Comprehensive safety checks and warnings

**Documentation:** See [tools/git/README.md](tools/git/README.md) for detailed usage guide, scenarios, and troubleshooting.

### Git Claude Contributor Fix

The [git-claude-contrib-fix.sh](tools/git/git-claude-contrib-fix.sh) script removes Claude Code from GitHub contributors when it autonomously adds itself without permission.

**Problem:** Claude Code sometimes adds "Co-Authored-By: Claude" attribution to commits without explicit user consent, causing Claude to appear as a repository contributor on GitHub.

**Usage:**

```bash
# Use current repository with default branch
cd dfe-developer
./tools/git/git-claude-contrib-fix.sh

# Specify repository URL
./tools/git/git-claude-contrib-fix.sh https://github.com/owner/repo.git

# Specify repository and branch
./tools/git/git-claude-contrib-fix.sh https://github.com/owner/repo.git develop
```

**Features:**
- Removes "Co-Authored-By: Claude" and "Generated with Claude Code" from commit messages
- Auto-detects repository default branch (main, master, etc.)
- Optional branch parameter to clean specific branches
- For default branch: forces GitHub contributor reindex
- For non-default branches: only cleans commits (no gh CLI required)
- Comprehensive error handling and automatic cleanup

**Requirements:**
- git (required)
- gh (GitHub CLI) - only required when working on default branch
- Push access to the repository

**Documentation:** See [tools/git/README.md](tools/git/README.md) for detailed usage guide, scenarios, and troubleshooting.

**Help:**
```bash
./tools/git/git-claude-contrib-fix.sh --help
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
- **Network Tools** - PuTTY, WinSCP, OpenVPN GUI, TigerVNC
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
