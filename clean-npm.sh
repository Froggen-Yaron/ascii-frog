#!/bin/bash

# Continue on errors - don't exit if individual commands fail
set +e

PROJECT_ROOT=$(pwd)

# Remove only root node_modules directory
if [ -d "node_modules" ]; then
    rm -rf node_modules 2>/dev/null || true
fi

# Remove only root package-lock.json file
if [ -f "package-lock.json" ]; then
    rm -f package-lock.json 2>/dev/null || true
fi

# Remove npm-run-all from root to test dependency resolution
# Remove from global npm cache
if [ -d "$HOME/.npm/_cacache" ]; then
    find "$HOME/.npm/_cacache" -name "*npm-run-all*" -type f -delete 2>/dev/null || true
fi

# Remove npm-run-all from root node_modules
if [ -d "node_modules" ]; then
    if [ -d "node_modules/npm-run-all" ]; then
        rm -rf "node_modules/npm-run-all" 2>/dev/null || true
    fi
fi
