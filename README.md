# Full-Stack Application

Spring Boot 3.5.6 + React 19 + PostgreSQL 17.6 + Vite + TypeScript + shadcn/ui

## Features

- ✅ JWT Authentication (Login/Register)
- ✅ Spring Security with custom login
- ✅ PostgreSQL database
- ✅ React + Vite + TypeScript
- ✅ shadcn/ui components
- ✅ Left sidebar navigation
- ✅ Protected routes
- ✅ Database health check
- ✅ Docker containerization
- ✅ Single-command startup
- ✅ Hot reloading (backend with Spring DevTools)

## Prerequisites

- Docker and Docker Compose
- Git

## Quick Start

1. Clone the repository
2. Run the start script:

```bash
./start.sh
```

The script will:
- Build all Docker images
- Start PostgreSQL, Backend, and Frontend
- Wait for all services to be healthy
- Display access points

## Access Points

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Health Check**: http://localhost:8080/actuator/health
- **PostgreSQL**: localhost:5432

## Development

### Backend Hot Reloading

Spring DevTools is enabled for hot reloading. Changes to Java files will automatically reload the application.

### Frontend Development

For faster frontend development without Docker:

```bash
cd frontend
npm install
npm run dev
```

Access at http://localhost:5173

### View Logs

```bash
docker-compose logs -f
```

View specific service:
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

## Stop Application

```bash
docker-compose down
```

To remove volumes (database data):
```bash
docker-compose down -v
```

## Project Structure

```
fullstack-app/
├── backend/              # Spring Boot application
│   ├── src/
│   │   └── main/
│   │       ├── java/     # Java source code
│   │       └── resources/# Configuration files
│   ├── Dockerfile
│   └── build.gradle
├── frontend/             # React application
│   ├── src/
│   │   ├── features/    # Feature-based organization
│   │   └── shared/      # Shared components & utils
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml
└── start.sh
```

## Environment Variables

### Backend (.env)
- `DB_HOST`: PostgreSQL host
- `DB_PORT`: PostgreSQL port
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `JWT_SECRET`: JWT secret key
- `PORT`: Backend server port

### Frontend (.env)
- `VITE_API_URL`: Backend API URL

## Troubleshooting

### Services not starting
Check logs: `docker-compose logs`

### Database connection failed
Ensure PostgreSQL is healthy: `docker inspect fullstack-postgres`

### Port already in use
Change ports in `docker-compose.yml`

### Hot reload not working
Restart backend container: `docker-compose restart backend`
