# TODO - DFE Developer Environment

## IMMEDIATE: Complete macOS Support

**Priority:** Finish macOS implementation for ALL roles/tasks (except VM/RDP optimizers)

Add macOS support to every remaining task in:

**ansible/roles/dfe_developer/tasks:**
- ⏸️ git.yml - Add PATH environment to macOS Homebrew tasks
- ⏸️ cloud.yml - AWS CLI, Helm, Terraform (research macOS methods)
- ⏸️ k8s.yml - kubectl, k9s, minikube (Homebrew or binary)
- ⏸️ vscode.yml - VS Code via Homebrew cask
- ⏸️ chrome.yml - Chrome via Homebrew cask
- ⏸️ ghostty.yml - macOS installation method

**ansible/roles/dfe_developer_core/tasks:**
- ⏸️ jfrog.yml - JFrog CLI via Homebrew
- ⏸️ azure.yml - Azure CLI via Homebrew
- ⏸️ openvpn.yml - OpenVPN 3 for macOS
- ⏸️ linear.yml - Linear CLI for macOS
- ⏸️ c_tools.yml - Xcode Command Line Tools

**ansible/roles/dfe_system_cleanup/tasks:**
- ⏸️ Homebrew cleanup
- ⏸️ /tmp/askpass.sh removal

**Process:**
1. Research macOS equivalent (Homebrew preferred)
2. Add task with PATH + become: false
3. Test on Scaleway Mac (51.159.120.9)
4. Fix issues, commit, move to next

**Test:** `ansible-playbook -i tests/mac/inventory_scaleway.yml playbooks/main.yml --tags <tag>`

---

## Future Enhancements

- WSL Ubuntu support research
- macOS cloud VM alternatives to Scaleway

---

**Note:** Completed tasks are documented in CHANGELOG.md and removed from TODO.md
