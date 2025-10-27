# DFE Developer Environment

Standardised complete developer environment setup for HyperSec DFE developers on Fedora Linux.

## Quick Start

To be installed onto Fedora Linux 42+

```bash
# Clone the repository
git clone https://github.com/hypersec-io/dfe-developer
cd dfe-developer/fedora

# Run main installer
./install-dfe-developer.sh

# Optional: Add advanced tools
./install-dfe-developer-core.sh

# Optional: Optimise for VM/RDP
./install-vm-optimizer.sh
./install-rdp-optimizer.sh

# Optional: Install Ghostty
./install-ghostty.sh

```

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

- `fedora/` - Installation scripts
- `fedora/lib.sh` - Shared utility functions
- `fedora/tests/` - Test suite
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

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to submit pull requests
- Code standards and style guidelines
- Testing requirements
- Development workflow

## License

Apache License 2.0 - See [LICENSE](LICENSE) file for details.


