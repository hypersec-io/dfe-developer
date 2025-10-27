#!/usr/bin/env bash
# ============================================================================
# claude-contrib-fix.sh - Remove Claude from GitHub Contributors
# ============================================================================
# This script fixes the GitHub contributors list after Claude Code deliberately
# added itself as a contributor by including "Co-Authored-By: Claude" in commits.
#
# SCENARIO THAT CAUSED THIS SCRIPT TO BE DEVELOPED:
#   Ask Claude Code to update the semver and push, thats all.
#   Claude then proceeds to add itself as a full contributor unasked
#   and stains the Github contributor list permanently.
#
#   The issue occurred when requesting a simple version bump (v2.1.2 -> v2.1.3),
#   and Claude Code autonomously added attribution in the commit message, which
#   GitHub then interpreted as a co-author contribution.
#
# HOW IT WORKS:
#   1. Clones a fresh copy of the repository
#   2. Checks for and removes any Claude-attributed commits from history
#   3. Creates a temporary orphan branch with a single commit
#   4. Sets it as the default branch (forces GitHub to recalculate)
#   5. Verifies Claude is removed from contributors
#   6. Restores original default branch
#   7. Cleans up the temporary branch
#   8. Removes the cloned directory
#
# USAGE:
#   ./claude-contrib-fix.sh [repo-url]
#   ./claude-contrib-fix.sh --help
#
# ARGUMENTS:
#   repo-url  - Optional. Git repository URL (if not provided, uses current repo's remote URL)
#   --help    - Show this help message
#
# REQUIREMENTS:
#   - gh (GitHub CLI) must be installed and authenticated
#   - git must be installed
#   - Must have push access to the repository
#
# LICENSE:
#   Licensed under the Apache License, Version 2.0
#   See ../LICENSE file for full license text
# ============================================================================

set -euo pipefail

# Help function
show_help() {
    cat << EOF
claude-contrib-fix.sh - Remove Claude from GitHub Contributors

This script fixes the GitHub contributors list after Claude Code added itself
as a contributor by including "Co-Authored-By: Claude" in commit messages.

USAGE:
    ./claude-contrib-fix.sh [REPO_URL]
    ./claude-contrib-fix.sh --help

ARGUMENTS:
    REPO_URL    Optional. GitHub repository URL (HTTPS or SSH)
                If not provided, uses the current repository's remote URL

OPTIONS:
    --help      Show this help message and exit

EXAMPLES:
    # Use current repository
    ./claude-contrib-fix.sh

    # Specify repository URL
    ./claude-contrib-fix.sh https://github.com/owner/repo.git

    # SSH URL
    ./claude-contrib-fix.sh git@github.com:owner/repo.git

REQUIREMENTS:
    - gh (GitHub CLI) must be installed and authenticated
    - git must be installed
    - Must have push access to the repository

HOW IT WORKS:
    1. Clones a fresh copy of the repository
    2. Checks for and removes any Claude-attributed commits from history
    3. Creates a temporary orphan branch
    4. Sets it as the default branch (forces GitHub to recalculate contributors)
    5. Verifies Claude is removed from contributors
    6. Restores original default branch
    7. Cleans up temporary branch and working directory

EOF
    exit 0
}

# Check for help flag
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
fi

# Configuration
# If no argument provided, try to get remote URL from current repo
if [ -z "${1:-}" ]; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
        if [ -z "${REPO_URL}" ]; then
            echo "ERROR: No repository URL provided and current directory is not a git repository with a remote." >&2
            echo "       Run './claude-contrib-fix.sh --help' for usage information." >&2
            exit 1
        fi
        echo "Using current repository: ${REPO_URL}"
        echo
    else
        echo "ERROR: No repository URL provided and current directory is not a git repository." >&2
        echo "       Run './claude-contrib-fix.sh --help' for usage information." >&2
        exit 1
    fi
else
    REPO_URL="${1}"
fi

