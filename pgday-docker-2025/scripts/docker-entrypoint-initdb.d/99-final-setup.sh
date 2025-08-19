#!/bin/bash
set -e

# Final setup script for cross-platform compatibility
echo "Running final setup for cross-platform compatibility..."

# Ensure proper permissions for PostgreSQL directories
chown -R postgres:postgres /var/lib/postgresql
chown -R postgres:postgres /var/run/postgresql
chmod 755 /var/lib/postgresql
chmod 2777 /var/run/postgresql

# Create archive directory if it doesn't exist
mkdir -p /var/lib/postgresql/archive
chown postgres:postgres /var/lib/postgresql/archive
chmod 755 /var/lib/postgresql/archive

echo "Cross-platform setup completed successfully!"
