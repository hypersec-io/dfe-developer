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

## Manual Scaleway CLI Testing

The Scaleway CLI is installed on this machine for manual operations:

```bash
# Activate Python venv with Scaleway CLI
source ~/.local/share/scaleway-cli/venv/bin/activate

# List Mac minis
scw apple-silicon server list zone=fr-par-3

# Get server details
scw apple-silicon server get <server-id> zone=fr-par-3

# Delete server
scw apple-silicon server delete <server-id> zone=fr-par-3

# List serverless functions
scw function function list region=fr-par
```

## Usage

### Proxmox Tests (Fedora + Ubuntu)

```bash
# Reset VMs to clean snapshots and generate inventory
ansible-playbook tests/proxmox/provision.yml

# Run all 4 comprehensive tests (Ansible + install.sh on both VMs)
ansible-playbook tests/proxmox/test_all.yml

# Or run deployment tests directly
ansible-playbook -i tests/proxmox/inventory_proxmox.yml playbooks/main.yml
```

### Scaleway Tests (macOS)

```bash
# One-time: Deploy serverless auto-cleanup function (optional)
# First, enable in .env: DEPLOY_SCALEWAY_IDLE_FUNCTION=true
ansible-playbook tests/mac/serverless/deploy_function.yml

# Provision Mac mini (creates or reuses existing)
ansible-playbook tests/mac/provision.yml

# Run deployment tests
ansible-playbook -i tests/mac/inventory_scaleway.yml playbooks/main.yml

# Cleanup (delete Mac mini)
ansible-playbook tests/mac/cleanup.yml
```

## Cost Management

- **Proxmox**: Free (local VMs), instant reset via snapshots
- **Scaleway Mac mini**: ~$1/hour
  - Auto-deletes after 24h of IDLE (CPU <5%, low network)
  - Requires serverless function (one-time setup, ~$0.40/month)
  - Always cleanup when done!

## Security

- `.env` file contains sensitive credentials
- All `.env` files are gitignored (root and ansible/tests/)
- Use `.env.sample` as template only
- Never hardcode credentials in playbooks
- Scaleway CLI venv available for manual operations
