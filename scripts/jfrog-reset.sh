#!/bin/bash

# JFrog Reset Script - Handles Artifactory cleanup  
# Part of the Reset to State Zero system

set -euo pipefail

echo "JFrog Reset Script"
echo "=================="

# Load environment variables from .env file
if [ -f "$(dirname "$0")/../.env" ]; then
    source "$(dirname "$0")/../.env"
    echo "✓ Loaded environment variables from .env file"
elif [ -f ".env" ]; then
    source ".env"
    echo "✓ Loaded environment variables from .env file"
else
    echo "⚠️  Warning: .env file not found. Please create one with JFROG_TOKEN and ARTIFACTORY_URL"
fi

# Configuration (with fallbacks for backward compatibility)
FLY_REGISTRY_DOMAIN="${FLY_REGISTRY_DOMAIN:-froggen.jfrogdev.org}"
ARTIFACTORY_URL="${ARTIFACTORY_URL:-https://z0flylnp1.jfrogdev.org}"
TOKEN="${JFROG_TOKEN:-$TOKEN}"

echo "🌐 Using Fly registry: $FLY_REGISTRY_DOMAIN"

# Check if token is available
if [ -z "$TOKEN" ]; then
    echo "❌ Error: JFROG_TOKEN not found in environment variables or .env file"
    echo "Please create a .env file in the project root with:"
    echo "JFROG_TOKEN=\"your_token_here\""
    echo "ARTIFACTORY_URL=\"https://z0flylnp1.jfrogdev.org\""
    exit 1
fi

echo "✓ Using Artifactory URL: $ARTIFACTORY_URL"

# Validate JFrog Fly credentials
check_jfrog_creds() {
    echo "🔍 Validating JFrog Fly credentials file..."
    local creds_file="$HOME/.jfrog/fly_creds.json"
    
    if [[ ! -f "$creds_file" ]]; then
        echo "❌ ERROR: JFrog Fly credentials file not found at $creds_file"
        echo "Please run 'jf config add' to set up JFrog credentials"
        exit 1
    fi
    
    if ! jq . "$creds_file" >/dev/null 2>&1; then
        echo "❌ ERROR: JFrog Fly credentials file is not valid JSON"
        exit 1
    fi
    
    local server_url username token
    server_url=$(jq -r '.url // empty' "$creds_file")
    username=$(jq -r '.username // empty' "$creds_file")
    token=$(jq -r '.token // empty' "$creds_file")
    
    if [[ -z "$server_url" ]]; then
        echo "❌ ERROR: JFrog Fly credentials missing server URL"
        exit 1
    fi
    
    if [[ -z "$token" ]]; then
        echo "❌ ERROR: JFrog Fly credentials missing token"
        exit 1
    fi
    
    if [[ "$server_url" != *"$FLY_REGISTRY_DOMAIN"* ]]; then
        echo "❌ ERROR: JFrog Fly credentials URL does not match expected registry"
        echo "Expected: URL containing '$FLY_REGISTRY_DOMAIN'"
        echo "Found: $server_url"
        exit 1
    fi
    
    # Validate expected username
    if [[ "$username" != "yoav" ]]; then
        echo "⚠️  WARNING: JFrog Fly credentials username is not the expected 'yoav'"
        echo "Expected: yoav"
        echo "Found: $username"
        echo "Continuing anyway..."
    fi
    
    echo "✓ JFrog Fly credentials validated successfully"
    echo "  Server: $server_url"
    echo "  Username: $username"
    echo "  Token: [REDACTED - $(echo "$token" | cut -c1-10)...]"
}

check_jfrog_creds

EXECUTE="${1:-false}"

# Platform detection
detect_platform() {
    if [[ "$(uname)" == "Linux" ]]; then
        export CURL_OPTS="--connect-timeout 30 --max-time 300 --retry 3 --retry-delay 2"
        echo "Detected Linux - using enhanced curl options"
    else
        export CURL_OPTS="--connect-timeout 30 --max-time 300"
        echo "Detected macOS - using standard curl options"
    fi
}

