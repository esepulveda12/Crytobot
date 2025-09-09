import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../services/bot_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final BotService _botService = BotService();
  List<LogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _setupBotService();
  }

  void _setupBotService() {
    _botService.onLogsUpdated = (logs) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    };
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _botService.getCurrentLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error cargando logs: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getLogColor(String type) {
    switch (type) {
      case 'success': return const Color(0xFF4ade80);
      case 'buy': return const Color(0xFF60a5fa);
      case 'sell': return const Color(0xFFfbbf24);
      case 'warning': return const Color(0xFFfb923c);
      case 'error': return const Color(0xFFf87171);
      default: return const Color(0xFFd1d5db);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          'Logs en Tiempo Real',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1f2937),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Actualizar logs',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header con información del bot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1f2937).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: const Color(0xFFfbbf24),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado del Bot',
                          style: TextStyle(
                            color: Color(0xFF9ca3af),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _botService.isRunning 
                                    ? const Color(0xFF4ade80) 
                                    : const Color(0xFF6b7280),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _botService.isRunning ? 'Ejecutándose' : 'Detenido',
                              style: TextStyle(
                                color: _botService.isRunning 
                                    ? const Color(0xFF4ade80) 
                                    : const Color(0xFF6b7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_logs.length} entradas',
                    style: const TextStyle(
                      color: Color(0xFF9ca3af),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de logs
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2937).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFfbbf24)),
                        ),
                      )
                    : _logs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  color: Color(0xFF6b7280),
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No hay logs disponibles',
                                  style: TextStyle(
                                    color: Color(0xFF6b7280),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getLogColor(log.type).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _getLogColor(log.type),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '[${log.time}]',
                                                style: const TextStyle(
                                                  color: Color(0xFF6b7280),
                                                  fontSize: 12,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getLogColor(log.type).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  log.type.toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getLogColor(log.type),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            log.message,
                                            style: TextStyle(
                                              color: _getLogColor(log.type),
                                              fontSize: 14,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLogs,
        backgroundColor: const Color(0xFFfbbf24),
        foregroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
