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
    final cleanTitle = _compactText(title);
    final cleanMessage = _compactText(message);
    Flushbar<void>? flushbar;

    flushbar = Flushbar<void>(
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 72),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(14),
      backgroundColor: color,
      boxShadows: [
        BoxShadow(
          color: color.withValues(alpha: 0.22),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      messageText: _ToastContent(
        type: type,
        color: color,
        title: cleanTitle,
        message: cleanMessage,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                flushbar?.dismiss();
                onAction();
              },
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

  static String? _compactText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Color _color(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const Color(0xFF12B76A);
      case AppToastType.error:
        return AppTheme.danger;
      case AppToastType.warning:
        return AppTheme.warning;
      case AppToastType.info:
        return AppTheme.primary;
    }
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.type,
    required this.color,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final AppToastType type;
  final Color color;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 21, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title!,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                if (message != null && message!.isNotEmpty) ...[
                  if (title != null && title!.isNotEmpty)
                    const SizedBox(height: 2),
                  Text(
                    message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
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
