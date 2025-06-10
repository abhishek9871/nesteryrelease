import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../utils/api_exception.dart';
import '../../data/models/earnings_history_model.dart';
import '../../data/repositories/commission_tracking_repository.dart';
import 'earnings_history_provider.dart';

part 'payout_provider.g.dart';
part 'payout_provider.freezed.dart';

// Payout filter state
@freezed
class PayoutFilter with _$PayoutFilter {
  const factory PayoutFilter({
    @Default(null) String? status,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _PayoutFilter;
}

// Payout filter provider
@riverpod
class PayoutFilterNotifier extends _$PayoutFilterNotifier {
  @override
  PayoutFilter build() => const PayoutFilter();

  void updateFilter({String? status}) {
    state = state.copyWith(
      status: status,
      page: 1, // Reset to first page when filter changes
    );
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void clearFilters() {
    state = const PayoutFilter();
  }
}

// Payout requests provider
@riverpod
class PayoutRequests extends _$PayoutRequests {
  @override
  Future<List<PayoutRequestModel>> build() async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    final filter = ref.watch(payoutFilterNotifierProvider);
    
    final result = await repository.getPayoutRequests(
      page: filter.page,
      limit: filter.limit,
      status: filter.status,
    );
    
    return result.fold(
      (error) => throw error,
      (payouts) => payouts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is AsyncData<List<PayoutRequestModel>>) {
      final filter = ref.read(payoutFilterNotifierProvider);
      ref.read(payoutFilterNotifierProvider.notifier).setPage(filter.page + 1);
      
      final repository = ref.read(commissionTrackingRepositoryProvider);
      final result = await repository.getPayoutRequests(
        page: filter.page + 1,
        limit: filter.limit,
        status: filter.status,
      );
      
      result.fold(
        (error) => throw error,
        (newPayouts) {
          final currentPayouts = currentState.value;
          state = AsyncValue.data([...currentPayouts, ...newPayouts]);
        },
      );
    }
  }
}

// Payout info provider (minimum threshold, available balance, etc.)
@riverpod
class PayoutInfo extends _$PayoutInfo {
  @override
  Future<Map<String, dynamic>> build() async {
    final repository = ref.watch(commissionTrackingRepositoryProvider);
    
    final result = await repository.getPayoutInfo();
    
    return result.fold(
      (error) => throw error,
      (info) => info,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// Payout creation state
@freezed
class PayoutCreationState with _$PayoutCreationState {
  const factory PayoutCreationState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(null) PayoutRequestModel? createdPayout,
  }) = _PayoutCreationState;
}

// Payout creation provider
@riverpod
class PayoutCreation extends _$PayoutCreation {
  @override
  PayoutCreationState build() => const PayoutCreationState();

  Future<void> createPayout(CreatePayoutRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repository = ref.read(commissionTrackingRepositoryProvider);
    final result = await repository.createPayoutRequest(request);
    
    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (payout) {
        state = state.copyWith(
          isLoading: false,
          createdPayout: payout,
          error: null,
        );
        // Refresh the payout requests list
        ref.invalidate(payoutRequestsProvider);
      },
    );
  }

  Future<void> cancelPayout(String payoutId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repository = ref.read(commissionTrackingRepositoryProvider);
    final result = await repository.cancelPayoutRequest(payoutId);
    
    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (payout) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        // Refresh the payout requests list
        ref.invalidate(payoutRequestsProvider);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCreatedPayout() {
    state = state.copyWith(createdPayout: null);
  }
}

// Helper provider for checking if user can request payout
@riverpod
Future<bool> canRequestPayout(CanRequestPayoutRef ref) async {
  try {
    final payoutInfo = await ref.watch(payoutInfoProvider.future);
    final availableBalance = payoutInfo['availableBalance']?.toDouble() ?? 0.0;
    final minimumThreshold = payoutInfo['minimumThreshold']?.toDouble() ?? 50.0;
    
    return availableBalance >= minimumThreshold;
  } catch (e) {
    return false;
  }
}

// Helper provider for available balance
@riverpod
Future<double> availableBalance(AvailableBalanceRef ref) async {
  try {
    final payoutInfo = await ref.watch(payoutInfoProvider.future);
    return payoutInfo['availableBalance']?.toDouble() ?? 0.0;
  } catch (e) {
    return 0.0;
  }
}

// Helper provider for minimum payout threshold
@riverpod
Future<double> minimumPayoutThreshold(MinimumPayoutThresholdRef ref) async {
  try {
    final payoutInfo = await ref.watch(payoutInfoProvider.future);
    return payoutInfo['minimumThreshold']?.toDouble() ?? 50.0;
  } catch (e) {
    return 50.0;
  }
}
