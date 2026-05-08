import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_action_page.dart';
import 'package:flutter/material.dart';

class LockerDetailPage extends StatefulWidget {
  const LockerDetailPage({super.key, required this.lockerId});

  final String lockerId;

  @override
  State<LockerDetailPage> createState() => _LockerDetailPageState();
}

class _LockerDetailPageState extends State<LockerDetailPage> {
  final LockerService _lockerService = LockerService();

  bool _isLoading = false;
  String? _errorMessage;
  LockerItemView? _locker;

  @override
  void initState() {
    super.initState();
    _loadLocker();
  }

  Future<void> _loadLocker() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _lockerService.getLockerById(widget.lockerId);
      final data = response['data'];
      final lockerJson = data is Map<String, dynamic> ? data : response;
      _locker = LockerItemView.fromJson(lockerJson);
    } catch (error) {
      _errorMessage = 'Failed to load locker details.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        ),
        title: const Text(
          'Locker Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _ErrorState(message: _errorMessage!, onRetry: _loadLocker)
            else if (_locker != null)
              _LockerHeader(locker: _locker!)
            else
              const Center(
                child: Text(
                  'Locker not found.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            const SizedBox(height: 32),
            const Text(
              'Hardware Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ESP32: -- • Relay: --',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _locker == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              LockerActionPage(lockerId: widget.lockerId),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Open Actions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockerHeader extends StatelessWidget {
  const _LockerHeader({required this.locker});

  final LockerItemView locker;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(locker.status);
    final backgroundColor = statusColor.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            locker.code.isEmpty ? '-' : locker.code,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          Text(
            locker.status.isEmpty ? 'Unknown' : locker.status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(_buildMeta(locker), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _buildMeta(LockerItemView locker) {
    final location = locker.location.isEmpty ? '-' : locker.location;
    final size = locker.size.isEmpty ? '-' : locker.size;
    final doorState = locker.doorState.isEmpty ? '-' : locker.doorState;
    return '$location • Size $size • Door: $doorState';
  }

  Color _statusColor(String status) {
    final value = status.toUpperCase();
    if (value.contains('AVAILABLE') || value.contains('FREE')) {
      return Colors.green;
    }
    if (value.contains('IN_USE') || value.contains('ACTIVE')) {
      return Colors.red;
    }
    if (value.contains('MAINTENANCE')) {
      return Colors.orange;
    }
    return Colors.blueGrey;
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
