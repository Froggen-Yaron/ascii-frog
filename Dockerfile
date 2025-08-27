# Multi-stage build for ASCII Frog Generator
FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine AS frontend-builder

WORKDIR /app/frontend
# Copy pre-built frontend (already built in CI)
COPY frontend/ ./

FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine AS backend-builder

WORKDIR /app/backend
# Copy pre-built backend (already installed in CI)
COPY backend/ ./

# Production image
FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine

WORKDIR /app

# Copy built frontend from builder stage
COPY --from=frontend-builder /app/frontend/dist/ ./frontend/dist/

# Copy backend with dependencies from builder stage
COPY --from=backend-builder /app/backend/ ./backend/

# Setup security: curl + non-root user
RUN apk add --no-cache curl && \
    addgroup -g 1001 -S nodejs && \
    adduser -S froggen -u 1001 && \
    chown -R froggen:nodejs /app

USER froggen

# Expose port
EXPOSE 8000

# Health check using proper endpoint  
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Environment
ENV NODE_ENV=production PORT=8000

CMD ["node", "backend/server.js"]
