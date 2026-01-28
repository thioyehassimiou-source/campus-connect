import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/domain/models/admin_user.dart';
import '../../features/admin/domain/models/block_model.dart';
import '../../features/admin/domain/models/room_model.dart';

class AdminService {
  final SupabaseClient _client;

  AdminService(this._client);

  Future<List<AdminUser>> fetchUsers() async {
    final rows = await _client
        .from('users')
        .select('id,email,first_name,last_name,role')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => AdminUser.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Blocks CRUD
  Future<List<BlockModel>> fetchBlocks() async {
    final rows = await _client.from('blocs').select('*').order('name');
    return (rows as List)
        .map((e) => BlockModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<BlockModel> createBlock({required String name, String? description}) async {
    final row = await _client
        .from('blocs')
        .insert({'name': name, 'description': description})
        .select()
        .single();
    return BlockModel.fromMap(row);
  }

  Future<BlockModel> updateBlock({
    required String id,
    required String name,
    String? description,
  }) async {
    final row = await _client
        .from('blocs')
        .update({'name': name, 'description': description})
        .eq('id', id)
        .select()
        .single();
    return BlockModel.fromMap(row);
  }

  Future<void> deleteBlock(String id) async {
    await _client.from('blocs').delete().eq('id', id);
  }

  // Rooms CRUD
  Future<List<RoomModel>> fetchRooms({String? blockId}) async {
    var query = _client.from('salles').select('*');
    if (blockId != null && blockId.isNotEmpty) {
      query = query.eq('block_id', blockId);
    }
    final rows = await query.order('name');

    return (rows as List)
        .map((e) => RoomModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<RoomModel> createRoom({
    required String blockId,
    required String name,
    int? capacity,
  }) async {
    final row = await _client
        .from('salles')
        .insert({'block_id': blockId, 'name': name, 'capacity': capacity})
        .select()
        .single();
    return RoomModel.fromMap(row);
  }

  Future<RoomModel> updateRoom({
    required String id,
    required String blockId,
    required String name,
    int? capacity,
  }) async {
    final row = await _client
        .from('salles')
        .update({'block_id': blockId, 'name': name, 'capacity': capacity})
        .eq('id', id)
        .select()
        .single();
    return RoomModel.fromMap(row);
  }

  Future<void> deleteRoom(String id) async {
    await _client.from('salles').delete().eq('id', id);
  }
}
