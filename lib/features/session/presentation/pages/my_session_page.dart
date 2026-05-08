import 'package:flutter/material.dart';
import 'package:face_locker/core/services/session_service.dart';
import 'package:face_locker/features/session/presentation/pages/active_session_page.dart';
import 'package:face_locker/features/session/presentation/pages/all_sessions_page.dart';
import 'package:face_locker/features/session/presentation/pages/completed_sessions_page.dart';
import 'package:face_locker/features/session/presentation/models/session_item_view.dart';

class MySessionPage extends StatefulWidget {
  const MySessionPage({super.key});

  @override
  State<MySessionPage> createState() => _MySessionPageState();
}

class _MySessionPageState extends State<MySessionPage> {
  SessionFilterTab _selectedTab = SessionFilterTab.all;
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _errorMessage;
  List<SessionItemView> _sessions = [];

  void _onTabSelected(SessionFilterTab tab) {
    if (_selectedTab == tab) {
      return;
    }

    setState(() {
      _selectedTab = tab;
    });
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadSessions);
    }

    switch (_selectedTab) {
      case SessionFilterTab.all:
        return AllSessionsPage(sessions: _sessions);
      case SessionFilterTab.active:
        return ActiveSessionsPage(
          sessions: _filterSessions(_sessions, onlyActive: true),
        );
      case SessionFilterTab.completed:
        return CompletedSessionsPage(
          sessions: _filterSessions(_sessions, onlyCompleted: true),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _sessionService.getMySessions(page: 1, limit: 50);
      final data = response['data'];

      if (data is List) {
        _sessions = data
            .whereType<Map<String, dynamic>>()
            .map(SessionItemView.fromJson)
            .toList();
      } else {
        _sessions = [];
      }
    } catch (error) {
      _errorMessage = 'Failed to load sessions. Please try again.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<SessionItemView> _filterSessions(
    List<SessionItemView> sessions, {
    bool onlyActive = false,
    bool onlyCompleted = false,
  }) {
    if (!onlyActive && !onlyCompleted) {
      return sessions;
    }

    return sessions.where((session) {
      final status = session.status.toUpperCase();
      final isActive = status.contains('ACTIVE') || status.contains('IN_USE');
      final isCompleted =
          status.contains('COMPLETED') ||
          status.contains('CHECKED') ||
          status.contains('FINISHED');

      if (onlyActive) {
        return isActive;
      }

      if (onlyCompleted) {
        return isCompleted;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Sessions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _isLoading ? null : _loadSessions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'All',
                    isActive: _selectedTab == SessionFilterTab.all,
                    onTap: () => _onTabSelected(SessionFilterTab.all),
                  ),
                  _FilterTab(
                    label: 'Active',
                    isActive: _selectedTab == SessionFilterTab.active,
                    onTap: () => _onTabSelected(SessionFilterTab.active),
                  ),
                  _FilterTab(
                    label: 'Completed',
                    isActive: _selectedTab == SessionFilterTab.completed,
                    onTap: () => _onTabSelected(SessionFilterTab.completed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: _buildTabContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SessionFilterTab { all, active, completed }

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
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
