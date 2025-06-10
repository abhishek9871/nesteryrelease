import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../providers/repository_providers.dart';
import '../../data/models/revenue_metrics_model.dart';
import '../../data/repositories/revenue_analytics_repository.dart';
import '../../data/repositories/revenue_analytics_repository_impl.dart';

part 'revenue_analytics_provider.g.dart';

// Repository provider
@riverpod
RevenueAnalyticsRepository revenueAnalyticsRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RevenueAnalyticsRepositoryImpl(apiClient);
}

// Time range selection for analytics
enum AnalyticsTimeRange { sevenDays, thirtyDays, ninetyDays }

extension AnalyticsTimeRangeExtension on AnalyticsTimeRange {
  int get days {
    switch (this) {
      case AnalyticsTimeRange.sevenDays:
        return 7;
      case AnalyticsTimeRange.thirtyDays:
        return 30;
      case AnalyticsTimeRange.ninetyDays:
        return 90;
    }
  }

  String get label {
    switch (this) {
      case AnalyticsTimeRange.sevenDays:
        return '7 Days';
      case AnalyticsTimeRange.thirtyDays:
        return '30 Days';
      case AnalyticsTimeRange.ninetyDays:
        return '90 Days';
    }
  }
}

// Selected analytics time range provider
@riverpod
class AnalyticsSelectedTimeRange extends _$AnalyticsSelectedTimeRange {
  @override
  AnalyticsTimeRange build() => AnalyticsTimeRange.thirtyDays;

  void setTimeRange(AnalyticsTimeRange timeRange) {
    state = timeRange;
  }
}

// Partner revenue metrics provider
@riverpod
class PartnerRevenueMetrics extends _$PartnerRevenueMetrics {
  @override
  Future<RevenueMetricsModel> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    final timeRange = ref.watch(analyticsSelectedTimeRangeProvider);

    final result = await repository.getPartnerRevenueMetrics(days: timeRange.days);

    return result.fold(
      (error) => throw error,
      (metrics) => metrics,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Partner revenue trends provider
@riverpod
class PartnerRevenueTrends extends _$PartnerRevenueTrends {
  @override
  Future<List<RevenueTrendModel>> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    final timeRange = ref.watch(analyticsSelectedTimeRangeProvider);

    final result = await repository.getPartnerRevenueTrends(days: timeRange.days);
    
    return result.fold(
      (error) => throw error,
      (trends) => trends,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Commission batches provider (admin only)
@riverpod
class CommissionBatches extends _$CommissionBatches {
  @override
  Future<List<CommissionBatchModel>> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    
    final result = await repository.getCommissionBatches();
    
    return result.fold(
      (error) => throw error,
      (batches) => batches,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> processCommissions() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    
    final result = await repository.processCommissions();
    
    result.fold(
      (error) => throw error,
      (response) {
        // Refresh the batches after processing
        refresh();
      },
    );
  }
}

// Overall revenue summary provider (admin only)
@riverpod
class RevenueSummary extends _$RevenueSummary {
  @override
  Future<RevenueMetricsModel> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    final timeRange = ref.watch(analyticsSelectedTimeRangeProvider);

    final result = await repository.getRevenueSummary(days: timeRange.days);

    return result.fold(
      (error) => throw error,
      (metrics) => metrics,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Partner performance provider (admin only)
@riverpod
class PartnerPerformance extends _$PartnerPerformance {
  @override
  Future<List<PartnerPerformanceModel>> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);

    final result = await repository.getPartnerPerformance();

    return result.fold(
      (error) => throw error,
      (performance) => performance,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Overall revenue trends provider (admin only)
@riverpod
class OverallRevenueTrends extends _$OverallRevenueTrends {
  @override
  Future<List<RevenueTrendModel>> build() async {
    final repository = ref.watch(revenueAnalyticsRepositoryProvider);
    final timeRange = ref.watch(analyticsSelectedTimeRangeProvider);

    final result = await repository.getRevenueTrends(days: timeRange.days);
    
    return result.fold(
      (error) => throw error,
      (trends) => trends,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
