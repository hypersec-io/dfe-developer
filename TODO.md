# TODO - DFE Developer Environment

## COMPLETED: Initial macOS Support ✅

**Status:** Basic macOS support implemented for all applicable tasks via Homebrew.

**What works:**
- ✅ Git + GitHub CLI (tested on macOS)
- ✅ Cloud tools: AWS CLI, Helm, Terraform, Vault (tested on macOS)
- ✅ Ghostty + JetBrains Mono font (tested on macOS)
- ✅ K8s tools: kubectl, k9s, kubectx, minikube, argocd, dive (added)
- ✅ VS Code, Chrome (added)
- ✅ JFrog, Azure CLI, OpenVPN, Slack, Node.js (added/fixed)
- ✅ UV Python manager (cross-platform by design)
- ✅ Development utilities (jq, bat, fzf, ripgrep, etc.)
- ✅ System cleanup (Homebrew update/cleanup)

**Skipped (Linux-only by design):**
- Repository configuration (package mirrors)
- Security configuration (automatic updates)
- VM/RDP optimizers (Linux VMs only)
- Wallpaper (GNOME-specific)

---

## IMMEDIATE: Code Quality Refactoring

**Priority:** Reduce code duplication by using vars for common Homebrew environment

Created `/projects/dfe-developer/ansible/roles/dfe_developer/vars/macos.yml` with:
- `homebrew_env` - for regular Homebrew tasks
- `homebrew_cask_env` - for Homebrew cask tasks requiring sudo

**Action needed:** Update all macOS tasks to use `environment: "{{ homebrew_env }}"` instead of repeating PATH definitions (~40 instances).

**Example refactoring:**
```yaml
# Before:
- name: Install something (macOS)
  community.general.homebrew:
    name: something
  become: false
  environment:
    PATH: "/opt/homebrew/bin:/usr/local/bin:{{ ansible_env.PATH }}"
  when: ansible_distribution == 'MacOSX'

# After:
- name: Install something (macOS)
  community.general.homebrew:
    name: something
  become: false
  environment: "{{ homebrew_env }}"
  when: ansible_distribution == 'MacOSX'
```

---

## Testing & Quality

**Remaining work:**
- ⚠️ Test complete playbook run on macOS (not just individual tasks)
- ⚠️ Test on Ubuntu 24.04 (ensure no regressions)
- ⚠️ Test on Fedora 42 (ensure no regressions)
- ⚠️ Individual testing of: k8s.yml, vscode.yml, chrome.yml, nodejs.yml, slack.yml on macOS
- ⚠️ Full integration test with docker.yml, uv.yml on macOS

---

## Future Enhancements

### Platform Support
- WSL Ubuntu support research
- macOS cloud VM alternatives to Scaleway
- Consider Homebrew Bundle for macOS (Brewfile for easier maintenance)

### macOS-Native Improvements
- Research `defaults` command for system configuration
- Investigate proper macOS user defaults patterns (not /etc/skel)
- Research macOS security settings automation
- Application preferences via .plist manipulation

### Code Quality
- Apply vars/macos.yml refactoring (reduce 40+ duplicate environment blocks)
- Consider role-level vars for common patterns
- Add more comprehensive task-level documentation

---

**Note:** Completed tasks are documented in CHANGELOG.md and removed from TODO.md
