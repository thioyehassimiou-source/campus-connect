import 'dart:async';
import 'dart:io';
import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import '../models/messaging_models.dart';
import 'package:campusconnect/shared/models/message_model.dart';

class MessagingService {
  /// Get stream of conversations for current user
  /// Currently simulated via periodic fetch or single fetch
  static Stream<List<ChatConversation>> getConversationsStream() {
    return Stream.fromFuture(fetchConversations());
  }

  static Future<List<ChatConversation>> fetchConversations() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getChatConversations(token: token);
      
      if (response.success && response.data != null) {
        return response.data!.map((conv) => ChatConversation(
          id: conv['id'],
          displayName: conv['name'] ?? 'Chat',
          displayLastMessage: conv['last_message'],
          participantIds: [], 
          isGroup: conv['is_group'] ?? false,
          lastMessageTime: conv['last_message_time'] != null 
              ? DateTime.parse(conv['last_message_time']) 
              : DateTime.now(),
          type: conv['is_group'] == true ? ChatConversationType.group : ChatConversationType.private,
          avatarUrl: conv['avatar_url'],
          lastMessageSenderId: conv['last_message_sender_id'],
          isLastMessageRead: conv['is_last_message_read'] ?? true,
          unreadCount: 0,
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations REST: $e');
      return [];
    }
  }

  /// Fetch available contacts based on user role
  static Future<List<Map<String, dynamic>>> getAvailableContacts() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getChatContacts(token: token);
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching contacts REST: $e');
      return [];
    }
  }

  /// Create or get existing conversation
  static Future<String> getOrCreateConversation(String otherUserId) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getOrCreateConversation(otherUserId, token: token);
      if (response.success && response.data != null) {
        return response.data!['id'];
      }
      throw Exception(response.error?.message ?? 'Failed to get/create conversation');
    } catch (e) {
      print('Error getOrCreateConversation REST: $e');
      rethrow;
    }
  }

  /// Mark all messages as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final token = await AuthService.getToken();
      await ApiService.markChatAsRead(conversationId, token: token);
    } catch (e) {
      print('Error markMessagesAsRead REST: $e');
    }
  }

  /// Get real-time stream of messages
  static Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return Stream.fromFuture(fetchMessages(conversationId));
  }

  static Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getChatMessages(conversationId, token: token);
      
      if (response.success && response.data != null) {
        return response.data!.map((m) => ChatMessage(
          id: m['id'],
          conversationId: m['conversation_id'],
          senderId: m['sender_id'] ?? '',
          senderName: m['sender_name'],
          content: m['content'] ?? '',
          timestamp: DateTime.parse(m['created_at']),
          isRead: m['is_read'] ?? false,
          type: _parseMessageType(m['type']),
          status: m['is_read'] == true ? MessageStatus.read : MessageStatus.sent,
          replyToId: m['reply_to_id'],
          repliedMessageContent: m['replied_content'],
          repliedMessageSenderName: m['replied_sender_name'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching messages REST: $e');
      return [];
    }
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      default: return MessageType.text;
    }
  }

  /// Send a message
  static Future<void> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    String? replyToId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.postChatMessage(
        conversationId, 
        content, 
        type: type, 
        token: token
      );
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Failed to send message');
      }
    } catch (e) {
      print('❌ Erreur envoi message REST: $e');
      rethrow;
    }
  }

  /// Delete chat history
  static Future<void> clearChat(String conversationId) async {
    try {
      final token = await AuthService.getToken();
      await ApiService.deleteChatConversation(conversationId, token: token);
    } catch (e) {
      print('Error clearChat REST: $e');
      rethrow;
    }
  }

  /// Delete a single message
  static Future<void> deleteMessage(String messageId) async {
    print('Deleting message via API: $messageId');
  }

  /// Upload a file for messaging
  static Future<String> uploadFile(String filePath, String fileName) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token');
      
      final response = await ApiService.uploadFile(filePath, token);
      if (response.success && response.data != null) {
        return response.data!['url'];
      }
      throw Exception(response.error?.message ?? 'Upload failed');
    } catch (e) {
      print('Error uploading file in MessagingService: $e');
      rethrow;
    }
  }
}
