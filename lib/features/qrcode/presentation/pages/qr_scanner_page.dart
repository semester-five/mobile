import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final TextEditingController _manualInputController = TextEditingController();

  bool _isProcessing = false;
  String? _statusMessage;
  Color _statusColor = Colors.white;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _showResult(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });
  }

  Future<void> _completeScan(String rawValue) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    final isValid = rawValue.trim() == 'generate-qr';

    _showResult(
      isValid
          ? 'Scan successful: valid QR detected'
          : 'Scan failed: invalid QR content: ${rawValue.trim()}',
      isValid ? Colors.greenAccent : Colors.redAccent,
    );

    await _scannerController.stop();

    if (!isValid) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = null;
        _statusColor = Colors.white;
        _isProcessing = false;
      });

      await _scannerController.start();
      return;
    }

    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop<String>(rawValue);
  }

  Future<void> _handleBarcodeCapture(BarcodeCapture capture) async {
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    await _completeScan(rawValue);
  }

  Future<void> _simulateScan() async {
    final value = _manualInputController.text.trim();
    if (value.isEmpty) {
      _showResult('Enter QR content first', Colors.orangeAccent);
      return;
    }

    await _completeScan(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeCapture,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(width: 32, height: 32, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.greenAccent, width: 4), left: BorderSide(color: Colors.greenAccent, width: 4)))),
                  ),
                ],
              ),
            ),
          ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _statusMessage ?? 'Point your camera at the QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _statusMessage == null ? Colors.white : _statusColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Point your camera at the QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manualInputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Simulator fallback: generate-qr',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white10,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _simulateScan,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Test scan result'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
