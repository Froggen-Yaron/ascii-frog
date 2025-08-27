#!/bin/bash

# Linux AMD64 compatibility settings
set -euo pipefail  # Exit on error, undefined vars, pipe failures
export LC_ALL=C.UTF-8  # Consistent Unicode handling
export LANG=C.UTF-8

# Artifactory configuration
ARTIFACTORY_URL="https://z0flylnp1.jfrogdev.org"
TOKEN="eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJmbzgxOEZDVl9ELWVUbnFsdHlIZndiYnNuSzVETXF3NTZobmFuNnJ4Sk1jIn0.eyJpc3MiOiJqZmZlQDAxazA0NDR6cGp2ZGY5MHZrZ3dramswOWYzIiwic3ViIjoiamZhY0AwMWswNDQ0enBqdmRmOTB2a2d3a2prMDlmMy91c2Vycy9hZG1pbiIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnMvYWRtaW4iLCJhdWQiOiIqQCoiLCJpYXQiOjE3NTYxMDU0NDUsImp0aSI6IjFiZjRjMDBlLTA4YmEtNDg4My04NTYxLWU2ZWY3ZjA2YmIzMSJ9.oOVO8dYv7ja6h6imdgAO4r97P_PftXLZxUPeJtJ4yjB9rpRHFPj_ozZ53FUJ2dpyZ_mJWGGha7pwQoj4Jsad6kgoVVQCtGUKsjl7zp5qs-ruV1BE__3C7lPERrJsQkgOBg7DSbJFCLmDAsQsouyKCTO7sI2m51yL_moJzSFtnIb5YwdwWXJh9KI_RHjT3BgIWmWubqtqvJRgJVzrFlmgi2gRjGqVPmW-zvxG60DVfZ8j-YkFkbXKjr0e1CGMg-1sT5eODEIz-MMtwItCRJUrG8jmy_BQWB8OdtCvZRfuRLrV2L8WzrDH9sMUhG55gNrZQYGEklK3JMMVAks1dDBw2w"

EXECUTE="${1:-false}"

# Linux AMD64 tool detection and compatibility
detect_tools() {
    echo "🔧 Detecting Linux AMD64 tools..."
    
    # Check for required tools
    for tool in curl jq sed grep awk; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "❌ Missing required tool: $tool"
            exit 1
        fi
    done
    
    # Platform-specific tool configuration
    if [[ "$(uname)" == "Linux" ]]; then
        # Linux AMD64 (GitHub runners)
        echo "✅ Detected Linux AMD64 - using GNU tools"
        export CURL_OPTS="--connect-timeout 30 --max-time 300 --retry 3 --retry-delay 2"
        export JQ_OPTS="-r"
        # Ensure we handle large responses properly on Linux
        ulimit -n 4096 2>/dev/null || true
    else
        # macOS compatibility
        echo "✅ Detected macOS - using BSD tools"
        export CURL_OPTS="--connect-timeout 30 --max-time 300"
        export JQ_OPTS="-r"
    fi
}

detect_tools

echo "=== SIMPLE ARTIFACTORY CLEANUP ==="
if [[ "$EXECUTE" == "true" ]]; then
    echo "🔥 EXECUTION MODE"
else
    echo "📋 PREVIEW MODE (use: ./simple_cleanup.sh true)"
fi

# Environment check
echo -e "\n=== ENVIRONMENT CHECK ==="
echo "🌐 Artifactory URL: $ARTIFACTORY_URL"
echo "🔑 Token length: ${#TOKEN} characters"
echo "🔑 Token preview: ${TOKEN:0:30}...${TOKEN: -20}"
echo "🛠️ Curl version: $(curl --version | head -1)"
echo "🔧 JQ version: $(jq --version)"
echo "⚙️ CURL_OPTS: '$CURL_OPTS'"
echo "⚙️ JQ_OPTS: '$JQ_OPTS'"
echo "🐚 Shell: $0 (PID: $$)"
echo "🔧 Bash version: $BASH_VERSION"

