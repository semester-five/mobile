import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_action_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_edit_page.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _locker == null
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LockerEditPage(locker: _locker),
                      ),
                    );
                    if (result == true) {
                      _loadLocker();
                    }
                  },
          ),
        ],
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
              if (_locker != null) ...[
                const Text(
                  'Locker Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _InfoGrid(locker: _locker!),
                const SizedBox(height: 24),
                const Text(
                  'Hardware & URLs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'ESP32 ID',
                  value: _locker!.espId.isEmpty ? '-' : _locker!.espId,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Open URL',
                  value: _locker!.openUrl.isEmpty ? '-' : _locker!.openUrl,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Close URL',
                  value: _locker!.closeUrl.isEmpty ? '-' : _locker!.closeUrl,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Created At',
                  value: _formatDate(_locker!.createdAt),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Updated At',
                  value: _formatDate(_locker!.updatedAt),
                ),
                const SizedBox(height: 40),
              ],
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

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.locker});

  final LockerItemView locker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(label: 'Code', value: locker.code.isEmpty ? '-' : locker.code),
        const SizedBox(height: 12),
        _InfoCard(
          label: 'Location',
          value: locker.location.isEmpty ? '-' : locker.location,
        ),
        const SizedBox(height: 12),
        _InfoCard(label: 'Size', value: locker.size.isEmpty ? '-' : locker.size),
        const SizedBox(height: 12),
        _InfoCard(
          label: 'Status',
          value: locker.status.isEmpty ? '-' : locker.status,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          label: 'Door State',
          value: locker.doorState.isEmpty ? '-' : locker.doorState,
        ),
        const SizedBox(height: 12),
        _InfoCard(label: 'Locker ID', value: locker.id),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String value) {
  if (value.isEmpty) {
    return '-';
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }

  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} ${two(parsed.hour)}:${two(parsed.minute)}';
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
