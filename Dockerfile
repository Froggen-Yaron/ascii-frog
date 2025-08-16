# Build stage with dependencies
FROM p1-flylnp1.jfrogdev.org/docker/node:18-alpine AS deps

WORKDIR /app

# Accept build argument for npm authentication (only in build stage)
ARG NPM_AUTH_TOKEN

# Copy package files
COPY package*.json ./

# Configure npm registry temporarily
RUN npm config set registry https://p1-flylnp1.jfrogdev.org/artifactory/api/npm/npm/ && \
    npm config set //p1-flylnp1.jfrogdev.org/artifactory/api/npm/npm/:_authToken ${NPM_AUTH_TOKEN} && \
    npm config set always-auth true && \
    npm ci --only=production && \
    npm cache clean --force

# Production stage (clean, no credentials)
FROM p1-flylnp1.jfrogdev.org/docker/node:18-alpine AS production

WORKDIR /app

# Copy only production dependencies (no npm config with credentials)
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./

# Copy application source
COPY . .

# Build frontend for production
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