detect_platform

echo "=== ARTIFACTORY CLEANUP ==="
if [[ "$EXECUTE" == "true" ]]; then
    echo "EXECUTION MODE: Will actually delete artifacts"
else
    echo "PREVIEW MODE: Will only show what would be deleted"
    echo "Use: $0 true  to execute deletions"
fi

# Function to safely call API with retries
safe_api_call() {
    local url="$1"
    local method="${2:-GET}"
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if [[ "$method" == "DELETE" ]]; then
            response=$(curl -s -w "%{http_code}" $CURL_OPTS -H "Authorization: Bearer $TOKEN" -X DELETE "$url" 2>/dev/null)
            http_code="${response: -3}"
            if [[ "$http_code" =~ ^[23] ]]; then
                return 0
            fi
        else
            response=$(curl -s $CURL_OPTS -H "Authorization: Bearer $TOKEN" "$url" 2>/dev/null)
            # Check if response is valid JSON, but be more lenient
            if echo "$response" | jq . >/dev/null 2>&1; then
                echo "$response"
                return 0
            elif [[ -n "$response" ]]; then
                # If we have a response but it's not valid JSON, still return it
                echo "$response"
                return 0
            fi
        fi
        
        ((retry++))
        echo "Retry $retry/$max_retries for $url" >&2
        sleep 2
    done
    return 1
}

# Test connectivity
echo -e "\nTesting connectivity to Artifactory..."
ping_response=$(curl -s -w "HTTP:%{http_code}" $CURL_OPTS \
    -H "Authorization: Bearer $TOKEN" \
    "$ARTIFACTORY_URL/artifactory/api/system/ping" -o /dev/null 2>/dev/null || echo "CURL_FAILED")

echo "Ping response: $ping_response"

if [[ "$ping_response" == *"HTTP:200"* ]]; then
    echo "Successfully connected to Artifactory"
elif [[ "$ping_response" == *"HTTP:403"* ]]; then
    echo "❌ ERROR: Authentication issue (HTTP 403) - token may be expired"
    echo "Please check your JFROG_TOKEN"
    exit 1
else
    echo "❌ ERROR: Cannot reach Artifactory ($ping_response)"
    echo "Please check your network connection and ARTIFACTORY_URL"
    exit 1
fi

