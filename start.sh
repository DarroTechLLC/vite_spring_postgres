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
for i in {1..60}; do
    if curl -f http://localhost:$BACKEND_PORT/actuator/health > /dev/null 2>&1; then
        echo "Backend is ready on port $BACKEND_PORT!"
        break
    fi
    echo "Attempt $i: Backend not ready yet, waiting..."
    sleep 3
done

# Check if backend is actually ready
if ! curl -f http://localhost:$BACKEND_PORT/actuator/health > /dev/null 2>&1; then
    echo "WARNING: Backend health check failed after 60 attempts, but continuing with nginx startup..."
    echo "Backend logs:"
    ps aux | grep java || echo "No Java process found"
else
    echo "Backend health check passed!"
fi

# Update nginx configuration to use the correct ports
echo "Updating nginx configuration..."
# Create a temporary nginx config with the correct ports
cat > /tmp/nginx.conf << EOF
# Global nginx configuration
pid /tmp/nginx.pid;
worker_processes auto;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    server {
        listen $NGINX_PORT;
        server_name _;
        root /var/www/html;
        index index.html;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https:;" always;

        # Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

        # Frontend routes
        location / {
            try_files \$uri \$uri/ /index.html;
        }

        # API proxy to backend
        location /api/ {
            proxy_pass http://localhost:$BACKEND_PORT/api/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        # Health check endpoint
        location /health {
            proxy_pass http://localhost:$BACKEND_PORT/actuator/health;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # Static assets caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            try_files \$uri =404;
        }
    }
}
EOF

# Copy the new config to the nginx directory
cp /tmp/nginx.conf /etc/nginx/nginx.conf

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

# Verify nginx is running
if ps -p $NGINX_PID > /dev/null; then
    echo "Nginx is running successfully on port $NGINX_PORT"
else
    echo "ERROR: Nginx failed to start"
    exit 1
fi

# Wait for nginx process
wait $NGINX_PID
