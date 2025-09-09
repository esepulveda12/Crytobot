class UserCredentials {
  final String apiKey;
  final String secretKey;

  UserCredentials({
    required this.apiKey,
    required this.secretKey,
  });

  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      apiKey: json['apiKey'] ?? '',
      secretKey: json['secretKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'secretKey': secretKey,
    };
  }

  bool get isValid => apiKey.isNotEmpty && secretKey.isNotEmpty;
}
