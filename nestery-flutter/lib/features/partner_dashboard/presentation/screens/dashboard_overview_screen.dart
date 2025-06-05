import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_metrics_provider.dart';
import '../widgets/metric_card.dart';
import '../utils/dashboard_helpers.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsyncValue = ref.watch(dashboardMetricsProvider);
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
      body: metricsAsyncValue.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5, // Adjust aspect ratio for single column
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

          final trafficQualityInfo = getTrafficQualityInfo(trafficData.conversionRateValue); // Still needed for color

          return GridView.count(
            padding: const EdgeInsets.all(16.0),
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
    );
  }
}

// ResponsiveMetricGrid removed as requested
