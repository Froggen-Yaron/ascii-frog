#!/bin/bash

# Clean npm-run-all dependency cache - targeted cleanup
# Continue on errors - don't exit if individual commands fail
set +e

echo "🧹 Starting targeted npm-run-all cache cleanup..."

PROJECT_ROOT=$(pwd)

# Remove npm-run-all from node_modules in all directories
echo "📦 Removing npm-run-all from node_modules..."
for dir in "." "frontend" "backend"; do
    if [ -d "$dir/node_modules/npm-run-all" ]; then
        echo "  Removing $dir/node_modules/npm-run-all"
        rm -rf "$dir/node_modules/npm-run-all" 2>/dev/null || true
    fi
done

# Clear npm cache for npm-run-all specifically
echo "🗑️  Clearing npm-run-all from npm cache..."
npm cache clean --force 2>/dev/null || echo "⚠️  npm cache clean failed"

# Remove npm-run-all from npm cache directory if it exists
echo "📂 Cleaning npm-run-all from cache directories..."
if [ -d "$HOME/.npm" ]; then
    find "$HOME/.npm" -name "*npm-run-all*" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$HOME/.npm" -name "*npm-run-all*" -type f -exec rm -f {} + 2>/dev/null || true
fi

# Remove npm-run-all from cacache directory
echo "🗂️  Cleaning npm-run-all from cacache..."
NPM_CACHE_DIR=$(npm config get cache 2>/dev/null || echo "$HOME/.npm")
if [ -d "$NPM_CACHE_DIR/_cacache" ]; then
    echo "  Checking cacache directory: $NPM_CACHE_DIR/_cacache"
    # Find and remove npm-run-all entries from cacache content directory
    find "$NPM_CACHE_DIR/_cacache/content-v2" -name "*npm-run-all*" -type f -delete 2>/dev/null || true
    # Find and remove npm-run-all entries from cacache index directory  
    find "$NPM_CACHE_DIR/_cacache/index-v5" -name "*npm-run-all*" -type f -delete 2>/dev/null || true
    echo "  ✓ Cleaned npm-run-all from cacache"
fi

echo "🎉 npm-run-all cache cleanup completed!"
echo "💡 Run 'npm install' to reinstall npm-run-all if needed"
