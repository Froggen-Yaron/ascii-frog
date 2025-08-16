# 🐳 Docker Build Guide

## Problem: NPM Registry Authentication

Your project uses JFrog Fly registry which requires authentication. Docker builds need special handling.

## ✅ Solutions (No Credentials in Repo)

### Option 1: Build with Arguments (Recommended)

```bash
# Get your auth token from ~/.npmrc
NPM_TOKEN=$(grep "_authToken" ~/.npmrc | cut -d'=' -f2)

# Build with authentication
docker build --build-arg NPM_AUTH_TOKEN="$NPM_TOKEN" -t ascii-frog .
```

**Note:** Modern npm (v7+) handles authentication automatically when auth tokens are configured - no need for `always-auth` setting.

### Option 2: Docker Compose Override

1. Copy the example override file:
```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

2. Edit `docker-compose.override.yml` and add your token from `~/.npmrc`

3. Build:
```bash
docker-compose build
```

### Option 3: CI/CD (Already Working!)

Your GitHub Actions workflows use `FrogGen/fly-action@v1` which automatically handles npm authentication. No changes needed!

## 🔒 Security Notes

- ✅ Dockerfile uses multi-stage build (credentials only in build stage)
- ✅ Final image contains no npm credentials
- ✅ No credentials stored in repository
- ✅ Build args are not persisted in final image

## 🚨 Never Do This

- ❌ Don't commit `.npmrc` with real tokens
- ❌ Don't hardcode tokens in Dockerfile
- ❌ Don't use ENV for secrets (they persist in image)
