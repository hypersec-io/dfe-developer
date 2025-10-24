# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.2] - 2025-10-24

### Fixed
- Dynamic version detection for Confluent CLI (uses latest from packages.confluent.io)
- Dynamic version detection for kubectl (uses latest stable from dl.k8s.io)
- Replaced cd with pushd/popd in AWS CLI installation for safer directory changes
- Updated unit tests to match ISO timestamp format in print functions
- ShellCheck warnings resolved (all tests pass)

### Changed
- Character policy updated to ASCII-only (no emojis)
- Standardized script headers across all optimizer scripts
- All documentation updated to reflect ASCII-only policy

### Added
- Comprehensive CONTRIBUTING.md with Apache project standards
- Full contribution guidelines including fork/PR workflow
- Code standards and testing requirements documentation

## [2.1.1] - 2025-10-24

### Added
- Helm Dashboard plugin installation for visual Helm chart management
- Freelens Kubernetes IDE via Flatpak for K8s cluster management
- Dash-to-panel transparency settings (40% opacity)
- K9s and Freelens verification checks in installation output

### Changed
- Removed specific version numbers from README.md (centralized in VERSION file)
- Updated documentation to reflect new Kubernetes tools

## [2.1.0] - 2025-10-20

### Added
- Slack installation via Flatpak in install-dfe-developer-core.sh
- Automatic flathub remote configuration for user-level Flatpak installations
- Robust error handling for optional Flatpak installations

### Fixed
- Claude Code CLI command (changed from `claude-code` to `claude`)
- Claude Code auto-update configuration now uses correct command
- Flatpak installations now use `--user` flag for proper permissions

### Changed
- Removed all SUDO_USER references from scripts (~50+ lines of code simplified)
- Scripts now use $HOME and $USER directly instead of complex SUDO_USER logic
- Simplified UV installation (removed SUDO_USER branching)
- Simplified VM optimizer GUI configurations (OBEX, VS Code, Chrome, Slack, Firefox, GNOME)
- Simplified restore_settings function in install-vm-optimizer.sh
- All user-specific paths now use $HOME instead of /home/$SUDO_USER/

### Improved
- Code maintainability with single execution path instead of root/user branching
- Consistency with "run as user, sudo only when needed" design principle

## [2.0.0] - 2025-10-19

### Ported
- Ported from internal HyperSec SOE build

### Changed
- Complete rewrite 
- Removed all verify, uninstall, and check functions
- Consolidated library functions into single lib.sh file
- Simplified all installation scripts by 85%  
- Removed numbered steps from console output and comments  

### Added
- BATS testing framework for unit and integration tests
- Container tests with Podman/Docker support
- developer_sudoers function for passwordless sudo setup
- Git pre-push hook for automatic version tagging

### Fixed
- All ShellCheck warnings (SC2155, SC2046, SC2034)
- Container test SELinux context issues
- Script executable permissions

### Removed
- Complex mode selection logic
- Verification and uninstallation functions
- Over-engineered error handling