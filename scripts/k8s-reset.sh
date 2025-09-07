#!/bin/bash

# Kubernetes Reset Script - Resets deployment to previous image
# Part of the Reset to State Zero system

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

echo "Kubernetes Reset Script"
echo "======================"

# Load URLs from environment.conf
SCRIPT_DIR="$(dirname "$0")"
ENV_CONTEXT_FILE="$SCRIPT_DIR/../environment.conf"

if [[ -f "$ENV_CONTEXT_FILE" ]]; then
    source "$ENV_CONTEXT_FILE"
    TARGET_IMAGE="$FLY_REGISTRY_DOMAIN/docker/$DOCKER_BASE_IMAGE_TAG"
    echo "✓ Using $ENV_CONTEXT environment (URLs from environment.conf)"
else
    echo "❌ ERROR: environment.conf not found"
    exit 1
fi


if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY RUN MODE: Will show what would happen"
else
    echo "⚡ EXECUTION MODE: Will make actual changes"
fi

# Configuration
NAMESPACE="default"
DEPLOYMENT_NAME="ascii-frog-app"

# TARGET_IMAGE is constructed from environment.conf values above
echo "🌐 Using registry: $FLY_REGISTRY_DOMAIN"
echo "🐳 Target image: $TARGET_IMAGE"

# KUBECONFIG_FILE is set from environment.conf, construct full path
KUBECONFIG_PATH="$HOME/.kube/$KUBECONFIG_FILE"

# Derive CLUSTER_CONTEXT from KUBECONFIG_FILE (remove file extension)
CLUSTER_CONTEXT="${KUBECONFIG_FILE%.*}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ ERROR: kubectl is not installed"
    echo "Please install kubectl to continue"
    exit 1
fi

# Check if kubeconfig file exists
if [[ ! -f "$KUBECONFIG_PATH" ]]; then
    echo "❌ ERROR: Kubeconfig file not found: $KUBECONFIG_PATH"
    echo "💡 Please ensure the kubeconfig file is located at: ~/.kube/$KUBECONFIG_FILE"
    echo "   Or set up your kubeconfig with: export KUBECONFIG=\$KUBECONFIG:~/.kube/$KUBECONFIG_FILE"
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

# Step 1: Set kubectl context and namespace
echo -e "\n⚙️  Configuring kubectl"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would configure kubectl:"
    echo "  - Set KUBECONFIG=$KUBECONFIG_PATH"
    echo "  - Use context: $CLUSTER_CONTEXT"
    echo "  - Set namespace: $NAMESPACE"
else
    echo "Configuring kubectl..."
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    echo "Setting kubectl context to: $CLUSTER_CONTEXT"
    if ! kubectl config use-context "$CLUSTER_CONTEXT"; then
        echo "❌ ERROR: Failed to set kubectl context to $CLUSTER_CONTEXT"
        exit 1
    fi
    
    echo "Setting namespace to: $NAMESPACE"
    if ! kubectl config set-context --current --namespace="$NAMESPACE"; then
        echo "❌ ERROR: Failed to set namespace to $NAMESPACE"
        exit 1
    fi
    
    echo "Current context: $(kubectl config current-context)"
    echo "Current namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
fi

# Step 2: Check current deployment status
echo -e "\n📊 Checking deployment status"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would check deployment status for: $DEPLOYMENT_NAME"
else
    echo "Checking current deployment status..."
    
    # Set kubeconfig for subsequent commands
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    # First test cluster connectivity
    echo "Testing cluster connectivity..."
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ ERROR: Cannot connect to Kubernetes cluster"
        echo "This could be due to:"
        echo "  1. Missing or incorrect server URL in kubeconfig"
        echo "  2. Network connectivity issues"
        echo "  3. Invalid certificates or authentication"
        echo ""
        echo "Please check your kubeconfig file: $KUBECONFIG_PATH"
        echo "Ensure the 'server' field contains a valid cluster endpoint URL"
        exit 1
    fi
    echo "✓ Cluster connectivity verified"
    
    # Check if deployment exists
    if kubectl get deployment "$DEPLOYMENT_NAME" &> /dev/null; then
        echo "✓ Deployment '$DEPLOYMENT_NAME' found"
        
        CURRENT_IMAGE=$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}')
        echo "Current image: $CURRENT_IMAGE"
        
        REPLICAS=$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.spec.replicas}')
        READY_REPLICAS=$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.status.readyReplicas}')
        echo "Replicas: $READY_REPLICAS/$REPLICAS ready"
    else
        echo "❌ ERROR: Deployment '$DEPLOYMENT_NAME' not found"
        echo "Available deployments:"
        kubectl get deployments
        exit 1
    fi
fi

# Step 3: Update deployment image
echo -e "\n🔄 Resetting deployment image"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would update deployment:"
    echo "  Deployment: $DEPLOYMENT_NAME"
    echo "  Target image: $TARGET_IMAGE"
    echo "  Command: kubectl set image deployment/$DEPLOYMENT_NAME $DEPLOYMENT_NAME=$TARGET_IMAGE"
else
    echo "Updating deployment image..."
    echo "Deployment: $DEPLOYMENT_NAME"
    echo "Target image: $TARGET_IMAGE"
    
    # Set kubeconfig and update the image
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    echo "Executing image update..."
    if ! kubectl set image deployment/"$DEPLOYMENT_NAME" "$DEPLOYMENT_NAME"="$TARGET_IMAGE"; then
        echo "❌ ERROR: Failed to update deployment image"
        exit 1
    fi
    
    echo "Waiting for rollout to complete..."
    if ! kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=300s; then
        echo "❌ ERROR: Deployment rollout failed or timed out"
        exit 1
    fi
fi

# Step 4: Verify deployment
echo -e "\n✅ Verifying deployment"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would verify deployment:"
    echo "  - Check pod status"
else
    echo "Verifying deployment..."
    
    # Set kubeconfig
    export KUBECONFIG="$KUBECONFIG_PATH"
    
    # Check pod status (only running pods)
    running_pods=$(kubectl get pods -l app="$DEPLOYMENT_NAME" --no-headers | grep -c "Running" || echo "0")
    total_pods=$(kubectl get pods -l app="$DEPLOYMENT_NAME" --no-headers | wc -l)
    echo "Pod status: $running_pods/$total_pods running"
    
    # Check deployment status
    kubectl get deployment "$DEPLOYMENT_NAME"
    
    # Verify the image was updated
    UPDATED_IMAGE=$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}')
    echo "Updated image: $UPDATED_IMAGE"
    
    if [[ "$UPDATED_IMAGE" == "$TARGET_IMAGE" ]]; then
        echo "✓ Image successfully updated to target"
    else
        echo "❌ WARNING: Image does not match target"
        echo "Expected: $TARGET_IMAGE"
        echo "Actual: $UPDATED_IMAGE"
    fi
    
fi

echo -e "\n✅ Kubernetes reset completed successfully!"
