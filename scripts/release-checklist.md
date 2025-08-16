# 🚀 MANDATORY RELEASE CHECKLIST

## EXACT ORDER for release:

### ✅ Step 1: Commit All Changes First
```bash
git add .
git commit -m "..."
git push origin [branch]
```

### ✅ Step 2: Analyze Changes
```bash
git diff main..HEAD
```
Look for:
- `feat:` → MINOR
- `fix:` → PATCH  
- `BREAKING:` → MAJOR

### ✅ Step 3: Version Bump (FINAL STEP - MANDATORY)
```bash
npm version [patch|minor|major]
```
**THIS IS THE FINAL STEP - NEVER SKIP**

### ✅ Step 4: Push Version Bump
```bash
git push origin [branch-name]
```

### ✅ Step 5: Verify
```bash
node -p "require('./package.json').version"
```

## ❌ FAILURE POINTS TO AVOID:
- Never skip version bump as final release step
- Never push without confirming version changed
- Version bump must be AFTER all development commits
