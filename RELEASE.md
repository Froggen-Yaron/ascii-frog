# 🚀 Release Guide - ASCII Frog Generator

## ⚠️ FULLY AUTOMATED RELEASE PROCESS NOW ACTIVE
**🤖 EVERY PR GETS AUTO-VERSIONED AND RELEASED** - Zero manual version management!

New automated workflow:
1. **Create PR to main** → Version bump automatically added to PR by `npm-version-bump` bot
2. **Merge PR** → Automatic release to npm and docker registries
3. **Zero manual work** - No `npm version` commands needed!

## 📦 New Automated Release Process

The project uses GitHub Actions for **fully automated** releases. No manual version management needed!

### 🎯 Step-by-Step Developer Workflow

**✨ SIMPLE 3-STEP PROCESS:**

**1. Create feature branch and make changes:**
```bash
# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Make your code changes...

# Stage and commit your changes
git add .
git commit -m "feat: add new frog template and improve UI styling"

# Push feature branch
git push origin feature/your-feature-name
```

**2. Create Pull Request:**
- Create PR from your feature branch to `main`
- **🤖 AUTOMATIC**: Version bump commit gets added to your PR by `npm-version-bump` bot
- Review the PR (including the version bump)

**3. Merge Pull Request:**
- Merge the PR to main
- **🤖 AUTOMATIC**: Release workflow publishes to npm and docker registries
- **Done!** New version is live

## 🤖 What Happens Automatically

**🔄 PR Workflow (`version-bump-pr.yml`):**
- **Triggers**: When PR is created/updated to main
- **Checks**: If PR already has version bump commit from `npm-version-bump`
- **Action**: Adds `npm version patch` commit to PR if needed
- **Result**: Every PR gets a version bump automatically

**🚀 Release Workflow (`release.yml`):**
- **Triggers**: When PR is merged to main (every push to main)
- **NPM Release**: Publishes to npm registry using version from package.json
- **Docker Release**: Builds and pushes with timestamp version (e.g., `2025.01.08-17.07.01`)
- **Result**: Every merge creates a new release

## 🎯 Version Strategy

- **NPM**: Uses semantic versioning from package.json (auto-bumped patch versions)
- **Docker**: Uses timestamp-based versions for unique identification
- **Frequency**: One release per merged PR
- **Type**: Always patch versions (1.0.1 → 1.0.2 → 1.0.3...)

## 🚫 No Manual Actions Needed

**❌ DON'T DO THESE ANYMORE:**
- ~~`npm version patch`~~ (automated in PR)
- ~~Manual version bumping~~ (automated in PR) 
- ~~Release planning~~ (every PR is a release)
- ~~Version coordination~~ (fully automated)

**✅ JUST FOCUS ON:**
- Writing code
- Creating PRs
- Code reviews
- Merging when ready

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
