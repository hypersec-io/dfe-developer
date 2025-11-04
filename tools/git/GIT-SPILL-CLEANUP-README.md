# Git Data Spill Cleanup Utility

## Overview

The Git Data Spill Cleanup Utility is a comprehensive tool for safely removing sensitive data that was accidentally committed to git history. It uses git-filter-repo (modern, officially recommended tool) and provides automatic backups to prevent data loss.

## What is a Git Data Spill?

A "data spill" occurs when sensitive information is accidentally committed to a git repository, including:

- **Credentials**: API keys, passwords, access tokens, client secrets
- **Configuration files**: `.env` files, `secrets.yml`, `credentials.json`
- **Private keys**: SSH keys (id_rsa), TLS certificates (.pem, .key)
- **Personal data**: PII, customer data, internal documents
- **Proprietary code**: Trade secrets, internal algorithms
- **AI assistant artifacts**: `.claude/`, `CLAUDE.md`, `.cursor/`, `.codex/`, etc.

Even after removing the file in a new commit, the sensitive data remains in git history and can be accessed by anyone with repository access.

## Prerequisites

### Required Tools

#### git-filter-repo (Required)

Modern, fast, and safe replacement for `git filter-branch` (officially recommended by GitHub):

```bash
# macOS (Homebrew)
brew install git-filter-repo

# Ubuntu/Debian
sudo apt update
sudo apt install git-filter-repo

# Fedora/RHEL
sudo dnf install git-filter-repo

# Using pip (any platform)
pip install --user git-filter-repo
# Or with pipx:
pipx install git-filter-repo

# From source
curl -O https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo
chmod +x git-filter-repo
sudo mv git-filter-repo /usr/local/bin/
```

**Note:** If git-filter-repo is not installed, the script will display friendly installation guidance with platform-specific instructions.

### Repository Requirements

- Clean working directory (no uncommitted changes)
- Git repository with commit access
- Backup space in `~/.git-spill-backups/`

## Usage

### Quick Start

```bash
# Navigate to your repository
cd /path/to/your/repo

# List potentially sensitive files in history
./tools/git/git-spill-cleanup.sh --list

# Remove a specific file (dry run first)
./tools/git/git-spill-cleanup.sh --file .env --dry-run

# Actually remove it
./tools/git/git-spill-cleanup.sh --file .env

# Remove entire directory and all contents
./tools/git/git-spill-cleanup.sh --directory .claude

# Remove all AI assistant artifacts
./tools/git/git-spill-cleanup.sh --ai

# Force push changes
git push origin --force --all
```

### Command Line Options

```
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
```

## Common Scenarios

### Scenario 1: Removed .env File

You committed a `.env` file with database passwords:

```bash
# 1. Check what will be removed
./tools/git/git-spill-cleanup.sh --file .env --dry-run

# 2. Create backup and remove
./tools/git/git-spill-cleanup.sh --file .env

# 3. Review changes
git log --oneline --all

# 4. Force push
git push origin --force --all
git push origin --force --tags

# 5. Rotate all credentials in that .env file!
```

### Scenario 2: AWS Keys in Config File

You committed AWS credentials in `config/aws.yml`:

```bash
# Remove the specific file
./tools/git/git-spill-cleanup.sh --file config/aws.yml

# Force push
git push origin --force --all

# Rotate AWS keys immediately
aws iam delete-access-key --access-key-id AKIAIOSFODNN7EXAMPLE
```

### Scenario 3: API Key Hardcoded in Source

You hardcoded an API key like `sk-abc123secretkey` in source code:

```bash
# Remove the string from all files in history
./tools/git/git-spill-cleanup.sh --string "sk-abc123secretkey"

# Force push
git push origin --force --all

# Revoke and regenerate the API key
```

### Scenario 4: Multiple .env Files

You have multiple environment files (`.env`, `.env.local`, `.env.production`):

```bash
# Remove all .env files using pattern
./tools/git/git-spill-cleanup.sh --pattern "*.env*"

# Or remove each one explicitly
./tools/git/git-spill-cleanup.sh --file .env
./tools/git/git-spill-cleanup.sh --file .env.local
./tools/git/git-spill-cleanup.sh --file .env.production

# Force push
git push origin --force --all
```

### Scenario 5: Private Keys

You committed SSH private keys:

```bash
# Remove all private key files
./tools/git/git-spill-cleanup.sh --pattern "id_rsa*"
./tools/git/git-spill-cleanup.sh --pattern "*.pem"
./tools/git/git-spill-cleanup.sh --pattern "*.key"

# Force push
git push origin --force --all

# Generate new SSH keys
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## How It Works

### Backup Creation

Before any cleanup, the utility creates a complete backup:

1. Creates directory: `~/.git-spill-backups/`
2. Generates git bundle: `repo-name_YYYYMMDD_HHMMSS.bundle`
3. Bundle contains complete history (all branches, tags, refs)

To restore from backup:

```bash
git clone ~/.git-spill-backups/my-repo_20251104_143022.bundle restored-repo
```

### Cleanup Process

#### Using git-filter-repo (Default)

1. **File removal**: Rewrites history excluding specified paths
2. **Pattern removal**: Uses glob patterns to match files
3. **String removal**: Replaces text with `***REMOVED***`
4. **Efficient**: Only processes affected commits

#### Using BFG Repo-Cleaner

1. **File removal**: Deletes files from all commits
2. **Text replacement**: Replaces sensitive strings
3. **Cleanup**: Expires reflog and runs garbage collection
4. **Fast**: Designed for large repositories

### Safety Features

- **Automatic backups**: Can't skip unless `--no-backup` specified
- **Working directory check**: Fails if uncommitted changes exist
- **Dry run mode**: Preview changes before executing
- **Tool verification**: Checks prerequisites before starting
- **Clear warnings**: Shows force-push requirements

## Team Coordination

### Before Cleanup

1. **Notify team**: Warn about upcoming history rewrite
2. **Schedule downtime**: Pick low-activity period
3. **Document**: Record what's being removed and why
4. **Branch protection**: Temporarily disable if enabled

### After Cleanup

1. **Force push**: Update remote repository
2. **Notify team**: Send re-clone instructions
3. **Monitor**: Watch for issues or questions

### Team Re-clone Instructions

Send this to your team:

```
IMPORTANT: Repository history has been rewritten to remove sensitive data.

