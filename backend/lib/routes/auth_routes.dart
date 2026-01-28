import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:convert' as convert;

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/response_utils.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // Register user
    router.post('/register', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        final createRequest = CreateUserRequest(
          email: data['email'],
          password: data['password'],
          firstName: data['first_name'],
          lastName: data['last_name'],
          role: UserRole.values.firstWhere(
            (role) => role.name == data['role'],
            orElse: () => UserRole.etudiant,
          ),
          phone: data['phone'],
          department: data['department'],
          studentId: data['student_id'],
        );

        final result = await AuthService.register(createRequest);
        
        return Response.ok(
          json.encode(result.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Login user
    router.post('/login', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        final loginRequest = LoginRequest(
          email: data['email'],
          password: data['password'],
        );

        final result = await AuthService.login(loginRequest);
        
        return Response.ok(
          json.encode(result.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return ResponseUtils.errorResponse(401, e.toString());
      }
    });

    // Logout user
    router.post('/logout', (Request request) async {
      try {
        final authHeader = request.headers['authorization'];
        if (authHeader == null) {
          return ResponseUtils.errorResponse(401, 'Authorization header required');
        }

        final token = authHeader.replaceFirst('Bearer ', '');
        await AuthService.logout(token);
        
        return Response.ok(
          json.encode({'message': 'Logout successful'}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Get current user profile
    router.get('/profile', (Request request) async {
      try {
        final authHeader = request.headers['authorization'];
        if (authHeader == null) {
          return ResponseUtils.errorResponse(401, 'Authorization header required');
        }

        final token = authHeader.replaceFirst('Bearer ', '');
        final user = await AuthService.getCurrentUser(token);
        
        return Response.ok(
          json.encode(user.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return ResponseUtils.errorResponse(401, e.toString());
      }
    });

    // Refresh token
    router.post('/refresh', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        final refreshToken = data['refreshToken'];
        final result = await AuthService.refreshToken(refreshToken);
        
        return Response.ok(
          json.encode(result.toJson()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return ResponseUtils.errorResponse(401, e.toString());
      }
    });

    return router;
  }
}
