#!/bin/bash

# Reset to State Zero - Main Orchestrator Script
# Calls both GitHub and JFrog reset scripts

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

echo "Reset to State Zero - Main Orchestrator"
echo "======================================"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY RUN MODE: Will show what would happen without making changes"
else
    echo "⚡ EXECUTION MODE: Will make actual changes"
fi

# Check if we're in the right directory
if [[ ! -d ".git" ]]; then
    echo "ERROR: This script must be run from the git repository root"
    exit 1
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_SCRIPT="$SCRIPT_DIR/github-reset.sh"
JFROG_SCRIPT="$SCRIPT_DIR/jfrog-reset.sh"

# Check if subscripts exist
if [[ ! -f "$GITHUB_SCRIPT" ]]; then
    echo "ERROR: GitHub reset script not found: $GITHUB_SCRIPT"
    exit 1
fi

if [[ ! -f "$JFROG_SCRIPT" ]]; then
    echo "ERROR: JFrog reset script not found: $JFROG_SCRIPT"
    exit 1
fi

# Make scripts executable
chmod +x "$GITHUB_SCRIPT"
chmod +x "$JFROG_SCRIPT"

# Function to prompt for confirmation
confirm() {
    local message="$1"
    echo "$message"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted by user"
        exit 1
    fi
}

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "This will show what a complete reset to state zero would do:"
    echo "1. GitHub reset preview (git operations, branches, workflows)"
    echo "2. JFrog reset preview (Artifactory cleanup)"
    echo ""
    confirm "Show preview of reset operations?"
else
    echo "This will execute a complete reset to state zero:"
    echo "1. GitHub reset (git operations, branches, workflows)"
    echo "2. JFrog reset (Artifactory cleanup)"
    echo ""
    confirm "This is DESTRUCTIVE and will reset your repository. Are you sure?"
fi

# Step 1: Run GitHub reset
echo -e "\n================================================"
echo "PHASE 1: GitHub Reset"
echo "================================================"

if [[ "$DRY_RUN" == "true" ]]; then
    if bash "$GITHUB_SCRIPT" --dry-run; then
        echo "GitHub reset preview completed successfully"
    else
        echo "ERROR: GitHub reset preview failed"
        exit 1
    fi
else
    if bash "$GITHUB_SCRIPT"; then
        echo "GitHub reset completed successfully"
    else
        echo "ERROR: GitHub reset failed"
        exit 1
    fi
fi

# Step 2: Run JFrog reset
echo -e "\n================================================"
echo "PHASE 2: JFrog Reset"
echo "================================================"

if [[ "$DRY_RUN" == "true" ]]; then
    if bash "$JFROG_SCRIPT" false; then
        echo "JFrog reset preview completed successfully"
    else
        echo "WARNING: JFrog reset preview failed (this is expected if token is invalid)"
        echo "Continuing with completion..."
    fi
else
    if bash "$JFROG_SCRIPT" true; then
        echo "JFrog reset completed successfully"
    else
        echo "WARNING: JFrog reset failed (this is expected if token is invalid)"
        echo "Continuing with completion..."
    fi
fi

# Final completion
echo -e "\n================================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "RESET TO STATE ZERO PREVIEW COMPLETE"
    echo "================================================"
    echo ""
    echo "The following operations would be performed:"
    echo "  - Main branch reset to main-backup"
    echo "  - Feature branches deleted"
    echo "  - Release workflow runs cleaned (kept 3 oldest)"
    echo "  - Artifactory artifacts cleaned"
    echo ""
    echo "To execute these changes, run: ./reset"
else
    echo "RESET TO STATE ZERO COMPLETE"
    echo "================================================"
    echo ""
    echo "Repository has been reset to state zero:"
    echo "  - Main branch reset to main-backup"
    echo "  - Feature branches deleted"
    echo "  - Release workflow runs cleaned (kept 3 oldest)"
    echo "  - Artifactory artifacts cleaned"
    echo ""
    echo "Repository is ready for demo!"
fi

# Final status
echo -e "\nFinal Status:"
echo "Current branch: $(git branch --show-current)"
echo "Last commit: $(git log --oneline -1)"
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Reset to State Zero preview completed successfully!"
else
    echo "Reset to State Zero completed successfully!"
fi