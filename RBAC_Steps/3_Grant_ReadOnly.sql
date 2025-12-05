-- =================================================================
-- DATABASE RBAC SETUP - STEP 3: Grant ReadOnly Privileges
-- =================================================================
-- This script grants SELECT privileges on all existing and future
-- objects to the ReadOnly role
-- =================================================================

-- Set the database name variable (must match previous steps)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;
USE DATABASE IDENTIFIER($database_name);

-- =================================================================
-- Grant SELECT on All Existing Tables and Views
-- =================================================================

GRANT SELECT ON ALL TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON ALL VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Grant SELECT on All Future Tables and Views
-- =================================================================

GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON FUTURE VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Grant USAGE on Functions and Procedures
-- =================================================================

GRANT USAGE ON ALL FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON ALL PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Grant READ on Stages (for listing and metadata)
-- =================================================================

GRANT READ ON ALL STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT READ ON FUTURE STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Grant USAGE on File Formats
-- =================================================================

GRANT USAGE ON ALL FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Grant MONITOR on Streams and Tasks (view status only)
-- =================================================================

GRANT MONITOR ON ALL STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON FUTURE STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON ALL TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON FUTURE TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Verify ReadOnly Grants
-- =================================================================

SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- Test ReadOnly Access (Optional)
-- =================================================================

/*
-- Switch to ReadOnly role and test
USE ROLE IDENTIFIER($database_name || '_READONLY');
USE DATABASE IDENTIFIER($database_name);
USE SCHEMA PUBLIC;

-- This should work
SELECT CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_ROLE();
SHOW TABLES;

-- This should fail
CREATE TABLE test_readonly (id INT);  -- Expected: Insufficient privileges
*/
