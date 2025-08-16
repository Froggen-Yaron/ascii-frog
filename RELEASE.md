# 🚀 Release Guide - ASCII Frog Generator

## 📦 Complete Release Process

The project uses GitHub Actions for automated releases. Follow this unified process:

### 🎯 Step-by-Step Release Flow

**🤖 AI ASSISTANT WORKFLOW**: The AI assistant will enforce proper release workflow automatically!

**1. Create feature branch and make changes:**
```bash
# Check current branch first
git branch --show-current

# Create and switch to feature branch (skip if already on feature branch)  
git checkout -b feature/your-feature-name

# Make your code changes...

# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new frog template and improve UI styling"
```

**2. Bump version (only if you want to trigger a release):**

**Choose the appropriate version bump based on your changes:**

```bash
# PATCH (1.0.1 → 1.0.2) - Bug fixes, small improvements, no API changes
npm version patch

# MINOR (1.0.1 → 1.1.0) - New features, backward compatible changes  
npm version minor

# MAJOR (1.0.1 → 2.0.0) - Breaking changes, API changes, major rewrites
npm version major
```

## 🤖 AI Assistant Release Protocol

**CRITICAL RULES - MUST ALWAYS FOLLOW:**

### 🚫 Absolute Prohibitions
- **NEVER push directly to main branch** - This is FORBIDDEN
- **NEVER commit to main branch** - Always use feature branches
- **NEVER bypass the workflow** - Follow the process every time

### 🔄 Mandatory Workflow Steps

**1. ALWAYS check current branch first:**
```bash
git branch --show-current
```

**2. If on main branch - STOP and create feature branch:**
```bash
git checkout -b feature/release-vX.X.X
# OR appropriate feature name based on changes
```

**3. Analyze changes to determine version bump:**
- **PATCH**: Bug fixes, docs, tests, small improvements, workflow updates
- **MINOR**: New features, new functionality, backward compatible changes  
- **MAJOR**: Breaking changes, API changes, major rewrites

**4. Auto-detect version type from git diff:**
```bash
git diff main..HEAD
```
- Look for: `feat:`, `feature:`, new files → **MINOR**
- Look for: `BREAKING CHANGE`, `major:` → **MAJOR**  
- Default to: **PATCH** for everything else

**5. Execute version bump:**
```bash
npm version [patch|minor|major]
```

**6. Push to feature branch:**
```bash
git push origin [feature-branch-name]
```

**7. Instruct user to create PR:**
- User must manually create PR from feature branch to main
- When PR is merged → automatic release workflow triggers

### 🚨 Error Recovery Scenarios

**If AI Assistant accidentally commits to main:**
1. Stop immediately - do not push
2. Create feature branch: `git checkout -b feature/fix-release-flow`
3. Move commits to feature branch
4. Reset main branch to previous state
5. Continue with proper workflow

**If AI Assistant detects they're on main:**
1. STOP all operations immediately
2. Create feature branch before any commits
3. Follow the protocol from step 2 above

**If direct push to main happens:**
1. The git hook should prevent this
2. If it somehow occurs, immediately create a revert strategy
3. Use feature branch for all future work

```bash
# Commit the version bump (done automatically by npm version)
# No need to manually add package.json - npm version handles it
```

**3. Push to feature branch:**
```bash
# Push to feature branch
git push origin feature/your-feature-name
```

**4. Create PR manually (user action):**
- Go to GitHub and create a Pull Request to `main` branch
- Review and merge the PR
- When the PR is merged to `main`, this automatically triggers the `🐸 ASCII Frog Release` workflow

**⚠️ Critical Reminders:**
- **🚫 NEVER commit directly to `main` branch** - Use feature branches only!
- **🤖 AI Assistant must follow the protocol above** - No exceptions!
- **Only bump version if you want to publish a new release**
- **No version bump = no publishing** (workflow skips gracefully)

## 🛡️ Branch Protection Setup

To prevent accidental direct pushes to main, set up branch protection:

### GitHub Branch Protection Rules
1. Go to **Settings** → **Branches** in your GitHub repo
2. Add rule for `main` branch:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators (prevents even admins from pushing directly)


## 🤖 What Happens Automatically

The workflow intelligently handles releases to prevent version conflicts:

1. **🔍 Version Check Job:**
   - **Compare local vs published version**
   - **Skip if versions match** - already published
   - **Continue if versions differ** - trigger both release jobs

2. **📦 NPM Release Job (conditional):**
   - **Only runs if version changed**
   - Setup Node.js 20 + JFrog Fly
   - Install dependencies (`npm ci`)
   - Run tests (`npm test`)
   - Publish to NPM (`npm publish`)

3. **🐳 Docker Release Job (conditional):**
   - **Only runs if version changed**
   - Setup JFrog Fly
   - Build Docker image (`docker build`)
   - Push to JFrog Fly registry (`p1-flylnp1.jfrogdev.org/docker/ascii-frog:latest`)

### 🎯 Smart Version Handling

- **Version already published**: Workflow completes successfully, skips publishing
- **New version detected**: Publishes to both NPM and Docker registries  
- **No more 403 errors** from duplicate version publishing
- **Simple version comparison** - local vs published

**🔍 Current Version: `1.0.1`**

### Monitor Progress

- Go to **Actions** tab in your repository
- Watch the workflow execution
- Check logs for any errors

## 🔧 Troubleshooting

### Common Scenarios

**✅ Version Already Published**
```
🔍 Current: 1.0.1, Latest: 1.0.1
⏭️ Skipping - version unchanged
✅ Workflow completed successfully
```
*This is normal - no action needed.*

**✅ New Version**
```
🔍 Current: 1.0.2, Latest: 1.0.1
✅ Will publish 1.0.2
📦 Publishing to npm registry...
🐳 Building and pushing Docker image...
✅ Release completed successfully
```


### Release Checklist

- [ ] Version bumped in `package.json`
- [ ] Changes tested locally (`npm test`)
- [ ] Feature branch merged to `main`
- [ ] GitHub Actions workflow completed
- [ ] Check npm registry for new package
- [ ] Verify Docker image in JFrog registry
