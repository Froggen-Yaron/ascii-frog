#!/bin/bash

# 🚀 ASCII Frog Release Helper Script
# Enforces proper release workflow to prevent direct commits to main

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

echo -e "${BLUE}🐸 ASCII Frog Release Helper${NC}"
echo -e "${BLUE}==============================${NC}"

# Check if we're on main branch
if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo -e "${RED}❌ ERROR: You are currently on the 'main' branch!${NC}"
    echo -e "${RED}Direct commits to main are not allowed.${NC}"
    echo ""
    echo -e "${YELLOW}Proper release flow:${NC}"
    echo -e "1. Create a feature branch: ${GREEN}git checkout -b feature/your-feature-name${NC}"
    echo -e "2. Make your changes and commit them"
    echo -e "3. Run this script again from the feature branch"
    echo -e "4. Push to feature branch and create a PR"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Current branch: $CURRENT_BRANCH${NC}"

# Check if there are any uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Do you want to commit these changes first? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        read -p "Enter commit message: " COMMIT_MSG
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${RED}❌ Please commit or stash your changes first${NC}"
        exit 1
    fi
fi

# Analyze changes to determine version bump type
echo -e "${BLUE}🔍 Analyzing changes...${NC}"

# Get diff from main
DIFF_OUTPUT=$(git diff main..HEAD)

if [[ -z "$DIFF_OUTPUT" ]]; then
    echo -e "${YELLOW}⚠️  No changes detected from main branch${NC}"
    read -p "Do you want to continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Auto-detect version bump type
SUGGESTED_BUMP="patch"
if echo "$DIFF_OUTPUT" | grep -q "BREAKING CHANGE\|breaking change\|major:"; then
    SUGGESTED_BUMP="major"
elif echo "$DIFF_OUTPUT" | grep -q "feat:\|feature:\|add.*:\|new.*:"; then
    SUGGESTED_BUMP="minor"
fi

echo -e "${BLUE}📊 Suggested version bump: ${GREEN}$SUGGESTED_BUMP${NC}"

# Show version bump options
echo ""
echo -e "${YELLOW}Version bump options:${NC}"
echo -e "1. ${GREEN}patch${NC} - Bug fixes, small improvements, docs (1.0.1 → 1.0.2)"
echo -e "2. ${GREEN}minor${NC} - New features, backward compatible (1.0.1 → 1.1.0)"
echo -e "3. ${GREEN}major${NC} - Breaking changes, API changes (1.0.1 → 2.0.0)"
echo -e "4. ${GREEN}none${NC} - Skip version bump (no release)"

read -p "Choose version bump (1-4) or press Enter for suggested ($SUGGESTED_BUMP): " CHOICE

case $CHOICE in
    1) VERSION_BUMP="patch" ;;
    2) VERSION_BUMP="minor" ;;
    3) VERSION_BUMP="major" ;;
    4) VERSION_BUMP="none" ;;
    "") VERSION_BUMP="$SUGGESTED_BUMP" ;;
    *) echo -e "${RED}❌ Invalid choice${NC}"; exit 1 ;;
esac

if [[ "$VERSION_BUMP" == "none" ]]; then
    echo -e "${YELLOW}⏭️  Skipping version bump${NC}"
else
    echo -e "${BLUE}🔢 Bumping version: $VERSION_BUMP${NC}"
    OLD_VERSION=$(node -p "require('./package.json').version")
    npm version $VERSION_BUMP
    NEW_VERSION=$(node -p "require('./package.json').version")
    echo -e "${GREEN}✅ Version bumped: $OLD_VERSION → $NEW_VERSION${NC}"
fi

# Push to feature branch
echo -e "${BLUE}📤 Pushing to feature branch...${NC}"
git push origin $CURRENT_BRANCH

echo ""
echo -e "${GREEN}🎉 Release preparation complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Go to GitHub and create a Pull Request"
echo -e "2. Set base branch to: ${GREEN}main${NC}"
echo -e "3. Review and merge the PR"
echo -e "4. The release workflow will trigger automatically on merge"
echo ""
echo -e "${BLUE}🔗 Create PR: https://github.com/FrogGen/ascii-frog/compare/$CURRENT_BRANCH${NC}"
