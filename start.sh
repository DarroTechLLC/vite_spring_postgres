#!/bin/bash
set -e

# Start backend in background
echo "Starting backend..."
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

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Start nginx in foreground (this will be the main process)
echo "Starting nginx in foreground..."
exec nginx -g "daemon off;"