ACTION REQUIRED:
1. Save any uncommitted work (stash or commit to a branch)
2. Delete your local clone
3. Re-clone the repository:
   git clone <repository-url> <new-directory>
4. Reapply your uncommitted work

DO NOT:
- Do NOT pull or merge (this will bring back old history)
- Do NOT push old branches (will reintroduce sensitive data)

Questions? Contact <your-name>
```

## Security Best Practices

### Immediate Actions

After removing sensitive data:

1. **Rotate credentials**: Assume compromised
2. **Monitor logs**: Check for unauthorized access
3. **Update .gitignore**: Prevent future commits
4. **Review access**: Audit who had repository access

### Prevention

Add to your `.gitignore`:

```gitignore
# Environment files
.env
.env.*
!.env.example

# Credentials
*credentials*
*secrets*
*secret*
*.pem
*.key
*.pfx
*.p12

# SSH keys
id_rsa*
*.ppk

# Cloud provider credentials
.aws/credentials
.azure/credentials
.gcloud/credentials
```

### Pre-commit Hooks

Install tools to prevent commits:

```bash
# Install pre-commit framework
pip install pre-commit

# Add to .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

# Install hooks
pre-commit install
```

## Troubleshooting

### Error: "Not in a git repository"

```bash
# Solution: Navigate to repository root
cd /path/to/your/repo
git rev-parse --git-dir  # Should show .git
```

### Error: "Working directory is not clean"

```bash
# Solution: Commit or stash changes
git status
git add .
git commit -m "Save work before cleanup"
# Or
git stash save "Work in progress"
```

### Error: "git-filter-repo not found"

```bash
# Solution: Install the tool
brew install git-filter-repo  # macOS
pip install git-filter-repo   # Linux
```

### Warning: "File not found in history"

The file may have been committed with a different path or name. Use `--list` to search:

```bash
./tools/git/git-spill-cleanup.sh --list
```

### Force Push Rejected

If branch protection is enabled:

```bash
# GitHub: Settings → Branches → Disable protection temporarily
# GitLab: Settings → Repository → Protected branches → Unprotect

# After force push, re-enable protection
```

### Large Repository Takes Too Long

For repositories > 1GB:

```bash
# Use BFG (faster for large repos)
./tools/git/git-spill-cleanup.sh --file .env --tool bfg

# Or filter only specific branches
git filter-repo --path .env --invert-paths --refs refs/heads/main
```

## Limitations

### What This Tool Cannot Do

1. **Cannot recall published data**: If code was public, assume compromised
2. **Cannot fix forks**: Each fork must be cleaned independently
3. **Cannot preserve exact timestamps**: Commits get new SHAs
4. **Cannot protect against determined attackers**: Cached or archived data may exist

### When to Use Alternative Approaches

- **Public repository with many forks**: Consider creating new repo
- **Data already scraped**: Rotate credentials, assume breach
- **Regulatory requirements**: Consult legal team first
- **Large binary files**: Use `git-lfs` migration instead

## Advanced Usage

### Custom Pattern Detection

Create a custom patterns file:

```bash
# patterns.txt
password\s*=\s*["'][^"']+["']
api[_-]?key\s*=\s*["'][^"']+["']
secret[_-]?token\s*=\s*["'][^"']+["']
```

Use with grep to find matches:

```bash
git log -p | grep -f patterns.txt
```

### Batch Operations

Remove multiple files efficiently:

```bash
# Create a script
cat > cleanup-batch.sh << 'EOF'
#!/bin/bash
files=(.env .env.local config/secrets.yml data/passwords.txt)
for file in "${files[@]}"; do
    ./tools/git/git-spill-cleanup.sh --file "$file" --no-backup
done
EOF

chmod +x cleanup-batch.sh
./cleanup-batch.sh
```

### Integration with CI/CD

Prevent sensitive data commits:

```yaml
# .github/workflows/security-scan.yml
name: Security Scan
on: [push, pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history
      - name: Detect secrets
        run: |
          ./tools/git/git-spill-cleanup.sh --list
          # Fail if sensitive files found
```

## References

- [git-filter-repo Documentation](https://github.com/newren/git-filter-repo)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Atlassian: Rewriting history](https://www.atlassian.com/git/tutorials/rewriting-history)

## Support

For issues or questions:

1. Check troubleshooting section above
2. Review git-filter-repo/BFG documentation
3. Create issue in this repository
4. Contact your security team for sensitive incidents

## License

This utility is part of the dfe-developer project. See repository LICENSE for details.
