# Production image for pre-built ASCII Frog Generator
FROM node:20-alpine

WORKDIR /app

# Copy pre-built backend (from CI/CD pipeline)
COPY backend/ ./backend/

# Copy pre-built frontend (from CI/CD pipeline)  
COPY frontend/dist/ ./frontend/dist/

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
