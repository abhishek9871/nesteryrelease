import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/dashboard_metrics_provider.dart';
import '../providers/revenue_analytics_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/revenue_metrics_card.dart';
import '../widgets/revenue_trends_chart.dart';
import '../widgets/commission_batch_widget.dart';
import '../utils/dashboard_helpers.dart';
import '../models/chart_data_point.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsyncValue = ref.watch(dashboardMetricsProvider);
    final selectedTimeRange = ref.watch(selectedTimeRangeProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine number of columns based on screen width
    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Overview')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              metricsAsyncValue.when(
                loading: () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const MetricCard(isLoading: true),
                ),
                error: (error, stackTrace) => Center(
                  child: Text('Error loading metrics: $error'),
                ),
                data: (metrics) {
                  final revenueData = metrics.revenue;
                  final salesData = metrics.monthlySales;
                  final trafficData = metrics.trafficQuality;
                  final conversionData = metrics.conversionRate;
                  final trafficQualityInfo = getTrafficQualityInfo(trafficData.conversionRateValue);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
              MetricCard(
                title: "Revenue",
                valueText: formatCurrency(revenueData.netEarnings),
                subtitleText:
                    "Your Earnings (${formatPercentage(revenueData.partnerCommissionRate, decimalDigits: 0)} of ${formatCurrency(revenueData.grossRevenueForCalc)})",
                iconData: Icons.attach_money,
                iconColor: Colors.green[600]!,
                trendText: calculateTrend(
                  revenueData.netEarnings,
                  revenueData.previousPeriodNetEarnings,
                  "MoM",
                ),
              ),
              MetricCard(
                title: "Monthly Sales",
                valueText: formatCurrency(salesData.monthlyGrossSales),
                subtitleText:
                    "Total Sales (Nestery: ${formatPercentage(salesData.nesteryCommissionRateForDisplay, decimalDigits: 0)})",
                iconData: Icons.trending_up,
                iconColor: Colors.blue[600]!,
                trendText: calculateTrend(
                  salesData.monthlyGrossSales,
                  salesData.previousPeriodGrossSales,
                  "MoM",
                ),
              ),
              MetricCard(
                title: "Traffic Quality",
                valueText: formatPercentage(trafficData.conversionRateValue),
                subtitleText: trafficData.qualityLabel, // Corrected
                iconData: Icons.speed,
                iconColor: trafficQualityInfo.color, // From local derivation
                trendText: calculateTrend(
                  trafficData.conversionRateValue,
                  trafficData.previousPeriodConversionRate,
                  "WoW",
                ),
              ),
              MetricCard(
                title: "Conversion Rate",
                valueText: formatPercentage(conversionData.conversionRateValue),
                iconData: Icons.transform,
                iconColor: Colors.purple[600]!,
                trendText: calculateTrend(
                  conversionData.conversionRateValue,
                  conversionData.previousPeriodConversionRate,
                  "WoW",
                ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // New Revenue Analytics Section
              const RevenueMetricsCard(),
              const SizedBox(height: 16),

              const RevenueTrendsChart(),
              const SizedBox(height: 16),

              // Commission Batch Widget (admin only - will handle visibility internally)
              const CommissionBatchWidget(),
              const SizedBox(height: 24),

              // Original charts section (kept for backward compatibility)
              Text(
                'Legacy Charts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _TimeRangeToggleButtons(
                selectedOption: selectedTimeRange,
                onOptionSelected: (option) {
                  ref.read(selectedTimeRangeProvider.notifier).state = option;
                },
              ),
              const SizedBox(height: 16),
              metricsAsyncValue.when(
                loading: () => _ChartShimmerPlaceholders(screenWidth: screenWidth),
                error: (error, stack) => Center(child: Text('Error loading chart data: $error')),
                data: (metrics) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      bool useHorizontalLayout = constraints.maxWidth >= 800;
                      if (useHorizontalLayout) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _NetEarningsChart(data: metrics.chartData.netEarningsData)),
                            const SizedBox(width: 16),
                            Expanded(child: _ConversionRateChart(data: metrics.chartData.conversionRateData)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _NetEarningsChart(data: metrics.chartData.netEarningsData),
                            const SizedBox(height: 16),
                            _ConversionRateChart(data: metrics.chartData.conversionRateData),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeToggleButtons extends StatelessWidget {
  final TimeRangeOption selectedOption;
  final ValueChanged<TimeRangeOption> onOptionSelected;

  const _TimeRangeToggleButtons({
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: TimeRangeOption.values.map((option) => option == selectedOption).toList(),
        onPressed: (index) {
          onOptionSelected(TimeRangeOption.values[index]);
        },
        borderRadius: BorderRadius.circular(8),
        selectedBorderColor: Theme.of(context).colorScheme.primary,
        selectedColor: Colors.white,
        fillColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.primary,
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('7D')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('30D')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('90D')),
        ],
      ),
    );
  }
}

class _ChartShimmerPlaceholders extends StatelessWidget {
  final double screenWidth;
  const _ChartShimmerPlaceholders({required this.screenWidth});

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const SizedBox(height: 300, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool useHorizontalLayout = screenWidth >= 800;
    if (useHorizontalLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildShimmerCard()),
          const SizedBox(width: 16),
          Expanded(child: _buildShimmerCard()),
        ],
      );
    } else {
      return Column(
        children: [
          _buildShimmerCard(),
          const SizedBox(height: 16),
          _buildShimmerCard(),
        ],
      );
    }
  }
}

