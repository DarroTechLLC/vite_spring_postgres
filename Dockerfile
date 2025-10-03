# Multi-stage build for fullstack application
# Stage 1: Build Frontend
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Copy package files
COPY frontend/package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY frontend/ .

# Fix permissions and build application
RUN chmod -R 755 node_modules && \
    npm run build

# Stage 2: Build Backend
FROM gradle:8.5-jdk21 AS backend-build
WORKDIR /app/backend

# Copy gradle files for dependency caching
COPY backend/build.gradle backend/settings.gradle ./

# Copy source code
COPY backend/src ./src

# Build application
RUN gradle clean build --no-daemon -x test

# Stage 3: Production Runtime
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Install nginx and curl
RUN apt-get update && \
    apt-get install -y nginx curl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy backend JAR
COPY --from=backend-build /app/backend/build/libs/*.jar backend.jar

# Copy frontend build
COPY --from=frontend-build /app/frontend/dist /var/www/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Copy startup script
COPY start.sh /app/start.sh

# Make startup script executable
RUN chmod +x /app/start.sh

# Create nginx directories and fix ownership
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/lib/nginx /tmp && \
    chown -R appuser:appuser /app /var/www/html /var/log/nginx /var/lib/nginx /var/cache/nginx /tmp

# Switch to non-root user
USER appuser

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start application
CMD ["/app/start.sh"]
# Fixed nginx.pid chown issue
