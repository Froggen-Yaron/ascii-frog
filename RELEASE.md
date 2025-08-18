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

## 🔧 Troubleshooting

### Common Scenarios

**✅ Normal PR Flow**
1. Create PR → version bump auto-added by `npm-version-bump`
2. Merge PR → automatic release triggers
3. Check **Actions** tab to monitor release progress

**⚠️ If version bump missing from PR:**
- Wait a few minutes (workflow might still be running)
- Check PR **Checks** tab for workflow status
- Re-run failed workflow if needed

**⚠️ If release fails:**
- Check **Actions** tab for error details
- Common issues: npm auth, docker registry permissions
- Re-run failed release workflow after fixing

### Monitor Progress

- **Actions** tab in your repository shows all workflow runs
- **PR Checks** show version bump workflow status
- **npm registry** to verify published packages
- **JFrog registry** to verify docker images

## 📊 What Gets Released

**📦 NPM Package:**
- Published to npm registry
- Version from `package.json` (auto-bumped)
- Includes built frontend assets

**🐳 Docker Image:**
- Pushed to `p1-flylnp1.jfrogdev.org/docker/ascii-frog`
- Tagged with timestamp (e.g., `2025.01.08-17.07.01`)
- Also tagged as `latest`
