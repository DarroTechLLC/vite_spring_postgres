# Multi-stage build for fullstack application
# Stage 1: Build Frontend
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Copy package files
COPY frontend/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY frontend/ .

# Build application
RUN npm run build

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

# Create startup script
RUN cat > /app/start.sh << 'EOF'
#!/bin/bash
set -e

# Start backend in background
java -jar backend.jar &
BACKEND_PID=$!

# Wait for backend to be ready
echo "Waiting for backend to start..."
for i in {1..30}; do
    if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "Backend is ready!"
        break
    fi
    echo "Attempt $i: Backend not ready yet, waiting..."
    sleep 2
done

# Start nginx in foreground
echo "Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Function to handle shutdown
cleanup() {
    echo "Shutting down..."
    kill $BACKEND_PID $NGINX_PID 2>/dev/null || true
    wait
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Wait for processes
wait
EOF

# Make startup script executable
RUN chmod +x /app/start.sh

# Change ownership
RUN chown -R appuser:appuser /app /var/www/html /var/log/nginx /var/lib/nginx /run/nginx.pid

# Switch to non-root user
USER appuser

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start application
CMD ["/app/start.sh"]