# Step 1: Clean up build info first
echo -e "\n🗂️  Cleaning build info"
builds_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/")
if [[ $? -eq 0 ]] && [[ -n "$builds_response" ]]; then
    # Filter for ASCII-Frog Release build directories (any build containing "ASCII-Frog Release")
    ascii_frog_builds=$(echo "$builds_response" | jq -r '.children[] | select(.folder == true and (.uri | contains("ASCII-Frog Release"))) | .uri' 2>/dev/null | sed 's|^/||')
    echo "ASCII-Frog Release build directories:"
    echo $ascii_frog_builds
    ascii_frog_count=$(echo "$ascii_frog_builds" | grep -c '^..*$' 2>/dev/null || echo "0")
    echo "Found $ascii_frog_count ASCII-Frog Release build directories"
    
    if [[ $ascii_frog_count -gt 0 ]]; then
        echo "Getting timestamps for ASCII-Frog Release builds (this may take a while)..."
        temp_builds=$(mktemp)
        
        echo "$ascii_frog_builds" | while IFS= read -r build_path; do
            if [[ -n "$build_path" ]]; then
                # Try to get build info from the build API first
                build_api_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/build/$build_path")
                echo "Build API response for $build_path:"
                echo "$build_api_response" | head -c 200
                
                # Also try to get storage info - encode the emoji and spaces properly
                encoded_build_path=$(echo "$build_path" | sed 's/🚀/%F0%9F%9A%80/g' | sed 's/ /%20/g')
                build_storage_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path")
                storage_exit_code=$?
                echo "Build storage response for $encoded_build_path:"
                echo "$build_storage_response" | head -c 200
                
                # Try to get timestamp from build API first, then storage
                timestamp=""
                if [[ $? -eq 0 ]] && [[ -n "$build_api_response" ]]; then
                    timestamp=$(echo "$build_api_response" | jq -r '.started // .created // empty' 2>/dev/null)
                    echo "Timestamp from build API: $timestamp"
                fi
                
                if [[ -z "$timestamp" || "$timestamp" == "null" ]]; then
                    if [[ $storage_exit_code -eq 0 ]] && [[ -n "$build_storage_response" ]]; then
                        timestamp=$(echo "$build_storage_response" | jq -r '.created // empty' 2>/dev/null)
                        echo "Timestamp from storage: $timestamp"
                    fi
                fi
                
                if [[ -n "$timestamp" && "$timestamp" != "null" ]]; then
                    echo "$timestamp $build_path" >> "$temp_builds"
                else
                    echo "Could not get timestamp for $build_path, using current time"
                    echo "$(date -u +%Y-%m-%dT%H:%M:%S.000Z) $build_path" >> "$temp_builds"
                fi
                sleep 1
            fi
        done
        
        if [[ -f "$temp_builds" ]]; then
            sort "$temp_builds" > "${temp_builds}_sorted"
            
            echo -e "\nProcessing each build directory to clean up JSON files..."
            
            # Process each build directory
            while read timestamp build_path; do
                if [[ -n "$build_path" ]]; then
                    echo "Processing build: $build_path"
                    
                    # Get the contents of this build directory - encode the emoji and spaces properly
                    encoded_build_path=$(echo "$build_path" | sed 's/🚀/%F0%9F%9A%80/g' | sed 's/ /%20/g')
                    
                    build_contents_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path")
                    contents_exit_code=$?
                    
                    if [[ $contents_exit_code -eq 0 ]] && [[ -n "$build_contents_response" ]]; then
                        # Get all JSON files in this build
                        json_files=$(echo "$build_contents_response" | jq -r '.children[] | select(.folder == false and (.uri | endswith(".json"))) | .uri' 2>/dev/null | sed 's|^/||')
                        json_count=$(echo "$json_files" | grep -c '^..*$' 2>/dev/null || echo "0")
                        echo "  Found $json_count JSON files in $build_path"
                        
                        if [[ $json_count -gt 3 ]]; then
                            echo "  Getting timestamps for JSON files..."
                            temp_json=$(mktemp)
                            
                            echo "$json_files" | while IFS= read -r json_file; do
                                if [[ -n "$json_file" ]]; then
                                    json_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path/$json_file")
                                    if [[ $? -eq 0 ]]; then
                                        json_timestamp=$(echo "$json_response" | jq -r '.created // empty' 2>/dev/null)
                                        if [[ -n "$json_timestamp" && "$json_timestamp" != "null" ]]; then
                                            echo "$json_timestamp $json_file" >> "$temp_json"
                                        fi
                                    fi
                                    sleep 1
                                fi
                            done
                            
                            if [[ -f "$temp_json" ]]; then
                                sort "$temp_json" > "${temp_json}_sorted"
                                
                                kept_count=$(head -3 "${temp_json}_sorted" | wc -l)
                                delete_count=$((json_count - kept_count))
                                echo "    Keeping $kept_count oldest JSON files, deleting $delete_count newer files"
                                tail -n +4 "${temp_json}_sorted" | while read ts json_file; do
                                    if [[ "$EXECUTE" == "true" ]]; then
                                        delete_url="$ARTIFACTORY_URL/artifactory/p1-build-info/$encoded_build_path/$json_file"
                                        delete_response=$(safe_api_call "$delete_url" "DELETE")
                                        sleep 1
                                    fi
                                done
                                
                                rm -f "$temp_json" "${temp_json}_sorted"
                            else
                                echo "    No timestamps collected, temp file not created"
                            fi
                        else
                            echo "  Only $json_count JSON files found. Not deleting any (≤3)."
                        fi
                    else
                        echo "  Error accessing contents of $build_path"
                    fi
                fi
            done < "${temp_builds}_sorted"
            
            rm -f "$temp_builds" "${temp_builds}_sorted"
        fi
    else
        echo "No ASCII-Frog Release build directories found."
    fi
    
    # Show other build directories (non-ASCII-Frog) for reference
    other_builds=$(echo "$builds_response" | jq -r '.children[] | select(.folder == true and (.uri | contains("ASCII-Frog Release") | not)) | .uri' 2>/dev/null | sed 's|^/||')
    other_count=$(echo "$other_builds" | grep -c '^..*$' 2>/dev/null || echo "0")
    if [[ $other_count -gt 0 ]]; then
        echo -e "\nOther build directories (not deleting):"
        echo "$other_builds" | while IFS= read -r build_path; do
            if [[ -n "$build_path" ]]; then
                echo "  - $build_path"
            fi
        done
    fi
