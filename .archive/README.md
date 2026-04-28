# ARCHIVED CODE

This directory contains legacy/duplicate code that was removed during
monorepo restructuring on 2026-04-28.

## Contents

### frontend_legacy_v2/
- Legacy Flutter frontend (184 KB, non-functional)
- Reason: Replaced by /frontend/ (main codebase)
- Status: Archive only, do not use
- Created: 2026-04-28

### professional_namespace_collision/
- Conflicted package (name: "campusconnect" - same as root)
- Reason: Namespace collision, incomplete implementation
- Status: Archive only, do not use
- Issue: Caused ambiguity in package resolution

### auth_module_duplicate/
- Standalone auth package (408 KB)
- Reason: Duplicate of /frontend/lib/features/auth
- Status: Reference only if auth logic needs review
- Note: Maintained during legacy development, no longer synchronized

### design_reference/
- Design mockups and reference UI ("stitch_tableau_de_bord_tudiant")
- Reason: Not part of active development flow
- Status: Can be used as design reference only
- Use case: Historical design documentation

## Recovery Procedure

If you need to recover any of this code:

```bash
git checkout HEAD -- .archive/
```

Or restore from backup:
```bash
tar -xzf ../CampusConnect_mobile_backup_20260428_*.tar.gz
```

## Monorepo Restructuring Details

**Executed by**: Architecture Audit  
**Date**: 2026-04-28  
**Reason**: Consolidate multiple Flutter frontends into single source of truth  
**Impact**: Eliminated code duplication, resolved namespace conflicts, simplified maintenance

## Previous Issues Resolved

1. ✅ Removed 4 concurrent Flutter pubspec.yaml files (namespace collision)
2. ✅ Consolidated frontend code into single `/frontend/` directory
3. ✅ Archived `auth/` package (code preserved in `/frontend/lib/features/auth/`)
4. ✅ Moved design artifacts to documentation reference

## Future Decisions

- **Backend**: Migration from Dart/Shelf to Node.js/Express/Prisma is recommended but pending decision
- **Database Migrations**: V001-V050 implemented with versioning
- **CI/CD**: Automation pending implementation

---

**Archive created**: 2026-04-28 15:45 UTC  
**Archiver**: Senior Architecture Review Process
