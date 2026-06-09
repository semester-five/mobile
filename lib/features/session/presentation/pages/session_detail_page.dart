import 'package:face_locker/features/session/presentation/models/session_item_view.dart';
import 'package:flutter/material.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.session});

  final SessionItemView session;

  bool get _isActive {
    final value = session.status.toUpperCase();
    return value.contains('ACTIVE') || value.contains('IN_USE');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(session.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        ),
        title: const Text(
          'Session Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR LOCKER',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    session.lockerCode.isEmpty ? '-' : session.lockerCode,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _StatusPill(status: session.status, color: statusColor),
                const SizedBox(height: 14),
                Text(
                  session.lockerLocation.isEmpty ? '-' : session.lockerLocation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoSection(
            title: 'Session Info',
            children: [
              _InfoRow(label: 'Session ID', value: session.id),
              _InfoRow(
                label: 'Authentication',
                value: _displayEnum(session.authMethod),
              ),
              _InfoRow(label: 'Status', value: _displayEnum(session.status)),
              _InfoRow(label: 'Duration', value: _formatDuration(session)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Timeline',
            children: [
              _InfoRow(
                label: 'Check-in',
                value: _formatDateTime(session.checkInAt),
              ),
              _InfoRow(
                label: 'Check-out',
                value: session.checkOutAt == null
                    ? (_isActive ? 'Still active' : '-')
                    : _formatDateTime(session.checkOutAt),
              ),
              _InfoRow(
                label: 'Created at',
                value: _formatDateTime(session.createdAt),
              ),
            ],
          ),
          if (_isActive) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Scan QR again from the QR tab to check out and open this locker.',
                      style: TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.isEmpty ? 'UNKNOWN' : status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111827),
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

Color _statusColor(String status) {
  final value = status.toUpperCase();
  if (value.contains('ACTIVE') || value.contains('IN_USE')) {
    return const Color(0xFF2563EB);
  }
  if (value.contains('COMPLETED') ||
      value.contains('CHECKED_OUT') ||
      value.contains('FINISHED')) {
    return const Color(0xFF16A34A);
  }
  if (value.contains('CANCELLED') || value.contains('FAILED')) {
    return const Color(0xFFDC2626);
  }
  return const Color(0xFF475569);
}

String _displayEnum(String value) {
  if (value.isEmpty) return '-';
  return value
      .toLowerCase()
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final local = dateTime.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}

String _formatDuration(SessionItemView session) {
  final start = session.checkInAt;
  if (start == null) return '-';
  final end = session.checkOutAt ?? DateTime.now();
  final diff = end.difference(start);
  if (diff.isNegative) return '-';
  final hours = diff.inHours.toString().padLeft(2, '0');
  final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
