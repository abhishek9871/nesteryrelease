import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/partner_dashboard_data_dto.dart';
import '../../data/repositories/partner_dashboard_repository.dart';
import '../../../../core/providers/time_range_provider.dart';
import '../../../../core/providers/earnings_filter_provider.dart';

/// Central data provider that fetches comprehensive dashboard data
/// Implements "fetch once, select many" pattern
final partnerDashboardDataProvider = FutureProvider<PartnerDashboardDataDto>((ref) async {
  final repository = ref.watch(partnerDashboardRepositoryProvider);
  final timeRange = ref.watch(selectedTimeRangeProvider);
  final earningsFilter = ref.watch(earningsFilterProvider);
  
  final result = await repository.getDashboardData(
    timeRange: timeRange,
    status: earningsFilter.status?.name,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

/// Provider for dashboard metrics data
final dashboardMetricsDataProvider = Provider((ref) {
  final dashboardData = ref.watch(partnerDashboardDataProvider);
  
  return dashboardData.when(
    data: (data) => AsyncValue.data(data.dashboardMetrics),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for earnings report data
final earningsReportDataProvider = Provider((ref) {
  final dashboardData = ref.watch(partnerDashboardDataProvider);
  
  return dashboardData.when(
    data: (data) => AsyncValue.data(data.earningsReport),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for partner offers data
final partnerOffersDataProvider = Provider((ref) {
  final dashboardData = ref.watch(partnerDashboardDataProvider);
  
  return dashboardData.when(
    data: (data) => AsyncValue.data(data.partnerOffers),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
