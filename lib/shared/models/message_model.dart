import 'package:equatable/equatable.dart';

enum MessageType { text, image, file, system }

class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String? receiverName;
  final String? groupId;
  final MessageType type;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final DateTime timestamp;
  final bool isRead;
  final bool isDeleted;
  final String? replyToId;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    this.receiverName,
    this.groupId,
    required this.type,
    required this.content,
    this.fileUrl,
    this.fileName,
    required this.timestamp,
    required this.isRead,
    required this.isDeleted,
    this.replyToId,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'],
      groupId: map['groupId'],
      type: MessageType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => MessageType.text,
      ),
      content: map['content'] ?? '',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      replyToId: map['replyToId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'groupId': groupId,
      'type': type.name,
      'content': content,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isDeleted': isDeleted,
      'replyToId': replyToId,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? groupId,
    MessageType? type,
    String? content,
    String? fileUrl,
    String? fileName,
    DateTime? timestamp,
    bool? isRead,
    bool? isDeleted,
    String? replyToId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        receiverId,
        receiverName,
        groupId,
        type,
        content,
        fileUrl,
        fileName,
        timestamp,
        isRead,
        isDeleted,
        replyToId,
      ];

  bool get isGroupMessage => groupId != null;
  bool get isDirectMessage => groupId == null;
  bool get isFileMessage => type == MessageType.file || type == MessageType.image;
  bool get isTextMessage => type == MessageType.text;
  bool get isSystemMessage => type == MessageType.system;

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  String get displayTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Aujourd\'hui, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ConversationModel extends Equatable {
  final String id;
  final String? userId1;
  final String? userId2;
  final String? groupId;
  final String? groupName;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCount;
  final bool isGroup;

  const ConversationModel({
    required this.id,
    this.userId1,
    this.userId2,
    this.groupId,
    this.groupName,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.isGroup,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      userId1: map['userId1'],
      userId2: map['userId2'],
      groupId: map['groupId'],
      groupName: map['groupName'],
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime']?.toDate(),
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCount: map['unreadCount'] ?? 0,
      isGroup: map['isGroup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'groupId': groupId,
      'groupName': groupName,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId1,
        userId2,
        groupId,
        groupName,
        participants,
        lastMessage,
        lastMessageTime,
        lastMessageSenderId,
        unreadCount,
        isGroup,
      ];

  String get displayName {
    if (isGroup && groupName != null) {
      return groupName!;
    }
    return 'Conversation directe';
  }

  String get displayLastMessage {
    if (lastMessage == null || lastMessage!.isEmpty) {
      return 'Aucun message';
    }
    if (lastMessage!.length > 50) {
      return '${lastMessage!.substring(0, 50)}...';
    }
    return lastMessage!;
  }
}
