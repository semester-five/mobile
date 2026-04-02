import 'package:flutter/material.dart';
import 'package:face_locker/features/session/presentation/pages/active_session_page.dart';
import 'package:face_locker/features/session/presentation/pages/all_sessions_page.dart';
import 'package:face_locker/features/session/presentation/pages/completed_sessions_page.dart';

class MySessionPage extends StatefulWidget {
  const MySessionPage({super.key});

  @override
  State<MySessionPage> createState() => _MySessionPageState();
}

class _MySessionPageState extends State<MySessionPage> {
  SessionFilterTab _selectedTab = SessionFilterTab.all;

  void _onTabSelected(SessionFilterTab tab) {
    if (_selectedTab == tab) {
      return;
    }

    setState(() {
      _selectedTab = tab;
    });
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case SessionFilterTab.all:
        return const AllSessionsPage();
      case SessionFilterTab.active:
        return const ActiveSessionsPage();
      case SessionFilterTab.completed:
        return const CompletedSessionsPage();
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
          'My Sessions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
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