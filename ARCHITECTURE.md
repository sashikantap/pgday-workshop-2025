# PostgreSQL Productivity Tools Lab - Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Docker Container Environment                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    PostgreSQL 17 Core Database                         │    │
│  │                         (Port 5433)                                    │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    Performance Extensions                               │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │    │
│  │  │pg_stat_     │ │pg_stat_     │ │plprofiler   │ │auto_explain │      │    │
│  │  │statements   │ │monitor      │ │             │ │             │      │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │    │
│  │  ┌─────────────┐ ┌─────────────┐                                      │    │
│  │  │pg_buffer    │ │pgstattuple  │                                      │    │
│  │  │cache        │ │             │                                      │    │
│  │  └─────────────┘ └─────────────┘                                      │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                   Maintenance Extensions                                │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │    │
│  │  │pg_repack    │ │pg_partman   │ │pg_prewarm   │ │pg_cron      │      │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                Development & Testing Extensions                         │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │    │
│  │  │hypopg       │ │plpgsql_     │ │pgaudit      │ │orafce       │      │    │
│  │  │             │ │check        │ │             │ │             │      │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                Data Access Extensions                                   │    │
│  │  ┌─────────────┐ ┌─────────────┐                                       │    │
│  │  │postgres_fdw │ │file_fdw     │                                       │    │
│  │  └─────────────┘ └─────────────┘                                       │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                Command-Line Tools                                       │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │    │
│  │  │pgcli        │ │pg_activity  │ │pg_view      │ │pgmetrics    │      │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │    │
│  │  ┌─────────────┐                                                       │    │
│  │  │pgCenter     │                                                       │    │
│  │  └─────────────┘                                                       │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                    │                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                External Analysis Tools                                  │    │
│  │  ┌─────────────┐                                                       │    │
│  │  │pgbadger     │  (Log Analysis - External to DB)                     │    │
│  │  └─────────────┘                                                       │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Host System                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    Persistent Storage                                   │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                       │    │
│  │  │postgres-data│ │SQL Scripts  │ │Config Files │                       │    │
│  │  │(Volume)     │ │(Mounted)    │ │(Mounted)    │                       │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                       │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    Network Access                                       │    │
│  │                   Host:5433 → Container:5433                           │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### Core Database Layer
- **PostgreSQL 17**: Latest version with all modern features
- **Port Mapping**: Host 5433 → Container 5433
- **Database**: `pgday` (auto-created on initialization)

### Extension Categories

#### Performance Analysis & Monitoring
- **pg_stat_statements**: Query execution statistics
- **pg_stat_monitor**: Enhanced Percona query monitoring
- **plprofiler**: Function-level performance profiling
- **auto_explain**: Automatic query plan logging
- **pg_buffercache**: Buffer cache analysis
- **pgstattuple**: Table bloat and statistics

#### Maintenance & Operations
- **pg_repack**: Online table reorganization
- **pg_partman**: Automated partition management
- **pg_prewarm**: Relation prewarming
- **pg_cron**: Job scheduling

#### Development & Testing
- **hypopg**: Hypothetical index testing
- **plpgsql_check**: PL/pgSQL code validation
- **pgaudit**: Comprehensive audit logging
- **orafce**: Oracle compatibility functions

#### Data Access & Integration
- **postgres_fdw**: PostgreSQL foreign data wrapper
- **file_fdw**: File-based foreign data wrapper

### Command-Line Tools
- **pgcli**: Enhanced PostgreSQL CLI client
- **pg_activity**: Real-time activity monitoring
- **pg_view**: Activity viewer
- **pgmetrics**: Metrics collection
- **pgCenter**: Admin tool
- **pgbadger**: Log analysis (external)

### Storage & Configuration
- **Persistent Volume**: `postgres-data/` for database files
- **Mounted Scripts**: Sample SQL and productivity examples
- **Configuration**: Custom postgresql.conf and pg_hba.conf

### Initialization Process
1. Container starts with PostgreSQL 17
2. Database `pgday` is created automatically
3. Extensions are installed via initialization script
4. Sample data and examples are loaded
5. All tools become available for use

This architecture provides a comprehensive PostgreSQL learning environment with all essential productivity tools pre-configured and ready to use.