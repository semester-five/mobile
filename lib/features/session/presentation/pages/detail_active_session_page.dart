import 'package:face_locker/features/session/presentation/models/session_item_view.dart';
import 'package:flutter/material.dart';

class DetailActiveSessionPage extends StatelessWidget {
  const DetailActiveSessionPage({super.key, required this.session});

  final SessionItemView session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Active Session',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR LOCKER',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    session.lockerCode.isEmpty ? '-' : session.lockerCode,
                    style: const TextStyle(
                      color: Color(0xFF1E40AF),
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    session.lockerLocation.isEmpty
                        ? '-'
                        : session.lockerLocation,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _formatElapsed(session.checkInAt),
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(DateTime? checkInAt) {
    if (checkInAt == null) {
      return '--:--:--';
    }
    final diff = DateTime.now().difference(checkInAt);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
