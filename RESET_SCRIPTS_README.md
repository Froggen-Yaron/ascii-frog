# Reset to State Zero - Script Suite

Three modular scripts to reset your repository to "state zero" - perfect for demos and clean starts.

## Scripts Overview

### 1. `reset` - Main Launcher
**Simple launcher script that calls the main orchestrator**
- Located in repository root for easy access
- Calls the main orchestrator script in scripts/

### 2. `scripts/reset.sh` - Main Orchestrator
**The main script that calls the other two**
- Runs GitHub reset first, then JFrog reset
- Provides overall progress and confirmation prompts
- **This is the actual reset logic**

### 3. `scripts/github-reset.sh` - GitHub Operations  
**Handles all GitHub/Git operations**
- Resets main branch to main-backup
- Deletes feature branches (add-random-color)
- Cleans up release.yml workflow runs (keeps 3 oldest by creation date)
- Requires: Git repository, push permissions
- Optional: GitHub CLI (`gh`) for workflow cleanup

### 4. `scripts/jfrog-reset.sh` - JFrog Artifactory Cleanup
**Handles Artifactory artifact cleanup with timestamp-based sorting**
- Deep cleans build info (goes into each build directory and cleans JSON files by age)
- Cleans NPM packages (backend/frontend) keeping 3 oldest by timestamp
- Cleans Docker images keeping 3 oldest by timestamp  
- Comprehensive error handling and detailed logging
- Uses temporary files for robust timestamp sorting

## Usage

### Quick Start (Most Common)
```bash
cd /path/to/ascii-frog
./reset --dry-run    # Preview what would happen
./reset              # Execute the reset
```

### Individual Scripts
```bash
# Only GitHub operations (preview)
./scripts/github-reset.sh --dry-run

# Only GitHub operations (execute)
./scripts/github-reset.sh

# Only JFrog cleanup (preview mode)
./scripts/jfrog-reset.sh

# JFrog cleanup (execution mode)
./scripts/jfrog-reset.sh true
```

### With GitHub CLI (Full Functionality)
```bash
# Authenticate GitHub CLI (one-time setup)
gh auth login

# Run reset with full workflow cleanup
./reset
```

## What Each Script Does

### GitHub Reset (`scripts/github-reset.sh`)
1. **Repository Reset**: Resets main → main-backup  
2. **Branch Cleanup**: Deletes add-random-color branches
3. **Release Workflow Cleanup**: Removes old release.yml workflow runs (keeps 3 oldest)

### JFrog Reset (`scripts/jfrog-reset.sh`)  
1. **Build Info Deep Clean**: Enters each ASCII-Frog Release build directory and cleans JSON files by timestamp
2. **NPM Packages**: Sorts backend/frontend packages by creation time, keeps 3 oldest
3. **Docker Images**: Sorts images by creation time, keeps 3 oldest
4. **Timestamp-Based**: Uses actual creation timestamps for proper age-based cleanup
5. **Preview Mode**: Shows detailed breakdown of what would be deleted

### Main Orchestrator (`scripts/reset.sh`)
1. **Validation**: Checks scripts exist and are executable
2. **GitHub Phase**: Runs complete GitHub reset (repo, branches, release workflows)
3. **JFrog Phase**: Runs JFrog cleanup (builds, packages, images)
4. **Completion**: Shows final status

## Prerequisites

**Required:**
- Git repository (ascii-frog project)
- Push permissions to GitHub repository
- Bash shell (macOS/Linux)

**Optional:**
- `gh` - GitHub CLI for workflow cleanup (install with `brew install gh`)
- `jq` - JSON processor (for JFrog operations)
- `curl` - HTTP client (for API calls)

## Safety Features

- **Dry run mode** - Preview all operations with `--dry-run`
- **Single confirmation** - One prompt before destructive operations
- **Modular design** - run only what you need
- **Preview mode** for JFrog operations
- **Error handling** - continues even if some steps fail
- **Clean output** - no emojis, clear progress indicators

## Dry Run Mode

All scripts support dry run mode to preview operations without making changes:

- **Main script**: `./reset --dry-run`
- **GitHub script**: `./scripts/github-reset.sh --dry-run`
- **JFrog script**: `./scripts/jfrog-reset.sh` (default is preview mode)

In dry run mode:
- Shows exactly what would be executed
- No actual changes are made to Git, GitHub, or JFrog
- Perfect for understanding impact before execution
- Safe to run multiple times

## Examples

**Preview complete reset:**
```bash
./reset --dry-run
```

**Execute complete reset:**
```bash
./reset
```

**Preview GitHub operations only:**
```bash
./scripts/github-reset.sh --dry-run
```

**Execute GitHub operations only:**
```bash
./scripts/github-reset.sh
```

**Preview JFrog cleanup:**
```bash
./scripts/jfrog-reset.sh
```

**Execute JFrog cleanup:**
```bash
./scripts/jfrog-reset.sh true
```

## Troubleshooting

**"Script not found" errors:**
- Make sure you're in the ascii-frog project root
- Check scripts are executable: `ls -la *.sh`

**GitHub operations fail:**
- Verify git credentials and push permissions
- For workflow cleanup: install and authenticate GitHub CLI (`gh auth login`)

**JFrog operations fail:**
- Expected if token is expired (script continues)
- Check network connectivity to z0flylnp1.jfrogdev.org

## Notes

- **Safe to run multiple times** - idempotent operations
- **No dependencies** on GitHub Actions runners
- **Mac optimized** but works on Linux
- **Modular** - use individual scripts as needed
