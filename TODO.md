# TODO - DFE Developer Environment

## IMMEDIATE: Refactor macOS Homebrew Environment Variables

**Priority:** Reduce code duplication by using vars for common Homebrew environment

Created `/projects/dfe-developer/ansible/roles/dfe_developer/vars/macos.yml` with:
- `homebrew_env` - for regular Homebrew tasks
- `homebrew_cask_env` - for Homebrew cask tasks requiring sudo

**Action needed:** Update all macOS tasks to use `environment: "{{ homebrew_env }}"` instead of repeating the PATH definition.

**Files to update:**
- ansible/roles/dfe_developer/tasks/git.yml (2 tasks)
- ansible/roles/dfe_developer/tasks/cloud.yml (5 tasks)
- ansible/roles/dfe_developer/tasks/k8s.yml (6 tasks)
- ansible/roles/dfe_developer/tasks/vscode.yml (1 task)
- ansible/roles/dfe_developer/tasks/chrome.yml (1 task)
- ansible/roles/dfe_developer/tasks/ghostty.yml (2 tasks)
- ansible/roles/dfe_developer_core/tasks/*.yml (multiple)
- ansible/roles/dfe_system_cleanup/tasks/main.yml (2 tasks)

---

## Testing & Quality

**Remaining work:**
- Test complete playbook run on macOS (not just individual tasks)
- Test on Ubuntu 24.04 (ensure no regressions)
- Test on Fedora 42 (ensure no regressions)
- Add test coverage for python.yml, docker.yml, utilities.yml on macOS

---

## Future Enhancements

- WSL Ubuntu support research
- macOS cloud VM alternatives to Scaleway
- Consider Homebrew Bundle for macOS (Brewfile)
- Investigate macOS security settings automation

---

**Note:** Completed tasks are documented in CHANGELOG.md and removed from TODO.md
