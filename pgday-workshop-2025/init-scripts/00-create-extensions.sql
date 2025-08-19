-- Create all required extensions for pgday database
-- This script runs during database initialization

-- Core extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS plpgsql_check;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- Advanced extensions
CREATE EXTENSION IF NOT EXISTS hypopg;
CREATE EXTENSION IF NOT EXISTS orafce;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_partman;
CREATE EXTENSION IF NOT EXISTS pg_repack;
CREATE EXTENSION IF NOT EXISTS pg_stat_monitor;
CREATE EXTENSION IF NOT EXISTS plprofiler;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA partman TO demo_user;
GRANT ALL ON ALL TABLES IN SCHEMA partman TO demo_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA partman TO demo_user;

-- Configure pg_cron (requires superuser)
SELECT cron.schedule('vacuum-job', '0 2 * * *', 'VACUUM ANALYZE;');

-- Display installed extensions
SELECT extname, extversion FROM pg_extension ORDER BY extname;
