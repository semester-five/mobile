class SessionItemView {
  const SessionItemView({
    required this.id,
    required this.lockerCode,
    required this.lockerLocation,
    required this.status,
    required this.authMethod,
    required this.checkInAt,
    required this.checkOutAt,
    required this.createdAt,
  });

  final String id;
  final String lockerCode;
  final String lockerLocation;
  final String status;
  final String authMethod;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final DateTime? createdAt;

  factory SessionItemView.fromJson(Map<String, dynamic> json) {
    final locker = _asMap(json['locker']);

    return SessionItemView(
      id: _readString(json['id'] ?? json['sessionId']),
      lockerCode: _readString(
        json['lockerCode'] ??
            json['locker_code'] ??
            locker?['lockerCode'] ??
            locker?['code'],
      ),
      lockerLocation: _readString(
        json['lockerLocation'] ??
            json['locker_location'] ??
            locker?['location'],
      ),
      status: _readString(json['status'] ?? json['sessionStatus']),
      authMethod: _readString(json['authMethod'] ?? json['method']),
      checkInAt: _parseDate(json['checkInAt'] ?? json['check_in_at']),
      checkOutAt: _parseDate(json['checkOutAt'] ?? json['check_out_at']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}
