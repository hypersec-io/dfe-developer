#!/bin/bash
# vscode-wayland.sh - Fix VSCode window sizing issues on Wayland/4K displays
#
# This script clears cached window dimensions that cause VSCode windows to
# open at incorrect sizes (e.g., 1920x1080) on 4K Wayland displays.

set -e

STORAGE_JSON="$HOME/.config/Code/User/globalStorage/storage.json"

# Check if VSCode is running
if pgrep -f "/usr/share/code/code" > /dev/null 2>&1; then
    echo "ERROR: VSCode is still running. Please close all VSCode windows first."
    exit 1
fi

echo "Fixing VSCode window sizing for Wayland..."

# Clear Session Storage and Local Storage
if [ -d "$HOME/.config/Code/Session Storage" ]; then
    rm -rf "$HOME/.config/Code/Session Storage"
    echo "- Cleared Session Storage"
fi

if [ -d "$HOME/.config/Code/Local Storage" ]; then
    rm -rf "$HOME/.config/Code/Local Storage"
    echo "- Cleared Local Storage"
fi

# Reset windowsState in storage.json
if [ -f "$STORAGE_JSON" ]; then
    python3 << 'PYEOF'
import json
import sys

storage_path = "$HOME/.config/Code/User/globalStorage/storage.json".replace("$HOME", __import__('os').environ['HOME'])

try:
    with open(storage_path, 'r') as f:
        data = json.load(f)
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f"ERROR: Could not read storage.json: {e}", file=sys.stderr)
    sys.exit(1)

# Reset windowsState with mode=1 (maximized) but no cached coordinates
data['windowsState'] = {
    "lastActiveWindow": {
        "uiState": {
            "mode": 1
        }
    },
    "openedWindows": []
}

# Clear backup workspaces folders list (these reference old window states)
if 'backupWorkspaces' in data:
    data['backupWorkspaces']['folders'] = []
    data['backupWorkspaces']['emptyWindows'] = []

with open(storage_path, 'w') as f:
    json.dump(data, f, indent=4)

print("- Reset windowsState (mode=1/maximized, no cached coordinates)")
PYEOF
else
    echo "WARNING: storage.json not found at $STORAGE_JSON"
fi

echo ""
echo "Done! VSCode windows will now open maximized at native resolution."
