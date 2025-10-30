# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.4] - 2025-10-30

### Fixed
- **[Fedora]** Added is_gnome() function to lib.sh for reliable GNOME detection
- **[Fedora]** Fixed missing HAS_GNOME initialization in all installer scripts
- **[Fedora]** GNOME detection now uses XDG_CURRENT_DESKTOP, GDMSESSION, and gnome-shell process check
- **[Fedora]** Fixes GUI tools (Firefox, VS Code, extensions) not installing when GNOME is present

## [2.2.3] - 2025-10-30

### Fixed
- **[Fedora]** Removed unnecessary systemd-journald service restarts from install-vm-optimizer.sh
- **[Fedora]** Services no longer restarted during installation (reboot required anyway)

## [2.2.2] - 2025-10-30

### Fixed
- **[Fedora]** Removed automatic call to install-dfe-developer-core.sh from install-dfe-developer.sh
- **[Fedora]** Prevents duplicate installation when using install-all.sh
- **[Fedora]** Scripts now properly modular (use install-all.sh for complete setup)

## [2.2.1] - 2025-10-30

### Fixed
- **[Fedora]** Fixed Claude Code CLI verification to not halt script execution
- **[Fedora]** Removed pyright verification check (no longer installed)
- **[Fedora]** Removed Yeoman (yo) verification check (no longer installed)

## [2.2.0] - 2025-10-30

### Added
- **[Fedora]** Linear.app CLI tool (@digitalstories/linear-cli) to core developer tools
- **[Fedora]** fedora/QUICKSTART.md for fast-start installation guide
- **[Windows]** Windows 11 SOE setup scripts integrated into repository
- **[Windows]** Built-in debloat with comprehensive telemetry and bloatware removal
- **[Windows]** Default Switch automatic scheduled task for new Hyper-V VMs
- **[Windows]** Development workflow documentation (Windows for productivity, Linux VMs for development)
- **[Claude]** Enhanced claude-contrib-fix.sh with optional branch parameter
- **[Claude]** Script now supports cleaning non-default branches without GitHub reindex
- **[Claude]** gh CLI dependency now optional (only required for default branch operations)

### Changed
- **[Windows]** Renamed script: `hypersec-windows-soe.ps1` → `hypersec-windows.ps1`
- **[Windows]** Switched from VMware to Microsoft Hyper-V as primary virtualization platform
- **[Windows]** Security first: Full VBS, Credential Guard, HVCI enabled by default
- **[Windows]** Simplified log files to `%USERPROFILE%\basename.log`
- **[Project]** Unified versioning across Fedora and Windows platforms (single CHANGELOG)
- **[Project]** Removed duplicate LICENSE files from subdirectories (all reference root LICENSE)
- **[Project]** Merged Windows README into root README for centralized documentation

### Deprecated
- **[Windows]** `hypersec-windows-vmware.ps1` retained but no longer maintained (security trade-offs)

### Fixed
- **[Windows]** PowerShell syntax error in scheduled task trigger creation
- **[Windows]** Log file location and naming consistency
- **[Claude]** Improved default branch auto-detection (git symbolic-ref, fallback to gh CLI)

## [2.1.3] - 2025-10-27

### Removed
- **[Fedora]** Removed yo (Yeoman) from npm global installations
- **[Fedora]** Removed pyright from npm global installations

## [2.1.2] - 2025-10-24

### Fixed
- **[Fedora]** Dynamic version detection for Confluent CLI (uses latest from packages.confluent.io)
- **[Fedora]** Dynamic version detection for kubectl (uses latest stable from dl.k8s.io)
- **[Fedora]** Replaced cd with pushd/popd in AWS CLI installation for safer directory changes
- **[Fedora]** Updated unit tests to match ISO timestamp format in print functions
- **[Fedora]** ShellCheck warnings resolved (all tests pass)

### Changed
- **[Fedora]** Character policy updated to ASCII-only (no emojis)
- **[Fedora]** Standardized script headers across all optimizer scripts
- **[Fedora]** All documentation updated to reflect ASCII-only policy

### Added
- **[Fedora]** Comprehensive CONTRIBUTING.md with Apache project standards
- **[Fedora]** Full contribution guidelines including fork/PR workflow
- **[Fedora]** Code standards and testing requirements documentation

## [2.1.1] - 2025-10-24

### Added
- **[Fedora]** Helm Dashboard plugin installation for visual Helm chart management
- **[Fedora]** Freelens Kubernetes IDE via Flatpak for K8s cluster management
- **[Fedora]** Dash-to-panel transparency settings (40% opacity)
- **[Fedora]** K9s and Freelens verification checks in installation output

### Changed
- **[Fedora]** Removed specific version numbers from README.md (centralized in VERSION file)
- **[Fedora]** Updated documentation to reflect new Kubernetes tools

## [2.1.0] - 2025-10-20

