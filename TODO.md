# DFE Developer Environment - Task List

## Completed

- [x] Add developer_sudoers function to lib.sh (passwordless sudo)
- [x] Set up VERSION 2.0 and git hook for semver tagging
- [x] Add policy: No Claude attribution in commits/code
- [x] Clean and simplify .gitignore, exclude Claude-related files
- [x] Create CHANGELOG.md starting at v2.0
- [x] Replace all special characters with ASCII only
- [x] Remove numbered steps from scripts and documentation
- [x] Rewrite STATE.md completely
- [x] Create new README.md
- [x] Simplified installation scripts (removed verify/uninstall/check functions)
- [x] Consolidated library functions to lib.sh
- [x] Implemented BATS testing framework
- [x] Fixed all ShellCheck warnings
- [x] Fixed container tests for Podman compatibility
- [x] Add GitHub CLI to install-dfe-developer-core.sh with validation
- [x] Update code comments to reflect new style (removed exclamation marks)
- [x] Clean and simplify .gitattributes

## Pending

- [ ] Test full installation on clean Fedora 42 system
- [ ] Create Ubuntu port (planned)
- [ ] Create macOS port (planned)

## Notes

- Style: Professional Australian, low-key (no hype words)
- ASCII only throughout all files
- No numbered steps in output or comments
- VERSION file is single source of truth
- Keep It Simple (KISS) principle
- No tool attribution in git commits or code