# Variable expansion test
echo -e "\n=== VARIABLE EXPANSION TEST ==="
echo "🔍 Testing if shell variable expansion works correctly:"
echo "Raw TOKEN variable: \$TOKEN"
echo "Expanded TOKEN (first 50 chars): ${TOKEN:0:50}..."
echo "Authorization header will be: 'Authorization: Bearer ${TOKEN:0:20}...${TOKEN: -10}'"
echo "CURL_OPTS expanded: '$CURL_OPTS'"

# Connectivity test with Linux AMD64 optimizations
echo -e "\n=== CONNECTIVITY TEST ==="
echo "🔍 Testing basic connectivity to Artifactory..."

# Enhanced connectivity test
echo "🌐 Network diagnostics:"
echo "  Platform: $(uname -a)"
echo "  DNS resolution: $(getent hosts $(echo "$ARTIFACTORY_URL" | sed 's|https://||' | sed 's|/.*||') 2>/dev/null | head -1 || echo 'DNS lookup failed')"

# Test ping endpoint with detailed response
echo "🔍 FULL CURL COMMAND FOR PING:"
echo "curl -s -w \"HTTP:%{http_code} Time:%{time_total}s Size:%{size_download}\" $CURL_OPTS \\"
echo "    -H \"Authorization: Bearer ${TOKEN:0:20}...${TOKEN: -10}\" \\"
echo "    -H \"Accept: application/json\" \\"
echo "    -H \"User-Agent: ascii-frog-cleanup/1.0\" \\"
echo "    \"$ARTIFACTORY_URL/artifactory/api/system/ping\" -o /dev/null"
echo ""

ping_response=$(curl -s -w "HTTP:%{http_code} Time:%{time_total}s Size:%{size_download}" $CURL_OPTS \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    -H "User-Agent: ascii-frog-cleanup/1.0" \
    "$ARTIFACTORY_URL/artifactory/api/system/ping" -o /dev/null 2>/dev/null || echo "CURL_FAILED")

echo "📡 Ping response: $ping_response"

# Extract HTTP code for validation
if [[ "$ping_response" == *"HTTP:200"* ]]; then
    echo "✅ Successfully connected to Artifactory"
elif [[ "$ping_response" == "CURL_FAILED" ]]; then
    echo "❌ CRITICAL: curl command failed completely"
    echo "  This indicates network connectivity issues on Linux AMD64"
elif [[ "$ping_response" == *"HTTP:403"* ]]; then
    echo "⚠️ Authentication issue (HTTP 403)"
elif [[ "$ping_response" == *"HTTP:404"* ]]; then
    echo "⚠️ Ping endpoint not found (HTTP 404)"
else
    echo "⚠️ WARNING: Cannot reach Artifactory ($ping_response)"
    echo "This may be why no artifacts are found in CI"
fi

