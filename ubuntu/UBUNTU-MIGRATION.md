# Ubuntu Migration Planning

This document outlines the migration of DFE developer environment from Fedora to Ubuntu 24.04 LTS (Noble Numbat).

## Target Platform

**Ubuntu 24.04 LTS (Noble Numbat)**
- Desktop Edition with GNOME 46
- LTS support until 2029
- Existing manually installed system (VM or physical)

## Package Management Strategy

### Primary: APT (Native Ubuntu)

Use APT as the primary package manager for all available packages:
- **Pros**: Native Ubuntu support, official repositories, best integration
- **Cons**: Some packages may be older versions
- **Use for**: System packages, Docker, Python build deps, development tools

### Secondary: Official Vendor Repositories

Add vendor-specific APT repositories when needed:
- Docker CE (docker.com repository)
- VS Code (Microsoft repository)
- kubectl (Kubernetes repository)
- Helm (official Helm repository)
- **Pros**: Latest versions from official sources
- **Cons**: More repository management

### Snap vs Flatpak Decision

**Avoid Snap where possible:**
- Ubuntu 24.04 pushes Snap by default (App Center, Firefox, Thunderbird)
- Snap has performance issues (slow startup)
- Conflicts with APT installations (Firefox trap)
- Proprietary backend (Canonical-controlled)

**Use Flatpak for GUI apps:**
- Freelens, Slack, optional GUI tools
- Better performance than Snap
- Open ecosystem (Flathub)
- Already used in Fedora port (consistency)

**Snap exceptions (if absolutely necessary):**
- Only if no APT or Flatpak alternative exists
- Document why Snap was chosen

### Tools Not to Use

**PPAs (Personal Package Archives):**
- Avoid third-party PPAs where possible
- Security risk (untrusted sources)
- Can break on system upgrades
- Prefer: Official vendor repositories or build from source

## Fedora → Ubuntu Package Mapping

### Package Manager Commands

| Task | Fedora (dnf) | Ubuntu (apt) |
|------|--------------|--------------|
| Update cache | `dnf makecache` | `apt update` |
| Install package | `dnf install -y` | `apt install -y` |
| Remove package | `dnf remove -y` | `apt remove -y` |
| Clean cache | `dnf clean all` | `apt clean` |
| Search package | `dnf search` | `apt search` |
| List installed | `dnf list --installed` | `dpkg -l` or `apt list --installed` |
| Add repository | `dnf config-manager` | `add-apt-repository` |
| Enable COPR | `dnf copr enable` | N/A (use PPA cautiously or vendor repos) |

### Core Development Tools

| Tool | Fedora Package | Ubuntu Package | Notes |
|------|----------------|----------------|-------|
| Docker | docker-ce (repo) | docker-ce (repo) | Use Docker's official repository |
| VS Code | code (repo) | code (repo) | Use Microsoft's repository |
| Git | git | git | Native APT |
| Python build | python3-devel | python3-dev | Different package name |
| C compiler | gcc, gcc-c++ | gcc, g++ | Different C++ package name |
| Make | make | make | Same |
| curl/wget | curl, wget | curl, wget | Same |

### Cloud Tools

| Tool | Fedora | Ubuntu | Installation Method |
|------|--------|--------|---------------------|
| AWS CLI v2 | Binary download | Binary download | Official installer (no apt repo available) |
| kubectl | Binary download | **APT repo** | Kubernetes official repository (BETTER!) |
| Helm | Binary download | **APT repo** | Helm official repository (BETTER!) |
| Terraform | Binary download | **APT repo** | HashiCorp official repository (BETTER!) |
| Azure CLI | Script install | **APT repo** | Microsoft official repository (BETTER!) |

**Note:** Ubuntu has official APT repositories for kubectl, Helm, Terraform, and Azure CLI - this is BETTER than binary downloads as packages auto-update!

### Python Environment

| Tool | Fedora | Ubuntu | Notes |
|------|--------|--------|-------|
| pyenv | Build from source | Build from source | Same approach |
| pipx | pipx package | pipx package | Native APT |
| UV | Binary download | Binary download | Same |

### GUI Applications

| App | Fedora | Ubuntu | Recommended Method |
|-----|--------|--------|-------------------|
| Firefox | Native dnf | Native apt | Use APT (avoid Snap trap) |
| Chrome | RPM repo | DEB repo | Google's official repo |
| VS Code | RPM repo | DEB repo | Microsoft's repo |
| Slack | Flatpak | Flatpak | Consistent with Fedora |
| Freelens | Flatpak | Flatpak | Consistent with Fedora |
| Ghostty | COPR (scottames) | PPA (mkasberg) | Terminal emulator with same Solarized config |

### System Utilities

| Tool | Fedora | Ubuntu | Notes |
|------|--------|--------|-------|
| jq | jq | jq | Same |
| yq | Binary | Binary | Same |
| bat | bat | bat | May need different package name |
| ripgrep | ripgrep | ripgrep | Native APT |
| fzf | fzf | fzf | Native APT |

