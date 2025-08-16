# Production build for ASCII Frog Generator
FROM p1-flylnp1.jfrogdev.org/docker/node:20-alpine

WORKDIR /app

# Install package from private registry (using copied .npmrc)
COPY .npmrc /root/.npmrc
RUN npm install ascii-frog@latest && \
    rm /root/.npmrc

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

CMD ["npx", "ascii-frog"]