# Linux AMD64 optimized API call function
safe_api_call() {
    local url="$1"
    local method="${2:-GET}"
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if [[ "$method" == "DELETE" ]]; then
            # Use platform-specific curl options
            echo "🔍 FULL CURL DELETE COMMAND:" >&2
            echo "curl -s -w \"%{http_code}\" $CURL_OPTS \\" >&2
            echo "    -H \"Authorization: Bearer ${TOKEN:0:20}...${TOKEN: -10}\" \\" >&2
            echo "    -H \"Accept: application/json\" \\" >&2
            echo "    -H \"User-Agent: ascii-frog-cleanup/1.0\" \\" >&2
            echo "    -X DELETE \"$url\"" >&2
            echo "" >&2
            
            response=$(curl -s -w "%{http_code}" $CURL_OPTS \
                -H "Authorization: Bearer $TOKEN" \
                -H "Accept: application/json" \
                -H "User-Agent: ascii-frog-cleanup/1.0" \
                -X DELETE "$url" 2>/dev/null)
            http_code="${response: -3}"
            if [[ "$http_code" =~ ^[23] ]]; then
                return 0
            fi
            echo "DELETE failed with HTTP $http_code for $url" >&2
        else
            # GET request with Linux AMD64 optimizations
            echo "🔍 FULL CURL GET COMMAND:" >&2
            echo "curl -s $CURL_OPTS \\" >&2
            echo "    -H \"Authorization: Bearer ${TOKEN:0:20}...${TOKEN: -10}\" \\" >&2
            echo "    -H \"Accept: application/json\" \\" >&2
            echo "    -H \"User-Agent: ascii-frog-cleanup/1.0\" \\" >&2
            echo "    -H \"Cache-Control: no-cache\" \\" >&2
            echo "    \"$url\"" >&2
            echo "" >&2
            
            response=$(curl -s $CURL_OPTS \
                -H "Authorization: Bearer $TOKEN" \
                -H "Accept: application/json" \
                -H "User-Agent: ascii-frog-cleanup/1.0" \
                -H "Cache-Control: no-cache" \
                "$url" 2>/dev/null)
            
            # Enhanced response validation for Linux
            if [[ -n "$response" ]]; then
                # Check if response is valid JSON
                if echo "$response" | jq empty >/dev/null 2>&1; then
                    echo "$response"
                    return 0
                elif [[ "$response" == *"<html"* ]] || [[ "$response" == *"<HTML"* ]]; then
                    echo "HTML response received instead of JSON from $url" >&2
                elif [[ "$response" == *"Access Denied"* ]] || [[ "$response" == *"403"* ]]; then
                    echo "Access denied from $url" >&2
                elif [[ "$response" == *"404"* ]] || [[ "$response" == *"Not Found"* ]]; then
                    echo "Resource not found: $url" >&2
                else
                    # Non-JSON but valid response
                    echo "$response"
                    return 0
                fi
            else
                echo "Empty response from $url" >&2
            fi
        fi
        
        ((retry++))
        if [[ $retry -lt $max_retries ]]; then
            echo "Retry $retry/$max_retries for $url (waiting ${retry}s...)" >&2
            sleep $retry  # Progressive backoff
        fi
    done
    
    echo "All retries failed for $url" >&2
    return 1
}

