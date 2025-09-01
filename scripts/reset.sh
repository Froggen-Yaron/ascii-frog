#!/bin/bash

# Reset to State Zero - Interactive Orchestrator Script
# Interactive selection of components and execution mode

set -euo pipefail

# Initialize variables
RUN_GITHUB=false
RUN_JFROG=false
RUN_K8S=false
DRY_RUN=false

# Interactive component selection
echo "Reset to State Zero"
echo "=============================================="
echo ""
echo "Select what to reset:"
echo "1. Reset All!"
echo "2. Fly (releases cleanup)"
echo "3. Kubernetes (deployment revert)"
echo "4. GitHub (branches, workflows)"
echo "5. Dry-run only"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        RUN_GITHUB=true
        RUN_JFROG=true
        RUN_K8S=true
        DRY_RUN=false
        echo "✅ Selected: Reset All!"
        ;;
    2)
        RUN_JFROG=true
        DRY_RUN=false
        echo "✅ Selected: Fly (releases cleanup)"
        ;;
    3)
        RUN_K8S=true
        DRY_RUN=false
        echo "✅ Selected: Kubernetes (deployment revert)"
        ;;
    4)
        RUN_GITHUB=true
        DRY_RUN=false
        echo "✅ Selected: GitHub (branches, workflows)"
        ;;
    5)
        RUN_GITHUB=true
        RUN_JFROG=true
        RUN_K8S=true
        DRY_RUN=true
        echo "✅ Selected: Dry-run only"
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""

# Check if we're in the right directory
if [[ ! -d ".git" ]]; then
    echo "ERROR: This script must be run from the git repository root"
    exit 1
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_SCRIPT="$SCRIPT_DIR/github-reset.sh"
JFROG_SCRIPT="$SCRIPT_DIR/jfrog-reset.sh"
K8S_SCRIPT="$SCRIPT_DIR/k8s-reset.sh"

# Check if required subscripts exist based on selection
if [[ "$RUN_GITHUB" == "true" && ! -f "$GITHUB_SCRIPT" ]]; then
    echo "ERROR: GitHub reset script not found: $GITHUB_SCRIPT"
    exit 1
fi

if [[ "$RUN_JFROG" == "true" && ! -f "$JFROG_SCRIPT" ]]; then
    echo "ERROR: JFrog reset script not found: $JFROG_SCRIPT"
    exit 1
fi

if [[ "$RUN_K8S" == "true" && ! -f "$K8S_SCRIPT" ]]; then
    echo "ERROR: Kubernetes reset script not found: $K8S_SCRIPT"
    exit 1
fi

# Make selected scripts executable
if [[ "$RUN_GITHUB" == "true" ]]; then
    chmod +x "$GITHUB_SCRIPT"
fi
if [[ "$RUN_JFROG" == "true" ]]; then
    chmod +x "$JFROG_SCRIPT"
fi
if [[ "$RUN_K8S" == "true" ]]; then
    chmod +x "$K8S_SCRIPT"
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

# Final confirmation
if [[ "$DRY_RUN" == "true" ]]; then
    confirm "Proceed with preview of selected operations?"
else
    confirm "This is DESTRUCTIVE and will make changes. Are you sure?"
fi

# Execute selected components
CURRENT_PHASE=1

# Run GitHub reset if selected
if [[ "$RUN_GITHUB" == "true" ]]; then
    echo -e "\n================================================"
    echo "PHASE $CURRENT_PHASE: GitHub Reset"
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
    ((CURRENT_PHASE++))
fi

# Run JFrog/Fly reset if selected
if [[ "$RUN_JFROG" == "true" ]]; then
    echo -e "\n================================================"
    echo "PHASE $CURRENT_PHASE: Fly Reset"
    echo "================================================"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        if bash "$JFROG_SCRIPT" false; then
            echo "Fly reset preview completed successfully"
        else
            echo "ERROR: Fly reset preview failed"
            exit 1
        fi
    else
        if bash "$JFROG_SCRIPT" true; then
            echo "Fly reset completed successfully"
        else
            echo "ERROR: Fly reset failed"
            exit 1
        fi
    fi
    ((CURRENT_PHASE++))
fi

# Run Kubernetes revert if selected
if [[ "$RUN_K8S" == "true" ]]; then
    echo -e "\n================================================"
    echo "PHASE $CURRENT_PHASE: Kubernetes Revert"
    echo "================================================"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        if bash "$K8S_SCRIPT" --dry-run; then
            echo "Kubernetes revert preview completed successfully"
        else
            echo "ERROR: Kubernetes revert preview failed"
            exit 1
        fi
    else
        if bash "$K8S_SCRIPT"; then
            echo "Kubernetes revert completed successfully"
        else
            echo "ERROR: Kubernetes revert failed"
            exit 1
        fi
    fi
    ((CURRENT_PHASE++))
fi

# Final completion
echo -e "\n================================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "RESET TO STATE ZERO PREVIEW COMPLETE"
    echo "================================================"
    echo ""
    echo "Preview completed successfully!"
    echo "To execute the changes, run ./reset and select execution mode."
else
    echo "RESET TO STATE ZERO COMPLETE"
    echo "================================================"
    echo ""
    echo "Selected components have been reset to state zero successfully!"
    echo "Components are ready for demo!"
fi

# Final status
echo -e "\nFinal Status:"
if [[ "$RUN_GITHUB" == "true" ]]; then
    echo "Current branch: $(git branch --show-current)"
    echo "Last commit: $(git log --oneline -1)"
fi
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Reset to State Zero preview completed successfully!"
else
    echo "Reset to State Zero completed successfully!"
fi