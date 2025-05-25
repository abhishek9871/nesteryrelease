import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

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
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _userRepository.getUserProfile();

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final updatedUser = await _userRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
        preferences: preferences,
      );

      state = state.copyWith(
        user: updatedUser,
        isUpdating: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final success = await _userRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isUpdating: false);

      return success;
    } on ApiException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
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
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load loyalty points and transactions in parallel
      final loyaltyData = await _userRepository.getLoyaltyPoints();
      final transactions = await _userRepository.getLoyaltyTransactions();
      final rewards = await _userRepository.getAvailableRewards();

      state = state.copyWith(
        points: loyaltyData['points'] ?? 0,
        tier: loyaltyData['tier'] ?? 'bronze',
        transactions: transactions,
        availableRewards: rewards,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Redeem reward
  Future<bool> redeemReward(String rewardId) async {
    try {
      state = state.copyWith(isRedeeming: true, error: null);

      final result = await _userRepository.redeemReward(rewardId);

      // Update state with new points
      state = state.copyWith(
        points: result['remainingPoints'] ?? state.points,
        isRedeeming: false,
      );

      // Reload transactions to reflect the redemption
      loadTransactions();

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Load transactions
  Future<void> loadTransactions() async {
    try {
      final transactions = await _userRepository.getLoyaltyTransactions();

      state = state.copyWith(transactions: transactions);
    } catch (e) {
      // Don't update error state, just log it
      print('Error loading transactions: $e');
    }
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
    try {
      state = state.copyWith(isLoading: true, error: null);

      final referralCode = await _userRepository.getReferralCode();

      state = state.copyWith(
        referralCode: referralCode,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Apply referral code
  Future<bool> applyReferralCode(String referralCode) async {
    try {
      state = state.copyWith(isApplying: true, error: null, applySuccess: false);

      final success = await _userRepository.applyReferralCode(referralCode);

      state = state.copyWith(
        isApplying: false,
        applySuccess: success,
      );

      return success;
    } on ApiException catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: e.message,
        applySuccess: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: e.toString(),
        applySuccess: false,
      );
      return false;
    }
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
