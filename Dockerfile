# Multi-stage build for ASCII Frog Generator
# Stage 1: Build frontend
FROM node:20-alpine AS frontend-build

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# Stage 2: Setup backend
FROM node:20-alpine AS backend

WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm ci --only=production

COPY backend/ ./

# Stage 3: Production image
FROM node:20-alpine AS production

WORKDIR /app

# Copy backend with dependencies
COPY --from=backend /app/backend/ ./backend/
COPY --from=backend /app/backend/node_modules/ ./backend/node_modules/

# Copy built frontend
COPY --from=frontend-build /app/frontend/dist/ ./frontend/dist/

# Setup security: curl + non-root user
RUN apk add --no-cache curl && \
    addgroup -g 1001 -S nodejs && \
    adduser -S froggen -u 1001 && \
    chown -R froggen:nodejs /app

USER froggen

# Expose port
EXPOSE 3000

# Health check using proper endpoint  
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Environment
ENV NODE_ENV=production PORT=3000

CMD ["node", "backend/server.js"]
