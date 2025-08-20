# PGDay 2025 Training - Essential PostgreSQL Tools and Extensions

## Lab for PostgreSQL DBA and Developer Productivity

This Docker setup provides PostgreSQL 17 with essential DBA and developer productivity tools, including pg_cron, optimized for cross-platform compatibility (Windows, Mac, Linux).

## Prerequisites

### Required Software
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** (usually included with Docker Desktop)
- **PGAdmin** (OpenSource)
- **PSQL** (Comes with PostgreSQL database)
- **PGCLI**
- **plprofiler**
- **pg_repack**

### System Requirements
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Disk Space**: At least 2GB free space
- **Ports**: Port 5433 must be available

### Installation Links
- **Ubuntu**: [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
- **Windows**: [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
- **Mac**: [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)

### Verify Installation
```bash
# Check Docker
docker --version

# Check Docker Compose  
docker-compose --version
```

## Features & Extensions Included

**Core Database:**
- [PostgreSQL v17](https://www.postgresql.org/docs/17/index.html)

**Performance Analysis & Monitoring:**
- [plprofiler](https://github.com/bigsql/plprofiler) - Function profiling and performance analysis
- [pgbadger](https://github.com/darold/pgbadger) - PostgreSQL log analyzer
- pg_stat_statements - Query performance tracking and statistics
- [pg_stat_monitor](https://github.com/percona/pg_stat_monitor) - Enhanced query statistics (Percona)
- pg_buffercache - Buffer cache inspection and analysis
- auto_explain - Automatic EXPLAIN logging for slow queries
- pgstattuple - Tuple-level statistics and bloat analysis

**Maintenance & Operations:**
- [pg_repack](https://github.com/reorg/pg_repack) - Online table and index reorganization
- [pg_partman](https://github.com/pgpartman/pg_partman) - Automated partition management
- pg_prewarm - Relation prewarming for faster startup
- [pg_cron](https://github.com/citusdata/pg_cron) - Job scheduler for automated maintenance tasks

**Development & Testing:**
- [hypopg](https://github.com/HypoPG/hypopg) - Hypothetical indexes for testing
- [plpgsql_check](https://github.com/okbob/plpgsql_check) - PL/pgSQL code validation
- [pgaudit](https://github.com/pgaudit/pgaudit) - Comprehensive audit logging
- [orafce](https://github.com/orafce/orafce) - Oracle compatibility functions

**Data Access & Integration:**
- postgres_fdw - Foreign data wrapper for PostgreSQL
- file_fdw - Foreign data wrapper for flat files

**Command-Line Tools & Clients:**
- [pgcli](https://github.com/dbcli/pgcli) - Enhanced PostgreSQL command-line client
- [pg_activity](https://github.com/dalibo/pg_activity) - Real-time PostgreSQL activity monitor
- [pg_view](https://github.com/zalando/pg_view) - PostgreSQL activity viewer
- [pgmetrics](https://github.com/rapidloop/pgmetrics) - PostgreSQL metrics collector
- [pgCenter](https://github.com/lesovsky/pgcenter) - Command-line admin tool for PostgreSQL

## Quick Start

### Clone and Setup
```bash
git clone https://github.com/sashikantap/pgday-workshop-2025.git
cd pgday-workshop-2025/pgday-docker-2025
```

### For Linux/Mac Users
```bash
chmod +x *
./build-and-test.sh
```

### For Windows Users
```cmd
build-and-test.bat
```

### Manual Steps (All Platforms)
```bash
# Build and start
docker-compose build --no-cache
docker-compose up -d

# Wait 2 minutes for initialization
# Check logs
docker-compose logs -f postgres_pgday

# Test connection
docker-compose exec postgres_pgday psql -U postgres -d pgday -c "SELECT version();"
```

## Connection Details

- **Host**: localhost / 127.0.0.1
- **Port**: 5433
- **Database**: pgday
- **Username**: postgres
- **Password**: password

## Connecting to PostgreSQL

### From Host Machine
```bash
# Using psql (if installed locally)
PGPASSWORD=password psql -h 127.0.0.1 -p 5433 -U postgres -d pgday

# Using Docker (if psql not installed locally)
docker-compose exec postgres_pgday psql -U postgres -d pgday
```

### From Inside Docker Container
```bash
# Connect to the running container
docker exec -it postgres_pgday bash
sudo su - postgres

# Then connect to PostgreSQL
psql -d pgday
```

### Using GUI Tools
Compatible with: pgAdmin, DBeaver, DataGrip, etc.

## Initialize Sample Data

```bash
# Connect to container
docker exec -it postgres_pgday bash
sudo su - postgres

# Load sample data
psql -d pgday -f /var/lib/scripts/sample_sql.sql
psql -d pgday -f /var/lib/scripts/productivity_examples.sql
```

## Use Cases for PostgreSQL Productivity Tools

### Performance Analysis

**Enable pg_stat_statements for query tracking:**
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT query, calls, total_exec_time, mean_exec_time 
FROM pg_stat_statements 
ORDER BY total_exec_time DESC LIMIT 10;
```

**Use plprofiler for function analysis:**
```sql
CREATE EXTENSION IF NOT EXISTS plprofiler;
SELECT plprofiler.pl_profiler_enable(true);
-- Run your functions
SELECT * FROM plprofiler.pl_profiler_functions_src();
```

**Analyze logs with pgbadger:**
```bash
pgbadger /var/log/postgresql/postgresql-*.log -o /tmp/report.html
```

### Maintenance Operations

**Online table reorganization with pg_repack:**
```bash
pg_repack -d pgday -t users --no-order
```

**Partition management with pg_partman:**
```sql
CREATE EXTENSION IF NOT EXISTS pg_partman;
SELECT partman.create_parent(
    p_parent_table => 'public.orders',
    p_control => 'order_date',
    p_type => 'range',
    p_interval => 'monthly'
);
```

### Development & Testing

**Test hypothetical indexes:**
```sql
CREATE EXTENSION IF NOT EXISTS hypopg;
SELECT hypopg_create_index('CREATE INDEX ON users (email)');
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
```

**Schedule jobs with pg_cron:**
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('vacuum-users', '0 2 * * *', 'VACUUM ANALYZE users;');

-- Check scheduled jobs
SELECT * FROM cron.job;

-- Check job run history
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

## Troubleshooting

### pg_cron Issues
- pg_cron is installed in both `postgres` and `pgday` databases
- The `cron.database_name` is set to `pgday` in postgresql.conf
- Jobs can be scheduled from the pgday database

### Connection Issues
- Ensure port 5433 is not in use by another service
- Check Docker container is running: `docker-compose ps`
- Check logs: `docker-compose logs postgres_pgday`

### Cross-Platform Issues
- Uses named volumes instead of bind mounts for data persistence
- Read-only mounts for configuration files
- Proper file permissions handling

## Configuration Files

- `dockerfile-postgres`: Main Dockerfile with all extensions
- `docker-compose.yaml`: Service definition with cross-platform settings
- `config/postgresql.conf`: PostgreSQL configuration with extensions enabled
- `config/pg_hba.conf`: Authentication configuration
- Sample Schema and use case files present in location `/var/lib/scripts/`

## Cleanup

### Stop and remove containers
```bash
docker-compose down
```

### Remove container and image
```bash
docker-compose down
docker rmi pgday/pgdatabase:latest
```

### Remove all data (WARNING: This deletes all database data)
```bash
docker-compose down -v
docker volume prune -f
```

### Complete cleanup
```bash
docker-compose down -v
docker system prune -f
```

## Authors and Acknowledgment

1. **Sashikanta.P**
2. **Bikash.R**
3. **Veera.G**
