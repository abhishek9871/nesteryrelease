import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';
import 'package:nestery_flutter/models/user.dart';

// User profile state
class UserProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  UserProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  // Create a new instance with updated values
  UserProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

// User profile provider
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserRepository _userRepository;

  UserProfileNotifier({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UserProfileState()) {
    // Load user profile on initialization
    loadUserProfile();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _userRepository.getUserProfile();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      },
    );
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _userRepository.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      preferences: preferences,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return false;
      },
      (updatedUser) {
        state = state.copyWith(
          user: updatedUser,
          isUpdating: false,
        );
        return true;
      },
    );
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _userRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(isUpdating: false);
        return success;
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Loyalty state
class LoyaltyState {
  final int points;
  final String tier;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> availableRewards;
  final bool isLoading;
  final String? error;
  final bool isRedeeming;

  LoyaltyState({
    this.points = 0,
    this.tier = 'bronze',
    this.transactions = const [],
    this.availableRewards = const [],
    this.isLoading = false,
    this.error,
    this.isRedeeming = false,
  });

  // Create a new instance with updated values
  LoyaltyState copyWith({
    int? points,
    String? tier,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? availableRewards,
    bool? isLoading,
    String? error,
    bool? isRedeeming,
  }) {
    return LoyaltyState(
      points: points ?? this.points,
      tier: tier ?? this.tier,
      transactions: transactions ?? this.transactions,
      availableRewards: availableRewards ?? this.availableRewards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRedeeming: isRedeeming ?? this.isRedeeming,
    );
  }
}

// Loyalty provider
class LoyaltyNotifier extends StateNotifier<LoyaltyState> {
  final UserRepository _userRepository;

  LoyaltyNotifier({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(LoyaltyState()) {
    // Load loyalty data on initialization
    loadLoyaltyData();
  }

  // Load loyalty data
  Future<void> loadLoyaltyData() async {
    state = state.copyWith(isLoading: true, error: null);

    // Load loyalty points and transactions in parallel
    final loyaltyDataResult = await _userRepository.getLoyaltyPoints();
    final transactionsResult = await _userRepository.getLoyaltyTransactions();
    final rewardsResult = await _userRepository.getAvailableRewards();

    // Handle all results
    loyaltyDataResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (loyaltyData) {
        transactionsResult.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure.message,
            );
          },
          (transactions) {
            rewardsResult.fold(
              (failure) {
                state = state.copyWith(
                  isLoading: false,
                  error: failure.message,
                );
              },
              (rewards) {
                state = state.copyWith(
                  points: loyaltyData['points'] ?? 0,
                  tier: loyaltyData['tier'] ?? 'bronze',
                  transactions: transactions,
                  availableRewards: rewards,
                  isLoading: false,
                );
              },
            );
          },
        );
      },
    );
  }

  // Redeem reward
  Future<bool> redeemReward(String rewardId) async {
    state = state.copyWith(isRedeeming: true, error: null);

    final result = await _userRepository.redeemReward(rewardId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRedeeming: false,
          error: failure.message,
        );
        return false;
      },
      (redeemResult) {
        // Update state with new points
        state = state.copyWith(
          points: redeemResult['remainingPoints'] ?? state.points,
          isRedeeming: false,
        );

        // Reload transactions to reflect the redemption
        loadTransactions();

        return true;
      },
    );
  }

  // Load transactions
  Future<void> loadTransactions() async {
    final result = await _userRepository.getLoyaltyTransactions();

    result.fold(
      (failure) {
        // Don't update error state for auxiliary data, just ignore
      },
      (transactions) {
        state = state.copyWith(transactions: transactions);
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Referral state
class ReferralState {
  final String? referralCode;
  final bool isLoading;
  final String? error;
  final bool isApplying;
  final bool applySuccess;

  ReferralState({
    this.referralCode,
    this.isLoading = false,
    this.error,
    this.isApplying = false,
    this.applySuccess = false,
  });

  // Create a new instance with updated values
  ReferralState copyWith({
    String? referralCode,
    bool? isLoading,
    String? error,
    bool? isApplying,
    bool? applySuccess,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isApplying: isApplying ?? this.isApplying,
      applySuccess: applySuccess ?? this.applySuccess,
    );
  }
}

// Referral provider
class ReferralNotifier extends StateNotifier<ReferralState> {
  final UserRepository _userRepository;

  ReferralNotifier({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(ReferralState()) {
    // Load referral code on initialization
    loadReferralCode();
  }

  // Load referral code
  Future<void> loadReferralCode() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _userRepository.getReferralCode();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (referralCode) {
        state = state.copyWith(
          referralCode: referralCode,
          isLoading: false,
        );
      },
    );
  }

  // Apply referral code
  Future<bool> applyReferralCode(String referralCode) async {
    state = state.copyWith(isApplying: true, error: null, applySuccess: false);

    final result = await _userRepository.applyReferralCode(referralCode);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isApplying: false,
          error: failure.message,
          applySuccess: false,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isApplying: false,
          applySuccess: success,
        );
        return success;
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset apply success
  void resetApplySuccess() {
    state = state.copyWith(applySuccess: false);
  }
}

// Providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(Provider<ApiClient>((ref) => ApiClient()));
  return UserRepository(apiClient: apiClient);
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserProfileNotifier(userRepository: userRepository);
});

final loyaltyProvider = StateNotifierProvider<LoyaltyNotifier, LoyaltyState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return LoyaltyNotifier(userRepository: userRepository);
});

final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return ReferralNotifier(userRepository: userRepository);
});
