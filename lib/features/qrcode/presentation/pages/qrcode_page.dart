import 'package:face_locker/core/services/session_service.dart';
import 'package:face_locker/core/theme/app_theme.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/qrcode/presentation/pages/qr_scanner_page.dart';
import 'package:flutter/material.dart';

class QrcodePage extends StatefulWidget {
  const QrcodePage({super.key});

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  final SessionService _sessionService = SessionService();
  bool _isProcessingScan = false;

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (!mounted || result == null) return;

    final scannedValue = result.trim();
    if (scannedValue.isEmpty) return;

    if (_isProcessingScan) return;

    setState(() => _isProcessingScan = true);

    try {
      final generatedToken = await _sessionService.generateQRCodeToken();
      final token = generatedToken['token']?.toString().trim();
      if (token == null || token.isEmpty) {
        throw Exception('QR token response is missing token');
      }
      final response = await _sessionService.cicoByQRCode(token);
      final lockerCode =
          response['lockerCode'] ??
          response['locker']?['code'] ??
          response['locker_code'] ??
          response['lockerId'];
      final status =
          response['status'] ?? response['sessionStatus'] ?? response['state'];
      final message = lockerCode != null && lockerCode.toString().isNotEmpty
          ? 'Locker $lockerCode'
          : status != null
          ? '$status'
          : null;

      if (!mounted) return;
      AppToast.success(context, title: 'CICO completed', message: message);
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, title: 'CICO failed', message: '$error');
    } finally {
      if (mounted) setState(() => _isProcessingScan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Scan QR',
                  subtitle: 'Scan locker QR or CICO token',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.softPanel(),
                  child: Column(
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 112,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _InlineMessage(
                        icon: Icons.camera_alt_outlined,
                        color: AppTheme.muted,
                        text: 'Use the phone camera to scan a locker QR.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isProcessingScan ? null : _openScanner,
                  icon: _isProcessingScan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan locker QR / CICO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
