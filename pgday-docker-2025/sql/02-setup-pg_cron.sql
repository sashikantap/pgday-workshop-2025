-- Setup pg_cron extension in pgday database
-- Connect to the target database and create pg_cron
\c pgday

-- Check if pg_cron library is available
SELECT name, setting FROM pg_settings WHERE name = 'shared_preload_libraries';

-- List available extensions
SELECT name FROM pg_available_extensions WHERE name LIKE '%cron%';

DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    RAISE NOTICE 'Created pg_cron extension in pgday database';
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Failed to create pg_cron in pgday database: %', SQLERRM;
END$$;

-- Grant necessary permissions for pg_cron usage
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;

-- Verify pg_cron installation
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_cron';

-- Example: Create a simple cron job (commented out)
-- SELECT cron.schedule('test-job', '*/5 * * * *', 'SELECT now();');
