import 'dart:async';
import '../models/bot_config.dart';
import '../models/log_entry.dart';
import 'api_service.dart';

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  final ApiService _apiService = ApiService();
  Timer? _logTimer;
  bool _isRunning = false;

  // Callbacks para notificar cambios
  Function(List<LogEntry>)? onLogsUpdated;
  Function(bool)? onBotStatusChanged;

  // Iniciar bot
  Future<bool> startBot(BotConfig config) async {
    if (_isRunning) return false;

    try {
      final success = await _apiService.startBot(config);
      if (success) {
        _isRunning = true;
        _startLogTimer();
        onBotStatusChanged?.call(true);
        return true;
      }
      return false;
    } catch (e) {
      print('Error iniciando bot: $e');
      return false;
    }
  }

  // Detener bot
  Future<bool> stopBot() async {
    if (!_isRunning) return false;

    try {
      final success = await _apiService.stopBot();
      if (success) {
        _isRunning = false;
        _stopLogTimer();
        onBotStatusChanged?.call(false);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deteniendo bot: $e');
      return false;
    }
  }

  // Obtener estado actual
  bool get isRunning => _isRunning;

  // Iniciar timer para logs en tiempo real
  void _startLogTimer() {
    _logTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isRunning) {
        await _updateLogs();
      }
    });
  }

  // Detener timer
  void _stopLogTimer() {
    _logTimer?.cancel();
    _logTimer = null;
  }

  // Actualizar logs
  Future<void> _updateLogs() async {
    try {
      final logs = await _apiService.getLogs();
      onLogsUpdated?.call(logs);
    } catch (e) {
      print('Error actualizando logs: $e');
    }
  }

  // Obtener logs actuales
  Future<List<LogEntry>> getCurrentLogs() async {
    return await _apiService.getLogs();
  }

  // Obtener estado del bot
  Future<Map<String, dynamic>> getBotStatus() async {
    return await _apiService.getBotStatus();
  }

  // Limpiar recursos
  void dispose() {
    _stopLogTimer();
  }
}
