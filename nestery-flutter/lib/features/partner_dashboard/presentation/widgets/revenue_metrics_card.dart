import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/revenue_metrics_model.dart';
import '../providers/revenue_analytics_provider.dart';

class RevenueMetricsCard extends ConsumerWidget {
  const RevenueMetricsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(partnerRevenueMetricsProvider);
    final timeRange = ref.watch(analyticsSelectedTimeRangeProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Revenue Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _TimeRangeSelector(
                  selectedRange: timeRange,
                  onChanged: (range) {
                    ref.read(analyticsSelectedTimeRangeProvider.notifier).setTimeRange(range);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            metricsAsync.when(
              data: (metrics) => _MetricsContent(metrics: metrics),
              loading: () => _LoadingContent(),
              error: (error, stack) => _ErrorContent(
                error: error.toString(),
                onRetry: () => ref.refresh(partnerRevenueMetricsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final AnalyticsTimeRange selectedRange;
  final ValueChanged<AnalyticsTimeRange> onChanged;

  const _TimeRangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AnalyticsTimeRange>(
      value: selectedRange,
      onChanged: (range) => range != null ? onChanged(range) : null,
      items: AnalyticsTimeRange.values.map((range) {
        return DropdownMenuItem(
          value: range,
          child: Text(range.label),
        );
      }).toList(),
    );
  }
}

class _MetricsContent extends StatelessWidget {
  final RevenueMetricsModel metrics;

  const _MetricsContent({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.percentPattern();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                title: 'Total Revenue',
                value: currencyFormat.format(metrics.totalRevenue),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricItem(
                title: 'Total Commissions',
                value: currencyFormat.format(metrics.totalCommissions),
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                title: 'Conversions',
                value: metrics.totalConversions.toString(),
                icon: Icons.swap_horiz,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricItem(
                title: 'Avg Commission',
                value: currencyFormat.format(metrics.averageCommission),
                icon: Icons.analytics,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GrowthIndicator(
          growthPercentage: metrics.growthPercentage,
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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

class _GrowthIndicator extends StatelessWidget {
  final double growthPercentage;

  const _GrowthIndicator({required this.growthPercentage});

  @override
  Widget build(BuildContext context) {
    final isPositive = growthPercentage >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final percentFormat = NumberFormat.percentPattern();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? '+' : ''}${percentFormat.format(growthPercentage / 100)} vs previous period',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _LoadingSkeleton(height: 80)),
            const SizedBox(width: 16),
            Expanded(child: _LoadingSkeleton(height: 80)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _LoadingSkeleton(height: 80)),
            const SizedBox(width: 16),
            Expanded(child: _LoadingSkeleton(height: 80)),
          ],
        ),
        const SizedBox(height: 16),
        _LoadingSkeleton(height: 50),
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  final double height;

  const _LoadingSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load revenue metrics',
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
    );
  }
}
