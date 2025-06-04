import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder for dashboard metrics data
class DashboardMetrics {
  final double totalRevenue;
  final double conversionRate;
  final int activeOffers;
  final int clicks;

  DashboardMetrics({required this.totalRevenue, required this.conversionRate, required this.activeOffers, required this.clicks});
}

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  // TODO: Fetch actual metrics from repository
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return DashboardMetrics(totalRevenue: 1234.56, conversionRate: 0.15, activeOffers: 10, clicks: 5000);
});
