class LockerItemView {
  const LockerItemView({
    required this.id,
    required this.code,
    required this.status,
    required this.location,
    required this.size,
    required this.doorState,
    this.espId = '',
    this.openUrl = '',
    this.closeUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  final String id;
  final String code;
  final String status;
  final String location;
  final String size;
  final String doorState;
  final String espId;
  final String openUrl;
  final String closeUrl;
  final String createdAt;
  final String updatedAt;

  factory LockerItemView.fromJson(Map<String, dynamic> json) {
    return LockerItemView(
      id: _readString(json['id'] ?? json['lockerId']),
      code: _readString(json['code'] ?? json['lockerCode']),
      status: _readString(json['status']),
      location: _readString(json['location']),
      size: _readString(json['size'] ?? json['lockerSize']),
      doorState: _readString(json['doorState'] ?? json['door_state']),
      espId: _readString(json['espId'] ?? json['esp32Id']),
      openUrl: _readString(json['openUrl'] ?? json['open_url']),
      closeUrl: _readString(json['closeUrl'] ?? json['close_url']),
      createdAt: _readString(json['createdAt'] ?? json['created_at']),
      updatedAt: _readString(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
