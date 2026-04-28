# Frontend - CampusConnect

## Overview

This is the primary Flutter frontend application for CampusConnect, a comprehensive university ERP system.

## Architecture

The frontend is organized using **Clean Architecture** with **Feature-Based Structure**:

```
frontend/
├── features/                 # Domain-driven features
│   ├── admin/               # Admin dashboard & management
│   ├── announcements/        # Announcements management
│   ├── assignments/          # Assignments & submissions
│   ├── attendance/           # Attendance tracking
│   ├── auth/                 # Authentication & registration
│   ├── calendar/             # Academic calendar
│   ├── chat/                 # Messaging system
│   ├── grades/               # Grade management
│   ├── notifications/        # Notifications
│   ├── profile/              # User profiles
│   ├── resources/            # Resource sharing
│   ├── schedules/            # Timetables
│   ├── services/             # Campus services
│   └── ... (other domains)
│
├── core/                     # Application-wide configuration
│   ├── config/              # App settings
│   ├── constants/           # Constants & enums
│   ├── routing/             # Navigation & routing
│   ├── providers/           # Riverpod providers
│   └── services/            # Core services
│
├── shared/                   # Shared components
│   ├── design_system/       # Design System tokens
│   ├── widgets/             # Reusable widgets
│   ├── errors/              # Error handling
│   ├── utils/               # Utility functions
│   └── extensions/          # Dart extensions
│
├── models/                   # Data models
├── services/                 # Backend integration
├── controllers/              # Business logic (if needed)
├── messaging/                # Messaging-specific logic
├── main.dart                 # Entry point
└── screens/                  # Legacy screens (to be refactored)
```

## Technology Stack

- **Framework**: Flutter 3.7+
- **State Management**: Riverpod 2.4.9
- **Navigation**: GoRouter 13.1.0
- **Backend**: Supabase Flutter SDK 2.12.0
- **Design System**: Custom Flutter Widgets
- **Localization**: intl 0.20.0
- **Database**: PostgreSQL (via Supabase)

## Key Features

✅ Multi-platform support: Android, iOS, Web, Desktop (Windows, Linux, macOS)
✅ Real-time messaging with Supabase Realtime
✅ Role-based access control (Admin, Teacher, Student)
✅ PDF export capabilities
✅ Voice recording for messages
✅ Rich calendar & scheduling UI
✅ Emoji support in messaging

## Getting Started

### Prerequisites
- Flutter 3.7+ with Dart 3.0+
- Xcode (for iOS development)
- Android Studio (for Android development)
- Git

### Installation

```bash
# Get dependencies
flutter pub get

# Generate build files
flutter pub run build_runner build

# Run on development device
flutter run

# Build for specific platform
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
flutter build linux        # Linux
flutter build macos        # macOS
```

## Development Workflow

### Code Organization Rules

1. **Features Should Be Independent**
   - Each feature has its own lib, data, presentation folders
   - No cross-feature imports except through shared/

2. **Shared Resources**
   - Only use shared/ for truly reusable components
   - Design System lives in shared/design_system/
   - Generic utilities in shared/utils/

3. **Services & Backend Integration**
   - All API calls go through services/
   - Backend communication abstracted from UI
   - Service layer handles Supabase integration

4. **Riverpod Providers**
   - All state management through Riverpod
   - Providers organized by feature
   - No direct setState() or legacy Provider pattern

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/features/admin/

# Integration tests
flutter drive --target=test_driver/app.dart
```

## API Integration

The frontend connects to backend services through:
- **Supabase REST API** for data operations
- **Supabase Realtime** for live updates
- **PostgreSQL** via Supabase for database

### Example Service Call

```dart
class AnnouncementService {
  Future<List<Announcement>> getAnnouncements() async {
    final response = await supabase
        .from('announcements')
        .select()
        .execute();
    
    return (response.data as List)
        .map((x) => Announcement.fromJson(x))
        .toList();
  }
}
```

## Design System

The application uses a centralized Design System for consistency:

- **Colors**: Material 3 color scheme
- **Typography**: Google Fonts (Poppins, Inter)
- **Spacing**: 8px base unit system
- **Components**: Reusable Flutter widgets

See `shared/design_system/` for implementation.

## Performance Considerations

- ✅ Lazy-load features to reduce startup time
- ✅ Cache API responses with Riverpod
- ✅ Use const constructors where possible
- ✅ Profile with Flutter DevTools

## Known Issues & Limitations

1. **Legacy Screens Folder**
   - Some screens in `/screens/` should be migrated to features/
   - Refactoring plan: Move 1 screen per sprint

2. **State Management Migration**
   - Codebase transitioning to full Riverpod
   - Some legacy StateNotifier code remains
   - Planned cleanup: 2-week effort

3. **Testing Coverage**
   - Current coverage: ~60%
   - Target: 80% by end of Q2 2026

## Deployment

### Development Build
```bash
flutter build apk --debug
flutter build ios --debug
flutter build web --debug
```

### Production Build
```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```

For detailed deployment instructions, see `../docs/DEPLOYMENT.md`

## Contributing Guidelines

1. Create feature branch: `git checkout -b feature/feature-name`
2. Follow code standards: `flutter analyze`
3. Format code: `dart format .`
4. Write tests for new features
5. Submit PR with description

## Support & Issues

For bugs and feature requests, use GitHub Issues.

For architecture questions, contact: Senior Architecture Review Team

---

**Last Updated**: 2026-04-28  
**Migrated From**: `/lib/` → `/frontend/`  
**Status**: ✅ Production Ready (with noted improvements pending)
