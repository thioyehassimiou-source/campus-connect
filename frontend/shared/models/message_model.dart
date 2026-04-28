class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType? type;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'],
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      type: _parseMessageType(json['type']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
        'type': type?.toString().split('.').last,
      };

  Map<String, dynamic> toMap() => toJson();

  factory MessageModel.fromMap(Map<String, dynamic> map) =>
      MessageModel.fromJson(map);

  static MessageType _parseMessageType(dynamic typeValue) {
    if (typeValue == null) return MessageType.text;
    final typeStr = typeValue.toString().toLowerCase();
    if (typeStr.contains('image')) return MessageType.image;
    if (typeStr.contains('file')) return MessageType.file;
    if (typeStr.contains('audio')) return MessageType.audio;
    return MessageType.text;
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
}

class ConversationModel {
  final String id;
  final String displayName;
  final String? displayLastMessage;
  final List<String> participantIds;
  final bool isGroup;
  final DateTime lastMessageTime;

  ConversationModel({
    required this.id,
    required this.displayName,
    this.displayLastMessage,
    required this.participantIds,
    this.isGroup = false,
    required this.lastMessageTime,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? '',
      displayLastMessage: json['last_message'],
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      isGroup: json['is_group'] ?? false,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'last_message': displayLastMessage,
        'participant_ids': participantIds,
        'is_group': isGroup,
        'last_message_time': lastMessageTime.toIso8601String(),
      };

  Map<String, dynamic> toMap() => toJson();

  factory ConversationModel.fromMap(Map<String, dynamic> map) =>
      ConversationModel.fromJson(map);
}
