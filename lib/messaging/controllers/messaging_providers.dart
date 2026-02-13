import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/messaging_models.dart';
import '../services/messaging_service.dart';

/// Stream of all conversations for the user
final chatConversationsProvider = StreamProvider<List<ChatConversation>>((ref) {
  return MessagingService.getConversationsStream();
});

/// Stream of messages for a specific conversation
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  return MessagingService.getMessagesStream(conversationId);
});

/// Controller for messaging actions
class MessagingController extends StateNotifier<AsyncValue<void>> {
  MessagingController() : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    try {
      await MessagingService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final messagingControllerProvider = StateNotifierProvider<MessagingController, AsyncValue<void>>((ref) {
  return MessagingController();
});
