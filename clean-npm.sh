#!/bin/bash

# Clean all npm cache and dependencies - comprehensive cleanup
# Continue on errors - don't exit if individual commands fail
set +e

echo "🧹 Starting comprehensive npm cache cleanup..."

PROJECT_ROOT=$(pwd)

# Clean npm cache completely
echo "🗑️  Cleaning npm cache..."
npm cache clean --force 2>/dev/null || echo "⚠️  npm cache clean failed"

# Remove all node_modules directories (root, frontend, backend)
echo "📦 Removing all node_modules directories..."
for dir in "." "frontend" "backend"; do
    if [ -d "$dir/node_modules" ]; then
        echo "  Removing $dir/node_modules"
        rm -rf "$dir/node_modules" 2>/dev/null || true
    fi
done

# Remove all package-lock.json files (root, frontend, backend)
echo "🔒 Removing all package-lock.json files..."
for dir in "." "frontend" "backend"; do
    if [ -f "$dir/package-lock.json" ]; then
        echo "  Removing $dir/package-lock.json"
        rm -f "$dir/package-lock.json" 2>/dev/null || true
    fi
done

# Remove entire npm cache directory
echo "📂 Cleaning npm cache directories..."
if [ -d "$HOME/.npm" ]; then
    echo "  Removing $HOME/.npm"
    rm -rf "$HOME/.npm" 2>/dev/null || true
fi

# Remove npm temp directories
echo "🗂️  Cleaning npm temp directories..."
rm -rf /tmp/npm-* 2>/dev/null || true

# Remove npm logs
echo "📄 Cleaning npm logs..."
find /tmp -name "npm-debug.log*" -type f -delete 2>/dev/null || true


echo "🎉 Npm cache cleanup completed!"
echo "💡 Run 'npm install' in each directory to reinstall dependencies"