# Step 1: Clean up build info first
echo -e "\n=== STEP 1: BUILD INFO CLEANUP ==="
echo "🔗 Calling: $ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/"
builds_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/")
echo "📊 API Response length: ${#builds_response}"
echo "📋 API Response preview: ${builds_response:0:200}..."
if [[ $? -eq 0 ]] && [[ -n "$builds_response" ]]; then
    # Filter for ASCII-Frog Release build directories (any build containing "ASCII-Frog Release")
    ascii_frog_builds=$(echo "$builds_response" | jq $JQ_OPTS '.children[] | select(.folder == true and (.uri | contains("ASCII-Frog Release"))) | .uri' 2>/dev/null | sed 's|^/||')
    echo "ASCII-Frog Release build directories found:"
    if [[ -n "$ascii_frog_builds" && "$ascii_frog_builds" != "" ]]; then
        echo "$ascii_frog_builds" | while IFS= read -r build; do
            if [[ -n "$build" && "$build" != "" ]]; then
                echo "  📁 $build"
            fi
        done
        # Linux AMD64 robust counting - filter empty lines
        ascii_frog_count=$(echo "$ascii_frog_builds" | grep -c '^..*$' 2>/dev/null || echo "0")
    else
        echo "  (none found)"
        ascii_frog_count=0
    fi
    echo "📊 Total ASCII-Frog Release build directories: $ascii_frog_count"
    
    if [[ $ascii_frog_count -gt 0 ]]; then
        echo "Getting timestamps for ASCII-Frog Release builds (this may take a while)..."
        temp_builds=$(mktemp)
        
        echo "$ascii_frog_builds" | while read build_path; do
            if [[ -n "$build_path" ]]; then
                # Try to get build info from the build API first
                build_api_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/build/$build_path")
                echo "Build API response:"
                echo $build_api_response
                
                # Also try to get storage info - encode the emoji and spaces properly
                encoded_build_path=$(echo "$build_path" | sed 's/🚀/%F0%9F%9A%80/g' | sed 's/ /%20/g')
                build_storage_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path")
                storage_exit_code=$?
                echo "Build storage response:"
                echo "$build_storage_response"
                
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
                    echo -e "\nProcessing build: $build_path"
                    
                    # Get the contents of this build directory - encode the emoji and spaces properly
                    encoded_build_path=$(echo "$build_path" | sed 's/🚀/%F0%9F%9A%80/g' | sed 's/ /%20/g')
                    echo "    Encoded path: $encoded_build_path"
                    echo "    Full URL: $ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path"
                    
                    # Try direct curl first for debugging
                    echo "    🔍 FULL DIRECT CURL COMMAND:"
                    echo "    curl -s -H \"Authorization: Bearer ${TOKEN:0:20}...${TOKEN: -10}\" \\"
                    echo "         \"$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path\""
                    echo ""
                    
                    direct_response=$(curl -s -H "Authorization: Bearer $TOKEN" "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path" 2>/dev/null)
                    echo "    Direct curl response length: ${#direct_response}"
                    echo "    Direct curl response preview: ${direct_response:0:200}..."
                    
                    build_contents_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path")
                    contents_exit_code=$?
                    echo "    Safe API call exit code: $contents_exit_code"
                    echo "    Safe API call response length: ${#build_contents_response}"
                    
                    if [[ $contents_exit_code -eq 0 ]] && [[ -n "$build_contents_response" ]]; then
                        # Get all JSON files in this build
                        json_files=$(echo "$build_contents_response" | jq $JQ_OPTS '.children[] | select(.folder == false and (.uri | endswith(".json"))) | .uri' 2>/dev/null | sed 's|^/||')
                        if [[ -n "$json_files" && "$json_files" != "" ]]; then
                            # Linux AMD64 robust counting
                            json_count=$(echo "$json_files" | grep -c '^..*$' 2>/dev/null || echo "0")
                            echo "  📊 Found $json_count JSON files in $build_path"
                            echo "  📄 JSON files found:"
                            echo "$json_files" | while IFS= read -r json_file; do
                                if [[ -n "$json_file" && "$json_file" != "" ]]; then
                                    echo "    - $json_file"
                                fi
                            done
                        else
                            json_count=0
                            echo "  📊 Found $json_count JSON files in $build_path"
                            echo "  📄 No JSON files found in this build"
                        fi
                        
                        if [[ $json_count -gt 3 ]]; then
                            echo "  Getting timestamps for JSON files..."
                            temp_json=$(mktemp)
                            
                            echo "$json_files" | while read json_file; do
                                if [[ -n "$json_file" ]]; then
                                    echo "    Checking timestamp for: $json_file"
                                    json_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-build-info/$encoded_build_path/$json_file")
                                    if [[ $? -eq 0 ]]; then
                                        json_timestamp=$(echo "$json_response" | jq -r '.created // empty' 2>/dev/null)
                                        echo "      Timestamp: $json_timestamp"
                                        if [[ -n "$json_timestamp" && "$json_timestamp" != "null" ]]; then
                                            echo "$json_timestamp $json_file" >> "$temp_json"
                                        fi
                                    else
                                        echo "      Error getting timestamp for $json_file"
                                    fi
                                    sleep 1
                                fi
                            done
                            
                            if [[ -f "$temp_json" ]]; then
                                echo "    Timestamps collected:"
                                cat "$temp_json"
                                sort "$temp_json" > "${temp_json}_sorted"
                                
                                echo "    Sorted timestamps:"
                                cat "${temp_json}_sorted"
                                
                                echo "    Keeping 3 oldest JSON files:"
                                head -3 "${temp_json}_sorted" | while read ts file; do
                                    echo "      - $file"
                                done
                                
                                echo "    Deleting newer JSON files:"
                                tail -n +4 "${temp_json}_sorted" | while read ts json_file; do
                                    if [[ "$EXECUTE" == "true" ]]; then
                                        echo "      🗑️ Deleting: $json_file"
                                        delete_url="$ARTIFACTORY_URL/artifactory/p1-build-info/$encoded_build_path/$json_file"
                                        echo "      Delete URL: $delete_url"
                                        delete_response=$(safe_api_call "$delete_url" "DELETE")
                                        echo "      Delete response: $delete_response"
                                        sleep 1
                                    else
                                        echo "      Would delete: $json_file"
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
    echo -e "\n=== ALL OTHER BUILD DIRECTORIES ==="
    other_builds=$(echo "$builds_response" | jq $JQ_OPTS '.children[] | select(.folder == true and (.uri | contains("ASCII-Frog Release") | not)) | .uri' 2>/dev/null | sed 's|^/||')
    if [[ -n "$other_builds" && "$other_builds" != "" ]]; then
        # Linux AMD64 robust counting
        other_count=$(echo "$other_builds" | grep -c '^..*$' 2>/dev/null || echo "0")
        echo "📊 Found $other_count other build directories (non-ASCII-Frog)"
        echo "📁 Other build directories (not processing):"
        echo "$other_builds" | while IFS= read -r build_path; do
            if [[ -n "$build_path" && "$build_path" != "" ]]; then
                echo "  - $build_path"
            fi
        done
    else
        other_count=0
        echo "📊 Found $other_count other build directories (non-ASCII-Frog)"
        echo "📁 No other build directories found"
    fi
