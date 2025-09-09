class LogEntry {
  final String time;
  final String message;
  final String type;

  LogEntry({
    required this.time,
    required this.message,
    required this.type,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      time: json['time'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'message': message,
      'type': type,
    };
  }
}
