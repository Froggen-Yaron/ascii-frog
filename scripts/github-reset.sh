#!/bin/bash

# GitHub Reset Script - Handles git operations, branches, and workflows
# Part of the Reset to State Zero system

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

echo "GitHub Reset Script"
echo "=================="

if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY RUN MODE: Will show what would happen"
else
    echo "⚡ EXECUTION MODE: Will make actual changes"
fi

# Configuration
TARGET_BRANCH="main-backup"
REPO_NAME="Frog-Gen/ascii-frog"

# Check if we're in the right directory
if [[ ! -d ".git" ]]; then
    echo "ERROR: This script must be run from the git repository root"
    exit 1
fi

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

# Step 1: Reset Repository to State Zero
echo -e "\nSTEP 1: Reset Repository to State Zero"
echo "======================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would reset repository to state zero..."
    echo "Target branch: $TARGET_BRANCH"
    confirm "Show what resetting main branch to $TARGET_BRANCH would do?"
else
    echo "Resetting repository to state zero..."
    echo "Target branch: $TARGET_BRANCH"
    echo "Proceeding with reset to $TARGET_BRANCH and force push..."
fi

# Configure git (use existing config)
echo "Using existing git configuration..."
echo "Git user: $(git config user.name)"
echo "Git email: $(git config user.email)"

if [[ "$DRY_RUN" == "true" ]]; then
    # Show what would happen
    echo ""
    echo "Would perform these git operations:"
    echo "  1. git fetch origin $TARGET_BRANCH"
    echo "  2. git checkout main"
    echo "  3. git reset --hard origin/$TARGET_BRANCH"
    echo "  4. git push --force origin main"
    echo ""
    echo "Current branch: $(git branch --show-current)"
    echo "Current commit: $(git log --oneline -1)"
    echo "Target commit: $(git log --oneline -1 origin/$TARGET_BRANCH 2>/dev/null || echo 'Unable to fetch target branch info')"
else
    # Fetch the main-backup branch
    echo "Fetching $TARGET_BRANCH branch..."
    git fetch origin $TARGET_BRANCH

    # Reset to the main-backup branch (state zero)
    echo "Resetting to $TARGET_BRANCH..."
    git checkout main
    git reset --hard origin/$TARGET_BRANCH

    # Force push to main branch to reset it
    echo "Force pushing reset to main branch..."
    git push --force origin main
fi

echo "Repository reset to state zero complete"

# Step 2: Delete add-random-color branches
echo -e "\nSTEP 2: Delete add-random-color branches"
echo "========================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would delete branches with 'add-random-color' in name..."
else
    echo "Deleting branches with 'add-random-color' in name..."
fi

# Fetch all branches and prune deleted ones (always do this to get current state)
echo "Fetching current branch information..."
git fetch --all --prune

# Find remote branches with 'add-random-color' in name (directly from remote)
echo "Finding remote branches with 'add-random-color' on GitHub..."
REMOTE_BRANCHES=$(git ls-remote --heads origin | grep "add-random-color" | sed 's|.*refs/heads/||' || true)

if [ -n "$REMOTE_BRANCHES" ]; then
    echo "Found remote branches:"
    echo "$REMOTE_BRANCHES"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        echo "Would delete these branches from GitHub:"
        for branch in $REMOTE_BRANCHES; do
            echo "  - origin/$branch"
        done
    else
        echo "Proceeding to delete these branches from GitHub..."
        
        for branch in $REMOTE_BRANCHES; do
            echo "Deleting remote branch: $branch"
            git push origin --delete "$branch" || echo "WARNING: Could not delete remote branch $branch"
        done
    fi
else
    echo "No remote branches with 'add-random-color' found"
fi

echo "Branch cleanup complete"

# Step 3: Clean up workflow runs
echo -e "\nSTEP 3: Clean up workflow runs"
echo "=============================="
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would clean up old workflow runs..."
else
    echo "Cleaning up old workflow runs..."
fi

# Check if gh CLI is available and authenticated
if ! command -v gh &> /dev/null; then
    echo "WARNING: GitHub CLI (gh) is not installed"
    echo "Install it with: brew install gh (on macOS) or visit https://cli.github.com/"
    echo "Skipping workflow cleanup"
elif ! gh auth status &> /dev/null; then
    echo "WARNING: GitHub CLI is not authenticated"
    echo "Authenticate with: gh auth login"
    echo "Skipping workflow cleanup"
else
    # Get workflow runs specifically for release.yml
    echo "Fetching release.yml workflow runs using GitHub CLI..."
    RELEASE_RUNS=$(gh run list --repo "$REPO_NAME" --workflow "release.yml" --json databaseId,createdAt,conclusion --limit 100 2>/dev/null || true)
    
    if [[ -n "$RELEASE_RUNS" && "$RELEASE_RUNS" != "[]" ]]; then
        # Sort by creation date (oldest first) and get runs to delete (skip first 3)
        RUNS_TO_DELETE=$(echo "$RELEASE_RUNS" | jq -r 'sort_by(.createdAt) | .[3:] | .[].databaseId' 2>/dev/null || true)
        TOTAL_RELEASE_RUNS=$(echo "$RELEASE_RUNS" | jq -r 'length' 2>/dev/null || echo "0")
        
        echo "Found $TOTAL_RELEASE_RUNS release.yml workflow runs"
        
        if [[ -n "$RUNS_TO_DELETE" && "$RUNS_TO_DELETE" != "" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                # Show what would be deleted
                echo "Would delete old release.yml workflow runs (keeping 3 oldest):"
                COUNT=0
                for run_id in $RUNS_TO_DELETE; do
                    # Get run details for display
                    run_info=$(echo "$RELEASE_RUNS" | jq -r ".[] | select(.databaseId == $run_id) | \"\(.createdAt) (\(.conclusion // \"unknown\"))\"" 2>/dev/null || echo "unknown")
                    echo "  - Would delete run: $run_id ($run_info)"
                    COUNT=$((COUNT + 1))
                done
                echo "Would clean up $COUNT release.yml workflow runs"
            else
                # Delete old release.yml workflow runs
                echo "Deleting old release.yml workflow runs (keeping 3 oldest)..."
                COUNT=0
                for run_id in $RUNS_TO_DELETE; do
                    # Get run details for display
                    run_info=$(echo "$RELEASE_RUNS" | jq -r ".[] | select(.databaseId == $run_id) | \"\(.createdAt) (\(.conclusion // \"unknown\"))\"" 2>/dev/null || echo "unknown")
                    echo "Deleting release.yml run: $run_id ($run_info)"
                    gh run delete "$run_id" --repo "$REPO_NAME" || echo "WARNING: Could not delete run $run_id"
                    COUNT=$((COUNT + 1))
                done
                
                echo "Cleaned up $COUNT release.yml workflow runs"
            fi
        else
            echo "Only 3 or fewer release.yml workflow runs found. Not deleting any."
        fi
    else
        echo "No release.yml workflow runs found"
    fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "\nGitHub reset preview completed successfully!"
    echo "Current git status (unchanged):"
else
    echo -e "\nGitHub reset completed successfully!"
    echo "Final git status:"
fi
echo "Current branch: $(git branch --show-current)"
echo "Last commit: $(git log --oneline -1)"
