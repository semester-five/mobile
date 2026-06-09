import 'package:face_locker/core/services/in_app_notification_service.dart';
import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/core/theme/app_theme.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_list_page.dart';
import 'package:face_locker/features/notifications/presentation/models/admin_alert_item_view.dart';
import 'package:face_locker/features/notifications/presentation/pages/admin_alerts_page.dart';
import 'package:face_locker/features/profile/presentation/pages/profile_page.dart';
import 'package:face_locker/features/qrcode/presentation/pages/qrcode_page.dart';
import 'package:face_locker/features/session/presentation/pages/my_session_page.dart';
import 'package:face_locker/features/statistics/presentation/pages/stats_overview_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userService});

  final UserService? userService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late UserService _userService;
  final InAppNotificationService _notificationService =
      InAppNotificationService();
  late List<Widget> _pages;
  String? _lastSnackAlertId;

  void _onNavChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_userService.isAdmin && index == 2) {
      _notificationService.markAllRead();
    }
  }

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _initializePages();
    if (_userService.isAdmin) {
      _notificationService.addListener(_onNotificationStateChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notificationService.start();
      });
    }
  }

  @override
  void dispose() {
    if (_userService.isAdmin) {
      _notificationService.removeListener(_onNotificationStateChanged);
    }
    super.dispose();
  }

  void _initializePages() {
    if (_userService.isAdmin) {
      _pages = [
        const LockerListPage(),
        const StatsOverviewPages(),
        const AdminAlertsPage(),
        const ProfilePage(),
      ];
    } else {
      _pages = [const MySessionPage(), const QrcodePage(), const ProfilePage()];
    }
  }

  void _onNotificationStateChanged() {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onNotificationStateChanged();
      });
      return;
    }

    setState(() {});
    final newAlerts = _notificationService.latestNewAlerts;
    if (newAlerts.isEmpty) return;

    final latestAlert = newAlerts.first;
    if (_lastSnackAlertId == latestAlert.id) return;

    _lastSnackAlertId = latestAlert.id;

    AppToast.show(
      context,
      type: _toastTypeFromSeverity(latestAlert.severity),
      title: newAlerts.length == 1
          ? latestAlert.title
          : '${newAlerts.length} new alerts',
      message: newAlerts.length == 1 ? latestAlert.content : latestAlert.title,
      actionLabel: 'View',
      onAction: () {
        setState(() => _selectedIndex = 2);
        _notificationService.markAllRead();
      },
      duration: const Duration(seconds: 5),
    );
    _notificationService.acknowledgeLatestNewAlerts();
  }

  AppToastType _toastTypeFromSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppToastType.error;
      case AlertSeverity.warning:
        return AppToastType.warning;
      case AlertSeverity.info:
        return AppToastType.info;
    }
  }

  List<NavigationDestination> _buildNavItems() {
    if (_userService.isAdmin) {
      return [
        const NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Lockers',
        ),
        const NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: _NotificationBadge(
            count: _notificationService.unreadCount,
            child: const Icon(Icons.notifications_active_outlined),
          ),
          selectedIcon: _NotificationBadge(
            count: _notificationService.unreadCount,
            child: const Icon(Icons.notifications_active),
          ),
          label: 'Alerts',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return const [
      NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history),
        label: 'Sessions',
      ),
      NavigationDestination(
        icon: Icon(Icons.qr_code_2_outlined),
        selectedIcon: Icon(Icons.qr_code_2),
        label: 'QR',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavChanged,
          destinations: _buildNavItems(),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = count > 99 ? '99+' : count.toString();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.danger,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
