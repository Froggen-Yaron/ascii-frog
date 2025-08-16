# 🚀 MANDATORY RELEASE CHECKLIST

## Before ANY release operation:

### ✅ Step 1: Analyze Changes
```bash
git diff main..HEAD
```
Look for:
- `feat:` → MINOR
- `fix:` → PATCH  
- `BREAKING:` → MAJOR

### ✅ Step 2: Version Bump (MANDATORY)
```bash
npm version [patch|minor|major]
```
**THIS STEP CANNOT BE SKIPPED**

### ✅ Step 3: Push Version
```bash
git push origin [branch-name]
```

### ✅ Step 4: Verify
```bash
node -p "require('./package.json').version"
```

## ❌ FAILURE POINTS TO AVOID:
- Never commit without version bump when releasing
- Never push without confirming version changed
- Never assume version bump happened
