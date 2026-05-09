import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_detail_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_edit_page.dart';
import 'package:flutter/material.dart';

class LockerListPage extends StatefulWidget {
  const LockerListPage({super.key});

  @override
  State<LockerListPage> createState() => _LockerListPageState();
}

class _LockerListPageState extends State<LockerListPage> {
  final LockerService _lockerService = LockerService();

  bool _isLoading = false;
  String? _errorMessage;
  List<LockerItemView> _lockers = [];
  LockerFilterTab _selectedTab = LockerFilterTab.all;

  @override
  void initState() {
    super.initState();
    _loadLockers();
  }

  Future<void> _loadLockers() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _lockerService.getAllLockers(
        pageNumber: 1,
        pageSize: 50,
      );
      final data = response['data'];

      if (data is List) {
        _lockers = data
            .whereType<Map<String, dynamic>>()
            .map(LockerItemView.fromJson)
            .toList();
      } else {
        _lockers = [];
      }
    } catch (error) {
      _errorMessage = 'Failed to load lockers. Please try again.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<LockerItemView> get _filteredLockers {
    if (_selectedTab == LockerFilterTab.all) {
      return _lockers;
    }

    return _lockers.where((locker) {
      final status = locker.status.toUpperCase();
      return status.contains('AVAILABLE') || status.contains('FREE');
    }).toList();
  }

  void _onTabSelected(LockerFilterTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Locker Room',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _isLoading ? null : _loadLockers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LockerEditPage()),
          );
          if (result == true) {
            _loadLockers();
          }
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isActive: _selectedTab == LockerFilterTab.all,
                  onTap: () => _onTabSelected(LockerFilterTab.all),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Available',
                  isActive: _selectedTab == LockerFilterTab.available,
                  onTap: () => _onTabSelected(LockerFilterTab.available),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Location: All ▾',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _ErrorState(message: _errorMessage!, onRetry: _loadLockers)
            else if (_filteredLockers.isEmpty)
              const Center(
                child: Text(
                  'No lockers found.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: _filteredLockers.length,
                itemBuilder: (context, index) {
                  final locker = _filteredLockers[index];
                  return _LockerCard(
                    locker: locker,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              LockerDetailPage(lockerId: locker.id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum LockerFilterTab { all, available }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LockerCard extends StatelessWidget {
  const _LockerCard({required this.locker, this.onTap});

  final LockerItemView locker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(locker.status);
    final backgroundColor = statusColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor, width: 1.5),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(
                  locker.code.isEmpty ? '-' : locker.code,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      locker.size.isEmpty ? '-' : locker.size,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              locker.status.isEmpty ? 'Unknown' : locker.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              locker.location.isEmpty ? '-' : locker.location,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
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
