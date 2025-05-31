import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

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
// Note: userRepositoryProvider is now defined in repository_providers.dart

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserProfileNotifier(userRepository: userRepository);
});



final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return ReferralNotifier(userRepository: userRepository);
});
