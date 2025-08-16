# ==============================================================================
# BUILD STAGE - Contains npm credentials (.npmrc) - NEVER SHIPPED TO PRODUCTION
# ==============================================================================
FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine AS deps

WORKDIR /app

# Copy package files AND .npmrc
COPY package*.json .npmrc ./

# Install dependencies using the configured .npmrc (credentials available here)
RUN npm ci --only=production

# ==============================================================================
# PRODUCTION STAGE - CLEAN IMAGE - NO CREDENTIALS - NO .npmrc
# ==============================================================================
FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine AS production

WORKDIR /app

# Copy ONLY node_modules from build stage (NO .npmrc, NO credentials)
COPY --from=deps /app/node_modules ./node_modules

# Copy package files (needed for npm start)
COPY package*.json ./

# Copy application source files SELECTIVELY (NO .npmrc!)
COPY backend/ ./backend/
COPY frontend/ ./frontend/
# Note: jsconfig.json & tsconfig.json NOT needed in production (IDE/dev tools only)

# Build frontend for production (no npm auth needed - deps already installed)
RUN npm run build

# Install curl for health checks (before switching to non-root user)
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S froggen -u 1001

# Change ownership of the app directory
RUN chown -R froggen:nodejs /app
USER froggen

# Expose port
EXPOSE 3000

# Health check using proper endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["npm", "start"]
