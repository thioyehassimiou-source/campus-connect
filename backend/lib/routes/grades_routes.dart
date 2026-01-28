import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../utils/response_utils.dart';

class GradesRoutes {
  Router get router {
    final router = Router();

    // Get grades for current user
    router.get('/', (Request request) async {
      try {
        // TODO: Implement grades logic
        return ResponseUtils.successResponse([
          {
            'id': '1',
            'subject': 'Mathématiques',
            'grade': 15.5,
            'coefficient': 3.0,
            'comment': 'Bon travail',
            'semester': 'S1',
            'academicYear': '2023-2024',
            'teacher': 'Prof. Dupont',
          }
        ]);
      } catch (e) {
        return ResponseUtils.errorResponse(500, e.toString());
      }
    });

    // Add new grade
    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        // TODO: Implement grade creation
        return ResponseUtils.successResponse({
          'id': '1',
          'message': 'Grade added successfully',
          'data': data,
        });
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Update grade
    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body);
        
        // TODO: Implement grade update
        return ResponseUtils.successResponse({
          'id': id,
          'message': 'Grade updated successfully',
          'data': data,
        });
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    // Delete grade
    router.delete('/<id>', (Request request, String id) async {
      try {
        // TODO: Implement grade deletion
        return ResponseUtils.successResponse({
          'message': 'Grade deleted successfully',
        });
      } catch (e) {
        return ResponseUtils.errorResponse(400, e.toString());
      }
    });

    return router;
  }
}
