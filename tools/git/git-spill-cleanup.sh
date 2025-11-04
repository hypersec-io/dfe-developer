#!/usr/bin/env bash
#
# Git Data Spill Cleanup Utility
#
# Safely removes sensitive data from git history using git-filter-repo.
#
# WARNING: This tool rewrites git history. Always backup before running!
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory and backup location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.git-spill-backups"

# Default patterns for sensitive data
SENSITIVE_PATTERNS=(
    "*.env"
    "*.env.*"
    ".env.local"
    ".env.production"
    "*credentials*"
    "*secret*"
    "*.pem"
    "*.key"
    "*.pfx"
    "*.p12"
    "id_rsa*"
    "*.ppk"
    "passwords.txt"
    "secrets.yml"
    "secrets.yaml"
)

# AI assistant artifact patterns
AI_PATTERNS=(
    ".claude/"
    ".claude/*"
    "CLAUDE.md"
    "STATE.md"
    ".codex/"
    ".codex/*"
    ".cursor/"
    ".cursor/*"
    ".aider/"
    ".aider/*"
    ".copilot/"
    ".copilot/*"
    "codex.md"
    ".windsurf/"
    ".windsurf/*"
)

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

show_usage() {
    cat << EOF
Git Data Spill Cleanup Utility

Usage: $(basename "$0") [OPTIONS]

Options:
    -f, --file FILE         Remove specific file from history
    -d, --directory DIR     Remove entire directory and all contents from history
    -p, --pattern PATTERN   Remove files matching pattern (e.g., "*.env")
    -s, --string STRING     Remove string/text from all files in history
    -r, --regex REGEX       Remove text matching regex from all files
    -l, --list              List common sensitive files in current history
    -b, --backup            Create backup only (no cleanup)
    --ai                    Remove AI assistant artifacts (.claude, CLAUDE.md, etc.)
    --no-backup             Skip backup creation (dangerous!)
    --dry-run               Show what would be done without doing it
    -h, --help              Show this help message

Examples:
    # Remove specific file from history
    $(basename "$0") --file .env

    # Remove entire directory from history
    $(basename "$0") --directory .claude

    # Remove all AI assistant artifacts
    $(basename "$0") --ai

    # Remove all .env files
    $(basename "$0") --pattern "*.env"

    # Remove API key string from all files
    $(basename "$0") --string "sk-abc123secretkey"

    # List potentially sensitive files
    $(basename "$0") --list

    # Dry run to see what would happen
    $(basename "$0") --file secrets.yml --dry-run

Notes:
    - Requires git-filter-repo (see installation guidance if missing)
    - Always creates a backup before cleanup (in ~/.git-spill-backups/)
    - Requires clean working directory
    - Force push required after cleanup (use with caution!)
    - All contributors must re-clone after force push

EOF
}

