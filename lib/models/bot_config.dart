class BotConfig {
  final String selectedPair;
  final double pullbackPercent;
  final double profitTarget;
  final bool useEMA;
  final bool trailingStop;
  final double trailingPercent;

  BotConfig({
    required this.selectedPair,
    required this.pullbackPercent,
    required this.profitTarget,
    required this.useEMA,
    required this.trailingStop,
    required this.trailingPercent,
  });

  factory BotConfig.defaultConfig() {
    return BotConfig(
      selectedPair: 'BTC/USDT',
      pullbackPercent: 2.0,
      profitTarget: 5.0,
      useEMA: true,
      trailingStop: true,
      trailingPercent: 2.0,
    );
  }

  factory BotConfig.fromJson(Map<String, dynamic> json) {
    return BotConfig(
      selectedPair: json['selectedPair'] ?? 'BTC/USDT',
      pullbackPercent: (json['pullbackPercent'] ?? 2.0).toDouble(),
      profitTarget: (json['profitTarget'] ?? 5.0).toDouble(),
      useEMA: json['useEMA'] ?? true,
      trailingStop: json['trailingStop'] ?? true,
      trailingPercent: (json['trailingPercent'] ?? 2.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedPair': selectedPair,
      'pullbackPercent': pullbackPercent,
      'profitTarget': profitTarget,
      'useEMA': useEMA,
      'trailingStop': trailingStop,
      'trailingPercent': trailingPercent,
    };
  }

  BotConfig copyWith({
    String? selectedPair,
    double? pullbackPercent,
    double? profitTarget,
    bool? useEMA,
    bool? trailingStop,
    double? trailingPercent,
  }) {
    return BotConfig(
      selectedPair: selectedPair ?? this.selectedPair,
      pullbackPercent: pullbackPercent ?? this.pullbackPercent,
      profitTarget: profitTarget ?? this.profitTarget,
      useEMA: useEMA ?? this.useEMA,
      trailingStop: trailingStop ?? this.trailingStop,
      trailingPercent: trailingPercent ?? this.trailingPercent,
    );
  }
}
