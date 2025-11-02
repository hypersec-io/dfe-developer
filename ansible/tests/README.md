# Test Infrastructure

Automated testing on Proxmox (Fedora/Ubuntu) and Scaleway (macOS).

## Setup

1. Copy `.env.sample` to `.env`:
   ```bash
   cp .env.sample .env
   ```

2. Edit `.env` with your credentials:
   - Scaleway API keys (for macOS testing)
   - Proxmox server details (for Fedora/Ubuntu testing)

3. **NEVER commit `.env`** - it's gitignored and contains secrets!

## Usage

### Proxmox Tests (Fedora + Ubuntu)

```bash
# Reset VMs to clean snapshots and generate inventory
ansible-playbook tests/proxmox/provision.yml

# Run deployment tests
ansible-playbook -i tests/proxmox/inventory_proxmox.yml playbooks/main.yml
```

### Scaleway Tests (macOS)

```bash
# Install Scaleway collection (first time only)
ansible-galaxy collection install scaleway.scaleway

# Provision Mac mini (creates or reuses existing)
ansible-playbook tests/mac/provision.yml

# Run deployment tests
ansible-playbook -i tests/mac/inventory_scaleway.yml playbooks/main.yml

# Cleanup (delete Mac mini)
ansible-playbook tests/mac/cleanup.yml
```

## Cost Management

- **Proxmox**: Free (local VMs), instant reset via snapshots
- **Scaleway Mac mini**: ~$1/hour, auto-deletes after 24h
- Always cleanup Scaleway instances when done!

## Security

- `.env` file contains sensitive credentials
- All `.env` files are gitignored
- Use `.env.sample` as template only
- Never hardcode credentials in playbooks
