-- PostgreSQL Maintenance and Operations Scripts
-- Essential scripts for DBA productivity

-- 1. Database Health Check
-- ========================

-- Check database sizes
SELECT 
    datname,
    pg_size_pretty(pg_database_size(datname)) as size
FROM pg_database
WHERE datistemplate = false
ORDER BY pg_database_size(datname) DESC;

-- Check table sizes and bloat
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size
FROM pg_tables 
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 2. Performance Monitoring
-- =========================

-- Long running queries
SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
AND state = 'active';

-- Most expensive queries
SELECT 
    query,
    calls,
    total_exec_time,
    rows,
    100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Cache hit ratio
SELECT 
    'index hit rate' as name,
    (sum(idx_blks_hit)) / nullif(sum(idx_blks_hit + idx_blks_read),0) as ratio
FROM pg_stat_user_indexes
UNION ALL
SELECT 
    'table hit rate' as name,
    sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0) as ratio
FROM pg_stat_user_tables;

-- 3. Index Analysis
-- =================

-- Unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY pg_relation_size(indexrelid) DESC;

-- Duplicate indexes
SELECT 
    pg_size_pretty(sum(pg_relation_size(idx))::bigint) as size,
    (array_agg(idx))[1] as idx1, 
    (array_agg(idx))[2] as idx2,
    (array_agg(idx))[3] as idx3,
    (array_agg(idx))[4] as idx4
FROM (
    SELECT 
        indexrelid::regclass as idx, 
        (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'||
         coalesce(indexprs::text,'')||E'\n' || coalesce(indpred::text,'')) as KEY
    FROM pg_index
) sub
GROUP BY KEY 
HAVING count(*)>1
ORDER BY sum(pg_relation_size(idx)) DESC;

-- 4. Connection and Lock Monitoring
-- =================================

-- Current connections by database
SELECT 
    datname,
    count(*) as connections,
    count(*) filter (where state = 'active') as active,
    count(*) filter (where state = 'idle') as idle,
    count(*) filter (where state = 'idle in transaction') as idle_in_transaction
FROM pg_stat_activity
GROUP BY datname
ORDER BY connections DESC;

-- Blocking queries
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- 5. Maintenance Operations
-- =========================

-- Vacuum and analyze statistics
SELECT 
    schemaname,
    tablename,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables
ORDER BY last_autovacuum DESC NULLS LAST;

-- Tables that need vacuum
SELECT 
    schemaname,
    tablename,
    n_dead_tup,
    n_live_tup,
    round(n_dead_tup::numeric / nullif(n_live_tup + n_dead_tup, 0) * 100, 2) as dead_tuple_percent
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_tuple_percent DESC;

-- 6. Replication Monitoring (if applicable)
-- =========================================

-- Replication lag
SELECT 
    client_addr,
    application_name,
    state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) as send_lag,
    pg_wal_lsn_diff(sent_lsn, write_lsn) as write_lag,
    pg_wal_lsn_diff(write_lsn, flush_lsn) as flush_lag,
    pg_wal_lsn_diff(flush_lsn, replay_lsn) as replay_lag
FROM pg_stat_replication;

-- 7. Configuration Recommendations
-- ================================

-- Check important settings
SELECT 
    name,
    setting,
    unit,
    context,
    short_desc
FROM pg_settings
WHERE name IN (
    'shared_buffers',
    'effective_cache_size',
    'work_mem',
    'maintenance_work_mem',
    'checkpoint_completion_target',
    'wal_buffers',
    'default_statistics_target',
    'random_page_cost',
    'seq_page_cost'
)
ORDER BY name;

-- 8. Automated Maintenance Tasks
-- ==============================

-- Create maintenance functions
CREATE OR REPLACE FUNCTION maintenance_vacuum_analyze()
RETURNS void AS $$
DECLARE
    rec record;
BEGIN
    FOR rec IN 
        SELECT schemaname, tablename 
        FROM pg_stat_user_tables 
        WHERE n_dead_tup > 1000
    LOOP
        EXECUTE format('VACUUM ANALYZE %I.%I', rec.schemaname, rec.tablename);
        RAISE NOTICE 'Vacuumed and analyzed %.%', rec.schemaname, rec.tablename;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create index maintenance function
CREATE OR REPLACE FUNCTION maintenance_reindex_fragmented()
RETURNS void AS $$
DECLARE
    rec record;
BEGIN
    FOR rec IN 
        SELECT schemaname, tablename, indexname
        FROM pg_stat_user_indexes
        WHERE idx_scan > 0  -- Only reindex used indexes
    LOOP
        EXECUTE format('REINDEX INDEX %I.%I', rec.schemaname, rec.indexname);
        RAISE NOTICE 'Reindexed %.%', rec.schemaname, rec.indexname;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 9. Backup and Recovery Helpers
-- ==============================

-- Check WAL archiving status
SELECT 
    archived_count,
    last_archived_wal,
    last_archived_time,
    failed_count,
    last_failed_wal,
    last_failed_time,
    stats_reset
FROM pg_stat_archiver;

-- Check point-in-time recovery info
SELECT 
    pg_is_in_recovery() as in_recovery,
    pg_last_wal_receive_lsn() as last_wal_received,
    pg_last_wal_replay_lsn() as last_wal_replayed,
    pg_last_xact_replay_timestamp() as last_xact_replay_time;

-- 10. Security and Audit Helpers
-- ==============================

-- Check user privileges
SELECT 
    r.rolname,
    r.rolsuper,
    r.rolinherit,
    r.rolcreaterole,
    r.rolcreatedb,
    r.rolcanlogin,
    r.rolconnlimit,
    r.rolvaliduntil
FROM pg_roles r
WHERE r.rolcanlogin = true
ORDER BY r.rolname;

-- Check database permissions
SELECT 
    d.datname,
    r.rolname,
    has_database_privilege(r.rolname, d.datname, 'CONNECT') as can_connect,
    has_database_privilege(r.rolname, d.datname, 'CREATE') as can_create
FROM pg_database d
CROSS JOIN pg_roles r
WHERE r.rolcanlogin = true
AND d.datistemplate = false
ORDER BY d.datname, r.rolname;