show_install_guidance() {
    cat << EOF

${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${YELLOW}  git-filter-repo is required but not installed${NC}
${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

git-filter-repo is a modern, fast, and safe tool for rewriting git
history. It's the officially recommended replacement for git-filter-branch.

${GREEN}Quick Installation:${NC}

  ${BLUE}macOS (Homebrew):${NC}
    brew install git-filter-repo

  ${BLUE}Ubuntu/Debian:${NC}
    sudo apt update
    sudo apt install git-filter-repo

  ${BLUE}Fedora/RHEL:${NC}
    sudo dnf install git-filter-repo

  ${BLUE}Using pip (any platform):${NC}
    pip install --user git-filter-repo
    # Or with pipx:
    pipx install git-filter-repo

  ${BLUE}From source:${NC}
    curl -O https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo
    chmod +x git-filter-repo
    sudo mv git-filter-repo /usr/local/bin/

${GREEN}After installation:${NC}
  Run this script again to continue.

${GREEN}More info:${NC}
  https://github.com/newren/git-filter-repo

${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if in git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository!"
        exit 1
    fi

    # Check working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        log_error "Working directory is not clean. Commit or stash changes first."
        git status --short
        exit 1
    fi

    # Check for git-filter-repo (required)
    if ! command -v git-filter-repo &> /dev/null; then
        log_error "git-filter-repo is not installed!"
        show_install_guidance
        exit 1
    fi

    log_success "Prerequisites OK"
}

create_backup() {
    if [[ "${NO_BACKUP}" == "true" ]]; then
        log_warning "Skipping backup (--no-backup specified)"
        return 0
    fi

    log_info "Creating backup..."

    # Create backup directory
    mkdir -p "${BACKUP_DIR}"

    # Generate backup name with timestamp
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="${BACKUP_DIR}/${repo_name}_${timestamp}.bundle"

    # Create git bundle (complete backup)
    git bundle create "${backup_path}" --all

    log_success "Backup created: ${backup_path}"
    echo "  To restore: git clone ${backup_path} restored-repo"
}

list_sensitive_files() {
    log_info "Scanning history for potentially sensitive files..."
    echo

    local found_any=false

    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        local files=$(git log --all --pretty=format: --name-only --diff-filter=A | \
                     grep -E "$(echo "$pattern" | sed 's/\*/.*/')" | \
                     sort -u 2>/dev/null || true)

        if [[ -n "$files" ]]; then
            found_any=true
            echo -e "${YELLOW}Pattern: ${pattern}${NC}"
            echo "$files" | sed 's/^/  /'
            echo
        fi
    done

    if [[ "$found_any" == "false" ]]; then
        log_success "No obviously sensitive files found in history"
    else
        log_warning "Found potentially sensitive files (see above)"
        echo "Use --file, --directory, or --pattern options to remove them"
    fi
}

list_ai_artifacts() {
    log_info "Scanning history for AI assistant artifacts..."
    echo

    local found_any=false

    for pattern in "${AI_PATTERNS[@]}"; do
        # Remove trailing /* for directory patterns
        local search_pattern="${pattern%/\*}"
        local files=$(git log --all --pretty=format: --name-only --diff-filter=A | \
                     grep -E "^${search_pattern}" | \
                     sort -u 2>/dev/null || true)

        if [[ -n "$files" ]]; then
            found_any=true
            echo -e "${YELLOW}Pattern: ${pattern}${NC}"
            echo "$files" | sed 's/^/  /'
            echo
        fi
    done

    if [[ "$found_any" == "false" ]]; then
        log_success "No AI assistant artifacts found in history"
    else
        log_warning "Found AI assistant artifacts (see above)"
        echo "Use --ai option to remove all AI artifacts at once"
    fi
}

remove_file_by_path() {
    local file_path="$1"

    log_info "Removing file from history: ${file_path}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN: Would remove ${file_path} from all commits"
        return 0
    fi

    git filter-repo --invert-paths --path "${file_path}" --force
    log_success "File removed: ${file_path}"
}

remove_directory() {
    local dir_path="$1"

    # Remove trailing slash if present
    dir_path="${dir_path%/}"

    log_info "Removing directory and all contents from history: ${dir_path}/"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN: Would remove directory ${dir_path}/ and all files within it"
        # Show what would be removed
        git log --all --pretty=format: --name-only --diff-filter=A | \
            grep "^${dir_path}/" | \
            sort -u | sed 's/^/  /'
        return 0
    fi

    # Use path-glob to remove directory and all contents
    git filter-repo --path-glob "${dir_path}/*" --invert-paths --force
    log_success "Directory removed: ${dir_path}/"
}

remove_file_by_pattern() {
    local pattern="$1"

    log_info "Removing files matching pattern: ${pattern}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN: Would remove files matching ${pattern}"
        # Show what would be removed
        git log --all --pretty=format: --name-only --diff-filter=A | \
            grep -E "$(echo "$pattern" | sed 's/\*/.*/')" | \
            sort -u | sed 's/^/  /'
        return 0
    fi

    git filter-repo --path-glob "${pattern}" --invert-paths --force
    log_success "Pattern removed: ${pattern}"
}

remove_ai_artifacts() {
    log_info "Removing all AI assistant artifacts from history..."
    echo

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN: Would remove the following AI artifacts:"
        list_ai_artifacts
        return 0
    fi

    local removed_count=0
    for pattern in "${AI_PATTERNS[@]}"; do
        # Check if pattern exists in history
        local search_pattern="${pattern%/\*}"
        local files=$(git log --all --pretty=format: --name-only --diff-filter=A | \
                     grep -E "^${search_pattern}" | \
                     sort -u 2>/dev/null || true)

        if [[ -n "$files" ]]; then
            log_info "Removing: ${pattern}"
            git filter-repo --path-glob "${pattern}" --invert-paths --force --partial 2>/dev/null || true
            ((removed_count++))
        fi
    done

    if [[ $removed_count -gt 0 ]]; then
        log_success "Removed ${removed_count} AI artifact pattern(s) from history"
    else
        log_info "No AI artifacts found to remove"
    fi
}

remove_string() {
    local string="$1"

    log_info "Removing string from all files in history"
    log_warning "This may take a long time on large repositories..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN: Would remove string: ${string:0:20}..."
        return 0
    fi

    # Create temporary replacement file
    local temp_file=$(mktemp)
    echo "${string}==>" > "${temp_file}"

    git filter-repo --replace-text "${temp_file}" --force
    rm "${temp_file}"
    log_success "String removed and replaced with '***REMOVED***'"
}

show_next_steps() {
    echo
    log_warning "============================================"
    log_warning "IMPORTANT: Next Steps"
    log_warning "============================================"
    echo
    echo "1. Review the changes:"
    echo "   git log --oneline --all"
    echo
    echo "2. Force push to remote (THIS WILL REWRITE HISTORY!):"
    echo "   git push origin --force --all"
    echo "   git push origin --force --tags"
    echo
    echo "3. Notify all team members:"
    echo "   - Everyone must re-clone the repository"
    echo "   - Do NOT merge or pull; it will bring back old history"
    echo "   - Command: git clone <url> <new-directory>"
    echo
    echo "4. If this is a public repository:"
    echo "   - Consider the data already compromised"
    echo "   - Rotate all exposed credentials immediately"
    echo "   - Monitor for unauthorized access"
    echo
    log_warning "Backup location: ${BACKUP_DIR}"
    echo
}

# Main script
main() {
    local ACTION=""
    local TARGET=""
    NO_BACKUP="false"
    DRY_RUN="false"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                ACTION="file"
                TARGET="$2"
                shift 2
                ;;
            -d|--directory)
                ACTION="directory"
                TARGET="$2"
                shift 2
                ;;
            -p|--pattern)
                ACTION="pattern"
                TARGET="$2"
                shift 2
                ;;
            -s|--string)
                ACTION="string"
                TARGET="$2"
                shift 2
                ;;
            -r|--regex)
                ACTION="regex"
                TARGET="$2"
                shift 2
                ;;
            -l|--list)
                ACTION="list"
                shift
                ;;
            -b|--backup)
                ACTION="backup"
                shift
                ;;
            --ai)
                ACTION="ai"
                shift
                ;;
            --no-backup)
                NO_BACKUP="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Show header
    echo
    echo "=========================================="
    echo "  Git Data Spill Cleanup Utility"
    echo "=========================================="
    echo

    # Validate action
    if [[ -z "${ACTION}" ]]; then
        log_error "No action specified"
        show_usage
        exit 1
    fi

    # Special case: list doesn't need prerequisites
    if [[ "${ACTION}" == "list" ]]; then
        check_prerequisites
        list_sensitive_files
        echo
        list_ai_artifacts
        exit 0
    fi

    # Special case: backup only
    if [[ "${ACTION}" == "backup" ]]; then
        check_prerequisites
        create_backup
        exit 0
    fi

    # Check prerequisites for cleanup actions
    check_prerequisites

    # Create backup before any cleanup
    create_backup

    # Perform requested action
    case "${ACTION}" in
        file)
            remove_file_by_path "${TARGET}"
            ;;
        directory)
            remove_directory "${TARGET}"
            ;;
        pattern)
            remove_file_by_pattern "${TARGET}"
            ;;
        string)
            remove_string "${TARGET}"
            ;;
        ai)
            remove_ai_artifacts
            ;;
        regex)
            log_error "Regex replacement not yet implemented"
            exit 1
            ;;
    esac

    # Show next steps if not dry run
    if [[ "${DRY_RUN}" == "false" ]]; then
        show_next_steps
    fi
}

# Run main function
main "$@"
