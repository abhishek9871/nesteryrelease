import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/referral.dart';
import 'package:nestery_flutter/services/api_service.dart';

/// State for referral data
class ReferralState {
  final ReferralStats? stats;
  final bool isLoading;
  final String? error;

  ReferralState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  ReferralState copyWith({
    ReferralStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return ReferralState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Referral provider for managing referral system
class ReferralNotifier extends StateNotifier<ReferralState> {
  final ApiService _apiService;

  ReferralNotifier(this._apiService) : super(ReferralState());

  /// Load referral stats for the current user
  Future<void> loadReferralStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/referrals/stats');

      if (response.statusCode == 200) {
        final stats = ReferralStats.fromJson(response.data);
        state = state.copyWith(stats: stats, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load referral stats',
        );
      }
    } catch (e) {
      // Mock data for development
      final mockStats = ReferralStats(
        userId: 'user123',
        referralCode: 'NEST${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        totalReferrals: 5,
        completedReferrals: 3,
        pendingReferrals: 2,
        totalMilesEarned: 1500,
        recentReferrals: [
          Referral(
            id: '1',
            referrerId: 'user123',
            referredUserId: 'user456',
            referredUserEmail: 'friend@example.com',
            referredUserName: 'John Doe',
            status: ReferralStatus.completed,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
            rewardMiles: 500,
            rewardDescription: 'First booking completed',
          ),
          Referral(
            id: '2',
            referrerId: 'user123',
            referredUserId: 'user789',
            referredUserEmail: 'buddy@example.com',
            referredUserName: 'Jane Smith',
            status: ReferralStatus.pending,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            rewardMiles: 500,
            rewardDescription: 'Waiting for first booking',
          ),
        ],
      );

      state = state.copyWith(stats: mockStats, isLoading: false);
    }
  }

  /// Generate or retrieve referral code
  Future<String?> getReferralCode() async {
    try {
      final response = await _apiService.get('/referrals/code');

      if (response.statusCode == 200) {
        return response.data['referralCode'];
      }
      return null;
    } catch (e) {
      // Return mock code
      return state.stats?.referralCode ??
          'NEST${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  /// Track a referral (when someone uses your code)
  Future<bool> trackReferral(String referralCode) async {
    try {
      final response = await _apiService.post('/referrals/track', data: {
        'referralCode': referralCode,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Refresh referral stats
  Future<void> refresh() async {
    await loadReferralStats();
  }
}

/// Provider for referral system
final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReferralNotifier(apiService);
});
