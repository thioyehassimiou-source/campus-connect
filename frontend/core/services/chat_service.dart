import 'package:campusconnect/shared/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all conversations for the current user
  static Stream<List<ConversationModel>> getConversations() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('conversation_participants')
        .stream(primaryKey: ['conversation_id', 'user_id'])
        .eq('user_id', userId)
        .asyncMap((participants) async {
          if (participants.isEmpty) return [];
          
          final conversationIds = participants.map((p) => p['conversation_id']).toList();
          
          final conversationsData = await _supabase
              .from('conversations')
              .select()
              .filter('id', 'in', conversationIds)
              .order('last_message_time', ascending: false);

          final List<ConversationModel> conversations = [];

          for (final conv in conversationsData) {
            final otherParticipantRes = await _supabase
                .from('conversation_participants')
                .select('user_id')
                .eq('conversation_id', conv['id'])
                .neq('user_id', userId)
                .limit(1)
                .maybeSingle(); // Use maybeSingle to avoid crash if empty

            String displayName = 'Chat';
            
            if (otherParticipantRes != null) {
               final otherUserId = otherParticipantRes['user_id'];
               final otherUserProfile = await _supabase
                  .from('profiles')
                  .select('nom')
                  .eq('id', otherUserId)
                  .maybeSingle();
                
               if (otherUserProfile != null) {
                 displayName = otherUserProfile['nom'] ?? 'Utilisateur';
               }
            }

            // Manually construct ConversationModel from Supabase data
            conversations.add(ConversationModel(
              id: conv['id'],
              displayName: displayName, // Computed display name
              displayLastMessage: conv['last_message'],
              participantIds: [], // We could fetch them, but for listing not strictly necessary yet
              isGroup: conv['is_group'] ?? false,
              lastMessageTime: conv['last_message_time'] != null 
                  ? DateTime.parse(conv['last_message_time']) 
                  : DateTime.now(),
            ));
          }
          
          return conversations;
        });
  }

  /// Get messages for a conversation
  static Stream<List<MessageModel>> getMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) {
          return data.map((json) {
            // Adapt Supabase JSON to MessageModel
            return MessageModel(
              id: json['id'],
              conversationId: json['conversation_id'],
              senderId: json['sender_id'] ?? '',
              // content: json['content'], // MessageModel expects content
              content: json['content'] ?? '',
              timestamp: DateTime.parse(json['created_at']),
              isRead: json['is_read'] ?? false,
              type: _parseMessageType(json['type']),
              senderName: '', // We might need to fetch this or map it in UI
            );
          }).toList();
        });
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      case 'audio': return MessageType.audio;
      default: return MessageType.text;
    }
  }

  /// Send a message
  static Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
      'type': type.toString().split('.').last,
    });

    // Update conversation last message
    await _supabase.from('conversations').update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  /// Start a new conversation
  static Future<String> createConversation(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    // Simple create
    final convRes = await _supabase.from('conversations').insert({
      'is_group': false,
      'last_message_time': DateTime.now().toIso8601String(),
    }).select().single();

    final convId = convRes['id'];

    await _supabase.from('conversation_participants').insert([
      {'conversation_id': convId, 'user_id': userId},
      {'conversation_id': convId, 'user_id': otherUserId},
    ]);

    return convId;
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').update({
      'is_read': true,
    }).eq('conversation_id', conversationId).neq('sender_id', userId);
  }


  /// Fetch available contacts based on user role
  static Future<List<Map<String, dynamic>>> getAvailableContacts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final role = user.userMetadata?['role'] ?? 'Étudiant';
    
    var query = _supabase.from('profiles').select('id, nom, avatar_url, role').neq('id', user.id);

    // Role filtering: Students only see non-students (teachers/admins)
    if (role == 'Étudiant') {
      query = query.neq('role', 'Étudiant');
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Create or get existing conversation between two users
  static Future<String> getOrCreateConversation(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    // 1. Check if private conversation already exists (simple client-side check for now)
    final existingPart = await _supabase
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', userId);
    
    final otherPart = await _supabase
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', otherUserId);

    final myConvIds = existingPart.map((e) => e['conversation_id']).toSet();
    final otherConvIds = otherPart.map((e) => e['conversation_id']).toSet();
    
    final commonIds = myConvIds.intersection(otherConvIds);
    
    if (commonIds.isNotEmpty) {
      // Need to verify it's a private chat (is_group = false)
      for (final id in commonIds) {
        final conv = await _supabase.from('conversations').select('is_group').eq('id', id).single();
        if (conv['is_group'] == false) return id;
      }
    }

    // 2. Create if not exists
    final convRes = await _supabase.from('conversations').insert({
      'is_group': false,
      'last_message_time': DateTime.now().toIso8601String(),
    }).select().single();

    final convId = convRes['id'];

    await _supabase.from('conversation_participants').insert([
      {'conversation_id': convId, 'user_id': userId},
      {'conversation_id': convId, 'user_id': otherUserId},
    ]);

    return convId;
  }

  /// Clear all messages and reset last message
  static Future<void> clearChat(String conversationId) async {
    await _supabase.from('messages').delete().eq('conversation_id', conversationId);
    await _supabase.from('conversations').update({
      'last_message': 'Discussion vidée',
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  /// Delete a conversation completely
  static Future<void> deleteConversation(String conversationId) async {
    try {
      // Les messages seront supprimés en cascade si la FK est configurée avec ON DELETE CASCADE
      // Sinon on doit les supprimer manuellement
      await _supabase.from('messages').delete().eq('conversation_id', conversationId);
      await _supabase.from('conversation_participants').delete().eq('conversation_id', conversationId);
      await _supabase.from('conversations').delete().eq('id', conversationId);
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }
}
