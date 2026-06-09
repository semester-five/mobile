import 'package:another_flushbar/flushbar.dart';
import 'package:face_locker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  const AppToast._();

  static void success(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      type: AppToastType.success,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      type: AppToastType.error,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      type: AppToastType.warning,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(
    BuildContext context, {
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      type: AppToastType.info,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    final color = _color(type);
    final cleanMessage = message?.trim();
    Flushbar<void>? flushbar;

    flushbar = Flushbar<void>(
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(10),
      borderColor: color,
      borderWidth: 1.5,
      backgroundColor: _backgroundColor(type),
      boxShadows: [
        BoxShadow(
          color: color.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      messageText: _ToastContent(
        type: type,
        color: color,
        title: cleanMessage == null || cleanMessage.isEmpty
            ? title
            : '$title  $cleanMessage',
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                flushbar?.dismiss();
                onAction();
              },
        onClose: () => flushbar?.dismiss(),
      ),
      duration: duration,
      animationDuration: const Duration(milliseconds: 180),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    );

    flushbar.show(context);
  }

  static Color _color(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return AppTheme.accent;
      case AppToastType.error:
        return AppTheme.danger;
      case AppToastType.warning:
        return AppTheme.warning;
      case AppToastType.info:
        return AppTheme.primary;
    }
  }

  static Color _backgroundColor(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const Color(0xFFEFFDFB);
      case AppToastType.error:
        return const Color(0xFFFFF1F4);
      case AppToastType.warning:
        return const Color(0xFFFFF8ED);
      case AppToastType.info:
        return const Color(0xFFEFF9FF);
    }
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.type,
    required this.color,
    required this.title,
    required this.onClose,
    this.actionLabel,
    this.onAction,
  });

  final AppToastType type;
  final Color color;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(_icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: color,
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: onClose,
            tooltip: 'Dismiss',
            icon: Icon(Icons.close_rounded, color: color, size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (type) {
      case AppToastType.success:
        return Icons.check_rounded;
      case AppToastType.error:
        return Icons.close_rounded;
      case AppToastType.warning:
        return Icons.warning_amber_rounded;
      case AppToastType.info:
        return Icons.info_outline_rounded;
    }
  }
}
