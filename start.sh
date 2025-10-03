#!/bin/bash

echo "🚀 Starting Full-Stack Application..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build and start all services
echo "📦 Building and starting containers..."
docker-compose up --build -d

echo ""
echo "⏳ Waiting for services to be healthy..."
echo ""

# Wait for services to be healthy
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt + 1))
    
    postgres_health=$(docker inspect --format='{{.State.Health.Status}}' fullstack-postgres 2>/dev/null)
    backend_health=$(docker inspect --format='{{.State.Health.Status}}' fullstack-backend 2>/dev/null)
    frontend_health=$(docker inspect --format='{{.State.Health.Status}}' fullstack-frontend 2>/dev/null)
    
    echo "Attempt $attempt/$max_attempts:"
    echo "  PostgreSQL: $postgres_health"
    echo "  Backend: $backend_health"
    echo "  Frontend: $frontend_health"
    echo ""
    
    if [ "$postgres_health" = "healthy" ] && [ "$backend_health" = "healthy" ] && [ "$frontend_health" = "healthy" ]; then
        echo "✅ All services are healthy!"
        echo ""
        echo "🎉 Application is ready!"
        echo ""
        echo "📍 Access points:"
        echo "  Frontend: http://localhost:3000"
        echo "  Backend API: http://localhost:8080"
        echo "  Backend Health: http://localhost:8080/actuator/health"
        echo "  PostgreSQL: localhost:5432"
        echo ""
        echo "📝 Default credentials:"
        echo "  Register a new account at http://localhost:3000/register"
        echo ""
        echo "🔍 View logs:"
        echo "  docker-compose logs -f"
        echo ""
        echo "🛑 Stop application:"
        echo "  docker-compose down"
        exit 0
    fi
    
    sleep 5
done

echo "❌ Services failed to become healthy within the timeout period."
echo ""
echo "🔍 Check logs with:"
echo "  docker-compose logs"
exit 1
