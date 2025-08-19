-- PostgreSQL Productivity Tools Examples
-- Run these examples to explore essential extensions

-- 1. Enable pg_stat_statements for query performance tracking
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 2. Create sample data for testing
CREATE TABLE IF NOT EXISTS performance_test (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    data JSONB
);

-- Insert sample data
INSERT INTO performance_test (name, email, data)
SELECT 
    'User ' || i,
    'user' || i || '@example.com',
    jsonb_build_object('age', (random() * 50 + 18)::int, 'city', 'City' || (i % 10))
FROM generate_series(1, 10000) i;

-- 3. Query performance analysis
-- View top queries by execution time
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    rows
FROM pg_stat_statements 
ORDER BY total_exec_time DESC 
LIMIT 10;

-- 4. Enable plprofiler for function profiling
CREATE EXTENSION IF NOT EXISTS plprofiler;

-- Sample function to profile
CREATE OR REPLACE FUNCTION expensive_function(n INTEGER)
RETURNS INTEGER AS $$
DECLARE
    result INTEGER := 0;
    i INTEGER;
BEGIN
    FOR i IN 1..n LOOP
        result := result + i;
        PERFORM pg_sleep(0.001); -- Simulate work
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 5. Hypothetical indexes for testing
CREATE EXTENSION IF NOT EXISTS hypopg;

-- Test query performance with hypothetical index
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM performance_test WHERE email = 'user5000@example.com';

-- Create hypothetical index
SELECT hypopg_create_index('CREATE INDEX ON performance_test (email)');

-- Test again with hypothetical index
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM performance_test WHERE email = 'user5000@example.com';

-- 6. Buffer cache analysis
SELECT 
    schemaname,
    tablename,
    attname,
    null_frac,
    avg_width,
    n_distinct
FROM pg_stats 
WHERE tablename = 'performance_test';

-- 7. Table statistics
CREATE EXTENSION IF NOT EXISTS pgstattuple;

-- Analyze table bloat
SELECT * FROM pgstattuple('performance_test');

-- 8. Audit logging setup
CREATE EXTENSION IF NOT EXISTS pgaudit;

-- Configure audit logging (add to postgresql.conf)
-- pgaudit.log = 'write'
-- pgaudit.log_catalog = off

-- 9. Job scheduling with pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule a maintenance job
SELECT cron.schedule(
    'maintenance-job',
    '0 2 * * *',  -- Daily at 2 AM
    'VACUUM ANALYZE performance_test;'
);

-- View scheduled jobs
SELECT * FROM cron.job;

-- 10. Partition management example
CREATE EXTENSION IF NOT EXISTS pg_partman;

-- Create partitioned table
CREATE TABLE sales_data (
    id SERIAL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2),
    customer_id INTEGER
) PARTITION BY RANGE (sale_date);

-- Setup automatic partitioning
SELECT partman.create_parent(
    p_parent_table => 'public.sales_data',
    p_control => 'sale_date',
    p_type => 'range',
    p_interval => 'monthly'
);

-- Useful queries for monitoring and maintenance
-- =============================================

-- 1. Database size and bloat
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 2. Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- 3. Connection and activity monitoring
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    query
FROM pg_stat_activity
WHERE state = 'active';

-- 4. Lock monitoring
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS current_statement_in_blocking_process
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;