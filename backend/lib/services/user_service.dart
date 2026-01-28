import '../models/user_model.dart';
import '../config/supabase_config.dart';

class UserService {
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
  }) async {
    final client = SupabaseConfig.client;
    
    List<Map<String, dynamic>> result;
    
    if (role != null && role.isNotEmpty) {
      result = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .eq('role', role)
          .order('created_at', ascending: false);
    } else {
      result = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
    }
    
    // Apply pagination manually
    final startIndex = (page - 1) * limit;
    final paginatedResults = startIndex < result.length 
        ? result.skip(startIndex).take(limit).toList()
        : <Map<String, dynamic>>[];
    
    final users = paginatedResults.map((row) => UserModel(
      id: row['id'].toString(),
      email: row['email'],
      firstName: row['first_name'],
      lastName: row['last_name'],
      role: row['role'],
      phone: row['phone'],
      department: row['department'],
      studentId: row['student_id'],
      createdAt: DateTime.parse(row['created_at']),
      updatedAt: DateTime.parse(row['updated_at']),
      isActive: row['is_active'],
    )).toList();
    
    return {
      'users': users,
      'total': result.length,
    };
  }
  
  static Future<UserModel> getUserById(String id) async {
    final client = SupabaseConfig.client;
    
    final result = await client
        .from('users')
        .select('*')
        .eq('id', id)
        .eq('is_active', true)
        .single();
    
    return UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
  }
  
  static Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final client = SupabaseConfig.client;
    
    // Build dynamic update data
    final updateData = <String, dynamic>{};
    
    if (data.containsKey('first_name')) {
      updateData['first_name'] = data['first_name'];
    }
    
    if (data.containsKey('last_name')) {
      updateData['last_name'] = data['last_name'];
    }
    
    if (data.containsKey('phone')) {
      updateData['phone'] = data['phone'];
    }
    
    if (data.containsKey('department')) {
      updateData['department'] = data['department'];
    }
    
    if (data.containsKey('student_id')) {
      updateData['student_id'] = data['student_id'];
    }
    
    if (data.containsKey('profile_image_url')) {
      updateData['profile_image_url'] = data['profile_image_url'];
    }
    
    if (updateData.isEmpty) {
      throw Exception('No valid fields to update');
    }
    
    updateData['updated_at'] = DateTime.now().toIso8601String();
    
    final result = await client
        .from('users')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();
    
    return UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
  }
  
  static Future<void> deleteUser(String id) async {
    final client = SupabaseConfig.client;
    
    // Soft delete - set is_active to false
    await client
        .from('users')
        .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  static Future<UserModel> getUserByEmail(String email) async {
    final client = SupabaseConfig.client;
    
    final result = await client
        .from('users')
        .select('*')
        .eq('email', email)
        .eq('is_active', true)
        .single();
    
    return UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
  }
}
