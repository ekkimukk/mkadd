// lib/services/websocket_service.dart

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _ip;
  final int _port;
  final Function(dynamic message) _onMessage;
  final Function() _onConnect;
  final Function() _onDisconnect;

  String? _currentBoardId;

  WebSocketService({
    required String ip,
    required int port,
    required Function(dynamic message) onMessage,
    required Function() onConnect,
    required Function() onDisconnect,
  }) : _ip = ip,
       _port = port,
       _onMessage = onMessage,
       _onConnect = onConnect,
       _onDisconnect = onDisconnect;

  // Подключиться к конкретной доске
  void connectToBoard(String boardId) {
    if (_currentBoardId == boardId && _channel != null) {
      // Уже подключены к этой доске
      return;
    }

    // Отключаем старое соединение
    disconnect();

    _currentBoardId = boardId;
    final url = 'ws://$_ip:$_port/ws?boardId=$_currentBoardId';
    print('🔌 Connecting to: $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (message) {
          print('📡 Received: $message');
          try {
            final decoded = jsonDecode(message);
            _onMessage(decoded);
          } catch (e) {
            print('❌ JSON decode error: $e');
          }
        },
        onDone: _onDisconnect,
        onError: (error) {
          print('WebSocket error: $error');
          _onDisconnect();
        },
      );

      _onConnect();
    } catch (e) {
      print('Connection error: $e');
      _onDisconnect();
    }
  }

  void sendMessage(dynamic message) {
    if (_channel?.sink != null) {
      print('📤 Sending: $message');
      _channel!.sink.add(jsonEncode(message));
    } else {
      print('⚠️ Cannot send: not connected');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _currentBoardId = null;
  }
}
