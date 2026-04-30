import 'dart:io';

void main() async {
  final dir = Directory('lib');
  if (!await dir.exists()) return;

  final files = await dir.list(recursive: true).where((e) => e is File && e.path.endsWith('.dart')).toList();
  
  final Map<String, String> replacements = {
    "package:campusconnect/features/auth/presentation/auth_controller.dart": "package:campusconnect/controllers/auth_providers.dart",
    "package:campusconnect/features/auth/presentation/login_screen.dart": "package:campusconnect/screens/modern_login_screen.dart",
    "package:campusconnect/features/auth/presentation/register_screen.dart": "package:campusconnect/screens/modern_register_screen.dart",
    "package:campusconnect/features/home/presentation/student_dashboard.dart": "package:campusconnect/screens/modern_student_dashboard.dart",
    "package:campusconnect/features/home/presentation/teacher_dashboard.dart": "package:campusconnect/screens/modern_teacher_dashboard.dart",
    "package:campusconnect/features/home/presentation/admin_dashboard.dart": "package:campusconnect/screens/modern_admin_dashboard.dart",
    "package:campusconnect/features/auth/domain/user_model.dart": "package:campusconnect/models/user_model.dart",
    "package:campusconnect/features/academic/presentation/schedule_screen.dart": "package:campusconnect/screens/modern_schedule_screen.dart",
    "package:campusconnect/features/academic/presentation/documents_screen.dart": "package:campusconnect/screens/modern_resources_screen.dart",
    "package:campusconnect/features/notifications/presentation/screens/notifications_screen.dart": "package:campusconnect/screens/modern_notifications_screen.dart",
    "package:campusconnect/features/documents/presentation/screens/documents_screen.dart": "package:campusconnect/screens/modern_resources_screen.dart",
    "package:campusconnect/features/documents/presentation/screens/upload_document_screen.dart": "package:campusconnect/screens/modern_resources_screen.dart",
    "package:campusconnect/features/communication/presentation/announcements_screen.dart": "package:campusconnect/screens/modern_announcements_screen.dart",
    "package:campusconnect/features/communication/presentation/create_announcement_screen.dart": "package:campusconnect/screens/modern_announcements_screen.dart",
    "package:campusconnect/features/auth/presentation/profile_screen.dart": "package:campusconnect/screens/modern_profile_screen.dart",
    "package:campusconnect/features/academic/presentation/grades_screen.dart": "package:campusconnect/screens/modern_grades_screen.dart",
    "package:campusconnect/screens/services_screen.dart": "package:campusconnect/screens/modern_services_screen.dart",
    "package:campusconnect/features/campus/presentation/campus_map_screen.dart": "package:campusconnect/screens/modern_campus_map_screen.dart",
    "package:campusconnect/screens/emploi_du_temps_screen.dart": "package:campusconnect/screens/modern_schedule_screen.dart",
    "package:campusconnect/screens/annonces_screen.dart": "package:campusconnect/screens/modern_announcements_screen.dart",
    "package:campusconnect/screens/notes_screen.dart": "package:campusconnect/screens/modern_grades_screen.dart",
    "package:cloud_firestore/cloud_firestore.dart": "package:campusconnect/models/user_model.dart",
    "package:firebase_core/firebase_core.dart": "package:campusconnect/models/user_model.dart",
    "package:firebase_storage/firebase_storage.dart": "package:campusconnect/models/user_model.dart",
    "package:campusconnect/core/services/firebase_service.dart": "package:campusconnect/services/api_service.dart",
    "package:campusconnect/core/services/auth_service.dart": "package:campusconnect/services/auth_service.dart",
    "package:campusconnect/core/services/chat_service.dart": "package:campusconnect/messaging/services/messaging_service.dart",
    "../services/academique_service.dart": "package:campusconnect/core/services/academic_service.dart",
    "../services/communication_service.dart": "package:campusconnect/core/services/announcement_service.dart",
    "../services/infrastructure_service.dart": "package:campusconnect/core/services/campus_service.dart",
    "../services/user_service.dart": "package:campusconnect/core/services/profile_service.dart",
    "../shared/models/academique.dart": "package:campusconnect/models/academique.dart",
    "../data/schedule_service.dart": "package:campusconnect/core/services/schedule_service.dart",
    ".withOpacity(": ".withValues(alpha: "
  };

  for (var fileEntity in files) {
    File file = fileEntity as File;
    String content = await file.readAsString();
    bool changed = false;
    
    for (var entry in replacements.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        changed = true;
      }
    }
    
    if (changed) {
      await file.writeAsString(content);
      print("Updated \${file.path}");
    }
  }
}
