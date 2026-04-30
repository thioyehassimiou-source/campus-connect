import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:campusconnect/config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  
  // StreamControllers for various events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;

  void connectAndListen() {
    // Éviter les multiples connexions
    if (socket != null && socket!.connected) return;

    socket = IO.io(ApiConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Connecté au serveur Socket.io');
    });

    socket!.on('receive_message', (data) {
      print('Nouveau message reçu via socket: $data');
      _messageController.add(data);
    });

    socket!.onDisconnect((_) => print('❌ Déconnecté de Socket.io'));
  }

  void joinConversation(String conversationId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_conversation', conversationId);
    }
  }

  void sendMessage(Map<String, dynamic> messageData) {
    if (socket != null && socket!.connected) {
      socket!.emit('send_message', messageData);
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    _messageController.close();
  }
}
