#!/bin/bash
set -e

echo "Building PostgreSQL Docker image with pg_cron and extensions..."

# Clean up any existing containers and volumes
docker-compose down -v 2>/dev/null || true
docker volume prune -f 2>/dev/null || true

# Build the image
docker-compose build --no-cache

echo "Starting PostgreSQL container..."
docker-compose up -d

echo "Waiting for PostgreSQL to be ready..."
sleep 30

# Test the connection and extensions
echo "Testing database connection and extensions..."
docker-compose exec postgres_pgday psql -U postgres -d pgday -c "
SELECT 
    name,
    installed_version,
    comment
FROM pg_available_extensions 
WHERE name IN ('pg_cron', 'pg_stat_statements', 'pgaudit', 'plprofiler', 'pg_stat_monitor')
ORDER BY name;
"

echo "Testing pg_cron specifically..."
docker-compose exec postgres_pgday psql -U postgres -d postgres -c "
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_cron';
"

docker-compose exec postgres_pgday psql -U postgres -d pgday -c "
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_cron';
"

echo "Build and test completed successfully!"
echo "You can connect to the database using:"
echo "  Host: localhost"
echo "  Port: 5433"
echo "  Database: pgday"
echo "  Username: postgres"
echo "  Password: password"
