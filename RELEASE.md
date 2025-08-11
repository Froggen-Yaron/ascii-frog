# 🚀 Release Guide - ASCII Frog Generator

## How to Trigger a Release

The project uses GitHub Actions for automated releases.

### Automatic Release Trigger

**Create feature branch, commit, and create PR:**
```bash
# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Stage your changes
git add .

# Commit with a descriptive message (generate appropriate message)
git commit -m "feat: add new frog template and improve UI styling"

# Push to feature branch
git push origin feature/your-feature-name
```

**Then create a Pull Request to `main` branch.**

**When the PR is merged to `main`**, this automatically triggers the `🐸 ASCII Frog Release` workflow.

**⚠️ Never commit directly to `main` branch.**

### What Happens

The workflow runs two jobs in parallel:

1. **📦 NPM Release Job:**
   - Setup Node.js 20 + JFrog Fly
   - Install dependencies (`npm ci`)
   - Run tests (`npm test`)
   - Publish to NPM (`npm publish`)

2. **🐳 Docker Release Job:**
   - Setup JFrog Fly
   - Build Docker image (`docker build`)
   - Push to JFrog Fly registry (`p1-flylnp1.jfrogdev.org/docker/ascii-frog:latest`)

### Monitor Progress

- Go to **Actions** tab in your repository
- Watch the workflow execution
- Check logs for any errors
