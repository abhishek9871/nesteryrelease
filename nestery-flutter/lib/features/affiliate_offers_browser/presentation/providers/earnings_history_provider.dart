import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../providers/repository_providers.dart';
import '../../data/models/earnings_history_model.dart';
import '../../data/repositories/commission_tracking_repository.dart';
import '../../data/repositories/commission_tracking_repository_impl.dart';

part 'earnings_history_provider.g.dart';
part 'earnings_history_provider.freezed.dart';

// Repository provider
@riverpod
CommissionTrackingRepository commissionTrackingRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommissionTrackingRepositoryImpl(apiClient);
}

// Earnings filter state
@freezed
class EarningsFilter with _$EarningsFilter {
  const factory EarningsFilter({
    @Default(null) String? status,
    @Default(null) DateTime? startDate,
    @Default(null) DateTime? endDate,
    @Default(null) String? offerId,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _EarningsFilter;
}

// Earnings filter provider
@riverpod
class EarningsFilterNotifier extends _$EarningsFilterNotifier {
  @override
  EarningsFilter build() => const EarningsFilter();

  void updateFilter({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? offerId,
  }) {
    state = state.copyWith(
      status: status,
      startDate: startDate,
      endDate: endDate,
      offerId: offerId,
      page: 1, // Reset to first page when filter changes
    );
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void clearFilters() {
    state = const EarningsFilter();
  }
}

// Earnings history provider
@riverpod
class EarningsHistory extends _$EarningsHistory {
  @override
  Future<List<EarningsHistoryModel>> build() async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    final filter = ref.watch(earningsFilterNotifierProvider);
    
    final result = await repository.getEarningsHistory(
      page: filter.page,
      limit: filter.limit,
      status: filter.status,
      startDate: filter.startDate,
      endDate: filter.endDate,
      offerId: filter.offerId,
    );
    
    return result.fold(
      (error) => throw error,
      (earnings) => earnings,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is AsyncData<List<EarningsHistoryModel>>) {
      final filter = ref.read(earningsFilterNotifierProvider);
      ref.read(earningsFilterNotifierProvider.notifier).setPage(filter.page + 1);
      
      final repository = ref.read(commissionTrackingRepositoryProvider);
      final result = await repository.getEarningsHistory(
        page: filter.page + 1,
        limit: filter.limit,
        status: filter.status,
        startDate: filter.startDate,
        endDate: filter.endDate,
        offerId: filter.offerId,
      );
      
      result.fold(
        (error) => throw error,
        (newEarnings) {
          final currentEarnings = currentState.value;
          state = AsyncValue.data([...currentEarnings, ...newEarnings]);
        },
      );
    }
  }
}

// User analytics provider
@riverpod
class UserAnalytics extends _$UserAnalytics {
  @override
  Future<UserAnalyticsModel> build() async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    
    final result = await repository.getUserAnalytics();
    
    return result.fold(
      (error) => throw error,
      (analytics) => analytics,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Earnings summary provider
@riverpod
class EarningsSummary extends _$EarningsSummary {
  @override
  Future<Map<String, dynamic>> build() async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    
    final result = await repository.getEarningsSummary();
    
    return result.fold(
      (error) => throw error,
      (summary) => summary,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Offer-specific earnings provider
@riverpod
class OfferEarnings extends _$OfferEarnings {
  @override
  Future<List<EarningsHistoryModel>> build(String offerId) async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    
    final result = await repository.getOfferEarnings(offerId);
    
    return result.fold(
      (error) => throw error,
      (earnings) => earnings,
    );
  }

  Future<void> refresh(String offerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(offerId));
  }
}
