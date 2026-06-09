import 'package:face_locker/core/services/statistics_service.dart';
import 'package:flutter/material.dart';

class StatsOverviewPages extends StatefulWidget {
  const StatsOverviewPages({super.key});

  @override
  State<StatsOverviewPages> createState() => _StatsOverviewPagesState();
}

class _StatsOverviewPagesState extends State<StatsOverviewPages> {
  final StatisticsService _statisticsService = StatisticsService();

  bool _isLoading = false;
  String? _errorMessage;
  GuestDemographicsStatsPage? _stats;

  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final start = now.subtract(const Duration(days: 29));
    _dateFrom = DateTime(start.year, start.month, start.day);
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _statisticsService.getGuestDemographics(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );

      if (!mounted) return;
      setState(() {
        _stats = response;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load statistics. Error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _dateFrom, end: _dateTo),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF3B82F6)),
          ),
          child: child!,
        );
      },
    );

    if (range == null) return;

    setState(() {
      _dateFrom = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      _dateTo = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
        999,
      );
    });

    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

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
          'Overview Statistics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadStats,
            icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            _DateRangeButton(
              label: '${_formatDate(_dateFrom)} - ${_formatDate(_dateTo)}',
              onTap: _isLoading ? null : _pickDateRange,
            ),
            const SizedBox(height: 20),
            if (_isLoading && stats == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null && stats == null)
              _ErrorState(message: _errorMessage!, onRetry: _loadStats)
            else ...[
              if (_errorMessage != null)
                _InlineErrorBanner(
                  message: _errorMessage!,
                  onRetry: _loadStats,
                ),
              _SummaryGrid(stats: stats),
              const SizedBox(height: 20),
              _GenderCard(stats: stats),
              const SizedBox(height: 20),
              _AgeGroupCard(items: stats?.data ?? const []),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats});

  final GuestDemographicsStatsPage? stats;

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalSessions ?? 0;
    final groups = stats?.totalRecords ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final childAspectRatio = isWide ? 2.4 : 1.45;

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _MetricCard(
              label: 'Guest Sessions',
              value: total.toString(),
              color: const Color(0xFF2563EB),
            ),
            _MetricCard(
              label: 'Male',
              value: (stats?.maleCount ?? 0).toString(),
              color: const Color(0xFF0EA5E9),
            ),
            _MetricCard(
              label: 'Female',
              value: (stats?.femaleCount ?? 0).toString(),
              color: const Color(0xFFDB2777),
            ),
            _MetricCard(
              label: 'Age Groups',
              value: groups.toString(),
              color: const Color(0xFF475569),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({required this.stats});

  final GuestDemographicsStatsPage? stats;

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalSessions ?? 0;
    final male = stats?.maleCount ?? 0;
    final female = stats?.femaleCount ?? 0;
    final unknown = stats?.unknownCount ?? 0;

    return _Panel(
      title: 'Gender Breakdown',
      child: Column(
        children: [
          _ProgressRow(
            label: 'Male',
            value: male,
            total: total,
            color: const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Female',
            value: female,
            total: total,
            color: const Color(0xFFDB2777),
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Unknown',
            value: unknown,
            total: total,
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}

class _AgeGroupCard extends StatelessWidget {
  const _AgeGroupCard({required this.items});

  final List<GuestDemographicsStats> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _Panel(
        title: 'Age Groups',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              'No guest statistics found for this date range.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final maxSessions = items.fold<int>(
      0,
      (max, item) => item.totalSessions > max ? item.totalSessions : max,
    );

    return _Panel(
      title: 'Age Groups',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AgeGroupRow(item: item, maxSessions: maxSessions),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AgeGroupRow extends StatelessWidget {
  const _AgeGroupRow({required this.item, required this.maxSessions});

  final GuestDemographicsStats item;
  final int maxSessions;

  @override
  Widget build(BuildContext context) {
    final progress = maxSessions == 0 ? 0.0 : item.totalSessions / maxSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.ageGroup,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${item.totalSessions} sessions',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Male ${item.maleCount}  -  Female ${item.femaleCount}  -  Unknown ${item.unknownCount}',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$value (${(percent * 100).round()}%)',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 12,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

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
          const SizedBox(height: 14),
          child,
        ],
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
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
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
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
    );
  }
}

String _formatDate(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year}';
}
