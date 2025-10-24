#!/bin/bash
# 01-shellcheck.sh - Static analysis with ShellCheck
# Catches common bash mistakes without running the scripts

echo "============================================================================"
echo "  ShellCheck Static Analysis"
echo "============================================================================"

# Check if shellcheck is installed
if ! command -v shellcheck &>/dev/null; then
    echo "[WARN] ShellCheck not installed - skipping static analysis"
    echo "       Install with: sudo dnf install -y ShellCheck"
    exit 0
fi

# Change to parent directory where scripts are
cd "$(dirname "$0")/.." || exit 1

FAILED=0
TOTAL=0

# Test all .sh files
for script in *.sh; do
    if [[ -f "$script" ]]; then
        ((TOTAL++))
        echo -n "Checking $script... "

        # Run shellcheck with reasonable exclusions
        # SC1091: Not following sourced files
        # SC2154: Variable may be referenced but not assigned (for sourced vars)
        if shellcheck -S warning -e SC1091,SC2154 "$script" 2>/dev/null; then
            echo "[OK]"
        else
            echo "[FAIL]"
            ((FAILED++))
            # Show the errors
            shellcheck -S warning -e SC1091,SC2154 "$script" 2>&1 | head -10
        fi
    fi
done

echo ""
echo "Results: $((TOTAL - FAILED))/$TOTAL passed"

exit $FAILED