import 'package:flutter/material.dart';
import '../models/bot_config.dart';
import '../models/log_entry.dart';
import '../services/bot_service.dart';
import '../services/api_service.dart';
import 'logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BotService _botService = BotService();
  final ApiService _apiService = ApiService();
  
  BotConfig _botConfig = BotConfig.defaultConfig();
  List<LogEntry> _logs = [];
  double _balance = 1250.75;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupBotService();
    _loadInitialData();
  }

  void _setupBotService() {
    _botService.onLogsUpdated = (logs) {
      setState(() {
        _logs = logs;
      });
    };

    _botService.onBotStatusChanged = (isRunning) {
      setState(() {});
    };
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final balance = await _apiService.getBalance();
      final logs = await _botService.getCurrentLogs();
      
      setState(() {
        _balance = balance;
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error cargando datos: $e');
    }
  }

  Future<void> _handleStartBot() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _botService.startBot(_botConfig);
      if (success) {
        _showSuccessSnackBar('Bot iniciado correctamente');
      } else {
        _showErrorSnackBar('Error iniciando el bot');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStopBot() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _botService.stopBot();
      if (success) {
        _showSuccessSnackBar('Bot detenido correctamente');
      } else {
        _showErrorSnackBar('Error deteniendo el bot');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1f2937), Color(0xFF111827)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance USDT',
                            style: TextStyle(
                              color: Color(0xFF9ca3af),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${_balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF4ade80),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _botService.isRunning 
                            ? const Color(0xFF4ade80).withOpacity(0.2)
                            : const Color(0xFF6b7280).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _botService.isRunning 
                              ? const Color(0xFF4ade80)
                              : const Color(0xFF6b7280),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: 6),
                          Text(
                            _botService.isRunning ? 'ACTIVO' : 'INACTIVO',
                            style: TextStyle(
                              color: _botService.isRunning 
                                  ? const Color(0xFF4ade80)
                                  : const Color(0xFF6b7280),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configuration Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2937).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          color: Color(0xFFfbbf24),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Configuración del Bot',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Trading pair selection
                    const Text(
                      'Par de Trading',
                      style: TextStyle(
                        color: Color(0xFFd1d5db),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _botConfig.selectedPair,
                      onChanged: (value) {
                        setState(() {
                          _botConfig = _botConfig.copyWith(selectedPair: value!);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF374151),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4b5563)),
                        ),
                      ),
                      dropdownColor: const Color(0xFF374151),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'BTC/USDT', child: Text('BTC/USDT')),
                        DropdownMenuItem(value: 'ETH/USDT', child: Text('ETH/USDT')),
                        DropdownMenuItem(value: 'BNB/USDT', child: Text('BNB/USDT')),
                        DropdownMenuItem(value: 'ADA/USDT', child: Text('ADA/USDT')),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Pullback slider
                    Text(
                      'Pullback para Comprar: ${_botConfig.pullbackPercent.toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFd1d5db),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Slider(
                      value: _botConfig.pullbackPercent,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: const Color(0xFFfbbf24),
                      onChanged: (value) {
                        setState(() {
                          _botConfig = _botConfig.copyWith(pullbackPercent: value);
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profit target slider
                    Text(
                      'Target de Ganancia: ${_botConfig.profitTarget.toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFd1d5db),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Slider(
                      value: _botConfig.profitTarget,
                      min: 1,
                      max: 15,
                      divisions: 14,
                      activeColor: const Color(0xFFfbbf24),
                      onChanged: (value) {
                        setState(() {
                          _botConfig = _botConfig.copyWith(profitTarget: value);
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // EMA toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Confirmar con EMA9/EMA21',
                            style: TextStyle(
                              color: Color(0xFFd1d5db),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Switch(
                          value: _botConfig.useEMA,
                          onChanged: (value) {
                            setState(() {
                              _botConfig = _botConfig.copyWith(useEMA: value);
                            });
                          },
                          activeColor: const Color(0xFFfbbf24),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Trailing stop toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Trailing Stop',
                            style: TextStyle(
                              color: Color(0xFFd1d5db),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Switch(
                          value: _botConfig.trailingStop,
                          onChanged: (value) {
                            setState(() {
                              _botConfig = _botConfig.copyWith(trailingStop: value);
                            });
                          },
                          activeColor: const Color(0xFFfbbf24),
                        ),
                      ],
                    ),
                    
                    if (_botConfig.trailingStop) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Trailing Stop: ${_botConfig.trailingPercent.toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFFd1d5db),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Slider(
                        value: _botConfig.trailingPercent,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: const Color(0xFFfbbf24),
                        onChanged: (value) {
                          setState(() {
                            _botConfig = _botConfig.copyWith(trailingPercent: value);
                          });
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Start/Stop button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_botService.isRunning ? _handleStopBot : _handleStartBot),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _botService.isRunning 
                              ? const Color(0xFFdc2626) 
                              : const Color(0xFF10b981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _botService.isRunning ? Icons.stop : Icons.play_arrow,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _botService.isRunning ? 'Detener Bot' : 'Iniciar Bot',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Live Logs Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2937).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          color: Color(0xFFfbbf24),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Log en Tiempo Real',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a pantalla completa de logs
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Ver todos',
                            style: TextStyle(color: Color(0xFFfbbf24)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay logs disponibles',
                                style: TextStyle(
                                  color: Color(0xFF6b7280),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _logs.length > 5 ? 5 : _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '[${log.time}]',
                                        style: const TextStyle(
                                          color: Color(0xFF6b7280),
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          log.message,
                                          style: TextStyle(
                                            color: _getLogColor(log.type),
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

