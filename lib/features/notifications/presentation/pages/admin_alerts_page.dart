import 'package:face_locker/core/services/in_app_notification_service.dart';
import 'package:face_locker/core/theme/app_theme.dart';
import 'package:face_locker/features/notifications/presentation/models/admin_alert_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AdminAlertsPage extends StatefulWidget {
  const AdminAlertsPage({super.key});

  @override
  State<AdminAlertsPage> createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  final InAppNotificationService _notificationService =
      InAppNotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _notificationService.start();
      _notificationService.markAllRead();
      if (_notificationService.alerts.isEmpty) {
        _notificationService.refresh(announceNewAlerts: false);
      }
    });
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationStateChanged);
    super.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _notificationService.alerts;
    final criticalCount = _notificationService.criticalCount;
    final warningCount = _notificationService.warningCount;
    final isLoading = _notificationService.isLoading;
    final errorMessage = _notificationService.errorMessage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () => _notificationService.refresh(announceNewAlerts: false),
            tooltip: 'Refresh alerts',
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _notificationService.refresh(announceNewAlerts: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _AlertSummaryBar(
              total: alerts.length,
              critical: criticalCount,
              warning: warningCount,
            ),
            const SizedBox(height: 12),
            if (isLoading && alerts.isEmpty)
              const _LoadingState()
            else if (errorMessage != null)
              _ErrorState(
                message: errorMessage,
                onRetry: () =>
                    _notificationService.refresh(announceNewAlerts: false),
              )
            else if (alerts.isEmpty)
              const _EmptyState()
            else
              ...alerts.map((alert) => _AlertCard(alert: alert)),
          ],
        ),
      ),
    );
  }
}

class _AlertSummaryBar extends StatelessWidget {
  const _AlertSummaryBar({
    required this.total,
    required this.critical,
    required this.warning,
  });

  final int total;
  final int critical;
  final int warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _SummaryMetric(
            label: 'Total',
            value: total,
            color: AppTheme.primary,
            icon: Icons.notifications_outlined,
          ),
          const SizedBox(width: 10),
          _SummaryMetric(
            label: 'Critical',
            value: critical,
            color: AppTheme.danger,
            icon: Icons.priority_high_rounded,
          ),
          const SizedBox(width: 10),
          _SummaryMetric(
            label: 'Warning',
            value: warning,
            color: AppTheme.warning,
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final AdminAlertItemView alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: alert.severity.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              alert.severity.icon,
              color: alert.severity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SeverityTag(severity: alert.severity),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${alert.source} • ${_formatDateTime(alert.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}

class _SeverityTag extends StatelessWidget {
  const _SeverityTag({required this.severity});

  final AlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: severity.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          color: severity.color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 72),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No alerts right now.',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'New warnings will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
