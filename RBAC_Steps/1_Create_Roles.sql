-- =================================================================
-- DATABASE RBAC SETUP - STEP 1: Create Roles
-- =================================================================
-- This script creates a 3-tier role hierarchy for database access:
-- - DB_<NAME>_READONLY: Read-only access
-- - DB_<NAME>_READWRITE: Read and write access
-- - DB_<NAME>_ADMIN: Full administrative access
-- =================================================================

-- Set the database name variable
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;

-- =================================================================
-- Create Role Hierarchy
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

-- =================================================================
-- Establish Role Hierarchy
-- =================================================================
-- ReadWrite inherits ReadOnly permissions
-- Admin inherits ReadWrite permissions (and transitively ReadOnly)

GRANT ROLE IDENTIFIER($database_name || '_READONLY') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT ROLE IDENTIFIER($database_name || '_READWRITE') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Grant Admin Role to SYSADMIN (Best Practice)
-- =================================================================
GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO ROLE SYSADMIN;

-- =================================================================
-- Verify Role Creation
-- =================================================================

SHOW ROLES LIKE CONCAT($database_name, '%');

-- View role hierarchy
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