## Ubuntu-Specific Considerations

### 1. Package Name Differences
- Development headers: `-devel` (Fedora) vs `-dev` (Ubuntu)
- C++ compiler: `gcc-c++` (Fedora) vs `g++` (Ubuntu)
- Python: `python3-*` naming similar but verify each package

### 2. Repository Management
- Ubuntu uses `/etc/apt/sources.list.d/` for additional repos
- Use signed-by for repository keys (modern approach)
- No COPR equivalent - use vendor repos or build from source

### 3. Desktop Environment
- Ubuntu 24.04 uses GNOME 46 (same as Fedora 42)
- GNOME extensions work the same way
- Wayland by default (same as Fedora)

### 4. Systemd
- Same systemd version and commands
- Service management identical to Fedora

### 5. SELinux vs AppArmor
- Fedora uses SELinux
- Ubuntu uses AppArmor
- Both handle security differently
- AppArmor is simpler, less configuration needed

## Migration Scope

### Phase 1: Core Installation (Minimal Viable Product)
- [ ] lib.sh with Ubuntu support (apt commands, distro detection)
- [ ] install-dfe-developer.sh Ubuntu port
  - Docker CE from official repository
  - Python development (pyenv, pipx, UV)
  - Cloud tools (AWS CLI, kubectl, Helm, Terraform)
  - Git and GitHub CLI
  - Development utilities (jq, yq, bat, fzf, ripgrep)
  - VS Code from Microsoft repository

### Phase 2: Advanced Tools
- [ ] install-dfe-developer-core.sh Ubuntu port
  - JFrog CLI
  - Azure CLI
  - Node.js (NodeSource repository)
  - Linear CLI

### Phase 3: Optimizations (If Applicable)
- [ ] VM optimizer (if applicable to Ubuntu VMs)
- [ ] RDP optimizer (if using gnome-remote-desktop on Ubuntu)

### Phase 4: Terminal (Optional)
- [ ] Ghostty terminal emulator
  - Available via mkasberg/ghostty-ubuntu PPA
  - Latest version 1.2.3 for Ubuntu 24.04
  - Install command: Quick install script or PPA
  - Same Solarized Dark config as Fedora

### Out of Scope
- Fedora-specific COPR repositories
- Fedora-specific kernel optimizations

## Test Environment

**Ubuntu 24.04 LTS VM - Proxmox**

- **Hostname**: dfe-dev-u.tyrell.com.au
- **VM ID**: 2006
- **User**: dfe
- **Password**: dfe
- **SSH**: SSH keys configured (no password needed)
- **Proxmox Host**: root@proxmox.tyrell.com.au
- **Snapshot**: initial_build

**Reset VM Command:**
```bash
ssh root@proxmox.tyrell.com.au "qm rollback 2006 initial_build && qm start 2006"
```

**SSH to Test VM:**
```bash
ssh dfe@dfe-dev-u.tyrell.com.au
```

**Test Workflow:**
1. Reset VM to initial_build snapshot
2. Deploy Ubuntu scripts
3. Verify all tools install correctly
4. Test functionality
5. Reset and iterate

## Implementation Approach

### 1. Extend lib.sh (Shared Functions)
- Add `is_ubuntu()` and `is_debian()` detection (already exists)
- Add APT-based package installation functions
- Keep dnf functions for Fedora compatibility
- Add distro-agnostic functions where possible

### 2. Create Ubuntu-Specific Scripts
- Copy Fedora scripts to ubuntu/ directory
- Replace dnf with apt commands
- Adjust package names (map Fedora → Ubuntu)
- Test each script on Ubuntu 24.04 VM

### 3. Testing Strategy
- Use Ubuntu 24.04 LTS VM for testing
- Verify all tools install correctly
- Ensure no conflicts with existing Ubuntu packages
- Test on fresh install and existing desktop

## Known Challenges

### Firefox Snap Trap
Ubuntu 24.04 forces Firefox to install as Snap even via `apt install firefox`.

**Solutions:**
- Use Mozilla Team PPA (risk: third-party PPA)
- Use Firefox from Flatpak
- Accept Snap for Firefox only
- **Recommended**: Use Flatpak for consistency with Fedora

### Snap vs Flatpak for GUI Apps
Ubuntu pushes Snap, we prefer Flatpak.

**Decision**: Use Flatpak for all GUI apps (Slack, Freelens, etc.)
- Consistency with Fedora scripts
- Better performance than Snap
- User can enable Flatpak support easily

### GNOME Extensions
Ubuntu's GNOME extensions may differ from Fedora.

**Approach**:
- Test extension packages
- Use gnome-shell-extension-manager if needed
- Document Ubuntu-specific extensions

## Testing Plan - Script by Script

Each script will be tested in order on fresh VM snapshots (VM 2006).

### 1. install-dfe-developer.sh

