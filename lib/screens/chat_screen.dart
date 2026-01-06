import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/message_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;
  final ConversationModel conversation;
  final UserModel? otherUser;

  const ChatScreen({
    super.key,
    required this.user,
    required this.conversation,
    this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('messages')
          .where('receiverId', isEqualTo: widget.conversation.id)
          .orderBy('timestamp', descending: true)
          .get();

      final messages = querySnapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((message) => !message.isDeleted)
          .toList();

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Mark messages as read
      await _markMessagesAsRead();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _markMessagesAsRead() async {
    final unreadMessages = _messages.where((message) => 
      !message.isRead && 
      message.receiverId == widget.user.id
    ).toList();

    for (final message in unreadMessages) {
      await FirebaseService.firestore
          .collection('messages')
          .doc(message.id)
          .update({'isRead': true});
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.user.id,
        senderName: widget.user.fullName,
        receiverId: widget.conversation.id,
        type: MessageType.text,
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isRead: false,
        isDeleted: false,
      );

      await FirebaseService.firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update conversation
      await FirebaseService.firestore
          .collection('conversations')
          .doc(widget.conversation.id)
          .update({
            'lastMessage': message.content,
            'lastMessageTime': message.timestamp,
            'lastMessageSenderId': message.senderId,
          });

      _messageController.clear();
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUser?.fullName ?? 
          widget.conversation.displayName ?? 
          'Conversation',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showConversationInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('Aucun message. Commencez la conversation!'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _showAttachmentOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.senderId == widget.user.id;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Text(
                    message.senderName,
                    style: AppTheme.captionStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color: message.isRead ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: widget.user.profileImageUrl != null
                  ? NetworkImage(widget.user.profileImageUrl!)
                  : null,
              child: widget.user.profileImageUrl == null
                  ? Text(
                      widget.user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement image attachment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bientôt disponible')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement file attachment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bientôt disponible')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations de la conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.otherUser != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: widget.otherUser!.profileImageUrl != null
                    ? NetworkImage(widget.otherUser!.profileImageUrl!)
                    : null,
                child: widget.otherUser!.profileImageUrl == null
                    ? Text(
                        widget.otherUser!.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                widget.otherUser!.fullName,
                style: AppTheme.subheadingStyle,
              ),
              Text(
                widget.otherUser!.role.name.toUpperCase(),
                style: AppTheme.captionStyle,
              ),
              if (widget.otherUser!.email.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.otherUser!.email,
                  style: AppTheme.bodyStyle,
                ),
              ],
            ] else ...[
              Text(
                widget.conversation.displayName,
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),
              Text(
                'Participants: ${widget.conversation.participants.length}',
                style: AppTheme.bodyStyle,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(dateTime);
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
