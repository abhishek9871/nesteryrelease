import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chart_data_point.dart';
import '../models/dashboard_chart_data.dart';
import '../utils/dashboard_helpers.dart';

enum TimeRangeOption { sevenDays, thirtyDays, ninetyDays }

final selectedTimeRangeProvider = StateProvider<TimeRangeOption>((ref) => TimeRangeOption.thirtyDays);

// Data structure for all dashboard metrics
class DashboardMetricValues {
  final RevenueCardData revenue;
  final MonthlySalesCardData monthlySales;
  final TrafficQualityCardData trafficQuality;
  final ConversionRateCardData conversionRate;
  final DashboardChartData chartData;

  DashboardMetricValues({
    required this.revenue,
    required this.monthlySales,
    required this.trafficQuality,
    required this.conversionRate,
    required this.chartData,
  });
}

class RevenueCardData {
  final double netEarnings;
  final double grossRevenueForCalc;
  final double partnerCommissionRate; // e.g., 0.85 for 85%
  final double previousPeriodNetEarnings;

  RevenueCardData({
    required this.netEarnings,
    required this.grossRevenueForCalc,
    required this.partnerCommissionRate,
    required this.previousPeriodNetEarnings,
  });
}

class MonthlySalesCardData {
  final double monthlyGrossSales;
  final double nesteryCommissionRateForDisplay; // e.g., 0.15 for 15%
  final double previousPeriodGrossSales;

  MonthlySalesCardData({
    required this.monthlyGrossSales,
    required this.nesteryCommissionRateForDisplay,
    required this.previousPeriodGrossSales,
  });
}

class TrafficQualityCardData {
  final double conversionRateValue; // e.g., 0.125 for 12.5%
  final double previousPeriodConversionRate;
  final String qualityLabel;
  final int totalClicks;
  final int totalConversions;

  TrafficQualityCardData({
    required this.conversionRateValue,
    required this.previousPeriodConversionRate,
    required this.qualityLabel,
    required this.totalClicks,
    required this.totalConversions,
  });
}


class ConversionRateCardData {
  final double conversionRateValue; // e.g., 0.08 for 8%
  final double previousPeriodConversionRate;

  ConversionRateCardData({
    required this.conversionRateValue,
    required this.previousPeriodConversionRate,
  });
}

List<ChartDataPoint> _generatePlaceholderTimeSeriesData(
  TimeRangeOption range, {
  required double minValue,
  required double maxValue,
  bool isPercentage = false,
  int? dataPoints,
}) {
  final random = Random();
  int numPoints;
  switch (range) {
    case TimeRangeOption.sevenDays:
      numPoints = dataPoints ?? 7;
      break;
    case TimeRangeOption.thirtyDays:
      numPoints = dataPoints ?? 30;
      break;
    case TimeRangeOption.ninetyDays:
      numPoints = dataPoints ?? 90;
      break;
  }

  final List<ChartDataPoint> series = [];
  final now = DateTime.now();

  // Generate a gentle plausible trend
  double startValue = minValue + random.nextDouble() * (maxValue - minValue) * 0.4; // Start in lower 40%
  double endValue = minValue + (maxValue - minValue) * (0.6 + random.nextDouble() * 0.4); // End in upper 40%
  if (random.nextBool()) { // Occasionally make it a downward trend
    final temp = startValue;
    startValue = endValue;
    endValue = temp;
  }

  final slope = (endValue - startValue) / numPoints;

  for (int i = 0; i < numPoints; i++) {
    final date = now.subtract(Duration(days: numPoints - 1 - i));
    double value = startValue + i * slope + (random.nextDouble() - 0.5) * (maxValue - minValue) * 0.15; // Noise is 15% of range
    value = value.clamp(minValue, maxValue);
    series.add(ChartDataPoint(date: date, value: value));
  }
  return series;
}

final dashboardMetricsProvider = FutureProvider<DashboardMetricValues>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  final currentTimeRange = ref.watch(selectedTimeRangeProvider);
  const double currentTrafficConversionRate = 0.125;
  final String trafficQualityLabel = getTrafficQualityInfo(currentTrafficConversionRate).label;

  final netEarningsChartData = _generatePlaceholderTimeSeriesData(
    currentTimeRange,
    minValue: 50.0,
    maxValue: 200.0,
  );
  final conversionRateChartData = _generatePlaceholderTimeSeriesData(
    currentTimeRange,
    minValue: 0.05,
    maxValue: 0.15,
    isPercentage: true,
  );

  return DashboardMetricValues(
    revenue: RevenueCardData(
      netEarnings: 1234.56,
      grossRevenueForCalc: 1452.42,
      partnerCommissionRate: 0.85,
      previousPeriodNetEarnings: 1175.00,
    ),
    monthlySales: MonthlySalesCardData(
      monthlyGrossSales: 1452.42,
      nesteryCommissionRateForDisplay: 0.15,
      previousPeriodGrossSales: 1417.00,
    ),
    trafficQuality: TrafficQualityCardData(
      conversionRateValue: currentTrafficConversionRate,
      previousPeriodConversionRate: 0.137,
      qualityLabel: trafficQualityLabel,
      totalClicks: 1500,
      totalConversions: 187,
    ),
    conversionRate: ConversionRateCardData(
      conversionRateValue: 0.08, // 8%
      previousPeriodConversionRate: 0.075,
    ),
    chartData: DashboardChartData(
      netEarningsData: netEarningsChartData,
      conversionRateData: conversionRateChartData,
    ),
  );
});
