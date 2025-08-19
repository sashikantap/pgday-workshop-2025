-- PostgreSQL Extensions Demo for pgday database
-- Demonstrates usage of installed extensions

\echo '=== PostgreSQL Extensions Demo ==='
\echo ''

-- Show all installed extensions
\echo '1. Installed Extensions:'
SELECT extname, extversion, nspname as schema 
FROM pg_extension e 
JOIN pg_namespace n ON e.extnamespace = n.oid 
ORDER BY extname;

\echo ''
\echo '2. pg_stat_statements - Query Performance Analysis:'
-- Show top 5 queries by total execution time
SELECT 
    substring(query, 1, 50) as query_snippet,
    calls,
    round(total_exec_time::numeric, 2) as total_time_ms,
    round(mean_exec_time::numeric, 2) as avg_time_ms
FROM pg_stat_statements 
ORDER BY total_exec_time DESC 
LIMIT 5;

\echo ''
\echo '3. hypopg - Hypothetical Indexes:'
-- Create a hypothetical index
SELECT * FROM hypopg_create_index('CREATE INDEX ON performance_test (random_number)');

-- Show hypothetical indexes
SELECT * FROM hypopg_list_indexes();

\echo ''
\echo '4. pg_stat_monitor - Enhanced Query Monitoring:'
-- Show query statistics from pg_stat_monitor
SELECT 
    substring(query, 1, 40) as query,
    calls,
    total_exec_time,
    rows
FROM pg_stat_monitor 
WHERE query NOT LIKE '%pg_stat_monitor%'
LIMIT 5;

\echo ''
\echo '5. file_fdw - Foreign Data Wrapper:'
-- Create a foreign server (example)
CREATE SERVER IF NOT EXISTS file_server FOREIGN DATA WRAPPER file_fdw;

\echo ''
\echo '6. postgres_fdw - PostgreSQL Foreign Data Wrapper:'
-- Show foreign data wrapper
SELECT fdwname, fdwhandler FROM pg_foreign_data_wrapper WHERE fdwname = 'postgres_fdw';

\echo ''
\echo '7. pg_cron - Job Scheduling:'
-- Show scheduled jobs
SELECT jobid, schedule, command, active FROM cron.job;

\echo ''
\echo '8. orafce - Oracle Compatibility:'
-- Test Oracle-compatible functions
SELECT orafce.add_months(CURRENT_DATE, 3) as three_months_later;
SELECT orafce.last_day(CURRENT_DATE) as last_day_of_month;

\echo ''
\echo '9. plpgsql_check - PL/pgSQL Code Analysis:'
-- Create a sample function to check
CREATE OR REPLACE FUNCTION sample_function(p_id integer)
RETURNS text AS $$
BEGIN
    RETURN 'ID: ' || p_id;
END;
$$ LANGUAGE plpgsql;

-- Check the function
SELECT * FROM plpgsql_check_function('sample_function(integer)');

\echo ''
\echo '10. pg_partman - Partition Management:'
-- Show partman schema objects
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname = 'partman' 
LIMIT 5;

\echo ''
\echo '=== Extensions Demo Complete ==='
\echo 'All extensions are installed and functional!'
