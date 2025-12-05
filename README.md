# Database RBAC Setup Scripts

## Overview
This set of scripts creates a complete 3-tier role-based access control (RBAC) hierarchy for a Snowflake database. The roles automatically inherit permissions from each other, providing a secure and scalable access management solution.

## 🚀 Quick Start (Recommended)

### Option 1: Single Consolidated Script ⚡
**File:** `Setup_Database_RBAC.sql`

The **fastest and easiest** way to set up complete RBAC for a database.

**Steps:**
1. Open `Setup_Database_RBAC.sql`
2. Change the database name variable (line 16):
   ```sql
   SET database_name = 'MY_DATABASE';  -- CHANGE THIS
   ```
3. Execute the entire script (select all and run)
4. Done! ✓

**Total Time: < 2 minutes**

---

### Option 2: Step-by-Step Scripts 📚
**Files:** Individual numbered scripts (1-7)

Use when you need granular control or want to learn RBAC concepts in detail.

| Step | File | Purpose | Time |
|------|------|---------|------|
| 1 | `1_Create_Roles.sql` | Create 3-tier role hierarchy | < 1 min |
| 2 | `2_Create_Database.sql` | Create database and grant ownership | < 1 min |
| 3 | `3_Grant_ReadOnly.sql` | Grant SELECT privileges | < 1 min |
| 4 | `4_Grant_ReadWrite.sql` | Grant DML privileges | < 1 min |
| 5 | `5_Grant_Admin.sql` | Grant full administrative privileges | < 1 min |
| 6 | `6_Grant_To_Users.sql` | Assign roles to users | As needed |
| 7 | `7_Verification_Testing.sql` | Verify setup and run tests | 2-3 min |

**Total Time: ~5-10 minutes**

**Steps:**
1. Change `database_name` variable in **each script**
2. Execute scripts in order:
   ```sql
   USE ROLE SYSADMIN;
   
   @1_Create_Roles.sql
   @2_Create_Database.sql
   @3_Grant_ReadOnly.sql
   @4_Grant_ReadWrite.sql
   @5_Grant_Admin.sql
   @6_Grant_To_Users.sql
   @7_Verification_Testing.sql
   ```

---

## When to Use Each Option

| Use Case | Recommended Option |
|----------|-------------------|
| Quick setup for new database | ✅ Consolidated Script |
| Standard RBAC configuration | ✅ Consolidated Script |
| Production deployment | ✅ Consolidated Script |
| Learning RBAC concepts | ✅ Step-by-Step Scripts |
| Custom privilege configuration | ✅ Step-by-Step Scripts |
| Troubleshooting specific grants | ✅ Step-by-Step Scripts |
| Need detailed verification | ✅ Step-by-Step Scripts |

---

## Role Hierarchy

```
┌─────────────────────────┐
│   DB_<NAME>_ADMIN       │  ← Full administrative access
│   • All DDL operations  │
│   • Create/Drop objects │
│   • Manage ownership    │
│   • Grant roles         │
└────────────┬────────────┘
             │ inherits
             ▼
┌─────────────────────────┐
│  DB_<NAME>_READWRITE    │  ← Read and write access
│  • INSERT, UPDATE       │
│  • DELETE, TRUNCATE     │
│  • Create objects       │
└────────────┬────────────┘
             │ inherits
             ▼
┌─────────────────────────┐
│  DB_<NAME>_READONLY     │  ← Read-only access
│  • SELECT on all tables │
│  • View metadata        │
└─────────────────────────┘
```

## Detailed Role Capabilities

### ReadOnly Role
**Can:**
- SELECT from all tables and views
- View metadata (SHOW commands)
- Use functions and procedures
- List stage contents (READ)
- Monitor streams and tasks

**Cannot:**
- Insert, update, or delete data
- Create, alter, or drop objects
- Execute tasks
- Write to stages

### ReadWrite Role
**Inherits ReadOnly, plus can:**
- INSERT, UPDATE, DELETE data
- TRUNCATE tables
- CREATE objects (tables, views, stages, functions, etc.)
- WRITE to stages
- OPERATE tasks (start/suspend)

**Cannot:**
- ALTER or DROP objects they don't own
- Change ownership
- Grant roles to users

### Admin Role
**Inherits ReadWrite, plus can:**
- ALTER and DROP any object
- Manage ownership
- Create and drop schemas
- Grant database roles to users (WITH ADMIN OPTION)
- Full database administration

---

## After Setup: Assigning Users

### Using Consolidated Script
In `Setup_Database_RBAC.sql`, uncomment Section 7:
```sql
-- Grant roles to individual users:
GRANT ROLE IDENTIFIER($database_name || '_READONLY') TO USER analyst_user;
GRANT ROLE IDENTIFIER($database_name || '_READWRITE') TO USER data_engineer;
GRANT ROLE IDENTIFIER($database_name || '_ADMIN') TO USER database_admin;
```

