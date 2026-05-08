import 'package:face_locker/core/services/session_service.dart';
import 'package:face_locker/features/qrcode/presentation/controllers/qrcode_controller.dart';
import 'package:face_locker/features/qrcode/presentation/pages/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class QrcodePage extends StatefulWidget {
  const QrcodePage({super.key, this.controller});

  final QrcodeController? controller;

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  late final QrcodeController _controller;
  late final bool _ownsController;
  final SessionService _sessionService = SessionService();
  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? QrcodeController();
    _controller.loadQrToken();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (!mounted || result == null) return;

    final token = result.trim();
    if (token == 'generate-qr') {
      await _controller.loadQrToken();
      return;
    }

    if (_isProcessingScan) return;

    setState(() => _isProcessingScan = true);

    try {
      if (token == 'cico-locker') {
        try {
          // Gửi request http để mở tủ thông qua ESP32
          final response = await http
              .get(Uri.parse('http://172.21.168.142/open1'))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            debugPrint('Mở tủ thành công: ${response.body}');
          } else {
            debugPrint('Lỗi khi mở tủ: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Lỗi kết nối ESP32: $e');
        }
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
          ? 'CICO success for locker $lockerCode'
          : 'CICO success${status != null ? ' ($status)' : ''}';

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CICO failed: $error')));
    } finally {
      if (mounted) setState(() => _isProcessingScan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final qrToken = _controller.qrTokenResponse;
        final remainingSeconds = _controller.remainingSeconds;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'QR Check-in',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: _controller.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : qrToken == null
                            ? Center(
                                child: Icon(
                                  Icons.qr_code_2,
                                  size: 120,
                                  color: Colors.grey[400],
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: QrImageView(
                                  data: qrToken.token,
                                  version: QrVersions.auto,
                                  size: 226,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_controller.errorMessage != null) ...[
                      Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (qrToken != null) ...[
                      Text(
                        'Expires at: ${_formatDateTime(qrToken.expiresAt)}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Auto refresh in ${_formatRemainingSeconds(remainingSeconds)}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      qrToken == null
                          ? 'Tap refresh to generate your check-in QR code.'
                          : 'Show this code to the locker camera',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _controller.isLoading
                            ? null
                            : _controller.loadQrToken,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate new QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _controller.isLoading || _isProcessingScan
                            ? null
                            : _openScanner,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan QR to check-in/out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          side: const BorderSide(color: Color(0xFF4A90E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  String _formatRemainingSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
