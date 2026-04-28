import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  
  final Logger _logger = Logger();
  late final SupabaseClient _client;
  
  void initialize() {
    _client = Supabase.instance.client;
    _logger.i('Supabase service initialized');
  }
  
  // Authentification
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('User signed in successfully');
      return response;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }
  
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      _logger.i('User signed up successfully');
      return response;
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }
  
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Database Operations
  Future<List<Map<String, dynamic>>> fetch({
    required String table,
    String? select,
    List<Filter>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(table);
      
      if (select != null) {
        query = query.select(select);
      }
      
      if (filters != null) {
        for (final filter in filters) {
          query = query.filter(filter.column, filter.operator, filter.value);
        }
      }
      
      if (orderBy != null) {
        query = query.order(orderBy);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final data = await query;
      _logger.i('Fetched ${data.length} records from $table');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _logger.e('Fetch error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      _logger.i('Record inserted into $table');
      return response;
    } catch (e) {
      _logger.e('Insert error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required String id,
  }) async {
    try {
      final response = await _client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      _logger.i('Record updated in $table');
      return response;
    } catch (e) {
      _logger.e('Update error: $e');
      rethrow;
    }
  }
  
  Future<void> delete({
    required String table,
    required String id,
  }) async {
    try {
      await _client.from(table).delete().eq('id', id);
      _logger.i('Record deleted from $table');
    } catch (e) {
      _logger.e('Delete error: $e');
      rethrow;
    }
  }
  
  // Storage Operations
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List file,
    String? contentType,
  }) async {
    try {
      final response = await _client.storage.from(bucket).uploadBinary(
        path,
        file,
        fileOptions: FileOptions(contentType: contentType),
      );
      _logger.i('File uploaded to $bucket/$path');
      return response;
    } catch (e) {
      _logger.e('Upload error: $e');
      rethrow;
    }
  }
  
  Future<String> getPublicUrl({
    required String bucket,
    required String path,
  }) async {
    try {
      final url = _client.storage.from(bucket).getPublicUrl(path);
      _logger.i('Public URL generated for $bucket/$path');
      return url;
    } catch (e) {
      _logger.e('Get public URL error: $e');
      rethrow;
    }
  }
}

class Filter {
  final String column;
  final String operator;
  final dynamic value;
  
  Filter({
    required this.column,
    required this.operator,
    required this.value,
  });
}
