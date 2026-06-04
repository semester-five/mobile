import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_detail_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_edit_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LockerListPage extends StatefulWidget {
  const LockerListPage({super.key});

  @override
  State<LockerListPage> createState() => _LockerListPageState();
}

class _LockerListPageState extends State<LockerListPage> {
  static const String _allValue = 'ALL';

  static const List<String> _statusOptions = [
    'AVAILABLE',
    'IN_USE',
    'MAINTENANCE',
    'RESERVED',
    'OUT_OF_SERVICE',
  ];

  static const List<String> _sizeOptions = ['SMALL', 'MEDIUM', 'LARGE'];

  final LockerService _lockerService = LockerService();

  bool _isLoading = false;
  String? _errorMessage;
  List<LockerItemView> _lockers = [];

  String _statusFilter = _allValue;
  String _sizeFilter = _allValue;
  String _locationFilter = "";

  @override
  void initState() {
    super.initState();
    _loadLockers(refresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (_statusFilter != _allValue && _statusFilter.isNotEmpty) {
      filters['status'] = _statusFilter;
    }
    if (_sizeFilter != _allValue && _sizeFilter.isNotEmpty) {
      filters['size'] = _sizeFilter;
    }
    if (_locationFilter.trim().isNotEmpty) {
      filters['location'] = _locationFilter.trim();
    }

    return filters;
  }

  Future<void> _loadLockers({bool refresh = false}) async {
    if (_isLoading) {
      return;
    }

    final filters = _buildFilters();

    setState(() {
      _errorMessage = null;
      _isLoading = true;
      if (refresh) {
        _lockers = [];
      }
    });

    try {
      final response = await _lockerService.getAllLockers(
        filters: filters.isEmpty ? null : filters,
      );

      if (kDebugMode) {
        debugPrint('API Response: $response');
        debugPrint('Response keys: ${response.keys.toList()}');
      }

      final items = _extractLockerItems(response);
      if (kDebugMode) {
        debugPrint('Extracted items count: ${items.length}');
        if (items.isNotEmpty) {
          debugPrint('First item: ${items[0]}');
        }
      }

      final lockers = items.map(LockerItemView.fromJson).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _lockers = lockers;
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Error loading lockers: $e');
        debugPrintStack(stackTrace: st);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Failed to load lockers. Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _extractLockerItems(dynamic response) {
    if (kDebugMode) {
      debugPrint('=== _extractLockerItems ===');
      debugPrint('Response type: ${response.runtimeType}');
      debugPrint('Full response: $response');
    }

    final candidates = <dynamic>[
      if (response is Map<String, dynamic>) ...[
        response['content'],
        response['data'],
        response['items'],
        response['lockers'],
      ],
      response,
    ];

    for (final candidate in candidates) {
      if (kDebugMode) {
        debugPrint(
          'Trying candidate: $candidate (type: ${candidate.runtimeType})',
        );
      }
      final items = _extractList(candidate);
      if (items.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Found ${items.length} items in this candidate');
        }
        return items;
      }
    }

    if (kDebugMode) {
      debugPrint('No items found in any candidate');
    }
    return [];
  }

  List<Map<String, dynamic>> _extractList(dynamic value) {
    if (value is List) {
      final result = value.whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
      if (kDebugMode) {
        debugPrint('_extractList: Found ${result.length} maps in list');
      }
      return result;
    }

    if (value is Map<String, dynamic>) {
      final nested =
          value['content'] ??
          value['data'] ??
          value['items'] ??
          value['lockers'];
      if (nested != null && nested != value) {
        if (kDebugMode) {
          debugPrint('_extractList: Found nested data, recursing...');
        }
        return _extractList(nested);
      }
    }

    if (kDebugMode) {
      debugPrint('_extractList: Cannot extract from ${value.runtimeType}');
    }
    return [];
  }

  bool get _hasActiveFilters =>
      _statusFilter != _allValue ||
      _sizeFilter != _allValue ||
      _locationFilter.trim().isNotEmpty;

  Future<void> _openFilterSheet() async {
    String? status = _statusFilter;
    String? size = _sizeFilter;

    final locationController = TextEditingController(text: _locationFilter);

    final result = await showModalBottomSheet<_LockerFilterValues>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Filter lockers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bỏ trống bộ lọc sẽ trả về toàn bộ locker hiện có.',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 20),
                      _DropdownField<String?>(
                        label: 'Status',
                        value: status,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: _allValue,
                            child: Text('All'),
                          ),
                          ..._statusOptions.map(
                            (item) => DropdownMenuItem<String?>(
                              value: item,
                              child: Text(_enumLabel(item)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() => status = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      _DropdownField<String?>(
                        label: 'Size',
                        value: size,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: _allValue,
                            child: Text('All'),
                          ),
                          ..._sizeOptions.map(
                            (item) => DropdownMenuItem<String?>(
                              value: item,
                              child: Text(_enumLabel(item)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() => size = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'First Floor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  status = _allValue;
                                  size = _allValue;
                                  locationController.clear();
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  sheetContext,
                                  _LockerFilterValues(
                                    status: status,
                                    size: size,
                                    location: locationController.text.trim(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    locationController.dispose();

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _statusFilter = result.status ?? _allValue;
      _sizeFilter = result.size ?? _allValue;
      _locationFilter = result.location;
    });

    await _loadLockers(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = _allValue;
      _sizeFilter = _allValue;
      _locationFilter = '';
    });
    _loadLockers(refresh: true);
  }

  String _enumLabel(String value) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 900
        ? 4
        : screenWidth >= 600
        ? 3
        : 2;

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
            icon: const Icon(Icons.filter_list, color: Color(0xFF4A90E2)),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _isLoading ? null : () => _loadLockers(refresh: true),
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
            _loadLockers(refresh: true);
          }
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadLockers(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bộ lọc và danh sách',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Bỏ trống bộ lọc sẽ trả về toàn bộ locker hiện có.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterSummaryChip(
                  label: 'Status',
                  value: _statusFilter == _allValue
                      ? 'All'
                      : _enumLabel(_statusFilter),
                ),
                _FilterSummaryChip(
                  label: 'Size',
                  value: _sizeFilter == _allValue
                      ? 'All'
                      : _enumLabel(_sizeFilter),
                ),
                _FilterSummaryChip(
                  label: 'Location',
                  value: _locationFilter.isEmpty ? 'All' : _locationFilter,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_errorMessage != null && _lockers.isNotEmpty)
              _InlineErrorBanner(
                message: _errorMessage!,
                onRetry: () => _loadLockers(refresh: true),
              ),
            if (_isLoading && _lockers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null && _lockers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 96),
                child: _ErrorState(
                  message: _errorMessage!,
                  onRetry: () => _loadLockers(refresh: true),
                ),
              )
            else if (_lockers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 96),
                child: Center(
                  child: Text(
                    'No lockers found.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.88,
                ),
                itemCount: _lockers.length,
                itemBuilder: (context, index) {
                  final locker = _lockers[index];
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

class _LockerFilterValues {
  const _LockerFilterValues({
    required this.status,
    required this.size,
    required this.location,
  });

  final String? status;
  final String? size;
  final String location;
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _FilterSummaryChip extends StatelessWidget {
  const _FilterSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: statusColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      locker.code.isEmpty ? '-' : locker.code,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _MiniBadge(text: locker.size.isEmpty ? '-' : locker.size),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                locker.status.isEmpty ? 'Unknown' : locker.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Text(
              locker.location.isEmpty ? '-' : locker.location,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              locker.doorState.isEmpty ? '-' : 'Door: ${locker.doorState}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
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

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
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
