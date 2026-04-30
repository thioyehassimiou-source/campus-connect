# ============================================================================
# DART BUILD ARTIFACTS
# ============================================================================
.dart_tool/
.packages
build/
*.g.dart
*.pbserver.dart
*.pbjson.dart

# ============================================================================
# FLUTTER BUILD ARTIFACTS
# ============================================================================
coverage/
lib/generated_plugin_registrant.dart
.flutter-plugins
.flutter-plugins-dependencies
**/doc/api/
**/ios/Flutter/.last_build_id
.pub-cache/
.pub/

# ============================================================================
# PLATFORM-SPECIFIC BUILD FOLDERS (LOCAL ONLY - NEVER COMMIT)
# ============================================================================
# These are generated during `flutter build` and contain native code artifacts.
# They should be generated locally by each developer, not stored in git.
android/
ios/
windows/
linux/
macos/
web/

# ============================================================================
# BUILD OUTPUTS
# ============================================================================
*.apk
*.aar
*.dill
*.dill.sha1
*.jar
*.jks
*.jts
*.zip

# ============================================================================
# IDE & EDITOR CONFIGURATION
# ============================================================================
.vscode/
.idea/
*.iml
*.iws
*.ipr
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace

# ============================================================================
# OS FILES
# ============================================================================
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db
.directory
ehthumbs.db

# ============================================================================
# TEMPORARY & BACKUP FILES
# ============================================================================
*.tmp
*.bak
*.swp
*.swo
*~
.#*
\#*\#
*.class
*.log
*.pyc

# ============================================================================
# ENVIRONMENT & SECRETS
# ============================================================================
.env
.env.local
.env.*.local
.env.production.local
*.key
*.pem
*.keystore

# ============================================================================
# DART SPECIFIC
# ============================================================================
.analysis_cache
.dart_plugin/
pubspec.lock
.svn/
.fvm/

# ============================================================================
# BUILD SYSTEM ARTIFACTS
# ============================================================================
/.gradle/
/build/
/android/app/debug/
/android/app/profile/
/android/app/release/
.buildlog/
.history/
migrate_working_dir/

# ============================================================================
# SUPABASE LOCAL DEVELOPMENT
# ============================================================================
.supabase/
supabase/.env.local

# ============================================================================
# NODE.JS (for potential backend migration)
# ============================================================================
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
pnpm-debug.log*

# ============================================================================
# MISCELLANEOUS
# ============================================================================
.vercel
*.symbols
*.map.json
.atom/
.buildbot
migrate_working_dir/

# ============================================================================
# INTENTIONALLY PRESERVED
# ============================================================================
# Archive folder contains legacy code and should be version-controlled
# !.archive/

# Test screens (local only)
lib/screens/test_*.dart
test_profile.dart

# Vercel / Env
.env*
.vercel

