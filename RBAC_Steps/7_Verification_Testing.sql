-- =================================================================
-- DATABASE RBAC SETUP - STEP 7: Verification and Testing
-- =================================================================
-- This script provides comprehensive verification queries and
-- test scenarios for the RBAC setup
-- =================================================================

-- Set the database name variable (must match previous steps)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;

-- =================================================================
-- VERIFICATION QUERIES
-- =================================================================

-- 1. Verify all roles were created
SELECT 
    'Role Verification' as check_type,
    name as role_name,
    comment as description,
    created_on,
    owner
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE name LIKE CONCAT($database_name, '%')
ORDER BY name;

-- 2. Verify role hierarchy
SELECT 
    'Role Hierarchy' as check_type,
    grantee_name as child_role,
    role as parent_role,
    granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE role LIKE CONCAT($database_name, '%')
   OR grantee_name LIKE CONCAT($database_name, '%')
ORDER BY grantee_name;

-- 3. Verify database and schema ownership
SHOW GRANTS ON DATABASE IDENTIFIER($database_name);
SHOW GRANTS ON SCHEMA IDENTIFIER($database_name || '.PUBLIC');

-- 4. Verify grants to ReadOnly role
SELECT 
    'ReadOnly Grants' as role_type,
    privilege,
    granted_on,
    name as object_name,
    granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = $database_name || '_READONLY'
  AND deleted_on IS NULL
ORDER BY granted_on, privilege;

-- 5. Verify grants to ReadWrite role
SELECT 
    'ReadWrite Grants' as role_type,
    privilege,
    granted_on,
    name as object_name,
    granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = $database_name || '_READWRITE'
  AND deleted_on IS NULL
ORDER BY granted_on, privilege;

-- 6. Verify grants to Admin role
SELECT 
    'Admin Grants' as role_type,
    privilege,
    granted_on,
    name as object_name,
    granted_by
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = $database_name || '_ADMIN'
  AND deleted_on IS NULL
ORDER BY granted_on, privilege;

-- 7. Summary of privilege counts by role
SELECT 
    grantee_name as role_name,
    granted_on as object_type,
    COUNT(DISTINCT privilege) as privilege_count,
    COUNT(*) as total_grants
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name LIKE CONCAT($database_name, '%')
  AND deleted_on IS NULL
GROUP BY grantee_name, granted_on
ORDER BY grantee_name, granted_on;

-- =================================================================
-- TEST SCENARIOS
-- =================================================================

-- Test 1: Create test table as Admin
USE ROLE IDENTIFIER($database_name || '_ADMIN');
USE DATABASE IDENTIFIER($database_name);
USE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE rbac_test_table (
    id INT AUTOINCREMENT,
    test_name VARCHAR(100),
    test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    test_role VARCHAR(50),
    PRIMARY KEY (id)
);

INSERT INTO rbac_test_table (test_name, test_role)
VALUES ('Admin created table', CURRENT_ROLE());

SELECT * FROM rbac_test_table;

-- Test 2: ReadOnly role - Should succeed
USE ROLE IDENTIFIER($database_name || '_READONLY');

-- This should work
SELECT 
    'ReadOnly Test' as test_scenario,
    CURRENT_ROLE() as current_role,
    COUNT(*) as record_count
FROM rbac_test_table;

-- This should fail
-- INSERT INTO rbac_test_table (test_name, test_role) 
-- VALUES ('ReadOnly attempted insert', CURRENT_ROLE());
-- Expected: SQL access control error: Insufficient privileges

-- Test 3: ReadWrite role - Should succeed for DML
USE ROLE IDENTIFIER($database_name || '_READWRITE');

-- This should work
INSERT INTO rbac_test_table (test_name, test_role)
VALUES ('ReadWrite insert test', CURRENT_ROLE());

UPDATE rbac_test_table 
SET test_name = 'ReadWrite updated record'
WHERE test_role = CURRENT_ROLE();

SELECT * FROM rbac_test_table WHERE test_role = CURRENT_ROLE();

-- This should fail (DDL not allowed)
-- ALTER TABLE rbac_test_table ADD COLUMN new_column VARCHAR(50);
-- Expected: SQL access control error: Insufficient privileges

-- DROP TABLE rbac_test_table;
-- Expected: SQL access control error: Insufficient privileges

-- Test 4: Admin role - Should succeed for everything
USE ROLE IDENTIFIER($database_name || '_ADMIN');

-- All operations should work
ALTER TABLE rbac_test_table ADD COLUMN description VARCHAR(255);

INSERT INTO rbac_test_table (test_name, test_role, description)
VALUES ('Admin full test', CURRENT_ROLE(), 'Admin can do everything');

SELECT * FROM rbac_test_table;

-- =================================================================
-- AUTOMATED TEST PROCEDURE
-- =================================================================

CREATE OR REPLACE PROCEDURE sp_test_rbac_permissions()
RETURNS TABLE(
    test_name VARCHAR,
    role_tested VARCHAR,
    operation VARCHAR,
    expected_result VARCHAR,
    actual_result VARCHAR,
    passed BOOLEAN
)
LANGUAGE SQL
AS
$$
DECLARE
    db_name VARCHAR DEFAULT CURRENT_DATABASE();
    results RESULTSET;
