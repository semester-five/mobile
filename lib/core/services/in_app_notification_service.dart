import 'dart:async';

import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/core/services/notification_service.dart';
import 'package:face_locker/core/services/session_service.dart';
import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:face_locker/features/notifications/presentation/models/admin_alert_item_view.dart';
import 'package:face_locker/features/session/presentation/models/session_item_view.dart';
import 'package:flutter/foundation.dart';

class InAppNotificationService extends ChangeNotifier {
  factory InAppNotificationService() => _instance;

  InAppNotificationService._internal();

  static final InAppNotificationService _instance =
      InAppNotificationService._internal();

  static const int _overdueSessionHours = 24;
  static const int _doorOpenWarningMinutes = 5;
  static const Duration _defaultPollInterval = Duration(seconds: 30);

  final NotificationService _notificationService = NotificationService();
  final SessionService _sessionService = SessionService();
  final LockerService _lockerService = LockerService();
  final UserService _userService = UserService();

  Timer? _timer;
  bool _isLoading = false;
  bool _hasBootstrapped = false;
  String? _errorMessage;
  List<AdminAlertItemView> _alerts = const [];
  List<AdminAlertItemView> _latestNewAlerts = const [];
  final Set<String> _knownAlertIds = <String>{};
  final Set<String> _unreadAlertIds = <String>{};

  bool get isLoading => _isLoading;
  bool get isRunning => _timer != null;
  String? get errorMessage => _errorMessage;
  List<AdminAlertItemView> get alerts => List.unmodifiable(_alerts);
  List<AdminAlertItemView> get latestNewAlerts =>
      List.unmodifiable(_latestNewAlerts);
  int get unreadCount => _unreadAlertIds.length;
  int get criticalCount =>
      _alerts.where((alert) => alert.severity == AlertSeverity.critical).length;
  int get warningCount =>
      _alerts.where((alert) => alert.severity == AlertSeverity.warning).length;

  void start({Duration interval = _defaultPollInterval}) {
    if (!_userService.isAdmin) {
      stop(clear: true);
      return;
    }

    if (_timer != null) return;

    refresh(announceNewAlerts: false);
    _timer = Timer.periodic(interval, (_) {
      refresh();
    });
  }

  void stop({bool clear = false}) {
    _timer?.cancel();
    _timer = null;

    if (clear) {
      _alerts = const [];
      _latestNewAlerts = const [];
      _knownAlertIds.clear();
      _unreadAlertIds.clear();
      _errorMessage = null;
      _hasBootstrapped = false;
      notifyListeners();
    }
  }

  void markAllRead() {
    if (_unreadAlertIds.isEmpty && _latestNewAlerts.isEmpty) return;

    _unreadAlertIds.clear();
    _latestNewAlerts = const [];
    notifyListeners();
  }

  void acknowledgeLatestNewAlerts() {
    if (_latestNewAlerts.isEmpty) return;

    _latestNewAlerts = const [];
    notifyListeners();
  }

  Future<void> refresh({bool announceNewAlerts = true}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextAlerts = await _loadAlerts();
      final activeIds = nextAlerts.map((alert) => alert.id).toSet();
      final newAlerts = nextAlerts
          .where((alert) => !_knownAlertIds.contains(alert.id))
          .toList();

      _alerts = nextAlerts;
      _knownAlertIds
        ..clear()
        ..addAll(activeIds);
      _unreadAlertIds.removeWhere((id) => !activeIds.contains(id));

      if (_hasBootstrapped && announceNewAlerts && newAlerts.isNotEmpty) {
        _latestNewAlerts = newAlerts;
        _unreadAlertIds.addAll(newAlerts.map((alert) => alert.id));
      } else {
        _latestNewAlerts = const [];
      }

      _hasBootstrapped = true;
    } catch (error) {
      _errorMessage = 'Failed to load alerts: $error';
      _latestNewAlerts = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AdminAlertItemView>> _loadAlerts() async {
    final userId = _userService.currentUser?.id;
    final serverAlerts = userId == null || userId.isEmpty
        ? <AdminAlertItemView>[]
        : await _loadServerAlerts(userId);
    final localSessionAlerts = await _loadOverdueSessionAlerts();
    final doorAlerts = await _loadDoorOpenAlerts();

    return [...localSessionAlerts, ...doorAlerts, ...serverAlerts]
      ..sort(_sortAlerts);
  }

  Future<List<AdminAlertItemView>> _loadServerAlerts(String userId) async {
    try {
      final notifications = await _notificationService.getNotificationsByUserId(
        userId,
        channels: const ['mobile'],
      );
      return notifications
          .map(AdminAlertItemView.fromNotificationJson)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[InAppNotificationService] Server notifications: $error');
      }
      return const [];
    }
  }

  Future<List<AdminAlertItemView>> _loadOverdueSessionAlerts() async {
    try {
      final response = await _sessionService.getActiveSessions(
        page: 1,
        limit: 100,
      );
      final sessions = _extractItems(response)
          .map(SessionItemView.fromJson)
          .where((session) => session.checkInAt != null)
          .toList();
      final now = DateTime.now();

      return sessions
          .where(
            (session) =>
                now.difference(session.checkInAt!).inHours >=
                _overdueSessionHours,
          )
          .map((session) {
            final hours = now.difference(session.checkInAt!).inHours;
            final lockerCode = session.lockerCode.isEmpty
                ? 'Unknown locker'
                : session.lockerCode;
            final location = session.lockerLocation.isEmpty
                ? 'unknown location'
                : session.lockerLocation;

            return AdminAlertItemView(
              id: 'overdue-session-${session.id}',
              title: 'Locker used over 24h',
              content:
                  '$lockerCode at $location has been active for $hours hours.',
              severity: AlertSeverity.critical,
              source: 'Active sessions',
              createdAt: session.checkInAt!,
            );
          })
          .toList();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[InAppNotificationService] Overdue sessions: $error');
      }
      return const [];
    }
  }

  Future<List<AdminAlertItemView>> _loadDoorOpenAlerts() async {
    try {
      final response = await _lockerService.getAllLockers(
        pageNumber: 1,
        pageSize: 100,
      );
      final lockers = _extractItems(response).map(LockerItemView.fromJson);
      final now = DateTime.now();

      return lockers
          .where((locker) => locker.doorState.toUpperCase() == 'OPEN')
          .where((locker) {
            final updatedAt = DateTime.tryParse(locker.updatedAt);
            if (updatedAt == null) return false;
            return now.difference(updatedAt).inMinutes >=
                _doorOpenWarningMinutes;
          })
          .map((locker) {
            final updatedAt = DateTime.tryParse(locker.updatedAt)!;
            final minutes = now.difference(updatedAt).inMinutes;
            final code = locker.code.isEmpty ? locker.id : locker.code;

            return AdminAlertItemView(
              id: 'door-open-${locker.id}',
              title: 'Locker door left open',
              content: '$code has been open for $minutes minutes.',
              severity: AlertSeverity.warning,
              source: 'Locker state',
              createdAt: updatedAt,
            );
          })
          .toList();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[InAppNotificationService] Door alerts: $error');
      }
      return const [];
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic response) {
    final candidates = <dynamic>[
      if (response is Map<String, dynamic>) ...[
        response['data'],
        response['items'],
        response['sessions'],
        response['lockers'],
        response['content'],
      ],
      response,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  int _sortAlerts(AdminAlertItemView a, AdminAlertItemView b) {
    final severityCompare = a.severity.priority.compareTo(b.severity.priority);
    if (severityCompare != 0) return severityCompare;
    return b.createdAt.compareTo(a.createdAt);
  }
}
