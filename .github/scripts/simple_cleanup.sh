#!/bin/bash

# Artifactory configuration
ARTIFACTORY_URL="https://z0flylnp1.jfrogdev.org"
TOKEN="${FLY_TOKEN:-eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJmbzgxOEZDVl9ELWVUbnFsdHlIZndiYnNuSzVETXF3NTZobmFuNnJ4Sk1jIn0.eyJpc3MiOiJqZmZlQDAxazA0NDR6cGp2ZGY5MHZrZ3dramswOWYzIiwic3ViIjoiamZhY0AwMWswNDQ0enBqdmRmOTB2a2d3a2prMDlmMy91c2Vycy9hZG1pbiIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnMvYWRtaW4iLCJhdWQiOiIqQCoiLCJpYXQiOjE3NTYxMDU0NDUsImp0aSI6IjFiZjRjMDBlLTA4YmEtNDg4My04NTYxLWU2ZWY3ZjA2YmIzMSJ9.oOVO8dYv7ja6h6imdgAO4r97P_PftXLZxUPeJtJ4yjB9rpRHFPj_ozZ53FUJ2dpyZ_mJWGGha7pwQoj4Jsad6kgoVVQCtGUKsjl7zp5qs-ruV1BE__3C7lPERrJsQkgOBg7DSbJFCLmDAsQsouyKCTO7sI2m51yL_moJzSFtnIb5YwdwWXJh9KI_RHjT3BgIWmWubqtqvJRgJVzrFlmgi2gRjGqVPmW-zvxG60DVfZ8j-YkFkbXKjr0e1CGMg-1sT5eODEIz-MMtwItCRJUrG8jmy_BQWB8OdtCvZRfuRLrV2L8WzrDH9sMUhG55gNrZQYGEklK3JMMVAks1dDBw2w}"

EXECUTE="${1:-false}"

echo "=== SIMPLE ARTIFACTORY CLEANUP ==="
if [[ "$EXECUTE" == "true" ]]; then
    echo "🔥 EXECUTION MODE"
else
    echo "📋 PREVIEW MODE (use: ./simple_cleanup.sh true)"
fi

