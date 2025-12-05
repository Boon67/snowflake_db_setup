-- =================================================================
-- DATABASE RBAC COMPLETE SETUP SCRIPT
-- =================================================================
-- This consolidated script creates a 3-tier role hierarchy for
-- database access control and grants appropriate privileges
-- 
-- Role Hierarchy:
--   DB_<NAME>_ADMIN (Full administrative access)
--       ↓ inherits
--   DB_<NAME>_READWRITE (Read and write access)
--       ↓ inherits
--   DB_<NAME>_READONLY (Read-only access)
-- =================================================================

-- =================================================================
-- CONFIGURATION - CHANGE THIS
-- =================================================================

SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

-- =================================================================
-- SETUP - USE SYSADMIN ROLE
-- =================================================================

USE ROLE SYSADMIN;

-- =================================================================
-- SECTION 1: Create Role Hierarchy
-- =================================================================

-- Admin Role (Top Level)
CREATE ROLE IF NOT EXISTS IDENTIFIER($database_name || '_ADMIN')
    COMMENT = 'Administrator role for ' || $database_name || ' database with full privileges';

-- ReadWrite Role (Middle Level)
CREATE ROLE IF NOT EXISTS IDENTIFIER($database_name || '_READWRITE')
    COMMENT = 'Read-Write role for ' || $database_name || ' database with DML privileges';

-- ReadOnly Role (Base Level)
CREATE ROLE IF NOT EXISTS IDENTIFIER($database_name || '_READONLY')
    COMMENT = 'Read-Only role for ' || $database_name || ' database with SELECT privileges';

-- Establish role hierarchy
GRANT ROLE IDENTIFIER($database_name || '_READONLY') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT ROLE IDENTIFIER($database_name || '_READWRITE') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- Grant Admin role to SYSADMIN
GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO ROLE SYSADMIN;

-- =================================================================
-- SECTION 2: Create Database and Schema
-- =================================================================

CREATE DATABASE IF NOT EXISTS IDENTIFIER($database_name)
    COMMENT = 'Database managed by role-based access control';

USE DATABASE IDENTIFIER($database_name);

CREATE SCHEMA IF NOT EXISTS PUBLIC
    COMMENT = 'Default public schema';

-- Grant database ownership to Admin role
GRANT OWNERSHIP ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') 
    COPY CURRENT GRANTS;

GRANT OWNERSHIP ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') 
    COPY CURRENT GRANTS;

-- Grant database and schema usage to lower roles
GRANT USAGE ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT USAGE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- SECTION 3: Grant ReadOnly Privileges
-- =================================================================

-- SELECT on all existing tables and views
GRANT SELECT ON ALL TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON ALL VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- SELECT on all future tables and views
GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON FUTURE VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- USAGE on functions and procedures
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON ALL PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- READ on stages
GRANT READ ON ALL STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT READ ON FUTURE STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- USAGE on file formats
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- MONITOR on streams and tasks
GRANT MONITOR ON ALL STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON FUTURE STREAMS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON ALL TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT MONITOR ON FUTURE TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

-- =================================================================
-- SECTION 4: Grant ReadWrite Privileges
-- =================================================================

-- DML on all existing and future tables
GRANT INSERT, UPDATE, DELETE, TRUNCATE 
    ON ALL TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT INSERT, UPDATE, DELETE, TRUNCATE 
    ON FUTURE TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- WRITE on stages
GRANT WRITE ON ALL STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT WRITE ON FUTURE STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- CREATE privileges on schema
GRANT CREATE TABLE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE VIEW ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE STAGE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE FILE FORMAT ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE SEQUENCE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE FUNCTION ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT CREATE PROCEDURE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- OPERATE on tasks
GRANT OPERATE ON ALL TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT OPERATE ON FUTURE TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- SECTION 5: Grant Admin Privileges
-- =================================================================

-- CREATE SCHEMA privilege
GRANT CREATE SCHEMA ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- ALL PRIVILEGES on schema
GRANT ALL PRIVILEGES ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- ALL PRIVILEGES on all existing objects
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

-- ALL PRIVILEGES on all future objects
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

-- Role management privileges
GRANT ROLE IDENTIFIER($database_name || '_READONLY') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') WITH ADMIN OPTION;

GRANT ROLE IDENTIFIER($database_name || '_READWRITE') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') WITH ADMIN OPTION;

-- Database management privileges
GRANT MODIFY, MONITOR ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- SECTION 6: Verification
-- =================================================================

-- Show created roles
SHOW ROLES LIKE CONCAT($database_name, '%');

-- Show role hierarchy
SELECT 
    $database_name || '_READONLY' as role_name,
    'Base Level - Read Only' as level,
    'SELECT on all objects' as privileges
UNION ALL
SELECT 
    $database_name || '_READWRITE',
    'Middle Level - Read Write',
    'INSERT, UPDATE, DELETE, TRUNCATE + inherits ReadOnly'
UNION ALL
SELECT 
    $database_name || '_ADMIN',
    'Top Level - Admin',
    'CREATE, DROP, ALTER, OWNERSHIP + inherits ReadWrite';

-- Show grants to each role
SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_READONLY');
SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_READWRITE');
SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- Show database and schema details
SHOW DATABASES LIKE $database_name;
SHOW GRANTS ON DATABASE IDENTIFIER($database_name);
SHOW GRANTS ON SCHEMA IDENTIFIER($database_name || '.PUBLIC');

-- =================================================================
-- SECTION 7: User Assignment (Optional - Uncomment to Use)
-- =================================================================

-- Grant roles to individual users:
-- GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO USER analyst_user;
-- GRANT ROLE IDENTIFIER($database_name || '_READWRITE') TO USER data_engineer;
-- GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO USER database_admin;

-- =================================================================
-- SECTION 8: Testing (Optional - Uncomment to Test)
-- =================================================================

/*
-- Test ReadOnly access
USE ROLE IDENTIFIER($database_name || '_READONLY');
USE DATABASE IDENTIFIER($database_name);
SELECT CURRENT_ROLE() as role, CURRENT_DATABASE() as database;
-- CREATE TABLE test (id INT);  -- Should fail

-- Test ReadWrite access
USE ROLE IDENTIFIER($database_name || '_READWRITE');
CREATE TABLE test_table (id INT, name VARCHAR(100));
INSERT INTO test_table VALUES (1, 'Test');
SELECT * FROM test_table;
-- ALTER TABLE test_table ADD COLUMN email VARCHAR(255);  -- Should fail
DROP TABLE test_table;

-- Test Admin access
USE ROLE IDENTIFIER($database_name || '_ADMIN');
CREATE TABLE admin_test (id INT);
ALTER TABLE admin_test ADD COLUMN name VARCHAR(100);
DROP TABLE admin_test;
CREATE SCHEMA test_schema;
DROP SCHEMA test_schema;
*/

-- =================================================================
-- SETUP COMPLETE
-- =================================================================

SELECT 
    '✓ RBAC Setup Complete!' as status,
    $database_name as database_name,
    $database_name || '_READONLY' as readonly_role,
    $database_name || '_READWRITE' as readwrite_role,
    $database_name || '_ADMIN' as admin_role;