else
    echo "No build directories found or error accessing build storage"
fi

# Step 2: Clean up NPM packages
echo -e "\n📦 Cleaning NPM packages"

# Clean up backend packages
echo "Cleaning up backend packages..."
npm_backend_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/")
if [[ $? -eq 0 ]] && [[ -n "$npm_backend_response" ]]; then
    npm_backend_packages=$(echo "$npm_backend_response" | jq -r '.children[] | select(.folder == false) | .uri' 2>/dev/null | sed 's|^/||')
    npm_backend_count=$(echo "$npm_backend_packages" | grep -c '^..*$' 2>/dev/null || echo "0")
    echo "Found $npm_backend_count backend NPM packages"
    
    if [[ $npm_backend_count -gt 3 ]]; then
        echo "Getting timestamps for backend packages (this may take a while)..."
        temp_npm_backend=$(mktemp)
        
        echo "$npm_backend_packages" | while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                pkg_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/$package")
                if [[ $? -eq 0 ]]; then
                    timestamp=$(echo "$pkg_response" | jq -r '.created // empty' 2>/dev/null)
                    if [[ -n "$timestamp" && "$timestamp" != "null" ]]; then
                        echo "$timestamp $package" >> "$temp_npm_backend"
                    fi
                fi
                sleep 1
            fi
        done
        
        if [[ -f "$temp_npm_backend" ]]; then
            sort "$temp_npm_backend" > "${temp_npm_backend}_sorted"
            
            kept_count=$(head -3 "${temp_npm_backend}_sorted" | wc -l)
            delete_count=$((npm_backend_count - kept_count))
            echo "Keeping $kept_count oldest backend packages, deleting $delete_count newer packages"
            
            tail -n +4 "${temp_npm_backend}_sorted" | while read timestamp package; do
                if [[ "$EXECUTE" == "true" ]]; then
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/$package" "DELETE"
                fi
                sleep 1
            done
            
            rm -f "$temp_npm_backend" "${temp_npm_backend}_sorted"
        fi
    else
        echo "Only $npm_backend_count backend packages found. Not deleting any (≤3)."
    fi
else
    echo "No backend NPM packages found or error accessing packages"
fi

