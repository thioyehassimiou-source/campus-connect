import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/messaging_models.dart';
import '../services/messaging_service.dart';
import '../../core/services/socket_service.dart';
import '../../shared/models/message_model.dart';

/// Stream of all conversations for the user
final chatConversationsProvider = StreamProvider<List<ChatConversation>>((ref) {
  return MessagingService.getConversationsStream();
});

/// StateNotifier pour gérer les messages en temps réel d'une conversation
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final String conversationId;
  final Ref ref;

  ChatMessagesNotifier(this.conversationId, this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      // 1. Initialiser et connecter le socket
      SocketService().connectAndListen();
      SocketService().joinConversation(conversationId);

      // 2. Récupérer l'historique
      final history = await MessagingService.fetchMessages(conversationId);
      state = AsyncValue.data(history);

      // 3. Écouter les nouveaux messages
      SocketService().onNewMessage.listen((data) {
        if (data['conversation_id'] == conversationId || data['conversationId'] == conversationId) {
          final newMessage = ChatMessage(
            id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: conversationId,
            senderId: data['senderId'] ?? data['sender_id'] ?? '',
            senderName: data['senderName'] ?? data['sender_name'],
            content: data['content'] ?? data['message'] ?? '',
            timestamp: DateTime.now(),
            isRead: false,
            type: MessageType.text,
            status: MessageStatus.sent,
          );

          // Ajouter le message à la liste actuelle
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

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, conversationId) {
  return ChatMessagesNotifier(conversationId, ref);
});

/// Provider pour la conversation sélectionnée
final selectedConversationProvider = StateProvider<ChatConversation?>((ref) => null);

/// Controller for messaging actions
class MessagingController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  MessagingController(this.ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Envoi via REST (pour persistance)
      await MessagingService.sendMessage(
        conversationId: conversationId,
        content: content,
        replyToId: replyToId,
      );

      // 2. Envoi via Socket.io (pour temps réel)
      SocketService().sendMessage({
        'conversationId': conversationId,
        'content': content,
        'replyToId': replyToId,
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await MessagingService.markMessagesAsRead(conversationId);
      // Optionnel: rafraîchir la liste des conversations pour mettre à jour les compteurs
      ref.invalidate(chatConversationsProvider);
    } catch (e) {
      print('Erreur marquage lecture: $e');
    }
  }
}

final messagingControllerProvider = StateNotifierProvider<MessagingController, AsyncValue<void>>((ref) {
  return MessagingController(ref);
});
