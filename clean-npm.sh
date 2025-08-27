#!/bin/bash

set -e

PROJECT_ROOT=$(pwd)

# Remove all node_modules directories
find . -name "node_modules" -type d -prune -exec rm -rf {} +

# Remove package-lock.json files
find . -name "package-lock.json" -type f -delete

# Clear npm cache
npm cache clean --force 2>/dev/null || true

# Remove cacache directories (macOS)
rm -rf "$HOME/.npm/_cacache" 2>/dev/null || true
rm -rf /tmp/npm-* 2>/dev/null || true
rm -rf "$HOME/Library/Caches/npm" 2>/dev/null || true
