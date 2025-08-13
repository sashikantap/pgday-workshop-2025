# pgconf-Lab-2025

## Name
Lab for __PGDay 2025 Training - Essential PostgreSQL Tools and Extensions for DBA and Developer Productivity__

# Pre-Req needs to be followed by participant
1. Docker service should be installed in your laptop/Desktop
2. Follow the steps from below links
    1. Ubuntu: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
    2. Windows: [https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)
    3. Mac : [https://docs.docker.com/desktop/install/mac-install/](https://docs.docker.com/desktop/install/mac-install/)

## Description

>The Dockerized lab setup with PostgreSQL 17 containing essential tools and extensions for DBA and developer productivity:

**Core Database:**
* [PostgreSQL v17](https://www.postgresql.org/docs/17/index.html)

**Performance Analysis & Monitoring:**
* [plprofiler](https://github.com/bigsql/plprofiler) - Function profiling and performance analysis
* [pgbadger](https://github.com/darold/pgbadger) - PostgreSQL log analyzer
* pg_stat_statements - Query performance tracking and statistics
* [pg_stat_monitor](https://github.com/percona/pg_stat_monitor) - Enhanced query statistics (Percona)
* pg_buffercache - Buffer cache inspection and analysis
* auto_explain - Automatic EXPLAIN logging for slow queries
* pgstattuple - Tuple-level statistics and bloat analysis

**Maintenance & Operations:**
* [pg_repack](https://github.com/reorg/pg_repack) - Online table and index reorganization
* [pg_partman](https://github.com/pgpartman/pg_partman) - Automated partition management
* pg_prewarm - Relation prewarming for faster startup
* pg_cron - Job scheduler for automated maintenance tasks

**Development & Testing:**
* [hypopg](https://github.com/HypoPG/hypopg) - Hypothetical indexes for testing
* [plpgsql_check](https://github.com/okbob/plpgsql_check) - PL/pgSQL code validation
* pgaudit - Comprehensive audit logging
* [orafce](https://github.com/orafce/orafce) - Oracle compatibility functions

**Data Access & Integration:**
* postgres_fdw - Foreign data wrapper for PostgreSQL
* file_fdw - Foreign data wrapper for flat files

**Command-Line Tools & Clients:**
* [pgcli](https://github.com/dbcli/pgcli) - Enhanced PostgreSQL command-line client
* [pg_activity](https://github.com/dalibo/pg_activity) - Real-time PostgreSQL activity monitor
* [pg_view](https://github.com/zalando/pg_view) - PostgreSQL activity viewer
* [pgmetrics](https://github.com/rapidloop/pgmetrics) - PostgreSQL metrics collector
* [pgCenter](https://github.com/lesovsky/pgcenter) - Command-line admin tool for PostgreSQL

* Sample Schema and use case files present in location ```/var/lib/scripts/```


# Usage and steps to deploy container

## Clone and Setup
```
git clone https://github.com/sashikantap/pgday-workshop-2025.git
cd pgday-workshop-2025/pgday-docker-2025
```
### Build Postgres container image 

```
docker build -t pgday/pgdatabase:latest -f dockerfile-postgres .

```

### Launch and create container using docker compose 

#### Start pgconf container and initialize with sample schema 


```
docker-compose up -d postgres_pgday
```

<!-- Adding Blockquote --> 
> $`\textcolor{red}{\text{IMPORTANT}}`$ After you start the pgconf container, it will take atleast 2 minutes to create the cluster.
You can check the progress using below command 

```
docker-compose logs postgres_pgday

```
<!-- Adding Blockquote --> 
> $`\textcolor{orange}{\text{NOTE}}`$ The logs should show something like below 
```

postgres_pgday  | PostgreSQL init process complete; ready for start up.
postgres_pgday  | 
postgres_pgday  | 2025-08-08 18:18:13 UTC [1]: [1-1] user=,db=,app=,client= LOG:  redirecting log output to logging collector process
postgres_pgday  | 2025-08-08 18:18:13 UTC [1]: [2-1] user=,db=,app=,client= HINT:  Future log output will appear in directory "log".

```

### Verify all files and Connect to pgday database

```
docker exec -it postgres_pgday bash

```

```
sudo su - postgres
ls -lrth /var/lib/scripts/
```

```
postgres@container:/var/lib/scripts$ ls -lrth
-rw-rw-r-- 1 postgres postgres 2.2K sample_sql.sql
-rw-rw-r-- 1 postgres postgres 8.5K productivity_examples.sql
-rw-rw-r-- 1 postgres postgres 12K maintenance_scripts.sql
-rwxr-xr-x 1 postgres postgres  500 monitor_db.sh

```

Create tables and setup productivity tools in the pgday database

```
psql -d pgday -f /var/lib/scripts/sample_sql.sql
psql -d pgday -f /var/lib/scripts/productivity_examples.sql
```

```
psql -d pgday 
```

```
pgday=# \dt
            List of relations
 Schema |    Name     | Type  |  Owner   
--------+-------------+-------+----------
 public | customers   | table | postgres
 public | order_items | table | postgres
 public | orders      | table | postgres
 public | products    | table | postgres
 public | users       | table | postgres
 public | performance_test | table | postgres
(6 rows)

pgday=# \dx
                                     List of installed extensions
        Name        | Version |   Schema   |                        Description                        
--------------------+---------+------------+-----------------------------------------------------------
 hypopg             | 1.3.1   | public     | Hypothetical indexes for PostgreSQL
 pg_stat_statements | 1.10    | public     | track planning and execution statistics of all SQL statements
 pgaudit            | 1.7     | public     | provides auditing functionality
 pgstattuple        | 1.5     | public     | show tuple-level statistics
 plpgsql            | 1.0     | pg_catalog | PL/pgSQL procedural language
 plprofiler         | 4.2     | public     | server-side support for profiling PL/pgSQL functions
(6 rows)

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
```

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
rm -rf postgres-data/
```

### Complete cleanup
```bash
docker-compose down -v
docker rmi pgday/pgdatabase:latest
rm -rf postgres-data/
docker system prune -f
```

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

1. __Sashikanta.P__
2. __Bikash.R__
3. __Veera.G__

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
