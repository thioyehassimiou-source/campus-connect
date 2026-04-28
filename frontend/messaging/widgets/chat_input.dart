import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/messaging_models.dart';
import '../services/messaging_service.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onAttach;
  final bool readOnly;
  final ChatMessage? repliedMessage;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onAttach,
    this.readOnly = false,
    this.repliedMessage,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSend = false;
  bool _showEmoji = false;

  // Audio Recording State
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

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
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repliedMessage != null && oldWidget.repliedMessage == null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = p.join(tempDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      if (!cancel && path != null) {
        _uploadRecording(path);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _uploadRecording(String path) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Envoi de l\'audio...'), duration: Duration(seconds: 1)),
        );
      }
      final fileName = p.basename(path);
      final publicUrl = await MessagingService.uploadFile(path, fileName);
      widget.onSend(publicUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'envoi audio: $e')),
        );
      }
    }
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
        if (widget.repliedMessage != null && !_isRecording) _buildReplyPreview(isDark),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.transparent,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: _isRecording ? const EdgeInsets.symmetric(horizontal: 16) : null,
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
                    child: _isRecording 
                      ? _buildRecordingUI(isDark)
                      : Row(
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
                  onTapDown: (_) {
                    if (!_showSend && !_isRecording) {
                      _startRecording();
                    }
                  },
                  onTap: () {
                    if (_showSend) {
                      _handleSend();
                    } else if (_isRecording) {
                      _stopRecording();
                    }
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _showSend ? Icons.send : (_isRecording ? Icons.stop : Icons.mic),
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

  Widget _buildRecordingUI(bool isDark) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16)
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 500.ms)
              .then()
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 500.ms)
              .then()
              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 500.ms),
          const SizedBox(width: 8),
          Text(
            '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Enregistrement...',
            style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _stopRecording(cancel: true),
            child: const Text('ANNULER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C33) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(left: BorderSide(color: Colors.green, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.repliedMessage!.senderName ?? 'Réponse',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                ),
                Text(
                  widget.repliedMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: widget.onCancelReply,
          ),
        ],
      ),
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