# Function to safely call API with retries
safe_api_call() {
    local url="$1"
    local method="${2:-GET}"
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if [[ "$method" == "DELETE" ]]; then
            response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $TOKEN" -X DELETE "$url" 2>/dev/null)
            http_code="${response: -3}"
            if [[ "$http_code" =~ ^[23] ]]; then
                return 0
            fi
        else
            response=$(curl -s -H "Authorization: Bearer $TOKEN" "$url" 2>/dev/null)
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

# Step 1: Clean up build info using Build API (much more efficient)
echo -e "\n=== STEP 1: BUILD INFO CLEANUP ==="

# Build name to clean up (keeping only 3 oldest builds)
BUILD_NAME="1041291360-🚀 ASCII-Frog Release"
echo "Cleaning up build: $BUILD_NAME"

# 1. Fetch all build numbers using Build API
echo "Fetching build numbers..."
builds_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/build/$BUILD_NAME")
if [[ $? -eq 0 ]] && [[ -n "$builds_response" ]]; then
    # Extract build numbers and sort them (oldest first by build number)
    build_numbers=$(echo "$builds_response" | jq -r '.builds[].uri' 2>/dev/null | sed 's|/||g' | sort -n)
    build_count=$(echo "$build_numbers" | wc -w)
    
    echo "Found $build_count builds for '$BUILD_NAME'"
    
    if [[ $build_count -gt 3 ]]; then
        echo "Build numbers (sorted oldest first):"
        echo "$build_numbers"
        
        # 2. Keep 3 oldest builds
        keep_builds=$(echo "$build_numbers" | head -n 3)
        echo -e "\nKeeping 3 oldest builds:"
        echo "$keep_builds"
        
        # 3. Get builds to delete (everything except the 3 oldest)
        delete_builds=$(echo "$build_numbers" | tail -n +4)
        delete_count=$(echo "$delete_builds" | wc -w)
        
        if [[ $delete_count -gt 0 ]]; then
            echo -e "\nBuilds to delete ($delete_count):"
            echo "$delete_builds"
            
            if [[ "$EXECUTE" == "true" ]]; then
                echo -e "\n🗑️ Deleting builds using bulk delete API..."
                
                # 4. Create JSON payload for bulk delete
                delete_array=$(printf '%s\n' $delete_builds | jq -R . | jq -s .)
                payload=$(jq -n \
                    --arg bn "$BUILD_NAME" \
                    --argjson nums "$delete_array" \
                    '{builds: [{buildName: $bn, buildNumbers: $nums}]}')
                
                echo "Bulk delete payload:"
                echo "$payload" | jq .
                
                # 5. Call bulk delete API
                echo "Calling bulk delete API..."
                delete_response=$(curl -s -w "%{http_code}" \
                    -H "Authorization: Bearer $TOKEN" \
                    -H "Content-Type: application/json" \
                    -X POST \
                    -d "$payload" \
                    "$ARTIFACTORY_URL/artifactory/api/build/delete" 2>/dev/null)
                
                http_code="${delete_response: -3}"
                response_body="${delete_response%???}"
                
                echo "Delete API response code: $http_code"
                echo "Delete API response: $response_body"
                
                if [[ "$http_code" =~ ^[23] ]]; then
                    echo "✅ Successfully deleted $delete_count builds"
                else
                    echo "❌ Failed to delete builds (HTTP $http_code)"
                fi
            else
                echo -e "\n📋 PREVIEW MODE: Would delete $delete_count builds"
                echo "$delete_builds" | while read build_num; do
                    echo "  Would delete: $BUILD_NAME #$build_num"
                done
            fi
        else
            echo "No builds to delete"
        fi
    else
        echo "Only $build_count builds found. Not deleting any (≤3)."
        if [[ $build_count -gt 0 ]]; then
            echo "Existing builds:"
            echo "$build_numbers"
        fi
    fi
else
    echo "No builds found for '$BUILD_NAME' or error accessing build API"
fi

# Step 2: Clean up NPM packages
echo -e "\n=== STEP 2: NPM CLEANUP ==="

# Clean up backend packages
echo "Cleaning up backend packages..."
npm_backend_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/")
if [[ $? -eq 0 ]] && [[ -n "$npm_backend_response" ]]; then
    npm_backend_packages=$(echo "$npm_backend_response" | jq -r '.children[] | select(.folder == false) | .uri' 2>/dev/null | sed 's|^/||')
    npm_backend_count=$(echo "$npm_backend_packages" | wc -l)
    echo "Found $npm_backend_count backend NPM packages"
    
    if [[ $npm_backend_count -gt 3 ]]; then
        echo "Getting timestamps for backend packages (this may take a while)..."
        temp_npm_backend=$(mktemp)
        
        echo "$npm_backend_packages" | while read package; do
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
            
            echo -e "\nKeeping 3 oldest backend NPM packages:"
            head -3 "${temp_npm_backend}_sorted"
            
            echo -e "\nDeleting backend NPM packages:"
            tail -n +4 "${temp_npm_backend}_sorted" | while read timestamp package; do
                if [[ "$EXECUTE" == "true" ]]; then
                    echo "🗑️ Deleting backend: $package"
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/$package" "DELETE"
                else
                    echo "Would delete backend: $package"
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
    npm_frontend_count=$(echo "$npm_frontend_packages" | wc -l)
    echo "Found $npm_frontend_count frontend NPM packages"
    
    if [[ $npm_frontend_count -gt 3 ]]; then
        echo "Getting timestamps for frontend packages (this may take a while)..."
        temp_npm_frontend=$(mktemp)
        
        echo "$npm_frontend_packages" | while read package; do
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
            
            echo -e "\nKeeping 3 oldest frontend NPM packages:"
            head -3 "${temp_npm_frontend}_sorted"
            
            echo -e "\nDeleting frontend NPM packages:"
            tail -n +4 "${temp_npm_frontend}_sorted" | while read timestamp package; do
                if [[ "$EXECUTE" == "true" ]]; then
                    echo "🗑️ Deleting frontend: $package"
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/$package" "DELETE"
                else
                    echo "Would delete frontend: $package"
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
echo -e "\n=== STEP 3: DOCKER CLEANUP ==="
docker_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-docker-local/ascii-frog-app/")
if [[ $? -eq 0 ]] && [[ -n "$docker_response" ]]; then
    docker_tags=$(echo "$docker_response" | jq -r '.children[] | select(.folder == true) | .uri' 2>/dev/null | sed 's|^/||' | grep -v '^_' | grep -v '^yahav$')
    docker_count=$(echo "$docker_tags" | wc -l)
    echo "Found $docker_count Docker images"
    
    if [[ $docker_count -gt 3 ]]; then
        echo "Getting timestamps (this may take a while)..."
        temp_docker=$(mktemp)
        
        echo "$docker_tags" | while read tag; do
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
            
            echo -e "\nKeeping 3 oldest Docker images:"
            head -3 "${temp_docker}_sorted"
            
            echo -e "\nDeleting Docker images:"
            tail -n +4 "${temp_docker}_sorted" | while read timestamp tag; do
                if [[ "$EXECUTE" == "true" ]]; then
                    echo "🗑️ Deleting: $tag"
                    safe_api_call "$ARTIFACTORY_URL/artifactory/p1-docker-local/ascii-frog-app/$tag/" "DELETE"
                else
                    echo "Would delete: $tag"
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

echo -e "\n=== CLEANUP COMPLETE ==="