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