### Using Step-by-Step Scripts
Run script 6 or use stored procedures in `6_Grant_To_Users.sql`:
```sql
CALL sp_grant_database_access('john_doe', 'READONLY');
CALL sp_grant_database_access('jane_smith', 'READWRITE');
CALL sp_grant_database_access('admin_user', 'ADMIN');
```

---

## Key Features

### 1. Future Grants
All roles automatically receive privileges on **future objects**:
```sql
GRANT SELECT ON FUTURE TABLES IN SCHEMA ... TO ROLE ...
```
No need to re-run grants when creating new objects!

### 2. Role Inheritance
- ReadWrite inherits all ReadOnly privileges
- Admin inherits all ReadWrite privileges
- Simplifies management and reduces grant complexity

### 3. Automated Verification
Both options include verification:
- **Consolidated Script**: Built-in verification in Section 6
- **Step-by-Step**: Comprehensive testing in Script 7

### 4. Multiple Schema Support
Easily extend to additional schemas by adding grants for new schema names.

---

## Configuration Options

### Warehouse Access
Add warehouse grants if needed:
```sql
GRANT USAGE ON WAREHOUSE YOUR_WAREHOUSE 
    TO ROLE IDENTIFIER($database_name || '_READWRITE');
```

### Custom Privileges
Add specialized privileges as needed:
```sql
-- Example: Allow ReadOnly to execute specific procedures
GRANT USAGE ON PROCEDURE my_report_procedure() 
    TO ROLE IDENTIFIER($database_name || '_READONLY');
```

### Multiple Databases
To set up RBAC for multiple databases:

**Using consolidated script:**
1. Run script with first database name
2. Change `database_name` variable
3. Run script again

**Using step-by-step:**
1. Execute all steps for first database
2. Change `database_name` in each script
3. Execute all steps again

---

## Monitoring & Maintenance

### View Current Role Assignments
```sql
-- Users assigned to roles
SHOW GRANTS OF ROLE DB_MY_DATABASE_READONLY;
SHOW GRANTS OF ROLE DB_MY_DATABASE_READWRITE;
SHOW GRANTS OF ROLE DB_MY_DATABASE_ADMIN;

-- All grants to a specific user
SHOW GRANTS TO USER your_username;
```

### Audit Role Usage
```sql
-- Query history by role
SELECT 
    query_text,
    role_name,
    user_name,
    execution_status,
    start_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE role_name LIKE 'DB_MY_DATABASE_%'
  AND start_time > DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

### Review Privilege Grants
```sql
-- All privileges granted to a role
SELECT 
    privilege,
    granted_on,
    name as object_name,
    granted_by,
    created_on
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE grantee_name = 'DB_MY_DATABASE_ADMIN'
  AND deleted_on IS NULL
ORDER BY created_on DESC;
```

---

## Best Practices

### 1. Naming Convention
- Always use `DB_<DATABASE_NAME>_<LEVEL>` format
- Makes roles easily identifiable
- Prevents conflicts across databases

### 2. Principle of Least Privilege
- Start users with ReadOnly role
- Promote to ReadWrite only when needed
- Limit Admin role to true administrators

### 3. Role Assignment
- Grant roles to users, not directly to privileges
- Use role hierarchy to simplify management
- Document user → role mappings

### 4. Regular Audits
- Review role assignments quarterly
- Remove inactive users
- Validate privilege grants

### 5. Integration with Organization Roles
```sql
-- Example: Link to existing org structure
GRANT ROLE DB_MY_DATABASE_READONLY TO ROLE ANALYST_TEAM;
GRANT ROLE DB_MY_DATABASE_READWRITE TO ROLE DATA_ENGINEERING_TEAM;
GRANT ROLE DB_MY_DATABASE_ADMIN TO ROLE DATABASE_ADMIN_TEAM;
```

---

## Troubleshooting

### Issue: "Insufficient privileges" errors
**Solution:** Check current role and database context:
```sql
SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

-- Switch role
USE ROLE DB_MY_DATABASE_ADMIN;
```

### Issue: Future grants not working
**Solution:** Future grants only apply to NEW objects. Existing objects need explicit grants:
```sql
-- Grant on existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA ... TO ROLE ...;

-- Future tables will inherit automatically
```

### Issue: Cannot grant role to user
**Solution:** Ensure you have appropriate privileges with SYSADMIN:
```sql
-- Check if you have admin option
SHOW GRANTS OF ROLE DB_MY_DATABASE_ADMIN;

-- Use SYSADMIN to grant initially
USE ROLE SYSADMIN;
GRANT ROLE DB_MY_DATABASE_ADMIN TO USER your_username 
    WITH ADMIN OPTION;

