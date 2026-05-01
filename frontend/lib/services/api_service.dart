import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';
import '../models/announcement_model.dart';
import '../models/course_model.dart';
import '../models/resource_model.dart';
import '../shared/models/notification_model.dart';
import '../shared/models/notification_model.dart';
import '../config/api_config.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
class ApiService {
  static final _client = http.Client();
  
  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  static Future<ApiResponse<T>> _handleRequest<T>(
    Future<http.Response> Function() requestFunction,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await requestFunction();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        return ApiResponse<T>.fromJson(body, fromJson);
      } else {
        final body = json.decode(response.body);
        String message = 'Request failed';
        int? code;
        
        if (body is Map) {
          if (body['error'] is Map) {
            message = body['error']['message'] ?? message;
            code = body['error']['code'];
          } else if (body['error'] is String) {
            message = body['error'];
          } else if (body['message'] is String) {
            message = body['message'];
          }
        }
        
        return ApiResponse<T>.error(message, code: code);
      }
    } catch (e) {
      return ApiResponse<T>.error('Network error: $e');
    }
  }
  
  // Auth endpoints
  static Future<ApiResponse<AuthResponse>> register(CreateUserRequest request) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  static Future<ApiResponse<Map<String, dynamic>>> logout(String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: _getHeaders(token: token),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }
  
  static Future<ApiResponse<UserModel>> getCurrentUser(String token) async {
    return _handleRequest<UserModel>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: _getHeaders(token: token),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh'),
        headers: _getHeaders(),
        body: json.encode({'refreshToken': refreshToken}),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  // User endpoints
  static Future<ApiResponse<List<UserModel>>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (role != null) {
      queryParams['role'] = role;
    }
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/users')
        .replace(queryParameters: queryParams);
    
    return _handleRequest<List<UserModel>>(
      () => _client.get(
        uri,
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json['data'] as List;
        return data.map((item) => UserModel.fromJson(item)).toList();
      },
    );
  }
  
  static Future<ApiResponse<UserModel>> getUserById(String id, {String? token}) async {
    return _handleRequest<UserModel>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<UserModel>> updateUser(
    String id,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    return _handleRequest<UserModel>(
      () => _client.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(String id, {String? token}) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }
  
  static Future<ApiResponse<List<ScheduleItem>>> getSchedules({String? token}) async {
    return _handleRequest<List<ScheduleItem>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/schedule'),
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json as List;
        return data.map((item) => ScheduleItem.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<List<Announcement>>> getAnnouncements({String? token}) async {
    return _handleRequest<List<Announcement>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/announcements'),
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json as List;
        return data.map((item) => Announcement.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<List<Course>>> getCourses({String? token}) async {
    return _handleRequest<List<Course>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/courses'),
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json as List;
        return data.map((item) => Course.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<void>> deleteCourse(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/courses/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<NotificationModel>>> getNotifications({String? token}) async {
    return _handleRequest<List<NotificationModel>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json as List;
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<void>> markNotificationAsRead(String id, {String? token}) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> markAllNotificationsAsRead({String? token}) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> deleteNotification(String id, {String? token}) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getCampusBlocs() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/campus/blocs'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getInstitutionalServices({String? category}) async {
    final queryParams = category != null ? '?category=$category' : '';
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/campus/services$queryParams'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<List<Resource>>> getResources({String? subject, String? token}) async {
    final queryParams = subject != null ? '?subject=$subject' : '';
    return _handleRequest<List<Resource>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/resources$queryParams'),
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json as List;
        return data.map((item) => Resource.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createResource(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/resources'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getChatConversations({String? token}) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(String conversationId, {String? token}) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/messages/$conversationId'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getChatContacts({String? token}) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/contacts'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> postChatMessage(String conversationId, String content, {String type = 'text', String? token}) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/messages'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'conversationId': conversationId,
          'content': content,
          'type': type,
        }),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getOrCreateConversation(String otherUserId, {String? token}) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'otherUserId': otherUserId}),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<void>> markChatAsRead(String conversationId, {String? token}) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$conversationId/read'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> deleteChatConversation(String conversationId, {String? token}) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$conversationId'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  // Schedules
  static Future<ApiResponse<List<Map<String, dynamic>>>> getWeekSchedule(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/schedule'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createSchedule(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/schedule'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> deleteSchedule(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/schedule/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> updateScheduleStatus(String id, String status, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/schedule/$id/status'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'status': status}),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> updateSchedule(String id, Map<String, dynamic> data, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/schedule/$id'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => null,
    );
  }

  // Submissions & Grading
  static Future<ApiResponse<Map<String, dynamic>>> gradeSubmission(String submissionId, Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/submissions/$submissionId/grade'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getMySubmissions(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/submissions/my'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getSubmissionForAssignment(String assignmentId, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/assignments/$assignmentId/my-submission'),
        headers: _getHeaders(token: token),
      ),
      (json) => json,
    );
  }

  // Announcements (Admin)
  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllAnnouncements(String token, {bool includeDrafts = true}) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/announcements/admin?includeDrafts=$includeDrafts'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createAnnouncement(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/announcements'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> publishAnnouncement(String id, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/announcements/$id/publish'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> deleteAnnouncement(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/announcements/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  // Activity Logs
  static Future<ApiResponse<List<Map<String, dynamic>>>> getActivityLogs(String token, {int limit = 20}) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/logs?limit=$limit'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<void>> logActivity(Map<String, dynamic> data, String token) async {
    return _handleRequest<void>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/logs'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<void>> toggleUserStatus(String userId, bool isActive, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/status'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'is_active': isActive}),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getUsersPaginated(String token, {int page = 0, int limit = 20, String? search, String? role}) async {
    final queryParams = 'page=$page&limit=$limit${search != null ? '&search=$search' : ''}${role != null ? '&role=$role' : ''}';
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/paginated?$queryParams'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  // Academic Management (Admin)
  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllFilieres(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/academic/filieres'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json as List),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createFiliere(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/academic/filieres'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> deleteFiliere(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/academic/filieres/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllCourses(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/academic/courses'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createCourse(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/academic/courses'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> updateCourse(String id, Map<String, dynamic> data, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/academic/courses/$id'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getTeachersList(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/academic/teachers'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  // Admin
  static Future<ApiResponse<Map<String, dynamic>>> getAdminStats(String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
        headers: _getHeaders(token: token),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllUsers(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/users'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }


  static Future<ApiResponse<Map<String, dynamic>>> createUser(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  // University Data
  static Future<ApiResponse<List<Map<String, dynamic>>>> getFaculties() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/universities/faculties'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getDepartments(String facultyId) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/universities/faculties/$facultyId/departments'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getFilieres() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/universities/filieres'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getServices() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/universities/services'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  // Attendance
  static Future<ApiResponse<List<Map<String, dynamic>>>> getStudentAttendance(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/student'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getAttendanceForDate(String course, String date, String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/course/$course?date=$date'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<void>> upsertAttendance(List<Map<String, dynamic>> data, String token) async {
    return _handleRequest<void>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/upsert'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getStudentsForCourse(String course, String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/courses/$course/students'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  // Assignments
  static Future<ApiResponse<List<Map<String, dynamic>>>> getStudentAssignments(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/assignments/student'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getTeacherAssignments(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/assignments/teacher'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createAssignment(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/assignments'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> submitAssignment(String assignmentId, Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/assignments/$assignmentId/submit'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getAssignmentSubmissions(String assignmentId, String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/assignments/$assignmentId/submissions'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  // Rooms
  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllRooms() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getRoomsByBloc(String bloc) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms/bloc/$bloc'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> upsertRoom(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/rooms'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> deleteRoom(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/rooms/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createRoomBooking(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/rooms/bookings'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getRoomBookings({bool onlyMine = false, String? token}) async {
    final url = onlyMine 
      ? '${ApiConfig.baseUrl}/rooms/bookings/my' 
      : '${ApiConfig.baseUrl}/rooms/bookings';
    
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<void>> updateBookingStatus(String id, Map<String, dynamic> data, String token) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/rooms/bookings/$id/status'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => null,
    );
  }

  // Academic Calendar
  static Future<ApiResponse<List<Map<String, dynamic>>>> getAcademicEvents() async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/academic-calendar'),
        headers: _getHeaders(),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> addAcademicEvent(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/academic-calendar'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> deleteAcademicEvent(String id, String token) async {
    return _handleRequest<void>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/academic-calendar/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => null,
    );
  }

  // Grades
  static Future<ApiResponse<List<Map<String, dynamic>>>> getMyGrades(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/my'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getTeacherGrades(String token) async {
    return _handleRequest<List<Map<String, dynamic>>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/teacher'),
        headers: _getHeaders(token: token),
      ),
      (json) => List<Map<String, dynamic>>.from(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> addGrade(Map<String, dynamic> data, String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/grades'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      ),
      (json) => json,
    );
  }

  static Future<ApiResponse<void>> changePassword(String newPassword, {String? token}) async {
    return _handleRequest<void>(
      () => _client.patch(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'newPassword': newPassword}),
      ),
      (json) => null,
    );
  }

  // Health check
  static Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: _getHeaders(),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }


  static Future<ApiResponse<Map<String, dynamic>>> uploadFile(String filePath, String token, {String fieldName = 'file', String endpoint = '/upload'}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        filePath,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        return ApiResponse.fromJson(body, (j) => Map<String, dynamic>.from(j as Map));
      } else {
        final body = json.decode(response.body);
        return ApiResponse.error(
          body['error'] ?? body['message'] ?? 'Upload failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error during upload: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath, String token) async {
    return uploadFile(filePath, token, fieldName: 'avatar', endpoint: '/upload/avatar');
  }

  static Future<ApiResponse<Map<String, dynamic>>> uploadFileFromBytes(String fileName, List<int> bytes, String token) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        return ApiResponse.fromJson(body, (j) => Map<String, dynamic>.from(j as Map));
      } else {
        final body = json.decode(response.body);
        return ApiResponse.error(
          body['error'] ?? 'Upload failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error during upload: $e');
    }
  }
}
