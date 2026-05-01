import 'dart:async';
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
  StreamSubscription? _messageSub;

  ChatMessagesNotifier(this.conversationId, this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final socketService = ref.read(socketServiceProvider);
      
      // 1. Connecter le socket s'il ne l'est pas
      await socketService.connect();
      socketService.joinConversation(conversationId);

      // 2. Récupérer l'historique via REST
      final history = await MessagingService.fetchMessages(conversationId);
      state = AsyncValue.data(history);

      // 3. Écouter les nouveaux messages via Socket
      _messageSub = socketService.onNewMessage.listen((data) {
        if (data['conversation_id'] == conversationId || data['conversationId'] == conversationId) {
          final newMessage = ChatMessage(
            id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: conversationId,
            senderId: data['sender_id'] ?? data['senderId'] ?? '',
            senderName: data['users']?['profiles']?['full_name'] ?? data['sender']?['profiles']?['full_name'] ?? data['sender_name'] ?? 'Utilisateur',
            content: data['content'] ?? '',
            timestamp: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
            isRead: false,
            type: MessageType.text,
            status: MessageStatus.sent,
          );

          if (state.hasValue) {
            // Éviter les doublons si le message arrive aussi via REST (peu probable ici)
            final alreadyExists = state.value!.any((m) => m.id == newMessage.id);
            if (!alreadyExists) {
              state = AsyncValue.data([...state.value!, newMessage]);
            }
          }
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    ref.read(socketServiceProvider).leaveConversation(conversationId);
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, conversationId) {
  return ChatMessagesNotifier(conversationId, ref);
});

/// Controller for messaging actions
class MessagingController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  MessagingController(this.ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      // Nous envoyons uniquement via Socket maintenant, car le Backend 
      // se charge de sauvegarder en base lors de la réception du socket.
      // Cela évite les doublons et assure le temps réel.
      
      final socketService = ref.read(socketServiceProvider);
      await socketService.connect();
      
      socketService.sendMessage(conversationId, content);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void sendTyping(String conversationId, bool isTyping) {
    ref.read(socketServiceProvider).sendTyping(conversationId, isTyping);
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await MessagingService.markMessagesAsRead(conversationId);
      ref.invalidate(chatConversationsProvider);
    } catch (e) {
      print('Erreur marquage lecture: $e');
    }
  }
}

final messagingControllerProvider = StateNotifierProvider<MessagingController, AsyncValue<void>>((ref) {
  return MessagingController(ref);
});
