import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/data/repositories/loyalty_repository.dart';
import 'package:nestery_flutter/models/loyalty.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

/// State for Loyalty Status
class LoyaltyStatusState {
  final LoyaltyStatus? status;
  final bool isLoading;
  final String? error;

  LoyaltyStatusState({this.status, this.isLoading = false, this.error});

  LoyaltyStatusState copyWith({LoyaltyStatus? status, bool? isLoading, String? error}) {
    return LoyaltyStatusState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow error to be explicitly set to null
    );
  }
}

/// Notifier for Loyalty Status
class LoyaltyStatusNotifier extends StateNotifier<LoyaltyStatusState> {
  final LoyaltyRepository _loyaltyRepository;

  LoyaltyStatusNotifier(this._loyaltyRepository) : super(LoyaltyStatusState()) {
    fetchLoyaltyStatus();
  }

  Future<void> fetchLoyaltyStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loyaltyRepository.getLoyaltyStatus();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (status) => state = state.copyWith(isLoading: false, status: status, error: null),
    );
  }
}

final loyaltyStatusProvider = StateNotifierProvider<LoyaltyStatusNotifier, LoyaltyStatusState>((ref) {
  return LoyaltyStatusNotifier(ref.watch(loyaltyRepositoryProvider));
});

/// State for Daily Check-in
enum DailyCheckInStatus { initial, loading, success, error, alreadyCheckedIn }

class DailyCheckInState {
  final DailyCheckInStatus status;
  final String? message; // For success or error messages

  DailyCheckInState({this.status = DailyCheckInStatus.initial, this.message});

  DailyCheckInState copyWith({DailyCheckInStatus? status, String? message}) {
    return DailyCheckInState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

/// Notifier for Daily Check-in
class DailyCheckInNotifier extends StateNotifier<DailyCheckInState> {
  final LoyaltyRepository _loyaltyRepository;
  final Ref _ref;

  DailyCheckInNotifier(this._loyaltyRepository, this._ref) : super(DailyCheckInState());

  Future<void> performCheckIn() async {
    state = state.copyWith(status: DailyCheckInStatus.loading, message: null);
    final result = await _loyaltyRepository.performDailyCheckIn();
    result.fold(
      (failure) {
        if (failure.statusCode == 400 && failure.message.toLowerCase().contains('already checked in')) {
          state = state.copyWith(status: DailyCheckInStatus.alreadyCheckedIn, message: failure.message);
        } else {
          state = state.copyWith(status: DailyCheckInStatus.error, message: failure.message);
        }
      },
      (transaction) {
        state = state.copyWith(status: DailyCheckInStatus.success, message: 'Checked in! +${transaction.milesAmount} Miles');
        // Refresh loyalty status and transactions after successful check-in
        _ref.read(loyaltyStatusProvider.notifier).fetchLoyaltyStatus();
        _ref.read(loyaltyTransactionsProvider.notifier).fetchInitialTransactions();
      },
    );
  }

  void reset() {
    state = DailyCheckInState();
  }
}

final dailyCheckInNotifierProvider = StateNotifierProvider<DailyCheckInNotifier, DailyCheckInState>((ref) {
  return DailyCheckInNotifier(ref.watch(loyaltyRepositoryProvider), ref);
});


/// State for Loyalty Transactions
class LoyaltyTransactionsState {
  final List<LoyaltyTransaction> transactions;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  LoyaltyTransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  LoyaltyTransactionsState copyWith({
    List<LoyaltyTransaction>? transactions,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return LoyaltyTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notifier for Loyalty Transactions
class LoyaltyTransactionsNotifier extends StateNotifier<LoyaltyTransactionsState> {
  final LoyaltyRepository _loyaltyRepository;
  static const _pageSize = 20;

  LoyaltyTransactionsNotifier(this._loyaltyRepository) : super(LoyaltyTransactionsState());

  Future<void> fetchInitialTransactions() async {
    state = state.copyWith(isLoading: true, error: null, transactions: [], currentPage: 1, hasMore: true);
    await _fetchTransactions(1);
  }

  Future<void> fetchMoreTransactions() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    await _fetchTransactions(state.currentPage + 1);
  }

  Future<void> _fetchTransactions(int page) async {
    final result = await _loyaltyRepository.getLoyaltyTransactions(page: page, limit: _pageSize);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (paginatedResult) {
        final newTransactions = page == 1 ? paginatedResult.data : [...state.transactions, ...paginatedResult.data];
        state = state.copyWith(
          isLoading: false,
          transactions: newTransactions,
          currentPage: page,
          hasMore: paginatedResult.data.length == _pageSize,
          error: null,
        );
      },
    );
  }
}

final loyaltyTransactionsProvider = StateNotifierProvider<LoyaltyTransactionsNotifier, LoyaltyTransactionsState>((ref) {
  return LoyaltyTransactionsNotifier(ref.watch(loyaltyRepositoryProvider));
});
