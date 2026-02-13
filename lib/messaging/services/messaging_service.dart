import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' as foundation;
import '../models/messaging_models.dart';
import 'package:campusconnect/shared/models/message_model.dart';

class MessagingService {
  static final _supabase = Supabase.instance.client;

  /// Get real-time stream of conversations for current user
  /// Triggers on participation changes and global message updates
  static Stream<List<ChatConversation>> getConversationsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    final controller = StreamController<List<ChatConversation>>();

    // 1. Immediate initial fetch to avoid waiting for Realtime connection
    _fetchConversations(userId).then((list) {
      if (!controller.isClosed) controller.add(list);
    }).catchError((e) {
      print('Initial conversation fetch error: $e');
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Setup Realtime trigger using the messages table
    // We listen for any change as a signal to refresh our mapped conversation list
    final subscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .listen(
          (_) async {
            try {
              final list = await _fetchConversations(userId);
              if (!controller.isClosed) controller.add(list);
            } catch (e) {
              print('Background refresh error: $e');
            }
          },
          onError: (e) {
            print('Conversation Realtime subscription error: $e');
            // We don't close the controller on realtime error to keep initial data visible
          },
        );

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  static Future<List<ChatConversation>> _fetchConversations(String userId) async {
    try {
      final participants = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', userId);

      if (participants.isEmpty) return [];
      
      final conversationIds = participants.map((p) => p['conversation_id']).toList();
      
      final conversationsData = await _supabase
          .from('conversations')
          .select()
          .filter('id', 'in', conversationIds)
          .order('last_message_time', ascending: false);

      final List<ChatConversation> result = [];
      for (final conv in conversationsData) {
        final details = await _getConversationDetails(conv, userId);
        result.add(details);
      }
      return result;
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  static Future<ChatConversation> _getConversationDetails(Map<String, dynamic> conv, String userId) async {
    String displayName = conv['name'] ?? 'Chat';
    String? avatarUrl;
    ChatConversationType type = conv['is_group'] == true 
        ? ChatConversationType.group 
        : ChatConversationType.private;

    if (!conv['is_group']) {
      final otherParticipant = await _supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', conv['id'])
          .neq('user_id', userId)
          .limit(1)
          .maybeSingle();

      if (otherParticipant != null) {
        final profile = await _supabase
            .from('profiles')
            .select('nom, avatar_url')
            .eq('id', otherParticipant['user_id'])
            .maybeSingle();
        
        if (profile != null) {
          displayName = profile['nom'] ?? 'Utilisateur';
          avatarUrl = profile['avatar_url'];
        }
      }
    }

    return ChatConversation(
      id: conv['id'],
      displayName: displayName,
      displayLastMessage: conv['last_message'],
      participantIds: [], 
      isGroup: conv['is_group'] ?? false,
      lastMessageTime: conv['last_message_time'] != null 
          ? DateTime.parse(conv['last_message_time']) 
          : DateTime.now(),
      type: type,
      avatarUrl: avatarUrl,
      lastMessageSenderId: conv['last_message_sender_id'],
      isLastMessageRead: conv['is_last_message_read'] ?? true,
      unreadCount: 0, // Could be calculated via a count query if needed
    );
  }

  /// Fetch available contacts based on user role
  static Future<List<Map<String, dynamic>>> getAvailableContacts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final role = user.userMetadata?['role'] ?? 'Étudiant';
    
    var query = _supabase.from('profiles').select('id, nom, avatar_url, role').neq('id', user.id);

    // Role filtering: Students only see non-students
    if (role == 'Étudiant') {
      query = query.neq('role', 'Étudiant');
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Create or get existing conversation between two users
  static Future<String> getOrCreateConversation(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Non authentifié');

    // 1. Check if private conversation already exists
    final response = await _supabase.rpc('get_private_conversation', params: {
      'user1': userId,
      'user2': otherUserId,
    });

    if (response != null) return response.toString();

    // 2. Create if not exists
    final newConv = await _supabase.from('conversations').insert({
      'is_group': false,
    }).select().single();

    final convId = newConv['id'];

    await _supabase.from('conversation_participants').insert([
      {'conversation_id': convId, 'user_id': userId},
      {'conversation_id': convId, 'user_id': otherUserId},
    ]);

    return convId;
  }

  /// Mark all messages in a conversation as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Mark messages NOT sent by me as read
    await _supabase.from('messages').update({
      'is_read': true,
    }).eq('conversation_id', conversationId).neq('sender_id', userId);

    // 2. Update conversation status if the last message was the one we just read
    // We check if the last message sender was NOT me
    await _supabase.from('conversations').update({
      'is_last_message_read': true,
    }).eq('id', conversationId).neq('last_message_sender_id', userId);
  }

  /// Get real-time stream of messages for a specific conversation
  static Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    final controller = StreamController<List<ChatMessage>>();

    // 1. Initial fetch
    _fetchMessages(conversationId).then((list) {
      if (!controller.isClosed) controller.add(list);
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    // 2. Realtime listener
    final subscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .listen(
          (data) {
            final messages = data.map((json) => _mapToChatMessage(json)).toList();
            if (!controller.isClosed) controller.add(messages);
          },
          onError: (e) {
            print('Messages Realtime error: $e');
          },
        );

    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  static Future<List<ChatMessage>> _fetchMessages(String conversationId) async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
    
    return (data as List).map((json) => _mapToChatMessage(json)).toList();
  }

  static ChatMessage _mapToChatMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: _parseMessageType(json['type']),
      status: json['is_read'] == true ? MessageStatus.read : MessageStatus.sent,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      default: return MessageType.text;
    }
  }

  /// Send a message and update last_message cache
  static Future<void> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
      'type': type,
    });

    await _supabase.from('conversations').update({
      'last_message': content,
      'last_message_time': DateTime.now().toIso8601String(),
      'last_message_sender_id': userId,
      'is_last_message_read': false,
    }).eq('id', conversationId);
  }

  /// Upload file to Supabase Storage
  static Future<String> uploadFile(String filePath, String fileName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Non authentifié');

    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    
    // Ensure the file is actually uploaded to a 'chat_attachments' bucket
    // Note: User must have created this bucket in Supabase console
    await _supabase.storage.from('chat_attachments').upload(path, foundation.File(filePath));
    
    return _supabase.storage.from('chat_attachments').getPublicUrl(path);
  }

  /// Delete all messages in a conversation
  static Future<void> clearChat(String conversationId) async {
    await _supabase.from('messages').delete().eq('conversation_id', conversationId);
    
    // Reset last message in conversation
    await _supabase.from('conversations').update({
      'last_message': 'Discussion vidée',
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
