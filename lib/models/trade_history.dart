class TradeHistory {
  final String pair;
  final String type;
  final double price;
  final double amount;
  final String time;
  final String? profit;

  TradeHistory({
    required this.pair,
    required this.type,
    required this.price,
    required this.amount,
    required this.time,
    this.profit,
  });

  factory TradeHistory.fromJson(Map<String, dynamic> json) {
    return TradeHistory(
      pair: json['pair'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      time: json['time'] ?? '',
      profit: json['profit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'type': type,
      'price': price,
      'amount': amount,
      'time': time,
      'profit': profit,
    };
  }
}
