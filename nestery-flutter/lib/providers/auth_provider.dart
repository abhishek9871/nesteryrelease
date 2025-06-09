import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/core/auth/auth_repository.dart';
import 'package:nestery_flutter/models/auth_dtos.dart';
import 'package:nestery_flutter/models/user.dart';

/// Authentication status enum
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Enhanced auth state class to manage authentication state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  /// Convenience getters
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
  bool get isInitial => status == AuthStatus.initial;

  /// Create a new instance with updated values
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, hasTokens: ${accessToken != null}, error: $errorMessage)';
  }
}

/// Auth provider to manage authentication state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) {
    // Check if user is already authenticated on initialization
    tryAutoLogin();
  }

  /// Try to automatically login user if tokens exist
  Future<void> tryAutoLogin() async {
    if (!mounted) return;
    state = state.copyWith(status: AuthStatus.loading);

    // Check if tokens exist
    final accessToken = await _authRepository.getAccessToken();
    final refreshToken = await _authRepository.getRefreshToken();

    if (!mounted) return;
    if (accessToken == null || refreshToken == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // For now, just set authenticated if tokens exist
    // In a future LFS, we'll add user profile fetching
    state = state.copyWith(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Login user with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    // Placeholder for future LFS implementation
    // For now, just simulate a failed login
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Login functionality will be implemented in a future LFS',
    );
    return false;
  }

  /// Register a new user
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    // Placeholder for future LFS implementation
    // For now, just simulate a failed registration
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Registration functionality will be implemented in a future LFS',
    );
    return false;
  }

  /// Logout user and clear all tokens
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // Clear tokens from repository
      await _authRepository.clearTokens();

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        accessToken: null,
        refreshToken: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UpdateUserDto updateData) async {
    state = state.copyWith(status: AuthStatus.loading);

    // Placeholder for future LFS implementation
    // For now, just simulate a failed update
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Profile update functionality will be implemented in a future LFS',
    );
    return false;
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Riverpod providers for dependency injection

/// Provider for FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for AuthRepository - now using the new simplified auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(secureStorage);
});

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