# Extract owner and repo name from URL
if [[ "${REPO_URL}" =~ github\.com[:/]([^/]+)/([^/\.]+)(\.git)?$ ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
else
    echo "ERROR: Invalid GitHub repository URL: ${REPO_URL}" >&2
    echo "Expected format: https://github.com/owner/repo.git" >&2
    exit 1
fi

TEMP_BRANCH="temp-clean"
WORK_DIR="${HOME}/claude-contrib-fix-$(date +%s)"
GITHUB_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"

# Will be detected after cloning
MAIN_BRANCH=""

# Error handling function
error_exit() {
    echo "ERROR: $1" >&2
    echo "Cleaning up..."
    if [ -d "${WORK_DIR}" ]; then
        rm -rf "${WORK_DIR}"
    fi
    exit 1
}

# Cleanup function
cleanup() {
    echo "Cleaning up working directory..."
    if [ -d "${WORK_DIR}" ]; then
        rm -rf "${WORK_DIR}"
        echo "Working directory removed: ${WORK_DIR}"
    fi
}

echo "Starting GitHub contributors cleanup process..."
echo

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Check prerequisites
echo "[0/10] Checking prerequisites..."
command -v git >/dev/null 2>&1 || error_exit "git is not installed"
command -v gh >/dev/null 2>&1 || error_exit "gh (GitHub CLI) is not installed"
command -v curl >/dev/null 2>&1 || error_exit "curl is not installed"

# Check gh authentication
if ! gh auth status >/dev/null 2>&1; then
    error_exit "gh CLI is not authenticated. Run 'gh auth login' first."
fi

echo "All prerequisites met."
echo "Repository: ${REPO_URL}"
echo "Working directory: ${WORK_DIR}"
echo

# Step 1: Clone the repository
echo "[1/10] Cloning repository to ${WORK_DIR}..."
if ! git clone "${REPO_URL}" "${WORK_DIR}"; then
    error_exit "Failed to clone repository from ${REPO_URL}"
fi

# Change to working directory
cd "${WORK_DIR}" || error_exit "Failed to change to working directory"

# Detect the default branch
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Check if we're already on temp-clean branch (from a previous failed run)
CURRENT_DEFAULT=$(gh repo view "${REPO_OWNER}/${REPO_NAME}" --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo "")

if [ "${CURRENT_DEFAULT}" = "${TEMP_BRANCH}" ]; then
    echo "WARNING: Default branch is already '${TEMP_BRANCH}' from a previous run."
    echo "         Attempting to restore '${MAIN_BRANCH}' as default..."

    if gh repo edit "${REPO_OWNER}/${REPO_NAME}" --default-branch "${MAIN_BRANCH}" 2>/dev/null; then
        echo "         Successfully restored '${MAIN_BRANCH}' as default branch."
    else
        echo "         Failed to restore. Will attempt to clean up temp branch..."
    fi

    # Try to delete the leftover temp branch
    if git ls-remote --heads origin "${TEMP_BRANCH}" | grep -q "${TEMP_BRANCH}"; then
        echo "         Deleting leftover '${TEMP_BRANCH}' branch..."
        git push origin --delete "${TEMP_BRANCH}" 2>/dev/null || true
    fi
fi

echo "Repository cloned successfully."
echo "Detected default branch: ${MAIN_BRANCH}"
echo

# Step 2: Check for Claude-attributed commits and remove them
echo "[2/10] Checking for Claude-attributed commits..."
CLAUDE_COMMITS=$(git log --all --grep="Co-Authored-By: Claude" --format="%H" 2>/dev/null || echo "")

if [ -n "${CLAUDE_COMMITS}" ]; then
    echo "Found Claude-attributed commits. Removing Claude attribution from commit messages..."

    # Use filter-branch to remove Co-Authored-By: Claude lines
    if ! FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --msg-filter '
        sed "/Co-Authored-By: Claude/d" |
        sed "/Generated with \[Claude Code\]/d" |
        sed "/^\s*$/d" |
        awk "NF"
    ' --tag-name-filter cat -- --all; then
        error_exit "Failed to filter commit messages"
    fi

    # Clean up filter-branch refs
    rm -rf .git/refs/original/
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive

    echo "[3/10] Pushing cleaned history to remote..."
    if ! git push --force --all; then
        error_exit "Failed to push cleaned commits"
    fi
    if ! git push --force --tags; then
        error_exit "Failed to push cleaned tags"
    fi

    echo "Claude attribution removed from all commits."
else
    echo "No Claude-attributed commits found."
fi
echo

# Step 3: Create orphan branch with single commit
echo "[4/10] Creating temporary orphan branch '${TEMP_BRANCH}'..."
if ! git checkout --orphan "${TEMP_BRANCH}"; then
    error_exit "Failed to create orphan branch"
fi

echo "[5/10] Clearing staging area and creating placeholder..."
git rm -rf . 2>/dev/null || true
echo "cleanup" > .placeholder
git add .placeholder
if ! git commit -m "Force reindex (temporary default)"; then
    error_exit "Failed to commit placeholder"
fi

echo "[6/10] Pushing temporary branch to remote..."
if ! git push -f origin "${TEMP_BRANCH}"; then
    error_exit "Failed to push temporary branch"
fi

# Step 4: Change default branch using gh CLI
echo "[7/10] Setting default branch to '${TEMP_BRANCH}' (forces GitHub reindex)..."
if ! gh repo edit "${REPO_OWNER}/${REPO_NAME}" --default-branch "${TEMP_BRANCH}"; then
    error_exit "Failed to set default branch to ${TEMP_BRANCH}"
fi

echo "Waiting 10 seconds for GitHub to reindex..."
sleep 10

# Step 5: Verify Claude is removed from contributors
echo "[8/10] Checking if Claude has been removed from contributors..."
CONTRIBUTORS_HTML=$(curl -sL "${GITHUB_URL}" 2>/dev/null || echo "")

if [ -z "${CONTRIBUTORS_HTML}" ]; then
    echo "WARNING: Failed to fetch GitHub page. Cannot verify contributor removal."
elif echo "${CONTRIBUTORS_HTML}" | grep -q 'href="https://github.com/claude"'; then
    echo "WARNING: Claude still appears in contributors. GitHub may need more time to reindex."
    echo "         Check: ${GITHUB_URL}"
else
    echo "SUCCESS: Claude no longer appears in contributors list!"
fi

# Step 6: Restore main as default branch
echo "[9/10] Restoring '${MAIN_BRANCH}' as default branch..."
if ! gh repo edit "${REPO_OWNER}/${REPO_NAME}" --default-branch "${MAIN_BRANCH}"; then
    error_exit "Failed to restore default branch to ${MAIN_BRANCH}"
fi

# Step 7: Clean up temporary branch
echo "[10/10] Cleaning up temporary branch..."
if ! git checkout "${MAIN_BRANCH}"; then
    error_exit "Failed to checkout main branch"
fi

echo "Deleting temporary branch from remote..."
if ! git push origin --delete "${TEMP_BRANCH}"; then
    echo "WARNING: Failed to delete remote temporary branch"
fi

echo "Deleting local temporary branch..."
git branch -D "${TEMP_BRANCH}" 2>/dev/null || true

echo
echo "=========================================="
echo "Cleanup complete!"
echo "=========================================="
echo "Visit ${GITHUB_URL} to verify contributors list."
echo
echo "Note: GitHub's contributor cache may take a few minutes to fully update."
echo "If Claude still appears, the cache will eventually refresh."
echo
