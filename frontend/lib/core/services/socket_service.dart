import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:campusconnect/config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  
  // StreamControllers for various events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;

  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  Future<void> connect() async {
    if (socket != null && socket!.connected) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('⚠️ SocketService: Aucun token trouvé, connexion impossible.');
      return;
    }

    socket = IO.io(ApiConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Connecté au serveur Socket.io');
    });

    socket!.on('new_message', (data) {
      print('Nouveau message reçu via socket: $data');
      _messageController.add(data);
    });

    socket!.on('user_typing_start', (data) {
      _typingController.add({...data, 'isTyping': true});
    });

    socket!.on('user_typing_stop', (data) {
      _typingController.add({...data, 'isTyping': false});
    });

    socket!.onConnectError((err) => print('❌ Erreur de connexion Socket: $err'));
    socket!.onDisconnect((_) => print('❌ Déconnecté de Socket.io'));
  }

  void joinConversation(String conversationId) {
    socket?.emit('join_conversation', conversationId);
  }

  void leaveConversation(String conversationId) {
    socket?.emit('leave_conversation', conversationId);
  }

  void sendMessage(String conversationId, String content, {String type = 'text'}) {
    socket?.emit('send_message', {
      'conversationId': conversationId,
      'content': content,
      'type': type,
    });
  }

  void sendTyping(String conversationId, bool isTyping) {
    socket?.emit(isTyping ? 'typing_start' : 'typing_stop', conversationId);
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    _messageController.close();
    _typingController.close();
  }
}
