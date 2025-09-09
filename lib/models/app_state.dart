import 'bot_config.dart';
import 'log_entry.dart';
import 'trade_history.dart';
import 'user_credentials.dart';

class AppState {
  final bool isLoggedIn;
  final bool isConnecting;
  final bool botRunning;
  final double balance;
  final UserCredentials? credentials;
  final BotConfig botConfig;
  final List<LogEntry> logs;
  final List<TradeHistory> tradeHistory;

  AppState({
    required this.isLoggedIn,
    required this.isConnecting,
    required this.botRunning,
    required this.balance,
    this.credentials,
    required this.botConfig,
    required this.logs,
    required this.tradeHistory,
  });

  factory AppState.initial() {
    return AppState(
      isLoggedIn: false,
      isConnecting: false,
      botRunning: false,
      balance: 1250.75,
      credentials: null,
      botConfig: BotConfig.defaultConfig(),
      logs: [
        LogEntry(time: '10:05', message: 'Bot iniciado - Analizando BTC/USDT', type: 'info'),
        LogEntry(time: '10:05', message: 'Tendencia alcista detectada en BTC/USDT', type: 'success'),
        LogEntry(time: '10:07', message: 'Precio retrocedió -2% → COMPRA ejecutada a \$42,850', type: 'buy'),
        LogEntry(time: '11:10', message: 'Take Profit alcanzado +5% → VENTA ejecutada a \$44,992', type: 'sell'),
        LogEntry(time: '11:12', message: 'Esperando nueva oportunidad...', type: 'info'),
      ],
      tradeHistory: [
        TradeHistory(pair: 'BTC/USDT', type: 'BUY', price: 42850, amount: 0.02341, time: '10:07:23', profit: null),
        TradeHistory(pair: 'BTC/USDT', type: 'SELL', price: 44992, amount: 0.02341, time: '11:10:45', profit: '+5.2%'),
        TradeHistory(pair: 'ETH/USDT', type: 'BUY', price: 2680, amount: 0.3731, time: '09:15:12', profit: null),
        TradeHistory(pair: 'ETH/USDT', type: 'SELL', price: 2814, amount: 0.3731, time: '09:45:33', profit: '+5.0%'),
      ],
    );
  }

  AppState copyWith({
    bool? isLoggedIn,
    bool? isConnecting,
    bool? botRunning,
    double? balance,
    UserCredentials? credentials,
    BotConfig? botConfig,
    List<LogEntry>? logs,
    List<TradeHistory>? tradeHistory,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isConnecting: isConnecting ?? this.isConnecting,
      botRunning: botRunning ?? this.botRunning,
      balance: balance ?? this.balance,
      credentials: credentials ?? this.credentials,
      botConfig: botConfig ?? this.botConfig,
      logs: logs ?? this.logs,
      tradeHistory: tradeHistory ?? this.tradeHistory,
    );
  }
}