BEGIN
    -- Create test results table
    CREATE OR REPLACE TEMPORARY TABLE rbac_test_results (
        test_name VARCHAR,
        role_tested VARCHAR,
        operation VARCHAR,
        expected_result VARCHAR,
        actual_result VARCHAR,
        passed BOOLEAN
    );
    
    -- Test 1: ReadOnly SELECT (should pass)
    BEGIN
        EXECUTE IMMEDIATE 'USE ROLE IDENTIFIER(:1)' USING (db_name || '_READONLY');
        EXECUTE IMMEDIATE 'SELECT * FROM rbac_test_table LIMIT 1';
        INSERT INTO rbac_test_results VALUES (
            'ReadOnly SELECT',
            db_name || '_READONLY',
            'SELECT',
            'SUCCESS',
            'SUCCESS',
            TRUE
        );
    EXCEPTION
        WHEN OTHER THEN
            INSERT INTO rbac_test_results VALUES (
                'ReadOnly SELECT',
                db_name || '_READONLY',
                'SELECT',
                'SUCCESS',
                'FAILED: ' || SQLERRM,
                FALSE
            );
    END;
    
    -- Test 2: ReadOnly INSERT (should fail)
    BEGIN
        EXECUTE IMMEDIATE 'USE ROLE IDENTIFIER(:1)' USING (db_name || '_READONLY');
        EXECUTE IMMEDIATE 'INSERT INTO rbac_test_table (test_name) VALUES (''test'')';
        INSERT INTO rbac_test_results VALUES (
            'ReadOnly INSERT',
            db_name || '_READONLY',
            'INSERT',
            'FAIL',
            'UNEXPECTED SUCCESS',
            FALSE
        );
    EXCEPTION
        WHEN OTHER THEN
            INSERT INTO rbac_test_results VALUES (
                'ReadOnly INSERT',
                db_name || '_READONLY',
                'INSERT',
                'FAIL',
                'CORRECTLY FAILED',
                TRUE
            );
    END;
    
    -- Test 3: ReadWrite INSERT (should pass)
    BEGIN
        EXECUTE IMMEDIATE 'USE ROLE IDENTIFIER(:1)' USING (db_name || '_READWRITE');
        EXECUTE IMMEDIATE 'INSERT INTO rbac_test_table (test_name, test_role) VALUES (''RW Test'', CURRENT_ROLE())';
        INSERT INTO rbac_test_results VALUES (
            'ReadWrite INSERT',
            db_name || '_READWRITE',
            'INSERT',
            'SUCCESS',
            'SUCCESS',
            TRUE
        );
    EXCEPTION
        WHEN OTHER THEN
            INSERT INTO rbac_test_results VALUES (
                'ReadWrite INSERT',
                db_name || '_READWRITE',
                'INSERT',
                'SUCCESS',
                'FAILED: ' || SQLERRM,
                FALSE
            );
    END;
    
    -- Test 4: ReadWrite ALTER (should fail)
    BEGIN
        EXECUTE IMMEDIATE 'USE ROLE IDENTIFIER(:1)' USING (db_name || '_READWRITE');
        EXECUTE IMMEDIATE 'ALTER TABLE rbac_test_table ADD COLUMN test_col VARCHAR(10)';
        INSERT INTO rbac_test_results VALUES (
            'ReadWrite ALTER',
            db_name || '_READWRITE',
            'ALTER',
            'FAIL',
            'UNEXPECTED SUCCESS',
            FALSE
        );
    EXCEPTION
        WHEN OTHER THEN
            INSERT INTO rbac_test_results VALUES (
                'ReadWrite ALTER',
                db_name || '_READWRITE',
                'ALTER',
                'FAIL',
                'CORRECTLY FAILED',
                TRUE
            );
    END;
    
    -- Test 5: Admin ALTER (should pass)
    BEGIN
        EXECUTE IMMEDIATE 'USE ROLE IDENTIFIER(:1)' USING (db_name || '_ADMIN');
        EXECUTE IMMEDIATE 'ALTER TABLE rbac_test_table ADD COLUMN IF NOT EXISTS admin_test_col VARCHAR(10)';
        INSERT INTO rbac_test_results VALUES (
            'Admin ALTER',
            db_name || '_ADMIN',
            'ALTER',
            'SUCCESS',
            'SUCCESS',
            TRUE
        );
    EXCEPTION
        WHEN OTHER THEN
            INSERT INTO rbac_test_results VALUES (
                'Admin ALTER',
                db_name || '_ADMIN',
                'ALTER',
                'SUCCESS',
                'FAILED: ' || SQLERRM,
                FALSE
            );
    END;
    
    -- Return results
    results := (SELECT * FROM rbac_test_results ORDER BY test_name);
    RETURN TABLE(results);
END;
$$;

-- Run the automated test
CALL sp_test_rbac_permissions();

-- =================================================================
-- CLEANUP TEST OBJECTS
-- =================================================================

USE ROLE IDENTIFIER($database_name || '_ADMIN');

-- Keep test table for reference or drop it
-- DROP TABLE IF EXISTS rbac_test_table;

-- =================================================================
-- SUMMARY REPORT
-- =================================================================

SELECT 
    '=== RBAC Setup Summary ===' as section,
    NULL as detail
UNION ALL
SELECT 
    'Database',
    $database_name
UNION ALL
SELECT 
    'ReadOnly Role',
    $database_name || '_READONLY'
UNION ALL
SELECT 
    'ReadWrite Role',
    $database_name || '_READWRITE'
UNION ALL
SELECT 
    'Admin Role',
    $database_name || '_ADMIN'
UNION ALL
SELECT
    'Role Hierarchy',
    'READONLY < READWRITE < ADMIN'
UNION ALL
SELECT
    'Setup Status',
    'Complete - Verify tests above';