-- Note: If still encountering issues, may need ACCOUNTADMIN for specific operations
```

---

## Testing Your Setup

### Quick Verification (Consolidated Script)
Section 6 automatically shows:
- Created roles and hierarchy
- All grants to each role
- Database and schema details

### Comprehensive Testing (Step-by-Step)
Run script 7 for automated tests:
```sql
@7_Verification_Testing.sql
```

This includes:
- Permission validation for each role
- Role hierarchy verification
- Test table operations
- Automated test procedure

### Manual Testing
```sql
-- Test ReadOnly (should succeed)
USE ROLE DB_MY_DATABASE_READONLY;
SELECT * FROM my_table LIMIT 10;

-- Test ReadOnly (should fail)
INSERT INTO my_table VALUES (1, 'test');  -- Expected: Insufficient privileges

-- Test ReadWrite (should succeed)
USE ROLE DB_MY_DATABASE_READWRITE;
INSERT INTO my_table VALUES (1, 'test');
UPDATE my_table SET col = 'updated' WHERE id = 1;

-- Test Admin (should succeed)
USE ROLE DB_MY_DATABASE_ADMIN;
ALTER TABLE my_table ADD COLUMN new_col VARCHAR(100);
DROP TABLE IF EXISTS test_table;
```

---

## Advanced Scenarios

### Row-Level Security
Add row access policies to tables:
```sql
CREATE OR REPLACE ROW ACCESS POLICY employee_data_policy
AS (region VARCHAR) RETURNS BOOLEAN ->
    CASE 
        WHEN CURRENT_ROLE() = 'DB_MY_DATABASE_ADMIN' THEN TRUE
        WHEN region = CURRENT_USER() THEN TRUE
        ELSE FALSE
    END;

ALTER TABLE employees 
    ADD ROW ACCESS POLICY employee_data_policy ON (region);
```

### Column-Level Security
Add masking policies for sensitive data:
```sql
CREATE OR REPLACE MASKING POLICY mask_ssn AS (val STRING) 
    RETURNS STRING ->
    CASE 
        WHEN CURRENT_ROLE() IN ('DB_MY_DATABASE_ADMIN') THEN val
        ELSE '***-**-' || SUBSTRING(val, 8, 4)
    END;

ALTER TABLE employees 
    MODIFY COLUMN ssn SET MASKING POLICY mask_ssn;
```

### External Stage Access
Grant access to external stages:
```sql
-- Create storage integration (SYSADMIN or ACCOUNTADMIN with privileges required)
USE ROLE SYSADMIN;
CREATE STORAGE INTEGRATION s3_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/...'
    STORAGE_ALLOWED_LOCATIONS = ('s3://my-bucket/path/');

-- Grant usage to admin role
GRANT USAGE ON INTEGRATION s3_integration 
    TO ROLE DB_MY_DATABASE_ADMIN;
```

**Note:** Creating storage integrations may require ACCOUNTADMIN in some cases.

---

## Security Considerations

### 1. Admin Role Protection
- Limit Admin role grants
- Use MFA for admin users
- Enable session timeout policies

### 2. Audit Logging
- Enable ACCOUNT_USAGE monitoring
- Set up alerts for privilege changes
- Review access patterns regularly

### 3. Separation of Duties
- Keep production and development databases separate
- Use different role hierarchies per environment
- Implement approval workflows for Admin access

---

## Comparison: Consolidated vs Step-by-Step

| Feature | Consolidated Script | Step-by-Step Scripts |
|---------|-------------------|---------------------|
| **Setup Time** | < 2 minutes | 5-10 minutes |
| **Number of Files** | 1 | 7 |
| **Best For** | Quick setup, production | Learning, customization |
| **Verification** | Built-in (Section 6) | Separate script (#7) |
| **Testing** | Optional (commented) | Automated procedure |
| **Flexibility** | Standard config | Highly customizable |
| **Variable Changes** | Once | 7 times (one per script) |
| **Troubleshooting** | Harder to isolate issues | Easier per-section debugging |
| **Documentation** | Less verbose | More detailed comments |
| **Recommended For** | Most users | Advanced users, learners |

---

## Resources

- [Snowflake RBAC Overview](https://docs.snowflake.com/en/user-guide/security-access-control-overview)
- [Best Practices for Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-considerations)
- [Managing Roles](https://docs.snowflake.com/en/user-guide/security-access-control-manage-roles)

---

## Summary

**🎯 Recommendation:** 
- **New to RBAC?** Start with `Setup_Database_RBAC.sql` for quick setup
- **Need customization?** Use step-by-step scripts (1-7)
- **Learning?** Work through step-by-step scripts to understand each component

Both options create the exact same role hierarchy and grants - choose based on your workflow preference!

---

**Version:** 2.0  
**Last Updated:** December 2025  
**Maintained By:** Your Team
