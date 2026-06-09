import 'package:flutter/material.dart';

class AdminAlertItemView {
  const AdminAlertItemView({
    required this.id,
    required this.title,
    required this.content,
    required this.severity,
    required this.source,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String content;
  final AlertSeverity severity;
  final String source;
  final DateTime createdAt;
  final bool isRead;

  factory AdminAlertItemView.fromNotificationJson(Map<String, dynamic> json) {
    final message = _asMap(json['message']);
    final title = _readString(
      message?['title'] ?? json['title'] ?? 'Notification',
    );
    final content = _readString(
      message?['content'] ?? message?['body'] ?? json['content'] ?? '',
    );

    return AdminAlertItemView(
      id: _readString(json['id']).isEmpty
          ? 'notification-${json.hashCode}'
          : _readString(json['id']),
      title: title,
      content: content.isEmpty ? 'No notification detail.' : content,
      severity: AlertSeverity.fromText('$title $content'),
      source: 'Server',
      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
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

enum AlertSeverity {
  critical,
  warning,
  info;

  static AlertSeverity fromText(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('critical') ||
        lower.contains('over 24') ||
        lower.contains('24h')) {
      return AlertSeverity.critical;
    }
    if (lower.contains('warning') || lower.contains('open')) {
      return AlertSeverity.warning;
    }
    return AlertSeverity.info;
  }

  String get label {
    switch (this) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFDC2626);
      case AlertSeverity.warning:
        return const Color(0xFFD97706);
      case AlertSeverity.info:
        return const Color(0xFF2563EB);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFFEE2E2);
      case AlertSeverity.warning:
        return const Color(0xFFFEF3C7);
      case AlertSeverity.info:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.priority_high_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  int get priority {
    switch (this) {
      case AlertSeverity.critical:
        return 0;
      case AlertSeverity.warning:
        return 1;
      case AlertSeverity.info:
        return 2;
    }
  }
}
