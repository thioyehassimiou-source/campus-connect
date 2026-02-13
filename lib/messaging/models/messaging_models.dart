import 'package:campusconnect/shared/models/message_model.dart';

enum ChatConversationType {
  private,      // 1-1
  group,        // Class, Dept, etc.
  announcement, // Read-only for students
}

class ChatConversation extends ConversationModel {
  final ChatConversationType type;
  final String? scopeId; // Department ID or Class ID
  final String? avatarUrl;
  final int unreadCount;
  final String? lastMessageSenderId;
  final bool isLastMessageRead;
  final String? lastSenderName;
  final bool isMuted;

  ChatConversation({
    required super.id,
    required super.displayName,
    super.displayLastMessage,
    required super.participantIds,
    super.isGroup = false,
    required super.lastMessageTime,
    this.type = ChatConversationType.private,
    this.scopeId,
    this.avatarUrl,
    this.unreadCount = 0,
    this.lastMessageSenderId,
    this.isLastMessageRead = true,
    this.lastSenderName,
    this.isMuted = false,
  });

  factory ChatConversation.fromLegacy(ConversationModel legacy, {
    ChatConversationType type = ChatConversationType.private,
    int unreadCount = 0,
  }) {
    return ChatConversation(
      id: legacy.id,
      displayName: legacy.displayName,
      displayLastMessage: legacy.displayLastMessage,
      participantIds: legacy.participantIds,
      isGroup: legacy.isGroup,
      lastMessageTime: legacy.lastMessageTime,
      type: type,
      unreadCount: unreadCount,
    );
  }
}

class ChatMessage extends MessageModel {
  final MessageStatus status;
  final List<ChatAttachment>? attachments;

  ChatMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.senderName,
    required super.content,
    required super.timestamp,
    super.isRead = false,
    super.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.attachments,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error,
}

class ChatAttachment {
  final String url;
  final String fileName;
  final String fileType; // pdf, png, docx
  final int fileSize;

  ChatAttachment({
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });
}
