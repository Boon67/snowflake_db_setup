-- =================================================================
-- DATABASE RBAC SETUP - STEP 2: Create Database and Schema
-- =================================================================
-- This script creates the database and default schema, then grants
-- ownership to the admin role
-- =================================================================

-- Set the database name variable (must match Step 1)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;

-- =================================================================
-- Create Database
-- =================================================================

CREATE DATABASE IF NOT EXISTS IDENTIFIER($database_name)
    COMMENT = 'Database managed by role-based access control';

-- =================================================================
-- Create Default Schema
-- =================================================================

USE DATABASE IDENTIFIER($database_name);

CREATE SCHEMA IF NOT EXISTS PUBLIC
    COMMENT = 'Default public schema';

-- =================================================================
-- Grant Database Ownership to Admin Role
-- =================================================================

GRANT OWNERSHIP ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') 
    COPY CURRENT GRANTS;

GRANT OWNERSHIP ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_ADMIN') 
    COPY CURRENT GRANTS;

-- =================================================================
-- Grant Database Usage to Lower Roles
-- =================================================================

-- Grant database usage to all role levels
GRANT USAGE ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON DATABASE IDENTIFIER($database_name) 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- Grant schema usage to all role levels
GRANT USAGE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READONLY');

GRANT USAGE ON SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Verify Database and Ownership
-- =================================================================

SHOW DATABASES LIKE $database_name;

SHOW GRANTS ON DATABASE IDENTIFIER($database_name);

SHOW GRANTS ON SCHEMA IDENTIFIER($database_name || '.PUBLIC');
