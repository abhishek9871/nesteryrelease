import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/revenue_metrics_model.dart';
import '../providers/revenue_analytics_provider.dart';

class RevenueTrendsChart extends ConsumerWidget {
  const RevenueTrendsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(partnerRevenueTrendsProvider);

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
                  'Revenue Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(partnerRevenueTrendsProvider),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: trendsAsync.when(
                data: (trends) => _ChartContent(trends: trends),
                loading: () => _LoadingChart(),
                error: (error, stack) => _ErrorChart(
                  error: error.toString(),
                  onRetry: () => ref.refresh(partnerRevenueTrendsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartContent extends StatefulWidget {
  final List<RevenueTrendModel> trends;

  const _ChartContent({required this.trends});

  @override
  State<_ChartContent> createState() => _ChartContentState();
}

class _ChartContentState extends State<_ChartContent> {
  bool showRevenue = true;
  bool showCommissions = true;
  bool showConversions = false;

  @override
  Widget build(BuildContext context) {
    if (widget.trends.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Column(
      children: [
        _ChartLegend(
          showRevenue: showRevenue,
          showCommissions: showCommissions,
          showConversions: showConversions,
          onRevenueToggle: (value) => setState(() => showRevenue = value),
          onCommissionsToggle: (value) => setState(() => showCommissions = value),
          onConversionsToggle: (value) => setState(() => showConversions = value),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            _buildLineChartData(),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData() {
    final trends = widget.trends;
    final maxRevenue = trends.map((t) => t.revenue).reduce((a, b) => a > b ? a : b);
    final maxCommissions = trends.map((t) => t.commissions).reduce((a, b) => a > b ? a : b);
    final maxConversions = trends.map((t) => t.conversions.toDouble()).reduce((a, b) => a > b ? a : b);

    final maxY = [
      if (showRevenue) maxRevenue,
      if (showCommissions) maxCommissions,
      if (showConversions) maxConversions,
    ].reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY / 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: trends.length > 10 ? trends.length / 5 : 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < trends.length) {
                final date = DateTime.parse(trends[index].date);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat.compact().format(value),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
      ),
      minX: 0,
      maxX: trends.length.toDouble() - 1,
      minY: 0,
      maxY: maxY * 1.1,
      lineBarsData: [
        if (showRevenue) _buildLineBarData(
          trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue)).toList(),
          Colors.blue,
          'Revenue',
        ),
        if (showCommissions) _buildLineBarData(
          trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.commissions)).toList(),
          Colors.green,
          'Commissions',
        ),
        if (showConversions) _buildLineBarData(
          trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.conversions.toDouble())).toList(),
          Colors.orange,
          'Conversions',
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot spot) => Colors.blueGrey.withValues(alpha: 0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final index = flSpot.x.toInt();
              if (index >= 0 && index < trends.length) {
                final trend = trends[index];
                final date = DateTime.parse(trend.date);
                return LineTooltipItem(
                  '${DateFormat('MMM dd').format(date)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    if (showRevenue && barSpot.barIndex == 0)
                      TextSpan(
                        text: 'Revenue: \$${NumberFormat.compact().format(trend.revenue)}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    if (showCommissions && ((showRevenue && barSpot.barIndex == 1) || (!showRevenue && barSpot.barIndex == 0)))
                      TextSpan(
                        text: 'Commissions: \$${NumberFormat.compact().format(trend.commissions)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    if (showConversions)
                      TextSpan(
                        text: 'Conversions: ${trend.conversions}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                  ],
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots, Color color, String label) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: spots.length <= 10,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final bool showRevenue;
  final bool showCommissions;
  final bool showConversions;
  final ValueChanged<bool> onRevenueToggle;
  final ValueChanged<bool> onCommissionsToggle;
  final ValueChanged<bool> onConversionsToggle;

  const _ChartLegend({
    required this.showRevenue,
    required this.showCommissions,
    required this.showConversions,
    required this.onRevenueToggle,
    required this.onCommissionsToggle,
    required this.onConversionsToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(
          color: Colors.blue,
          label: 'Revenue',
          isSelected: showRevenue,
          onTap: () => onRevenueToggle(!showRevenue),
        ),
        _LegendItem(
          color: Colors.green,
          label: 'Commissions',
          isSelected: showCommissions,
          onTap: () => onCommissionsToggle(!showCommissions),
        ),
        _LegendItem(
          color: Colors.orange,
          label: 'Conversions',
          isSelected: showConversions,
          onTap: () => onConversionsToggle(!showConversions),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorChart extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorChart({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load chart data',
            style: Theme.of(context).textTheme.titleMedium,
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
    );
  }
}
