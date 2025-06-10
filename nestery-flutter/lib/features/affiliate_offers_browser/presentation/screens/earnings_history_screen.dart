import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/earnings_history_model.dart';
import '../providers/earnings_history_provider.dart';
import '../widgets/earnings_card.dart';

class EarningsHistoryScreen extends ConsumerStatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  ConsumerState<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends ConsumerState<EarningsHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      ref.read(earningsHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsHistoryProvider);
    final summaryAsync = ref.watch(earningsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(earningsHistoryProvider);
              ref.refresh(earningsSummaryProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(earningsHistoryProvider);
          ref.refresh(earningsSummaryProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Summary section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: summaryAsync.when(
                  data: (summary) => _SummarySection(summary: summary),
                  loading: () => _SummarySkeleton(),
                  error: (error, stack) => _ErrorCard(
                    title: 'Failed to load summary',
                    error: error.toString(),
                    onRetry: () => ref.refresh(earningsSummaryProvider),
                  ),
                ),
              ),
            ),
            
            // Filter chips
            if (_selectedStatus != null || _selectedDateRange != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _FilterChips(),
                ),
              ),
            
            // Earnings list
            earningsAsync.when(
              data: (earnings) => earnings.isEmpty
                  ? SliverFillRemaining(
                      child: _EmptyState(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < earnings.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: EarningsCard(earning: earnings[index]),
                            );
                          } else {
                            // Loading indicator for pagination
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                        childCount: earnings.length + 1,
                      ),
                    ),
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: _EarningsCardSkeleton(),
                  ),
                  childCount: 10,
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _ErrorCard(
                  title: 'Failed to load earnings',
                  error: error.toString(),
                  onRetry: () => ref.refresh(earningsHistoryProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedStatus: _selectedStatus,
        selectedDateRange: _selectedDateRange,
        onApply: (status, dateRange) {
          setState(() {
            _selectedStatus = status;
            _selectedDateRange = dateRange;
          });
          
          ref.read(earningsFilterNotifierProvider.notifier).updateFilter(
            status: status,
            startDate: dateRange?.start,
            endDate: dateRange?.end,
          );
        },
        onClear: () {
          setState(() {
            _selectedStatus = null;
            _selectedDateRange = null;
          });
          
          ref.read(earningsFilterNotifierProvider.notifier).clearFilters();
        },
      ),
    );
  }

  Widget _FilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        if (_selectedStatus != null)
          Chip(
            label: Text('Status: $_selectedStatus'),
            onDeleted: () {
              setState(() => _selectedStatus = null);
              ref.read(earningsFilterNotifierProvider.notifier).updateFilter(
                status: null,
                startDate: _selectedDateRange?.start,
                endDate: _selectedDateRange?.end,
              );
            },
          ),
        if (_selectedDateRange != null)
          Chip(
            label: Text(
              'Date: ${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
            ),
            onDeleted: () {
              setState(() => _selectedDateRange = null);
              ref.read(earningsFilterNotifierProvider.notifier).updateFilter(
                status: _selectedStatus,
                startDate: null,
                endDate: null,
              );
            },
          ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    title: 'Total Earnings',
                    value: currencyFormat.format(summary['totalEarnings'] ?? 0),
                    color: Colors.green,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryItem(
                    title: 'Pending',
                    value: currencyFormat.format(summary['pendingEarnings'] ?? 0),
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    title: 'Paid Out',
                    value: currencyFormat.format(summary['paidEarnings'] ?? 0),
                    color: Colors.blue,
                    icon: Icons.payment,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryItem(
                    title: 'Conversions',
                    value: (summary['totalConversions'] ?? 0).toString(),
                    color: Colors.purple,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(height: 20, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(height: 16, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No earnings yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start promoting offers to earn commissions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String? selectedStatus;
  final DateTimeRange? selectedDateRange;
  final Function(String?, DateTimeRange?) onApply;
  final VoidCallback onClear;

  const _FilterDialog({
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _status;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Earnings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'All statuses',
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All statuses')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
            child: Text(
              _dateRange != null
                  ? '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}'
                  : 'Select date range',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClear();
            Navigator.of(context).pop();
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_status, _dateRange);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