else
    echo "❌ No build directories found or error accessing build storage"
    echo "🔍 This could indicate:"
    echo "  - No artifacts in p1-build-info repository"
    echo "  - Network connectivity issues"
    echo "  - Authentication problems"
    echo "  - Repository doesn't exist"
fi

# Step 2: Clean up NPM packages
echo -e "\n=== STEP 2: NPM CLEANUP ==="

# Clean up backend packages
echo "Cleaning up backend packages..."
echo "🔗 Calling: $ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/"
npm_backend_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/backend/-/@ascii-frog/")
echo "📊 Backend NPM Response length: ${#npm_backend_response}"
echo "📋 Backend NPM Response preview: ${npm_backend_response:0:200}..."
if [[ $? -eq 0 ]] && [[ -n "$npm_backend_response" ]]; then
    npm_backend_packages=$(echo "$npm_backend_response" | jq $JQ_OPTS '.children[] | select(.folder == false) | .uri' 2>/dev/null | sed 's|^/||')
    if [[ -n "$npm_backend_packages" && "$npm_backend_packages" != "" ]]; then
        # Linux AMD64 robust counting
        npm_backend_count=$(echo "$npm_backend_packages" | grep -c '^..*$' 2>/dev/null || echo "0")
        echo "📊 Found $npm_backend_count backend NPM packages"
        echo "📦 Backend NPM packages found:"
        echo "$npm_backend_packages" | while IFS= read -r package; do
            if [[ -n "$package" && "$package" != "" ]]; then
                echo "  - $package"
            fi
        done
    else
        npm_backend_count=0
        echo "📊 Found $npm_backend_count backend NPM packages"
        echo "📦 No backend NPM packages found"
    fi
    
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
    echo "❌ No backend NPM packages found or error accessing packages"
    echo "🔍 This could indicate:"
    echo "  - No @ascii-frog/backend packages in p1-npm-local"
    echo "  - Network connectivity issues"
    echo "  - Authentication problems"
    echo "  - Repository path doesn't exist"
fi

