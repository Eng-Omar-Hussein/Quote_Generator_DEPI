# Quote Generator Service - Dockerfile
# Multi-stage build for optimized production image

# Stage 1: Base image with dependencies
FROM node:18-alpine AS base

# Install production dependencies only
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Stage 2: Production image
FROM node:18-alpine AS production

# Install wget for healthcheck
RUN apk add --no-cache wget

# Set environment to production
ENV NODE_ENV=production

# Create app directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Create data directory for SQLite database
RUN mkdir -p /app/data && \
    chown -R nodejs:nodejs /app/data

# Copy dependencies from base stage
COPY --from=base --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application source code
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs src ./src

# Switch to non-root user
USER nodejs

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "src/server.js"]
