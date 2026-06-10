import 'dart:async';

import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:flutter/material.dart';

class LockerActionPage extends StatefulWidget {
  const LockerActionPage({super.key, required this.lockerId});

  final String lockerId;

  @override
  State<LockerActionPage> createState() => _LockerActionPageState();
}

class _LockerActionPageState extends State<LockerActionPage> {
  final LockerService _lockerService = LockerService();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _forceReasonController = TextEditingController();
  Timer? _syncTimer;

  bool _isUpdating = false;
  String _selectedStatus = 'MAINTENANCE';
  String _selectedDoorState = 'CLOSED';
  int _temporaryOpenSeconds = 10;
  LockerItemView? _locker;

  @override
  void initState() {
    super.initState();
    _loadSyncedStatus();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadSyncedStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _reasonController.dispose();
    _forceReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSyncedStatus({bool silent = false}) async {
    try {
      final response = await _lockerService.getSyncedLockerStatus(
        widget.lockerId,
      );
      final data = response['data'];
      final lockerJson = data is Map<String, dynamic> ? data : response;
      if (!mounted) return;
      setState(() {
        _locker = LockerItemView.fromJson(lockerJson);
      });
    } catch (_) {
      if (!silent && mounted) {
        AppToast.error(
          context,
          title: 'Sync failed',
          message: 'State unavailable.',
        );
      }
    }
  }

  Future<void> _updateStatus() async {
    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _lockerService.updateLockerState(
        widget.lockerId,
        _selectedStatus,
        _selectedDoorState,
      );

      if (!mounted) {
        return;
      }

      AppToast.success(
        context,
        title: 'Locker updated',
        message: 'State synced.',
      );
      await _loadSyncedStatus(silent: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, title: 'Update failed', message: '$error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _forceOpen() async {
    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _lockerService.openLocker(
        widget.lockerId,
        durationSeconds: _temporaryOpenSeconds,
        reason: _forceReasonController.text,
      );
      await _loadSyncedStatus(silent: true);

      if (!mounted) {
        return;
      }

      AppToast.success(
        context,
        title: 'Locker opened',
        message: 'Command sent.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(context, title: 'Open failed', message: '$error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
          'Locker Actions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SyncedStateCard(locker: _locker),
            const SizedBox(height: 24),
            const Text(
              'Update Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'AVAILABLE', child: Text('AVAILABLE')),
                DropdownMenuItem(value: 'IN_USE', child: Text('IN_USE')),
                DropdownMenuItem(
                  value: 'MAINTENANCE',
                  child: Text('MAINTENANCE'),
                ),
              ],
              onChanged: _isUpdating
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedDoorState,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                DropdownMenuItem(value: 'CLOSED', child: Text('CLOSED')),
              ],
              onChanged: _isUpdating
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedDoorState = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Reason for status change...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 24),
            const Text(
              'Temporary Open Locker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This sends an OPEN door state to the backend. The current state above is refreshed from backend sync.',
                style: TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _temporaryOpenSeconds,
              decoration: InputDecoration(
                labelText: 'Open duration',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 seconds')),
                DropdownMenuItem(value: 10, child: Text('10 seconds')),
                DropdownMenuItem(value: 30, child: Text('30 seconds')),
                DropdownMenuItem(value: 60, child: Text('60 seconds')),
              ],
              onChanged: _isUpdating
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _temporaryOpenSeconds = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _forceReasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Reason for temporary opening...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUpdating ? null : _forceOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Send Temporary Open',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncedStateCard extends StatelessWidget {
  const _SyncedStateCard({required this.locker});

  final LockerItemView? locker;

  @override
  Widget build(BuildContext context) {
    final status = locker?.status;
    final doorState = locker?.doorState;
    final hasItem = locker?.hasItem;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synced Backend State',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StateChip(label: 'Status', value: _display(status)),
              _StateChip(label: 'Door', value: _display(doorState)),
              _StateChip(
                label: 'Item',
                value: hasItem == null ? '-' : (hasItem ? 'YES' : 'NO'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _display(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }
    return value;
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
