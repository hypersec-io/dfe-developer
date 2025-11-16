# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.1](https://github.com/hypersec-io/dfe-developer/compare/v2.5.0...v2.5.1) (2025-11-16)


### Bug Fixes

* Add GenAI Toolbox (MCP Toolbox) to core role ([c6cc07b](https://github.com/hypersec-io/dfe-developer/commit/c6cc07b058aa3508bef603b13fd804e3b0a32747))
* Add GNU Parallel to utilities and remove duplicate when condition ([08dc54c](https://github.com/hypersec-io/dfe-developer/commit/08dc54cd3b21ac66ddfbd1da8b19e97a2be1f07e))
* Add tokenx to global npm packages in core role ([0b7fe54](https://github.com/hypersec-io/dfe-developer/commit/0b7fe5442bc0e738e15c85b40564f4b581d35dcd))
* Configure GitHub linguist to detect Ansible as primary language ([c2455f0](https://github.com/hypersec-io/dfe-developer/commit/c2455f09a4752189392e39725feb7ec8c315e91b))
* Correct MCP Toolbox verification command and remove duplicate register ([87fc6b6](https://github.com/hypersec-io/dfe-developer/commit/87fc6b6d583ca384366341d4aa2dfeb3b1705d84))


### Reverts

* Revert "fix: Add tokenx to global npm packages in core role" ([2ac0f60](https://github.com/hypersec-io/dfe-developer/commit/2ac0f6026895dee2c951af77ac7790cf2fb2cd69))

# [2.5.0](https://github.com/hypersec-io/dfe-developer/compare/v2.4.4...v2.5.0) (2025-11-10)


### Features

* Add semantic-release automation for version management ([3bd6478](https://github.com/hypersec-io/dfe-developer/commit/3bd64784ec50901b359c5f3a76ca0a4b197cd6b4))

## [2.4.4] - 2025-11-05

### Added
- **[Core]** Gitleaks v8.29.0 secret detection tool for finding hardcoded credentials

### Removed
- **[Cleanup]** Removed redundant /claude directory (duplicate of tools/git/)

## [2.4.3] - 2025-11-05

### Fixed
- **[Ansible]** Ubuntu Vector GPG keys - Changed from RPM keys to APT keys (DATADOG_APT_KEY_*)
- **[Ansible]** Ubuntu VS Code repository conflicts - Added cleanup of pre-existing repos
- **[Ansible]** Missing verify.yml reference - Removed dead playbook reference
- **[Ansible]** QEMU guest agent verification - Accept 'static' UnitFileState on Ubuntu

### Changed
- **[Testing]** All platforms tested on fresh VMs (Ubuntu 24.04: 275 tasks/0 failed, Fedora 42: 257 tasks/0 failed)
- **[macOS]** Complete macOS Sequoia 15.3.1 support verified (120 tasks, 0 failures)

## [2.4.2] - 2025-10-31

### Fixed
- **[Ansible]** git-subtree not available as separate package on Ubuntu (included in git)
- **[Ansible]** Ghostty uses dynamic Ubuntu version (ansible_distribution_version)
- **[Ansible]** kubectl moved to k8s.yml with dynamic K8s version detection
- **[Ansible]** Added HashiCorp repository for Fedora (Terraform/Vault not in default repos)
- **[Ansible]** Ghostty Ubuntu uses pre-built .deb from mkasberg/ghostty-ubuntu

### Changed
- **[Ansible]** Dynamic Kubernetes version from https://dl.k8s.io/release/stable.txt
- **[Ansible]** Both Ubuntu and Fedora fully working (0 failures on both)

## [2.4.1] - 2025-10-31

### Added
- **[Ansible]** Complete dfe_developer role with Docker, Python (UV), Git, Cloud tools, K8s tools, Utilities
- **[Ansible]** Mirror validation before system modification
- **[Ansible]** GNOME detection in pre_tasks as dfe_has_gnome fact
- **[Ansible]** Repository backups before modification
- **[Ansible]** git-core PPA for latest Git on Ubuntu

### Changed
- **[Ansible]** Simplified Python to UV only (no pyenv/pipx)
- **[Ansible]** Task ordering: repository → utilities → Docker → Python → Git → cloud → k8s
- **[Ansible]** Renamed dfe_use_aarnet_mirrors → dfe_use_mirrors
- **[Ansible]** Consolidated Docker into single task file
- **[Ansible]** Ghostty skipped on Ubuntu (PPA doesn't support noble)
- **[Ansible]** Each task file adds its own vendor repositories

### Fixed
- **[Ansible]** Ubuntu 24.04 fully working (78 tasks, 0 failures, fully tested)
- **[Ansible]** Correct Ubuntu mirror path (/ubuntu/archive/)
- **[Ansible]** Podman removal ignores errors if not installed

## [2.4.0] - 2025-10-31

### Added
- **[Ansible]** Ansible-based deployment system for cross-platform support
- **[Ansible]** install.sh bootstrap script for Ubuntu, Fedora, and macOS
- **[Ansible]** Role-based architecture (4 roles matching bash scripts)
- **[Ansible]** dfe_developer role (Docker installation working on Ubuntu + Fedora)
- **[Ansible]** Task-based organization with distro conditionals inside tasks
- **[Ansible]** Complete role structure for all components (stubs created)
- **[Ansible]** Ansible 12+ compatibility with modern callback plugins
- **[Ansible]** Tested successfully on Ubuntu 24.04 and Fedora 42

### Changed
- **[Project]** Multi-platform support via Ansible (Ubuntu, Fedora, macOS)
- **[Project]** Declarative infrastructure-as-code approach
- **[Project]** Idempotent deployments (safe to re-run)

## [2.3.4] - 2025-10-31

### Fixed
- **[Fedora]** RDP optimizer now auto-generates system certificates for gnome-remote-desktop
- **[Fedora]** Certificates properly configured via grdctl for Remote Login mode
- **[Fedora]** Desktop now auto-resizes to match RDP client window size
- **[Fedora]** Certificate ownership and permissions set correctly for gnome-remote-desktop user

### Added
- **[Fedora]** Interactive password prompt for RDP credentials during installation
- **[Fedora]** --password and --username flags for automated/scripted deployments
- **[Fedora]** Automatic service restart after credential configuration
- **[Fedora]** Ready-to-use RDP setup (no manual credential configuration needed)

## [2.3.2] - 2025-10-30

### Added
- **[Fedora]** RDP optimizer now automatically enables gnome-remote-desktop.service

### Changed
- **[Fedora]** Removed renderer auto-detection from Ghostty config (not needed)
- **[Fedora]** Simplified Ghostty configuration by removing RDP session detection
- **[Fedora]** Cleaner config template with Solarized Dark as default

## [2.3.1] - 2025-10-30

### Changed
- **[Fedora]** Updated Ghostty configuration to Solarized Dark theme
- **[Fedora]** Enabled programming ligatures (calt, liga) instead of disabling them
- **[Fedora]** Reduced font size from 12 to 11 for better high-DPI displays
- **[Fedora]** Added window dimensions (35x140) for practical terminal size
- **[Fedora]** Disabled VSync for better RDP performance
- **[Fedora]** Added useful keybindings (copy/paste, tabs, font sizing)
- **[Fedora]** RDP-optimized settings (software renderer for remote sessions)

## [2.3.0] - 2025-10-30

### Fixed
- **[Fedora]** Fixed all systemctl enable/disable/daemon-reload commands to use sudo
- **[Fedora]** Fixed GRUB configuration operations to use sudo
- **[Fedora]** Fixed /sys/ filesystem writes to use sudo tee
- **[Fedora]** Fixed NetworkManager configuration writes to use sudo
- **[Fedora]** All scripts now run without PolicyKit authentication prompts

### Removed
- **[Fedora]** Removed file logging from VM optimizer (console only, use tee for logs)

## [2.2.9] - 2025-10-30

### Fixed
- **[Fedora]** Added complete verification function library to lib.sh (verify_sysctl_setting, verify_command_exists, etc.)
- **[Fedora]** Fixed VM and RDP optimizer scripts to use sudo properly for system file operations
- **[Fedora]** Fixed apply_system_dconf function to use sudo for /etc/dconf/ operations
- **[Fedora]** All optimizer scripts now work as regular user with passwordless sudo

### Removed
- **[Project]** Removed windows/VERSION file (using root VERSION only for unified versioning)

## [2.2.8] - 2025-10-30

### Fixed
- **[Fedora]** Fixed journald configuration in install-vm-optimizer.sh to use sudo
- **[Fedora]** Added missing verification helper function stubs

## [2.2.7] - 2025-10-30

### Fixed
- **[Fedora]** Minikube installation now idempotent (skips if already installed)
- **[Fedora]** Minikube downloads to /tmp with proper pushd/popd for directory changes
- **[Fedora]** Fixed ShellCheck warnings for directory navigation

## [2.2.6] - 2025-10-30

### Added
- **[Fedora]** Ghostty terminal emulator now installed via scottames/ghostty COPR repository
- **[Fedora]** Ghostty integrated into main install-dfe-developer.sh script
- **[Fedora]** Automatic Ghostty configuration with JetBrains Mono font

### Fixed
- **[Fedora]** Fixed missing BACKUP_DIR and STATE_FILE variables in install-rdp-optimizer.sh
- **[Fedora]** Added missing helper functions: dconf_update_safe, create_sysctl_config, reload_service_safe

### Removed
- **[Fedora]** Removed install-ghostty.sh (now integrated into main installer)
- **[Fedora]** Removed build-from-source option for Ghostty (now uses COPR)

## [2.2.5] - 2025-10-30

### Fixed
- **[Fedora]** Suppressed Flatpak progress bars during installation (Freelens, Slack, Ghostty)
- **[Fedora]** Uses FLATPAK_TTY_PROGRESS=0 and grep filtering to remove multi-line progress output
- **[Fedora]** Cleaner installation output while preserving status messages

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
