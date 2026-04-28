# Database Migrations - CampusConnect

## Versioning Scheme

- Format: `V###__description.sql` (e.g., `V001__create_users.sql`)
- Executed in **lexicographic order** (V001 → V051)
- **Immutable** once executed in production
- Each migration must be idempotent where possible

## Migration Execution Order

Migrations are executed sequentially from V001 to V051. This is the authoritative order.

### Core Schema Migrations (V001-V024)

| Version | Filename | Purpose | Status |
|---------|----------|---------|--------|
| V001 | add_reply_logic.sql | Messaging replies support | Pending Audit |
| V002 | add_scope_columns.sql | Scope-based access control | Pending Audit |
| V003 | add_service_id_to_announcements.sql | Service link for announcements | Pending Audit |
| V004 | check_user.sql | User validation utility | Pending Audit |
| V005 | cleanup_duplicate_services.sql | Data cleanup | Pending Audit |
| V006 | create_academic_calendar_table.sql | Academic calendar | Core |
| V007 | create_academic_tables.sql | Academic entities | Core |
| V008 | create_admin_activity_logs.sql | Admin audit trail | Core |
| V009 | create_announcements_table.sql | Announcements feature | Core |
| V010 | create_assignments_tables.sql | Assignments management | Core |
| V011 | create_assignment_submissions_table.sql | Assignment submissions | Core |
| V012 | create_attendance_table.sql | Attendance tracking | Core |
| V013 | create_campus_services_table.sql | Campus services | Core |
| V014 | create_campus_tables.sql | Campus data | Core |
| V015 | create_chat_tables.sql | Messaging system | Core |
| V016 | create_courses_table.sql | Courses | Core |
| V017 | create_filieres.sql | Academic programs | Core |
| V018 | create_grades_table.sql | Grades management | Core |
| V019 | create_notifications_table.sql | Notifications system | Core |
| V020 | create_resources_bucket.sql | Resources storage | Core |
| V021 | create_resources_table.sql | Resource management | Core |
| V022 | create_rooms_tables.sql | Room management | Core |
| V023 | create_schedules_table.sql | Timetables | Core |
| V024 | create_teacher_assignments.sql | Teacher assignments | Core |

### Configuration & Fixes (V025-V051)

| Version | Filename | Purpose | Status |
|---------|----------|---------|--------|
| V025 | enable_realtime.sql | Realtime subscriptions | Core |
| V026 | enhance_profiles.sql | User profile enhancements | Pending Audit |
| V027 | final_messaging_fix.sql | Messaging hotfix | Patch |
| V028 | final_register_fix.sql | Registration hotfix | Patch |
| V029 | fix_attendance_schema.sql | Attendance schema correction | Patch |
| V030 | fix_complet_schema.sql | Schema completion | Patch |
| V031 | fix_messaging_rls.sql | Messaging RLS policies | Security |
| V032 | fix_permissions.sql | Permission system fixes | Security |
| V033 | fix_recursion_force.sql | Recursion control | Patch |
| V034 | fix_registration.sql | Registration flow | Patch |
| V035 | fix_resources_rls.sql | Resource access control | Security |
| V036 | fix_schema_final.sql | Final schema adjustments | Patch |
| V037 | fix_submissions_table.sql | Submissions schema | Patch |
| V038 | force_trigger_fix.sql | Trigger management | Patch |
| V039 | integrate_services.sql | Service integration | Core |
| V040 | remove_trigger.sql | Trigger removal | Patch |
| V041 | restore_safety_trigger.sql | Safety trigger restoration | Patch |
| V042 | setup_storage.sql | Storage configuration | Core |
| V043 | supabase_diagnostic.sql | Diagnostic query | Utility |
| V044 | supabase_schema_fix.sql | Schema compatibility | Patch |
| V045 | test_isolation_rls.sql | RLS testing | Testing |
| V046 | update_chat_policies.sql | Chat security policies | Security |
| V047 | update_messaging_schema.sql | Messaging schema update | Patch |
| V048 | update_profiles_staff.sql | Staff profile updates | Patch |
| V049 | update_rls_policies_scope.sql | RLS scope improvements | Security |
| V050 | update_schedules_schema.sql | Schedule schema update | Patch |
| V051 | update_services_distinct_data.sql | Service data cleanup | Patch |

## ⚠️ CRITICAL AUDIT REQUIRED

The migration sequence shows multiple issues:

1. **Duplicate Creation & Fix Patterns**
   - Core creates (V006-V024) followed by immediate fixes (V027-V051)
   - Indicates potential schema design issues

2. **Multiple Hotfixes Without Root Cause Analysis**
   - V027: final_messaging_fix
   - V028: final_register_fix
   - V029-V038: Various fixes
   - → Suggests rushed initial implementation

3. **RLS Policy Fixes (V031, V035, V046, V049)**
   - Multiple security policy revisions
   - Requires security audit before next deployment

## Deployment Procedure

### First-Time Setup (Development)
```bash
cd database/
# Run each migration sequentially
psql -U postgres -d campusconnect -f migrations/V001__add_reply_logic.sql
psql -U postgres -d campusconnect -f migrations/V002__add_scope_columns.sql
# ... continue for all V###__*.sql files
```

### Automated Approach (Recommended)
```bash
# Using Flyway (recommended for production)
flyway -locations=filesystem:./migrations -schemas=public migrate

# Or using Liquibase
liquibase --changeLogFile=changelog.xml update
```

### Rollback Procedure

⚠️ **WARNING**: Rollback is destructive. Requires:
1. Database backup
2. Data export
3. Schema downgrade
4. Data restore

Currently **NO automatic rollback** supported. Implement before production.

## Next Steps

### Immediate (Sprint)
- [ ] Audit each migration for correctness
- [ ] Document rollback procedures for each critical migration
- [ ] Identify and consolidate redundant fixes
- [ ] Test migration sequence in fresh environment

### Short-term (1-2 weeks)
- [ ] Implement Flyway or Liquibase for automation
- [ ] Add migration validation tests
- [ ] Document each migration's purpose and dependencies
- [ ] Create emergency rollback playbook

### Long-term (1 month)
- [ ] Establish migration review process
- [ ] Consolidate V001-V051 into clean schema v2.0
- [ ] Remove all "fix" migrations
- [ ] Archive migration history

## History

- **Created**: 2026-04-28 during monorepo restructuring
- **Files**: V001-V051 (51 migrations, sorted alphabetically)
- **Status**: Pending comprehensive audit and validation
- **Dependencies**: PostgreSQL 12+, Supabase compatible

---

**Last Updated**: 2026-04-28  
**Reviewed By**: Senior Architecture Audit
