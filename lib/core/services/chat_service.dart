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
            // Get other participant (assuming 1-on-1 for now for display name)
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

    // Mark all messages in this conversation as read where receiver is current user
    // Note: In our current schema, we don't explicitly store receiver_id on message (only sender).
    // so we mark all messages in conversation NOT sent by me as read.
    
    await _supabase.from('messages').update({
      'is_read': true,
    }).eq('conversation_id', conversationId).neq('sender_id', userId);
  }
}