### Added
- **[Fedora]** Slack installation via Flatpak in install-dfe-developer-core.sh
- **[Fedora]** Automatic flathub remote configuration for user-level Flatpak installations
- **[Fedora]** Robust error handling for optional Flatpak installations
- **[Windows]** Enhanced Australian English locale configuration
- **[Windows]** Default Switch automatic network assignment for new Hyper-V VMs
- **[Windows]** C:\VM structure with automatic directory creation
- **[Windows]** Scheduled task for automatic Default Switch enforcement

### Fixed
- **[Fedora]** Claude Code CLI command (changed from `claude-code` to `claude`)
- **[Fedora]** Claude Code auto-update configuration now uses correct command
- **[Fedora]** Flatpak installations now use `--user` flag for proper permissions

### Changed
- **[Fedora]** Removed all SUDO_USER references from scripts (~50+ lines of code simplified)
- **[Fedora]** Scripts now use $HOME and $USER directly instead of complex SUDO_USER logic
- **[Fedora]** Simplified UV installation (removed SUDO_USER branching)
- **[Fedora]** Simplified VM optimizer GUI configurations
- **[Fedora]** All user-specific paths now use $HOME instead of /home/$SUDO_USER/
- **[Windows]** Improved Hyper-V configuration with registry and PowerShell module detection
- **[Windows]** Better handling of Hyper-V default paths (Set-VMHost with registry fallback)

### Improved
- **[Fedora]** Code maintainability with single execution path instead of root/user branching
- **[Fedora]** Consistency with "run as user, sudo only when needed" design principle

## [2.0.3] - 2025-09-23

### Changed
- **[Windows]** Updated Chocolatey packages to current versions
- **[Windows]** RoyalTS fixed to use `royalts-v7-x64` for latest v7 installation
- **[Windows]** GitHub Desktop added with `--NoDesktopShortcut` parameter
- **[Windows]** TigerVNC reverted to working `tigervnc` package name
- **[Windows]** Browser configuration updated to Windows 11-compatible manual method only

### Added
- **[Windows]** WinMerge as development tool
- **[Windows]** GitHub Desktop (replaced SourceTree)

### Removed
- **[Windows]** SetUserFTA dependencies and file association automation removed
- **[Windows]** Teams from bloatware cleanup (now properly installed with M365)
- **[Windows]** SourceTree (replaced with GitHub Desktop)

## [2.0.2] - 2025-08-27

### Changed
- **[Windows]** Windows 11 24H2 compatibility improvements
- **[Windows]** Updated package versions for Windows 11 24H2
- **[Windows]** Improved error handling for Windows 11 security restrictions

## [2.0.1] - 2025-07-22

### Added
- **[Windows]** Enhanced privacy hardening with built-in telemetry disabling
- **[Windows]** Improved bloatware removal automation
- **[Windows]** Better service cleanup and startup program management

### Changed
- **[Windows]** Refined Australian English locale configuration
- **[Windows]** Improved power management detection for laptop vs desktop

## [2.0.0] - 2025-10-19

### Ported
- **[Fedora]** Ported from internal HyperSec SOE build
- **[Windows]** Migrated from internal HyperSec repository to public GitHub

### Changed
- **[Fedora]** Complete rewrite
- **[Fedora]** Removed all verify, uninstall, and check functions
- **[Fedora]** Consolidated library functions into single lib.sh file
- **[Fedora]** Simplified all installation scripts by 85%
- **[Fedora]** Removed numbered steps from console output and comments
- **[Windows]** Restructured for public consumption and broader compatibility
- **[Windows]** Improved installation workflow and user experience
- **[Windows]** Better error handling and logging throughout

### Added
- **[Fedora]** BATS testing framework for unit and integration tests
- **[Fedora]** Container tests with Podman/Docker support
- **[Fedora]** developer_sudoers function for passwordless sudo setup
- **[Fedora]** Git pre-push hook for automatic version tagging
- **[Windows]** Complete rewrite with modular architecture
- **[Windows]** VMware Workstation optimization and automation
- **[Windows]** Enhanced privacy hardening with comprehensive telemetry disabling
- **[Windows]** Australian English configuration (locale, timezone, regional settings)
- **[Windows]** System restore point management
- **[Windows]** Automated software installation via Chocolatey
- **[Windows]** Custom wallpaper support
- **[Windows]** Windows Defender ATP onboarding support
- **[Windows]** Comprehensive documentation (README, QUICKSTART, VMWARE guides)

### Fixed
- **[Fedora]** All ShellCheck warnings (SC2155, SC2046, SC2034)
- **[Fedora]** Container test SELinux context issues
- **[Fedora]** Script executable permissions

### Removed
- **[Fedora]** Complex mode selection logic
- **[Fedora]** Verification and uninstallation functions
- **[Fedora]** Over-engineered error handling

### Note
- **[Fedora]** First public release after internal development at HyperSec
- **[Windows]** First public release after internal development at HyperSec
- Previous versions (1.x) were internal-only for both platforms
