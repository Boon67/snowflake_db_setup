-- =================================================================
-- DATABASE RBAC SETUP - STEP 5: Grant Admin Privileges
-- =================================================================
-- This script grants full administrative privileges to the Admin role
-- including CREATE, DROP, ALTER, and ownership management
-- Note: Admin inherits all ReadWrite and ReadOnly privileges
-- =================================================================

-- Set the database name variable (must match previous steps)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;
USE DATABASE IDENTIFIER($database_name);

-- =================================================================
-- Grant Full DDL Privileges on Schema
-- =================================================================

GRANT CREATE SCHEMA ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Grant Full Privileges on All Existing Objects
-- =================================================================

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON ALL TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Grant Full Privileges on All Future Objects
-- =================================================================

GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE SEQUENCES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Grant Role Management Privileges
-- =================================================================

-- Allow admin to grant/revoke the database roles to users
GRANT ROLE IDENTIFIER($database_name || '_READONLY') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') WITH ADMIN OPTION;

GRANT ROLE IDENTIFIER($database_name || '_READWRITE') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') WITH ADMIN OPTION;

-- =================================================================
-- Grant Database Management Privileges
-- =================================================================

GRANT MODIFY, MONITOR ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Verify Admin Grants
-- =================================================================

SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Test Admin Access (Optional)
-- =================================================================

/*
-- Switch to Admin role and test
USE ROLE IDENTIFIER($database_name || '_ADMIN');
USE DATABASE IDENTIFIER($database_name);
USE SCHEMA PUBLIC;

-- This should all work
CREATE TABLE test_admin (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO test_admin (id, name) VALUES (1, 'Admin Test');

ALTER TABLE test_admin ADD COLUMN email VARCHAR(255);

SELECT * FROM test_admin;

DROP TABLE test_admin;

-- Create a new schema
CREATE SCHEMA test_schema;
DROP SCHEMA test_schema;

-- Grant roles to users (if you have test users)
-- GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO USER test_user;
*/
