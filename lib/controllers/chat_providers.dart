import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/chat_service.dart';
import '../shared/models/message_model.dart';

/// Provider pour la stream des conversations
final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((ref) {
  return ChatService.getConversations();
});

/// Provider pour la conversation sélectionnée
final selectedConversationProvider = StateProvider<ConversationModel?>((ref) => null);

/// Provider pour la stream des messages d'une conversation
final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ChatService.getMessages(conversationId);
});

/// Provider pour enrichir les messages avec les noms d'expéditeur
final enrichedMessagesProvider = FutureProvider.family<List<EnrichedMessage>, String>((ref, conversationId) async {
  // On attend que les messages soient disponibles
  final messagesAsync = await ref.watch(messagesStreamProvider(conversationId).future);
  
  final List<EnrichedMessage> enrichedMessages = [];
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  
  for (final message in messagesAsync) {
    String senderName = 'Inconnu';
    bool isMe = message.senderId == currentUserId;
    
    if (isMe) {
      senderName = 'Moi';
    } else {
      // Récupérer le nom depuis Supabase
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('nom')
            .eq('id', message.senderId)
            .maybeSingle();
        
        if (profile != null) {
          senderName = profile['nom'] ?? 'Inconnu';
        }
      } catch (e) {
        print('Erreur récupération profil: $e');
      }
    }
    
    enrichedMessages.add(EnrichedMessage(
      message: message,
      senderName: senderName,
      isMe: isMe,
    ));
  }
  
  return enrichedMessages;
});

/// StateNotifier pour gérer les actions de messagerie
class ChatController extends StateNotifier<AsyncValue<void>> {
  ChatController() : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ChatService.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> createConversation(String otherUserId) async {
    state = const AsyncValue.loading();
    try {
      final convId = await ChatService.createConversation(otherUserId);
      state = const AsyncValue.data(null);
      return convId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await ChatService.markMessagesAsRead(conversationId);
    } catch (e) {
      print('Erreur marquage lecture: $e');
    }
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController();
});

/// Classe pour enrichir les messages avec des infos supplémentaires
class EnrichedMessage {
  final MessageModel message;
  final String senderName;
  final bool isMe;

  EnrichedMessage({
    required this.message,
    required this.senderName,
    required this.isMe,
  });
}