# Clean up frontend packages
echo "Cleaning up frontend packages..."
echo "🔗 Calling: $ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/"
npm_frontend_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-npm-local/@ascii-frog/frontend/-/@ascii-frog/")
echo "📊 Frontend NPM Response length: ${#npm_frontend_response}"
echo "📋 Frontend NPM Response preview: ${npm_frontend_response:0:200}..."
if [[ $? -eq 0 ]] && [[ -n "$npm_frontend_response" ]]; then
    npm_frontend_packages=$(echo "$npm_frontend_response" | jq $JQ_OPTS '.children[] | select(.folder == false) | .uri' 2>/dev/null | sed 's|^/||')
    if [[ -n "$npm_frontend_packages" && "$npm_frontend_packages" != "" ]]; then
        # Linux AMD64 robust counting
        npm_frontend_count=$(echo "$npm_frontend_packages" | grep -c '^..*$' 2>/dev/null || echo "0")
        echo "📊 Found $npm_frontend_count frontend NPM packages"
        echo "📦 Frontend NPM packages found:"
        echo "$npm_frontend_packages" | while IFS= read -r package; do
            if [[ -n "$package" && "$package" != "" ]]; then
                echo "  - $package"
            fi
        done
    else
        npm_frontend_count=0
        echo "📊 Found $npm_frontend_count frontend NPM packages"
        echo "📦 No frontend NPM packages found"
    fi
    
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
    echo "❌ No frontend NPM packages found or error accessing packages"
    echo "🔍 This could indicate:"
    echo "  - No @ascii-frog/frontend packages in p1-npm-local"
    echo "  - Network connectivity issues"
    echo "  - Authentication problems"
    echo "  - Repository path doesn't exist"
fi

# Step 3: Clean up Docker images
echo -e "\n=== STEP 3: DOCKER CLEANUP ==="
echo "🔗 Calling: $ARTIFACTORY_URL/artifactory/api/storage/p1-docker-local/ascii-frog-app/"
docker_response=$(safe_api_call "$ARTIFACTORY_URL/artifactory/api/storage/p1-docker-local/ascii-frog-app/")
echo "📊 Docker Response length: ${#docker_response}"
echo "📋 Docker Response preview: ${docker_response:0:200}..."
if [[ $? -eq 0 ]] && [[ -n "$docker_response" ]]; then
    docker_tags=$(echo "$docker_response" | jq $JQ_OPTS '.children[] | select(.folder == true) | .uri' 2>/dev/null | sed 's|^/||' | grep -v '^_' | grep -v '^yahav$' | grep -v '^$')
    if [[ -n "$docker_tags" && "$docker_tags" != "" ]]; then
        # Linux AMD64 robust counting
        docker_count=$(echo "$docker_tags" | grep -c '^..*$' 2>/dev/null || echo "0")
        echo "📊 Found $docker_count Docker images"
        echo "🐳 Docker image tags found:"
        echo "$docker_tags" | while IFS= read -r tag; do
            if [[ -n "$tag" && "$tag" != "" ]]; then
                echo "  - $tag"
            fi
        done
    else
        docker_count=0
        echo "📊 Found $docker_count Docker images"
        echo "🐳 No Docker image tags found"
    fi
    
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
    echo "❌ No Docker images found or error accessing images"
    echo "🔍 This could indicate:"
    echo "  - No ascii-frog-app images in p1-docker-local"
    echo "  - Network connectivity issues"
    echo "  - Authentication problems"
    echo "  - Repository path doesn't exist"
fi

echo -e "\n=== CLEANUP COMPLETE ==="
echo "📊 SUMMARY:"
echo "  🏗️ ASCII-Frog Release builds: ${ascii_frog_count:-0}"
echo "  📦 Backend NPM packages: ${npm_backend_count:-0}"
echo "  📦 Frontend NPM packages: ${npm_frontend_count:-0}"
echo "  🐳 Docker images: ${docker_count:-0}"
echo "  📁 Other builds: ${other_count:-0}"
echo ""
if [[ "$EXECUTE" == "true" ]]; then
    echo "🔥 EXECUTION MODE: Artifacts were actually deleted (if > 3)"
else
    echo "📋 PREVIEW MODE: No artifacts were deleted"
fi