import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onAttach;
  final bool readOnly;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onAttach,
    this.readOnly = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSend = false;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showSend = _controller.text.trim().isNotEmpty;
      });
    });
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.readOnly) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C33) : Colors.white,
          border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
        ),
        child: const Center(
          child: Text(
            'Seuls les administrateurs peuvent envoyer des messages.',
            style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.transparent,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            if (_showEmoji) {
                              _focusNode.requestFocus();
                            } else {
                              FocusScope.of(context).unfocus();
                              setState(() => _showEmoji = true);
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: 5,
                            minLines: 1,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Colors.grey),
                          onPressed: () => _showMediaOptions(context),
                        ),
                        if (!_showSend)
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.grey),
                            onPressed: () => _pickMedia(FileType.image, fromCamera: true),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showSend ? _handleSend : null,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _showSend ? Icons.send : Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showEmoji)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _controller.text += emoji.emoji;
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                viewOrderConfig: const ViewOrderConfig(),
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: isDark ? const Color(0xFF121B22) : Colors.white,
                  columns: 7,
                  emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: isDark ? const Color(0xFF1F2C33) : Colors.grey[100]!,
                  indicatorColor: const Color(0xFF25D366),
                  iconColorSelected: const Color(0xFF25D366),
                ),
                bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                searchViewConfig: const SearchViewConfig(),
              ),
            ),
          ),
      ],
    );
  }

  void _showMediaOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121B22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildMediaIcon(Icons.insert_drive_file, 'Document', Colors.indigo, FileType.any),
            _buildMediaIcon(Icons.camera_alt, 'Appareil photo', Colors.pink, FileType.image, fromCamera: true),
            _buildMediaIcon(Icons.image, 'Galerie', Colors.purple, FileType.image),
            _buildMediaIcon(Icons.headphones, 'Audio', Colors.orange, FileType.audio),
            _buildMediaIcon(Icons.location_on, 'Lieu', Colors.green, FileType.any),
            _buildMediaIcon(Icons.person, 'Contact', Colors.blue, FileType.any),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaIcon(IconData icon, String label, Color color, FileType type, {bool fromCamera = false}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _pickMedia(type, fromCamera: fromCamera);
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(FileType type, {bool fromCamera = false}) async {
    try {
      String? filePath;
      String? fileName;

      if (fromCamera) {
        final ImagePicker picker = ImagePicker();
        // Check if camera is available (image_picker on Linux/Desktop often lacks a delegate)
        try {
          final XFile? photo = await picker.pickImage(source: ImageSource.camera);
          if (photo != null) {
            filePath = photo.path;
            fileName = photo.name;
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Caméra non disponible sur cet appareil. Ouverture de la galerie...')),
            );
          }
          final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
          if (photo != null) {
            filePath = photo.path;
            fileName = photo.name;
          }
        }
      } else {
        final result = await FilePicker.platform.pickFiles(type: type);
        if (result != null) {
          filePath = result.files.single.path;
          fileName = result.files.single.name;
        }
      }

      if (filePath != null && fileName != null && mounted) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Envoi de $fileName...'), duration: const Duration(seconds: 1)),
        );

        try {
          final publicUrl = await MessagingService.uploadFile(filePath, fileName);
          widget.onSend(publicUrl); // Send the URL as the message
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur d\'envoi: $e')),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking/uploading file: $e');
    }
  }
}
