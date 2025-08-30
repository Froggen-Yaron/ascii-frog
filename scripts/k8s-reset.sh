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

if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY RUN MODE: Will show what would happen"
else
    echo "⚡ EXECUTION MODE: Will make actual changes"
fi

# Configuration
CLUSTER_CONTEXT="fly-k8s-prod-demo"
NAMESPACE="default"
DEPLOYMENT_NAME="ascii-frog-app"
TARGET_IMAGE="p1-flylnp1.jfrogdev.org/docker/ascii-frog-app:2025.08.28-14.52.53-b"
SERVICE_URL="http://ec2-34-225-1-15.compute-1.amazonaws.com:30080/"
KUBECONFIG_FILE="$(dirname "$0")/fly-k8s-prod-demo.conf"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ ERROR: kubectl is not installed"
    echo "Please install kubectl to continue"
    exit 1
fi

# Check if kubeconfig file exists
if [[ ! -f "$KUBECONFIG_FILE" ]]; then
    echo "❌ ERROR: Kubeconfig file not found: $KUBECONFIG_FILE"
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
echo -e "\nSTEP 1: Configure kubectl context and namespace"
echo "=============================================="

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would configure kubectl:"
    echo "  - Set KUBECONFIG=$KUBECONFIG_FILE"
    echo "  - Use context: $CLUSTER_CONTEXT"
    echo "  - Set namespace: $NAMESPACE"
else
    echo "Configuring kubectl..."
    export KUBECONFIG="$KUBECONFIG_FILE"
    
    echo "Setting kubectl context to: $CLUSTER_CONTEXT"
    kubectl config use-context "$CLUSTER_CONTEXT"
    
    echo "Setting namespace to: $NAMESPACE"
    kubectl config set-context --current --namespace="$NAMESPACE"
    
    echo "Current context: $(kubectl config current-context)"
    echo "Current namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
fi

# Step 2: Check current deployment status
echo -e "\nSTEP 2: Check current deployment status"
echo "======================================"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would check deployment status for: $DEPLOYMENT_NAME"
else
    echo "Checking current deployment status..."
    
    # Set kubeconfig for subsequent commands
    export KUBECONFIG="$KUBECONFIG_FILE"
    
    # First test cluster connectivity
    echo "Testing cluster connectivity..."
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ ERROR: Cannot connect to Kubernetes cluster"
        echo "This could be due to:"
        echo "  1. Missing or incorrect server URL in kubeconfig"
        echo "  2. Network connectivity issues"
        echo "  3. Invalid certificates or authentication"
        echo ""
        echo "Please check your kubeconfig file: $KUBECONFIG_FILE"
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
echo -e "\nSTEP 3: Reset deployment to previous image"
echo "========================================="

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
    export KUBECONFIG="$KUBECONFIG_FILE"
    
    echo "Executing image update..."
    kubectl set image deployment/"$DEPLOYMENT_NAME" "$DEPLOYMENT_NAME"="$TARGET_IMAGE"
    
    echo "Waiting for rollout to complete..."
    kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=300s
fi

# Step 4: Verify deployment
echo -e "\nSTEP 4: Verify deployment"
echo "========================"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would verify deployment:"
    echo "  - Check pod status"
    echo "  - Test service availability at: $SERVICE_URL"
else
    echo "Verifying deployment..."
    
    # Set kubeconfig
    export KUBECONFIG="$KUBECONFIG_FILE"
    
    # Check pod status
    echo "Pod status:"
    kubectl get pods -l app="$DEPLOYMENT_NAME" --no-headers
    
    # Check deployment status
    echo -e "\nDeployment status:"
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
    
    # Test service availability
    echo -e "\nTesting service availability..."
    echo "Service URL: $SERVICE_URL"
    
    if command -v curl &> /dev/null; then
        echo "Testing HTTP connectivity..."
        if curl -f -s --connect-timeout 10 "$SERVICE_URL" > /dev/null; then
            echo "✓ Service is accessible at $SERVICE_URL"
        else
            echo "❌ WARNING: Service may not be accessible at $SERVICE_URL"
            echo "Please check manually or wait for deployment to fully complete"
        fi
    else
        echo "⚠️  curl not available - please manually verify at: $SERVICE_URL"
    fi
fi

# Final completion
echo -e "\n================================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "KUBERNETES RESET PREVIEW COMPLETE"
    echo "================================================"
    echo ""
    echo "The following operations would be performed:"
    echo "  - Set kubectl context to $CLUSTER_CONTEXT"
    echo "  - Set namespace to $NAMESPACE"
    echo "  - Update deployment '$DEPLOYMENT_NAME' to image:"
    echo "    $TARGET_IMAGE"
    echo "  - Verify deployment and service accessibility"
    echo ""
    echo "To execute these changes, run: ./scripts/k8s-reset.sh"
else
    echo "KUBERNETES RESET COMPLETE"
    echo "================================================"
    echo ""
    echo "Deployment successfully reset:"
    echo "  - Context: $CLUSTER_CONTEXT"
    echo "  - Namespace: $NAMESPACE"
    echo "  - Deployment: $DEPLOYMENT_NAME"
    echo "  - Image: $TARGET_IMAGE"
    echo "  - Service URL: $SERVICE_URL"
    echo ""
    echo "Deployment is ready for use!"
fi

# Final status
echo -e "\nFinal Status:"
if [[ "$DRY_RUN" == "false" ]]; then
    export KUBECONFIG="$KUBECONFIG_FILE"
    echo "Current context: $(kubectl config current-context)"
    echo "Current namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
    echo "Deployment status: $(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.status.readyReplicas}')/$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.spec.replicas}') replicas ready"
fi
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Kubernetes reset preview completed successfully!"
else
    echo "Kubernetes reset completed successfully!"
fi
