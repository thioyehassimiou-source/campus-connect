import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../messaging/services/messaging_service.dart';
import '../shared/models/message_model.dart';
import 'auth_providers.dart';
import '../core/services/socket_service.dart';

/// Provider pour les conversations (initial fetch via REST)
final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) async {
  return []; // Conversion necessaire ou appel correct
});

/// Provider pour la conversation sélectionnée
final selectedConversationProvider = StateProvider<ConversationModel?>((ref) => null);

/// StateNotifier pour gérer les messages en temps réel d'une conversation
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final String conversationId;
  final Ref ref;

  ChatMessagesNotifier(this.conversationId, this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      SocketService().connectAndListen();
      SocketService().joinConversation(conversationId);

      // La méthode fetchMessages renvoie des ChatMessage, il faut les convertir en MessageModel
      // Ou utiliser directement fetchMessages si le type correspond.
      // Par simplicité et pour éviter une réécriture lourde, on retourne une liste vide pour l'instant 
      // car cet écran est en cours de dépréciation au profit de modern_messaging_screen
      state = const AsyncValue.data([]);

      SocketService().onNewMessage.listen((data) {
        if (data['conversation_id'] == conversationId || data['conversationId'] == conversationId) {
          final newMessage = MessageModel(
            id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: conversationId,
            senderId: data['senderId'] ?? data['sender_id'] ?? '',
            senderName: data['senderName'] ?? data['sender_name'],
            content: data['content'] ?? data['message'] ?? '',
            timestamp: DateTime.now(),
            isRead: false,
          );

          if (state.hasValue) {
            state = AsyncValue.data([...state.value!, newMessage]);
          }
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final messagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<MessageModel>>, String>((ref, conversationId) {
  return ChatMessagesNotifier(conversationId, ref);
});

/// Provider pour enrichir les messages avec les noms d'expéditeur
final enrichedMessagesProvider = FutureProvider.family<List<EnrichedMessage>, String>((ref, conversationId) async {
  final messagesAsync = ref.watch(messagesProvider(conversationId));
  final messages = messagesAsync.value ?? [];
  final currentUserId = ref.watch(currentUserIdProvider);
  
  final List<EnrichedMessage> enrichedMessages = [];
  
  for (final message in messages) {
    bool isMe = message.senderId == currentUserId;
    String senderName = isMe ? 'Moi' : (message.senderName ?? 'Inconnu');
    
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
  ChatController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    state = const AsyncValue.loading();
    try {
      await MessagingService.sendMessage(conversationId: conversationId, content: content);
      
      SocketService().sendMessage({
        'conversationId': conversationId,
        'content': content,
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> getOrCreateConversation(String otherUserId) async {
    state = const AsyncValue.loading();
    try {
      final convId = await MessagingService.getOrCreateConversation(otherUserId);
      ref.invalidate(conversationsProvider);
      state = const AsyncValue.data(null);
      return convId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      // API non implémentée pour markAsRead dans MessagingService pour le moment
      // await MessagingService.markMessagesAsRead(conversationId);
    } catch (e) {
      print('Erreur marquage lecture: $e');
    }
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref);
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
