import 'package:shelf/shelf.dart';
import 'dart:convert';

class ResponseUtils {
  static Response successResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: json.encode({
        'success': true,
        'data': data,
        'message': 'Operation successful',
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  static Response errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: json.encode({
        'success': false,
        'error': {
          'code': statusCode,
          'message': message,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  static Response validationErrorResponse(List<String> errors) {
    return Response(
      400,
      body: json.encode({
        'success': false,
        'error': {
          'code': 400,
          'message': 'Validation failed',
          'details': errors,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  static Response paginatedResponse(List<dynamic> data, int page, int limit, int total) {
    final totalPages = (total / limit).ceil();
    
    return Response(
      200,
      body: json.encode({
        'success': true,
        'data': data,
        'pagination': {
          'page': page,
          'limit': limit,
          'total': total,
          'totalPages': totalPages,
          'hasNext': page < totalPages,
          'hasPrev': page > 1,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