# Clean up frontend packages
echo "Cleaning up frontend packages..."
npm_frontend_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/")
if [[ $? -eq 0 ]] && [[ -n "$npm_frontend_response" ]]; then
    npm_frontend_packages=$(echo "$npm_frontend_response" | jq -r '.children[] | select(.folder == false) | .uri' 2>/dev/null | sed 's|^/||')
    npm_frontend_count=$(echo "$npm_frontend_packages" | grep -c '^..*$' 2>/dev/null || echo "0")
    echo "Found $npm_frontend_count frontend NPM packages"
    
    if [[ $npm_frontend_count -gt 3 ]]; then
        echo "Getting timestamps for frontend packages (this may take a while)..."
        temp_npm_frontend=$(mktemp)
        
        echo "$npm_frontend_packages" | while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                pkg_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/$package")
                if [[ $? -eq 0 ]]; then
                    timestamp=$(echo "$pkg_response" | jq -r '.created // empty' 2>/dev/null)
                    if [[ -n "$timestamp" && "$timestamp" != "null" ]]; then
                        echo "$timestamp $package" >> "$temp_npm_frontend"
                    fi
                fi
                sleep 1
            fi
        done
        
        if [[ -f "$temp_npm_frontend" ]]; then
            sort "$temp_npm_frontend" > "${temp_npm_frontend}_sorted"
            
            kept_count=$(head -3 "${temp_npm_frontend}_sorted" | wc -l)
            delete_count=$((npm_frontend_count - kept_count))
            echo "Keeping $kept_count oldest frontend packages, deleting $delete_count newer packages"
            
            tail -n +4 "${temp_npm_frontend}_sorted" | while read timestamp package; do
                if [[ "$EXECUTE" == "true" ]]; then
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/$package" "DELETE"
                fi
                sleep 1
            done
            
            rm -f "$temp_npm_frontend" "${temp_npm_frontend}_sorted"
        fi
    else
        echo "Only $npm_frontend_count frontend packages found. Not deleting any (≤3)."
    fi
else
    echo "No frontend NPM packages found or error accessing packages"
fi

# Step 3: Clean up Docker images
echo -e "\n🐳 Cleaning Docker images"
docker_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-docker-local/ascii-frog-app/")
if [[ $? -eq 0 ]] && [[ -n "$docker_response" ]]; then
    docker_tags=$(echo "$docker_response" | jq -r '.children[] | select(.folder == true) | .uri' 2>/dev/null | sed 's|^/||' | grep -v '^_' | grep -v '^yahav$')
    docker_count=$(echo "$docker_tags" | grep -c '^..*$' 2>/dev/null || echo "0")
    echo "Found $docker_count Docker images"
    
    if [[ $docker_count -gt 3 ]]; then
        echo "Getting timestamps (this may take a while)..."
        temp_docker=$(mktemp)
        
        echo "$docker_tags" | while IFS= read -r tag; do
            if [[ -n "$tag" ]]; then
                tag_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-docker-local/ascii-frog-app/$tag")
                if [[ $? -eq 0 ]]; then
                    timestamp=$(echo "$tag_response" | jq -r '.created // empty' 2>/dev/null)
                    if [[ -n "$timestamp" && "$timestamp" != "null" ]]; then
                        echo "$timestamp $tag" >> "$temp_docker"
                    fi
                fi
                sleep 1
            fi
        done
        
        if [[ -f "$temp_docker" ]]; then
            sort "$temp_docker" > "${temp_docker}_sorted"
            
            kept_count=$(head -3 "${temp_docker}_sorted" | wc -l)
            delete_count=$((docker_count - kept_count))
            echo "Keeping $kept_count oldest Docker images, deleting $delete_count newer images"
            
            tail -n +4 "${temp_docker}_sorted" | while read timestamp tag; do
                if [[ "$EXECUTE" == "true" ]]; then
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-docker-local/ascii-frog-app/$tag/" "DELETE"
                fi
                sleep 1
            done
            
            rm -f "$temp_docker" "${temp_docker}_sorted"
        fi
    else
        echo "Only $docker_count images found. Not deleting any (≤3)."
    fi
else
    echo "No Docker images found or error accessing images"
fi

echo -e "\nJFrog cleanup completed!"
echo "Summary:"
echo "  ASCII-Frog Release builds: ${ascii_frog_count:-0}"
echo "  Backend NPM packages: ${npm_backend_count:-0}"
echo "  Frontend NPM packages: ${npm_frontend_count:-0}"
echo "  Docker images: ${docker_count:-0}"

if [[ "$EXECUTE" == "true" ]]; then
    echo "EXECUTION MODE: Artifacts deleted where > 3 found in each category"
else
    echo "PREVIEW MODE: No artifacts were actually deleted"
fi