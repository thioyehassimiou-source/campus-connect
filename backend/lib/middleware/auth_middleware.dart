import 'package:shelf/shelf.dart';
import 'dart:convert';
import '../utils/jwt_utils.dart';

// Middleware for authentication
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip auth for certain routes
      if (request.url.path.startsWith('/auth/') || 
          request.url.path == '/health' ||
          request.method == 'OPTIONS') {
        return innerHandler(request);
      }
      
      final authHeader = request.headers['authorization'];
      
      if (authHeader == null) {
        return Response(401, body: json.encode({
          'success': false,
          'error': {'message': 'Authorization header required'},
        }), headers: {'content-type': 'application/json'});
      }
      
      if (!authHeader.startsWith('Bearer ')) {
        return Response(401, body: json.encode({
          'success': false,
          'error': {'message': 'Invalid authorization format'},
        }), headers: {'content-type': 'application/json'});
      }
      
      final token = authHeader.replaceFirst('Bearer ', '');
      
      try {
        final payload = await JwtUtils.validateAccessToken(token);
        
        // Add user info to request context
        final updatedRequest = request.change(
          context: {
            ...request.context,
            'userId': payload['userId'],
            'userEmail': payload['email'],
            'userRole': payload['role'],
          },
        );
        
        return innerHandler(updatedRequest);
      } catch (e) {
        return Response(401, body: json.encode({
          'success': false,
          'error': {'message': 'Invalid or expired token'},
        }), headers: {'content-type': 'application/json'});
      }
    };
  };
}

// Middleware for role-based access control
Middleware roleMiddleware(List<String> allowedRoles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final userRole = request.context['userRole'] as String?;
      
      if (userRole == null || !allowedRoles.contains(userRole)) {
        return Response(403, body: json.encode({
          'success': false,
          'error': {'message': 'Access denied: insufficient permissions'},
        }), headers: {'content-type': 'application/json'});
      }
      
      return innerHandler(request);
    };
  };
}

// Admin-only middleware
Middleware adminOnlyMiddleware() {
  return roleMiddleware(['administrateur']);
}

// Teacher or admin middleware
Middleware teacherOrAdminMiddleware() {
  return roleMiddleware(['enseignant', 'administrateur']);
}
