import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/shared/models/message_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/chat_service.dart';

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
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToMessages() {
    ChatService.getMessages(widget.conversation.id).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages; // Already sorted by order('created_at') in service
          _isLoading = false;
        });
        
        // Mark messages as read
        ChatService.markMessagesAsRead(widget.conversation.id);
        
        // Scroll to bottom
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (_scrollController.hasClients) {
        //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        //   }
        // });
      }
    }, onError: (e) {
      print('Error loading messages: $e');
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await ChatService.sendMessage(
        conversationId: widget.conversation.id,
        content: content,
      );
      // No need to manually add message, stream will update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur envoi: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.otherUser?.fullName ?? 
          widget.conversation.displayName.replaceAll('Utilisateur', 'Chat') ?? 
          'Conversation',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun message. Commencez la discussion !',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Show latest at bottom
                        padding: const EdgeInsets.all(16),
                        // Service returns ordered by created_at ascending (oldest first).
                        // Key trick: if reverse: true, index 0 is at bottom (visual end of list).
                        // If logic: oldest -> newest.
                        // ListView reverse means bottoms-up.
                        // So we want index 0 to be newest message.
                        // Let's reverse the list locally for display
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          // _messages is oldest -> newest
                          // We want newest at bottom.
                          // ListView reverse=true puts list[0] at bottom.
                          // So list[0] should be newest.
                          // => We need to reverse _messages order for UI if using reverse:trueListView
                          final reversedIndex = _messages.length - 1 - index;
                          final message = _messages[reversedIndex];
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF64748B)),
                  onPressed: _showAttachmentOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                    onPressed: _isSending ? null : _sendMessage,
                    color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFE2E8F0),
              child: Text(
                'U', // Placeholder, ideally fetch sender name based on senderId
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Color(0xFF2563EB)),
              ),
              title: const Text('Image', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bientôt disponible')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insert_drive_file, color: Color(0xFF10B981)),
              ),
              title: const Text('Document', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bientôt disponible')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showConversationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Infos conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                widget.conversation.displayName[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.conversation.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
      return DateFormat('EEEE HH:mm', 'fr_FR').format(dateTime);
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute}';
    }
  }
}
