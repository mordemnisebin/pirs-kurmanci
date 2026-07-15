import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_config.dart';

/// Multiplayer lîstik karûbar.
class MultiplayerService {
  static io.Socket? _socket;
  static final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  /// Event akışı
  static Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// Socket bağlantısı
  static bool get isConnected => _socket?.connected ?? false;

  /// Socket.IO'ya bağlan
  static void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('🔌 Socket.IO girêdayî');
      _eventController.add({'event': 'connected'});
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket.IO qut bû');
      _eventController.add({'event': 'disconnected'});
    });

    _socket!.onError((error) {
      print('❌ Socket.IO çewtî: $error');
      _eventController.add({'event': 'error', 'data': error});
    });

    // Oda olayları
    _socket!.on('roomCreated', (data) {
      _eventController.add({'event': 'roomCreated', 'data': data});
    });

    _socket!.on('roomJoined', (data) {
      _eventController.add({'event': 'roomJoined', 'data': data});
    });

    _socket!.on('playerJoined', (data) {
      _eventController.add({'event': 'playerJoined', 'data': data});
    });

    _socket!.on('playerReady', (data) {
      _eventController.add({'event': 'playerReady', 'data': data});
    });

    _socket!.on('playerLeft', (data) {
      _eventController.add({'event': 'playerLeft', 'data': data});
    });

    _socket!.on('playerDisconnected', (data) {
      _eventController.add({'event': 'playerDisconnected', 'data': data});
    });

    // Oyun olayları
    _socket!.on('gameStarted', (data) {
      _eventController.add({'event': 'gameStarted', 'data': data});
    });

    _socket!.on('newQuestion', (data) {
      _eventController.add({'event': 'newQuestion', 'data': data});
    });

    _socket!.on('answerResult', (data) {
      _eventController.add({'event': 'answerResult', 'data': data});
    });

    _socket!.on('gameEnded', (data) {
      _eventController.add({'event': 'gameEnded', 'data': data});
    });

    _socket!.on('error', (data) {
      _eventController.add({'event': 'serverError', 'data': data});
    });

    _socket!.connect();
  }

  /// Bağlantıyı kes
  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Yeni oda oluştur
  static void createRoom({
    required String userId,
    required String name,
    String? categoryId,
    String? difficulty,
    int maxPlayers = 4,
  }) {
    _socket?.emit('createRoom', {
      'userId': userId,
      'name': name,
      'categoryId': categoryId,
      'difficulty': difficulty,
      'maxPlayers': maxPlayers,
    });
  }

  /// Odaya katıl
  static void joinRoom({
    required String roomCode,
    required String userId,
    required String name,
  }) {
    _socket?.emit('joinRoom', {
      'roomCode': roomCode,
      'userId': userId,
      'name': name,
    });
  }

  /// Hazır ol
  static void setReady({
    required String roomCode,
    required String userId,
  }) {
    _socket?.emit('setReady', {
      'roomCode': roomCode,
      'userId': userId,
    });
  }

  /// Oyunu başlat (sadece oda sahibi)
  static void startGame({
    required String roomCode,
    required String userId,
  }) {
    _socket?.emit('startGame', {
      'roomCode': roomCode,
      'userId': userId,
    });
  }

  /// Cevap gönder
  static void submitAnswer({
    required String roomCode,
    required String userId,
    required String answer,
    required double timeSpent,
  }) {
    _socket?.emit('submitAnswer', {
      'roomCode': roomCode,
      'userId': userId,
      'answer': answer,
      'timeSpent': timeSpent,
    });
  }

  /// Sonraki soru
  static void nextQuestion({required String roomCode}) {
    _socket?.emit('nextQuestion', {'roomCode': roomCode});
  }

  /// Odadan ayrıl
  static void leaveRoom({
    required String roomCode,
    required String userId,
  }) {
    _socket?.emit('leaveRoom', {
      'roomCode': roomCode,
      'userId': userId,
    });
  }
}