class _NetEarningsChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const _NetEarningsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _CustomLineChartWidget(
      title: "Net Earnings Trend",
      data: data,
      lineColor: Colors.green[600]!,
      yAxisFormatter: (value) => formatCurrency(value, symbol: '\$', decimalDigits: 0),
      yAxisTitle: "Earnings (\$)",
      yAxisInterval: 50,
    );
  }
}

class _ConversionRateChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const _ConversionRateChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _CustomLineChartWidget(
      title: "Conversion Rate Trend",
      data: data,
      lineColor: Colors.purple[600]!,
      yAxisFormatter: (value) => formatPercentage(value, decimalDigits: 1),
      yAxisTitle: "Conversion Rate (%)",
      yAxisInterval: 0.02,
    );
  }
}

class _CustomLineChartWidget extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;
  final Color lineColor;
  final String Function(double) yAxisFormatter;
  final String yAxisTitle;
  final double? yAxisInterval;

  const _CustomLineChartWidget({
    required this.title,
    required this.data,
    required this.lineColor,
    required this.yAxisFormatter,
    required this.yAxisTitle,
    this.yAxisInterval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = data.asMap().entries.map((entry) {
      // Using index as x-value for simplicity if dates are sequential
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 250, // Fixed height for chart area
              child: data.isEmpty
                  ? Center(child: Text("No data available", style: theme.textTheme.bodyMedium))
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yAxisInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: theme.dividerColor.withValues(alpha: 0.5), strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (data.length / 6).ceilToDouble().toDouble(), // Aim for ~5-7 labels
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(DateFormat('MMM dd').format(data[index].date), style: theme.textTheme.bodySmall),
                            );
                          }
                          return Container();
                        },
                      ),
                      axisNameWidget: Text("Date", style: theme.textTheme.bodySmall),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(yAxisFormatter(value), style: theme.textTheme.bodySmall, textAlign: TextAlign.left);
                        },
                      ),
                      axisNameWidget: Text(yAxisTitle, style: theme.textTheme.bodySmall),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: (data.length -1).toDouble().clamp(0, double.infinity), // Ensure maxX is not negative
                  minY: data.isEmpty ? 0 : data.map((d) => d.value).reduce(min) * 0.9, // Adjust min/max Y for padding
                  maxY: data.isEmpty ? 1 : data.map((d) => d.value).reduce(max) * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.spotIndex;
                          if (index >= 0 && index < data.length) {
                            final point = data[index];
                            return LineTooltipItem(
                              '${DateFormat('MMM dd, yyyy').format(point.date)}\n',
                              theme.textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: yAxisFormatter(point.value),
                                  style: theme.textTheme.bodySmall!.copyWith(color: Colors.white),
                                ),
                              ],
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
