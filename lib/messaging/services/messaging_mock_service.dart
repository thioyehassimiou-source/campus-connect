import '../models/messaging_models.dart';

class MessagingMockService {
  static List<ChatConversation> getMockConversations() {
    return [
      ChatConversation(
        id: '1',
        displayName: 'Fatou Sow',
        displayLastMessage: 'Salut ! Peux-tu m\'envoyer le cours de Math ?',
        participantIds: ['me', 'fatou'],
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        type: ChatConversationType.private,
      ),
      ChatConversation(
        id: '2',
        displayName: 'Département Informatique',
        displayLastMessage: 'Annonce: Examen reporté au lundi 18.',
        participantIds: ['all'],
        isGroup: true,
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        type: ChatConversationType.announcement,
        unreadCount: 0,
      ),
      ChatConversation(
        id: '3',
        displayName: 'Groupe Licence 3 - Génie Logiciel',
        displayLastMessage: 'Hassimiou: Quelqu\'un a fini le TP Supabase ?',
        participantIds: ['me', 'user1', 'user2'],
        isGroup: true,
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        type: ChatConversationType.group,
        unreadCount: 5,
      ),
    ];
  }

  static List<ChatMessage> getMockMessages(String conversationId) {
    return [
      ChatMessage(
        id: 'm1',
        conversationId: conversationId,
        senderId: 'fatou',
        senderName: 'Fatou Sow',
        content: 'Bonjour !',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        conversationId: conversationId,
        senderId: 'me',
        content: 'Salut Fatou, comment vas-tu ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        conversationId: conversationId,
        senderId: 'fatou',
        senderName: 'Fatou Sow',
        content: 'Ça va bien, merci. Peux-tu m\'envoyer le cours de Math ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: MessageStatus.delivered,
      ),
    ];
  }
}
