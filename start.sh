#!/bin/bash
set -e

# Get the PORT from environment (Render sets this)
# Backend will run on a different port, nginx will run on the Render-assigned port
BACKEND_PORT=8080
NGINX_PORT=${PORT:-80}

echo "Starting application..."
echo "Backend will run on port: $BACKEND_PORT"
echo "Nginx will run on port: $NGINX_PORT"

# Start backend in background on internal port
echo "Starting backend on port $BACKEND_PORT..."
java -Dserver.port=$BACKEND_PORT -jar backend.jar &
BACKEND_PID=$!

# Wait for backend to be ready
echo "Waiting for backend to start..."
for i in {1..30}; do
    if curl -f http://localhost:$BACKEND_PORT/actuator/health > /dev/null 2>&1; then
        echo "Backend is ready on port $BACKEND_PORT!"
        break
    fi
    echo "Attempt $i: Backend not ready yet, waiting..."
    sleep 2
done

# Update nginx configuration to use the correct ports
echo "Updating nginx configuration..."
# Update nginx to listen on the Render-assigned port
sed -i "s/listen 80;/listen $NGINX_PORT;/" /etc/nginx/nginx.conf
# Ensure backend proxy points to the correct internal port
sed -i "s/localhost:8080/localhost:$BACKEND_PORT/g" /etc/nginx/nginx.conf

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Start nginx in foreground (this will be the main process)
echo "Starting nginx in foreground on port $NGINX_PORT..."
echo "PORT is set to: $PORT"

# Start nginx and show what's listening
nginx -g "daemon off;" &
NGINX_PID=$!

# Wait a moment for nginx to start
sleep 2

# Show what ports are being listened on
echo "Checking listening ports..."
netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null || echo "Cannot check ports"

# Wait for nginx process
wait $NGINX_PID
