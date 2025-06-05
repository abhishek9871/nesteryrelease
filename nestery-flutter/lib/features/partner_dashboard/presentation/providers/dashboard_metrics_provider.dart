import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/dashboard_helpers.dart';

// Data structure for all dashboard metrics
class DashboardMetricValues {
  final RevenueCardData revenue;
  final MonthlySalesCardData monthlySales;
  final TrafficQualityCardData trafficQuality;
  final ConversionRateCardData conversionRate;

  DashboardMetricValues({
    required this.revenue,
    required this.monthlySales,
    required this.trafficQuality,
    required this.conversionRate,
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

final dashboardMetricsProvider = FutureProvider<DashboardMetricValues>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  const double currentTrafficConversionRate = 0.125;
  final String trafficQualityLabel = getTrafficQualityInfo(currentTrafficConversionRate).label;

  // Return static sample data
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
  );
});
