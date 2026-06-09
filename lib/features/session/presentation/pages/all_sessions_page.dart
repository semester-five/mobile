import 'package:flutter/material.dart';
import 'package:face_locker/features/session/presentation/models/session_item_view.dart';
import 'package:face_locker/features/session/presentation/pages/session_detail_page.dart';

class AllSessionsPage extends StatelessWidget {
  const AllSessionsPage({super.key, required this.sessions});

  final List<SessionItemView> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No sessions found.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _SessionCard(
          session: session,
          lockerCode: session.lockerCode,
          dateTime: _formatDateTime(session.checkInAt ?? session.createdAt),
          status: session.status,
        );
      },
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.lockerCode,
    required this.dateTime,
    required this.status,
  });

  final SessionItemView session;
  final String lockerCode;
  final String dateTime;
  final String status;

  bool get _isActive {
    final value = status.toUpperCase();
    return value.contains('ACTIVE') || value.contains('IN_USE');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SessionDetailPage(session: session),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lockerCode.isEmpty ? '-' : lockerCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isActive
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFECFDF3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.isEmpty ? 'UNKNOWN' : status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isActive
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFF166534),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
