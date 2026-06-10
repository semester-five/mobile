import 'package:face_locker/core/services/session_service.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/session/presentation/models/session_item_view.dart';
import 'package:flutter/material.dart';

class DetailActiveSessionPage extends StatefulWidget {
  const DetailActiveSessionPage({super.key, required this.session});

  final SessionItemView session;

  @override
  State<DetailActiveSessionPage> createState() =>
      _DetailActiveSessionPageState();
}

class _DetailActiveSessionPageState extends State<DetailActiveSessionPage> {
  final SessionService _sessionService = SessionService();
  bool _isLoading = false;

  Future<void> _handleForceCheckout() async {
    final reasonController = TextEditingController();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Force Check-Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to force check out this session? Please provide a reason.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Force Checkout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      reasonController.dispose();
      return;
    }

    if (confirm != true) {
      reasonController.dispose();
      return;
    }

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      reasonController.dispose();
      AppToast.warning(
        context,
        title: 'Reason required',
        message: 'Enter a reason.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _sessionService.forceCheckOut(widget.session.id, reason);
      if (mounted) {
        AppToast.success(
          context,
          title: 'Checked out',
          message: 'Session closed.',
        );
        Navigator.of(context).pop(true); // Return true to refresh parent
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, title: 'Checkout failed', message: '$e');
      }
    } finally {
      reasonController.dispose();
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
        title: const Text(
          'Active Session',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        widget.session.lockerCode.isEmpty
                            ? '-'
                            : widget.session.lockerCode,
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        widget.session.lockerLocation.isEmpty
                            ? '-'
                            : widget.session.lockerLocation,
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
                  _formatElapsed(widget.session.checkInAt),
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleForceCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Force Check-Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
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
