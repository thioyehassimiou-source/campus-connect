import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/response_utils.dart';
import '../utils/jwt_utils.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    // Get all users (admin only)
    router.get('/', (Request request) async {
      try {
        final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
        final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
        final role = request.url.queryParameters['role'];
        
        final result = await UserService.getUsers(
          page: page,
          limit: limit,
          role: role,
        );
        
        return ResponseUtils.paginatedResponse(
          result['users'],
          page,
          limit,
          result['total'],
        );
      } catch (e) {
        return ResponseUtils.errorResponse(500, e.toString());
      }
    });

    // Get user by ID
    router.get('/<id>', (Request request, String id) async {
      try {
        final user = await UserService.getUserById(id);
        return ResponseUtils.successResponse(user);
      } catch (e) {
        return ResponseUtils.errorResponse(404, e.toString());
      }
    });

    // Update user
    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        final user = await UserService.updateUser(id, data);
        return ResponseUtils.successResponse(user);
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Delete user (admin only)
    router.delete('/<id>', (Request request, String id) async {
      try {
        await UserService.deleteUser(id);
        return ResponseUtils.successResponse({'message': 'User deleted successfully'});
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Get current user profile
    router.get('/me', (Request request) async {
      try {
        final authHeader = request.headers['authorization'];
        if (authHeader == null) {
          return ResponseUtils.errorResponse(401, 'Authorization header required');
        }

        final token = authHeader.replaceFirst('Bearer ', '');
        final payload = await JwtUtils.validateAccessToken(token);
        final userId = payload['userId'] as String;
        
        final user = await UserService.getUserById(userId);
        return ResponseUtils.successResponse(user);
      } catch (e) {
        return ResponseUtils.errorResponse(401, e.toString());
      }
    });

    // Update current user profile
    router.put('/me', (Request request) async {
      try {
        final authHeader = request.headers['authorization'];
        if (authHeader == null) {
          return ResponseUtils.errorResponse(401, 'Authorization header required');
        }

        final token = authHeader.replaceFirst('Bearer ', '');
        final payload = await JwtUtils.validateAccessToken(token);
        final userId = payload['userId'] as String;
        
        final body = await request.readAsString();
        final data = json.decode(body);
        
        final user = await UserService.updateUser(userId, data);
        return ResponseUtils.successResponse(user);
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    return router;
  }
}
