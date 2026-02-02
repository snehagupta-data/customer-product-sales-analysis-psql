-- ===========================================================================
-- SCHEMA SETUP
-- ===========================================================================
-- Terminate existing connections to the database (optional)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'data_wearhouse_analytics'
  AND pid <> pg_backend_pid();

-- Create schema 'gold' if it doesn't exist
CREATE SCHEMA IF NOT EXISTS gold;