**Test Procedure:**
1. Reset VM: `ssh root@proxmox.tyrell.com.au "qm rollback 2006 initial_build && qm start 2006"`
2. Deploy: `ssh dfe@dfe-dev-u.tyrell.com.au "cd ~/dfe-developer/ubuntu && ./install-dfe-developer.sh"`
3. Verify installations:
   - Docker Engine running
   - Docker group membership
   - Python (pyenv, pipx, UV)
   - Git and Git LFS
   - Cloud tools (kubectl, Helm, Terraform from APT repos)
   - VS Code installed
   - GNOME extensions (if GUI present)
4. Test Docker: `docker run hello-world`
5. Test kubectl: `kubectl version --client`
6. Test Helm: `helm version`

**Success Criteria:**
- [ ] All tools install without errors
- [ ] Docker works without sudo (after re-login)
- [ ] All verification checks pass
- [ ] Script is idempotent (can re-run)

### 2. install-dfe-developer-core.sh

**Test Procedure:**
1. Continue from previous test (don't reset VM)
2. Deploy: `ssh dfe@dfe-dev-u.tyrell.com.au "cd ~/dfe-developer/ubuntu && ./install-dfe-developer-core.sh"`
3. Verify installations:
   - JFrog CLI
   - Azure CLI (from Microsoft APT repo)
   - Node.js (from NodeSource repo)
   - semantic-release and plugins
   - Linear CLI
   - Slack (Flatpak)
4. Test tools: `az --version`, `jf --version`, `node --version`

**Success Criteria:**
- [ ] All core tools install
- [ ] Azure CLI works
- [ ] Node.js and npm available
- [ ] Flatpak apps install successfully

### 3. install-vm-optimizer.sh

**Test Procedure:**
1. Reset VM to clean state
2. Run install-dfe-developer.sh first
3. Deploy: `ssh dfe@dfe-dev-u.tyrell.com.au "cd ~/dfe-developer/ubuntu && ./install-vm-optimizer.sh"`
4. Verify optimizations:
   - VM tools installed (KVM guest agent for Proxmox)
   - Kernel parameters applied
   - Services disabled
   - GRUB optimizations
5. Check sysctl settings: `sysctl vm.swappiness` (should be 10)

**Success Criteria:**
- [ ] VM detection works (KVM/QEMU)
- [ ] Guest agent installed
- [ ] Kernel optimizations applied
- [ ] No errors during execution

### 4. install-rdp-optimizer.sh

**Test Procedure:**
1. Continue from VM optimizer test
2. Deploy: `ssh dfe@dfe-dev-u.tyrell.com.au "cd ~/dfe-developer/ubuntu && ./install-rdp-optimizer.sh --password dfe --username dfe"`
3. Verify RDP setup:
   - gnome-remote-desktop installed
   - Certificates generated
   - System service enabled
   - Port 3389 listening
4. Test RDP connection from Windows client
5. **Test auto-resize**: Resize RDP client window, verify desktop resizes

**Success Criteria:**
- [ ] RDP service starts successfully
- [ ] Certificates auto-generated
- [ ] Credentials configured
- [ ] RDP connection works
- [ ] **Desktop auto-resizes to client window** (critical!)

### 5. install-all.sh

**Test Procedure:**
1. Reset VM to completely fresh state
2. Deploy all-in-one: `ssh dfe@dfe-dev-u.tyrell.com.au "cd ~/dfe-developer/ubuntu && ./install-all.sh 2>&1 | tee install.log"`
3. Verify complete installation:
   - All components from scripts 1-4
   - No duplicate installations
   - Proper execution order
   - All services started
4. Reboot and verify persistence
5. Full integration test

**Success Criteria:**
- [ ] Complete installation without errors
- [ ] No duplicate installations
- [ ] All verification checks pass
- [ ] System ready for development work after reboot

## Success Criteria

Ubuntu port is successful when:
- [ ] All 5 scripts pass their individual tests
- [ ] All core development tools install on Ubuntu 24.04 LTS
- [ ] No manual intervention required after running scripts
- [ ] Docker, Python, Kubernetes tools working
- [ ] VS Code and Git configured
- [ ] Cloud CLIs (AWS, Azure) functional
- [ ] Flatpak apps install successfully
- [ ] RDP auto-resize works
- [ ] Scripts are idempotent (safe to re-run)
- [ ] Documentation covers Ubuntu-specific steps

## Timeline Estimate

**Ubuntu 24.04 port**: 3-4 days
- Day 1: lib.sh updates, install-dfe-developer.sh conversion and testing
- Day 2: install-dfe-developer-core.sh, testing and bug fixes
- Day 3: VM and RDP optimizers, install-all.sh
- Day 4: Final integration testing, documentation, cleanup

**Note:** Debian support is OUT OF SCOPE for this phase.

## Next Steps

1. Update TODO.md to mark Ubuntu port as in-progress
2. Start with lib.sh Ubuntu support
3. Port install-dfe-developer.sh to ubuntu/
4. Test on Ubuntu 24.04 VM
5. Iterate and refine
6. Update main README when complete
