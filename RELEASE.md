# 🚀 Release Guide - ASCII Frog Generator

## 📦 Complete Release Process

The project uses GitHub Actions for automated releases. Follow this unified process:

### 🎯 Step-by-Step Release Flow

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
```bash
# For patch fixes (1.0.1 → 1.0.2)
npm version patch

# For new features (1.0.1 → 1.1.0)
npm version minor

# For breaking changes (1.0.1 → 2.0.0)
npm version major

# Commit the version bump
git add package.json
git commit -m "chore: bump version to 1.0.2"
```

**3. Push and create PR:**
```bash
# Push to feature branch
git push origin feature/your-feature-name
```

**4. Merge to main:**
- Create a Pull Request to `main` branch
- When the PR is merged to `main`, this automatically triggers the `🐸 ASCII Frog Release` workflow

**⚠️ Important Notes:**
- **Never commit directly to `main` branch**
- **Only bump version if you want to publish a new release**
- **No version bump = no publishing** (workflow skips gracefully)

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

**❌ 403 Forbidden Error**
*This should no longer happen with our smart version checking.*
*If it does occur, ensure you bumped the version number in package.json.*

### Release Checklist

- [ ] Version bumped in `package.json`
- [ ] Changes tested locally (`npm test`)
- [ ] Feature branch merged to `main`
- [ ] GitHub Actions workflow completed
- [ ] Check npm registry for new package
- [ ] Verify Docker image in JFrog registry
