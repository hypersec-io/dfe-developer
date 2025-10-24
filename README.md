# DFE Developer Environment

Standardised complete eveloper environment setup for HyperSec DFE developers on Fedora Linux.

## Quick Start

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
- Python development (UV, Poetry, pyenv)
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
- `VERSION` - Version tracking
- `CHANGELOG.md` - Release history
- `TODO.md` - Task tracking

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to submit pull requests
- Code standards and style guidelines
- Testing requirements
- Development workflow

## License

Apache License 2.0 - See [LICENSE](LICENSE) file for details.


