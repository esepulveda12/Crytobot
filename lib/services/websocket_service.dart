import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._internal();
  
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _currentPair;

  // Callbacks para notificar cambios
  Function(Map<String, dynamic>)? onTradeUpdate;
  Function(Map<String, dynamic>)? onLogUpdate;
  Function(Map<String, dynamic>)? onPriceUpdate;
  Function(bool)? onConnectionStatusChanged;

  // Conectar al WebSocket
  Future<bool> connect() async {
    try {
      if (_isConnected) return true;

      _channel = IOWebSocketChannel.connect('wss://cryptobot-spot-backend.onrender.com');
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      onConnectionStatusChanged?.call(true);
      
      return true;
    } catch (e) {
      print('Error conectando WebSocket: $e');
      _isConnected = false;
      onConnectionStatusChanged?.call(false);
      return false;
    }
  }

  // Desconectar del WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _currentPair = null;
    onConnectionStatusChanged?.call(false);
  }

  // Suscribirse a un par específico
  void subscribeToPair(String pair) {
    if (!_isConnected || _channel == null) return;

    _currentPair = pair;
    _channel!.sink.add(jsonEncode({
      'type': 'subscribe',
      'pair': pair.replace('/', ''),
    }));
  }

  // Enviar ping para mantener conexión
  void ping() {
    if (!_isConnected || _channel == null) return;

    _channel!.sink.add(jsonEncode({
      'type': 'ping',
    }));
  }

  // Manejar mensajes recibidos
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      switch (data['type']) {
        case 'trade':
          onTradeUpdate?.call(data['data']);
          break;
        case 'log':
          onLogUpdate?.call(data['data']);
          break;
        case 'price':
          onPriceUpdate?.call(data['data']);
          break;
        case 'pong':
          // Respuesta al ping
          break;
        default:
          print('Mensaje WebSocket desconocido: $data');
      }
    } catch (e) {
      print('Error procesando mensaje WebSocket: $e');
    }
  }

  // Manejar errores
  void _handleError(dynamic error) {
    print('Error en WebSocket: $error');
    _isConnected = false;
    onConnectionStatusChanged?.call(false);
  }

  // Manejar desconexión
  void _handleDisconnect() {
    print('WebSocket desconectado');
    _isConnected = false;
    onConnectionStatusChanged?.call(false);
  }

  // Getters
  bool get isConnected => _isConnected;
  String? get currentPair => _currentPair;
}
