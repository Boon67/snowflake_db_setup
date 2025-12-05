-- =================================================================
-- DATABASE RBAC SETUP - STEP 6: Grant Roles to Users
-- =================================================================
-- This script provides templates for granting the database roles
-- to specific users or other roles
-- =================================================================

-- Set the database name variable (must match previous steps)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;

-- =================================================================
-- Grant Roles to Individual Users
-- =================================================================

-- Grant ReadOnly role to users
-- GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO USER user1;
-- GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO USER user2;

-- Grant ReadWrite role to users
-- GRANT ROLE IDENTIFIER($database_name || '_READWRITE') TO USER user3;
-- GRANT ROLE IDENTIFIER($database_name || '_READWRITE') TO USER user4;

-- Grant Admin role to users
-- GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO USER admin_user1;
-- GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO USER admin_user2;

-- =================================================================
-- Grant Roles to Other Roles (for hierarchical access)
-- =================================================================

-- Example: Grant database roles to existing organizational roles
-- GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO ROLE ANALYST_ROLE;
-- GRANT ROLE IDENTIFIER($database_name || '_READWRITE') TO ROLE DATA_ENGINEER_ROLE;
-- GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO ROLE DATA_ADMIN_ROLE;

-- =================================================================
-- Create Stored Procedure for User Management
-- =================================================================

USE DATABASE IDENTIFIER($database_name);
USE SCHEMA PUBLIC;

CREATE OR REPLACE PROCEDURE sp_grant_database_access(
    user_name VARCHAR,
    access_level VARCHAR  -- 'READONLY', 'READWRITE', or 'ADMIN'
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    db_name VARCHAR DEFAULT CURRENT_DATABASE();
    role_name VARCHAR;
    result VARCHAR;
BEGIN
    -- Construct role name based on access level
    role_name := db_name || '_' || UPPER(access_level);
    
    -- Grant the role to the user
    EXECUTE IMMEDIATE 'GRANT ROLE IDENTIFIER(:1) TO USER IDENTIFIER(:2)' 
        USING (role_name, user_name);
    
    result := 'Successfully granted ' || role_name || ' to user ' || user_name;
    RETURN result;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$;

-- =================================================================
-- Create Stored Procedure for Role Revocation
-- =================================================================

CREATE OR REPLACE PROCEDURE sp_revoke_database_access(
    user_name VARCHAR,
    access_level VARCHAR  -- 'READONLY', 'READWRITE', or 'ADMIN'
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    db_name VARCHAR DEFAULT CURRENT_DATABASE();
    role_name VARCHAR;
    result VARCHAR;
BEGIN
    -- Construct role name based on access level
    role_name := db_name || '_' || UPPER(access_level);
    
    -- Revoke the role from the user
    EXECUTE IMMEDIATE 'REVOKE ROLE IDENTIFIER(:1) FROM USER IDENTIFIER(:2)' 
        USING (role_name, user_name);
    
    result := 'Successfully revoked ' || role_name || ' from user ' || user_name;
    RETURN result;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'Error: ' || SQLERRM;
END;
$$;

-- =================================================================
-- Usage Examples for Stored Procedures
-- =================================================================

/*
-- Grant access using stored procedure
CALL sp_grant_database_access('john_doe', 'READONLY');
CALL sp_grant_database_access('jane_smith', 'READWRITE');
CALL sp_grant_database_access('admin_user', 'ADMIN');

-- Revoke access using stored procedure
CALL sp_revoke_database_access('john_doe', 'READONLY');
*/

-- =================================================================
-- View Current Role Assignments
-- =================================================================

-- Show all users with access to this database's roles
SHOW GRANTS OF ROLE IDENTIFIER($database_name || '_READONLY');
SHOW GRANTS OF ROLE IDENTIFIER($database_name || '_READWRITE');
SHOW GRANTS OF ROLE IDENTIFIER($database_name || '_ADMIN');

-- =================================================================
-- Query to List All Users and Their Database Access
-- =================================================================

SELECT 
    grantee_name as user_or_role,
    role as granted_role,
    granted_by,
    created_on as grant_date
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE role LIKE CONCAT($database_name, '%')
  AND deleted_on IS NULL
ORDER BY created_on DESC;

-- Alternative using GRANTS_TO_ROLES for role hierarchies
SELECT 
    grantee_name as role_receiving_grant,
    role as granted_role,
    granted_by,
    created_on as grant_date
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE role LIKE CONCAT($database_name, '%')
  AND deleted_on IS NULL
ORDER BY created_on DESC;

-- =================================================================
-- Bulk Grant Template (for multiple users)
-- =================================================================

/*
-- Create a table with user assignments
CREATE OR REPLACE TEMPORARY TABLE user_role_assignments (
    username VARCHAR,
    access_level VARCHAR
);

-- Insert user assignments
INSERT INTO user_role_assignments VALUES
    ('user1', 'READONLY'),
    ('user2', 'READONLY'),
    ('user3', 'READWRITE'),
    ('admin1', 'ADMIN');

-- Execute grants in bulk
DECLARE
    username VARCHAR;
    access_level VARCHAR;
    c1 CURSOR FOR SELECT username, access_level FROM user_role_assignments;
BEGIN
    FOR record IN c1 DO
        username := record.username;
        access_level := record.access_level;
        CALL sp_grant_database_access(:username, :access_level);
    END FOR;
END;
*/

-- =================================================================
-- Set Default Role for Users (Optional)
-- =================================================================

/*
-- Set default role for users so they automatically use it
ALTER USER user1 SET DEFAULT_ROLE = IDENTIFIER($database_name || '_READONLY');
ALTER USER user3 SET DEFAULT_ROLE = IDENTIFIER($database_name || '_READWRITE');
ALTER USER admin1 SET DEFAULT_ROLE = IDENTIFIER($database_name || '_ADMIN');
*/

-- =================================================================
-- Verify Grants
-- =================================================================

-- Check what roles a specific user has
-- SHOW GRANTS TO USER your_username;

-- Check current session privileges
SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA();
