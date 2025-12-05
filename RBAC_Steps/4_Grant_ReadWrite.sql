-- =================================================================
-- DATABASE RBAC SETUP - STEP 4: Grant ReadWrite Privileges
-- =================================================================
-- This script grants DML privileges (INSERT, UPDATE, DELETE, TRUNCATE)
-- on all existing and future objects to the ReadWrite role
-- Note: ReadWrite inherits all ReadOnly privileges
-- =================================================================

-- Set the database name variable (must match previous steps)
SET database_name = 'MY_DATABASE';  -- CHANGE THIS TO YOUR DATABASE NAME

USE ROLE SYSADMIN;
USE DATABASE IDENTIFIER($database_name);

-- =================================================================
-- Grant DML on All Existing Tables
-- =================================================================

GRANT INSERT, UPDATE, DELETE, TRUNCATE 
    ON ALL TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Grant DML on All Future Tables
-- =================================================================

GRANT INSERT, UPDATE, DELETE, TRUNCATE 
    ON FUTURE TABLES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Grant WRITE on All Existing Stages
-- =================================================================

GRANT WRITE ON ALL STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT WRITE ON FUTURE STAGES IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Grant CREATE Privileges on Schema (for temp objects)
-- =================================================================

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

-- =================================================================
-- Grant OPERATE on Existing Tasks (start/suspend)
-- =================================================================

GRANT OPERATE ON ALL TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

GRANT OPERATE ON FUTURE TASKS IN SCHEMA IDENTIFIER($database_name || '.PUBLIC') 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Grant USAGE on Warehouses (Read from Config)
-- =================================================================
-- Note: You may want to create dedicated warehouses for this database
-- and grant usage to ReadWrite role

-- Example: Grant on existing warehouse
-- GRANT USAGE ON WAREHOUSE YOUR_WAREHOUSE 
--     TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Verify ReadWrite Grants
-- =================================================================

SHOW GRANTS TO ROLE IDENTIFIER($database_name || '_READWRITE');

-- =================================================================
-- Test ReadWrite Access (Optional)
-- =================================================================

/*
-- Switch to ReadWrite role and test
USE ROLE IDENTIFIER($database_name || '_READWRITE');
USE DATABASE IDENTIFIER($database_name);
USE SCHEMA PUBLIC;

-- This should work
CREATE TABLE test_readwrite (
    id INT,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO test_readwrite (id, name) VALUES (1, 'Test Record');
SELECT * FROM test_readwrite;
UPDATE test_readwrite SET name = 'Updated Record' WHERE id = 1;
DELETE FROM test_readwrite WHERE id = 1;

-- This should fail
DROP TABLE test_readwrite;  -- Expected: Insufficient privileges
ALTER TABLE test_readwrite ADD COLUMN new_col INT;  -- Expected: Insufficient privileges

-- Cleanup
-- DROP TABLE IF EXISTS test_readwrite;
*/
