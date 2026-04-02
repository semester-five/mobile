class QrTokenResponseDto {
  const QrTokenResponseDto({
    required this.id,
    required this.token,
    required this.qrCodeBase64,
    required this.expiresAt,
    required this.expiresInSeconds,
  });

  final String id;
  final String token;
  final String qrCodeBase64;
  final DateTime expiresAt;
  final int expiresInSeconds;

  factory QrTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return QrTokenResponseDto(
      id: json['id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      qrCodeBase64: json['qrCodeBase64'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now(),
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
    );
  }
}
