import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart' show logRequests;

import '../lib/config/database.dart';
import '../lib/config/supabase_config.dart';
import '../lib/routes/auth_routes.dart';
import '../lib/routes/user_routes.dart';
import '../lib/routes/schedule_routes.dart';
import '../lib/routes/grades_routes.dart';
import '../lib/routes/announcements_routes.dart';
import '../lib/routes/documents_routes.dart';
import '../lib/middleware/auth_middleware.dart';

// Manual CORS middleware
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Handle preflight requests
      if (request.method == 'OPTIONS') {
        return Response.ok(
          null,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      // Add CORS headers to all responses
      final response = await innerHandler(request);
      
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          ...response.headers,
        },
      );
    };
  };
}

void main() async {
  // Load environment variables
  final env = DotEnv(includePlatformEnvironment: true)..load();
  
  // Initialize database
  await DatabaseConfig.initialize();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Create router
  final router = Router();
  
  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      '{"status": "healthy", "timestamp": "${DateTime.now().toIso8601String()}"}',
      headers: {'content-type': 'application/json'},
    );
  });
  
  // API routes
  router.mount('/auth', AuthRoutes().router);
  router.mount('/users', UserRoutes().router);
  router.mount('/schedule', ScheduleRoutes().router);
  router.mount('/grades', GradesRoutes().router);
  router.mount('/announcements', AnnouncementsRoutes().router);
  router.mount('/documents', DocumentsRoutes().router);
  
  // Apply middleware
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router);
  
  // Start server
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
  );
  
  print('🚀 CampusConnect Backend Server running on port ${server.port}');
  print('📊 Health check: http://localhost:${server.port}/health');
  print('🔗 API Base URL: http://localhost:${server.port}');
}
