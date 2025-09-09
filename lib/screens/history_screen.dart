import 'package:flutter/material.dart';
import '../models/trade_history.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<TradeHistory> _tradeHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTradeHistory();
  }

  Future<void> _loadTradeHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trades = await _apiService.getTradeHistory();
      setState(() {
        _tradeHistory = trades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error cargando historial: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          'Historial de Operaciones',
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
            onPressed: _loadTradeHistory,
            tooltip: 'Actualizar historial',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Trades',
                    '${_tradeHistory.length}',
                    Icons.trending_up,
                    const Color(0xFF4ade80),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Trades Exitosos',
                    '${_tradeHistory.where((t) => t.profit != null).length}',
                    Icons.check_circle,
                    const Color(0xFF10b981),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Trades Table
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
                    : _tradeHistory.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  color: Color(0xFF6b7280),
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No hay operaciones registradas',
                                  style: TextStyle(
                                    color: Color(0xFF6b7280),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowColor: MaterialStateProperty.all(const Color(0xFF374151)),
                              columns: const [
                                DataColumn(label: Text('Par', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Tipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Precio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Cantidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Hora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Ganancia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              ],
                              rows: _tradeHistory.map((trade) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(trade.pair, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: trade.type == 'BUY' 
                                              ? const Color(0xFF1e40af).withOpacity(0.2)
                                              : const Color(0xFFd97706).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          trade.type,
                                          style: TextStyle(
                                            color: trade.type == 'BUY' 
                                                ? const Color(0xFF60a5fa)
                                                : const Color(0xFFfbbf24),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('\$${trade.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white))),
                                    DataCell(Text(trade.amount.toString(), style: const TextStyle(color: Colors.white))),
                                    DataCell(Text(trade.time, style: const TextStyle(color: Color(0xFF9ca3af)))),
                                    DataCell(
                                      trade.profit != null
                                          ? Text(trade.profit!, style: const TextStyle(color: Color(0xFF4ade80), fontWeight: FontWeight.w500))
                                          : const Text('-', style: TextStyle(color: Color(0xFF6b7280))),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTradeHistory,
        backgroundColor: const Color(0xFFfbbf24),
        foregroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9ca3af),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
