import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/data/repositories/auth_repository.dart';
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
    state = state.copyWith(status: AuthStatus.loading);

    // Check if tokens exist
    final hasTokens = await _authRepository.hasValidTokens();
    if (!hasTokens) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // Try to get current user
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) async {
        // If 401, try to refresh token
        if (failure.statusCode == 401) {
          final refreshResult = await _authRepository.attemptTokenRefresh();
          refreshResult.fold(
            (refreshFailure) async {
              // Refresh failed, clear tokens and set unauthenticated
              await _authRepository.clearTokens();
              state = state.copyWith(status: AuthStatus.unauthenticated);
            },
            (authResponse) async {
              // Refresh successful, store new tokens and set authenticated
              await _authRepository.storeTokens(
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
              );
              state = state.copyWith(
                status: AuthStatus.authenticated,
                user: authResponse.user,
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
              );
            },
          );
        } else {
          // Other error, clear tokens and set unauthenticated
          await _authRepository.clearTokens();
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (user) async {
        // Successfully got user, set authenticated
        final accessToken = await _authRepository.getAccessToken();
        final refreshToken = await _authRepository.getRefreshToken();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      },
    );
  }

  /// Login user with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final loginDto = LoginDto(email: email, password: password);
    final result = await _authRepository.login(loginDto);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (authResponse) async {
        // Store tokens
        await _authRepository.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        return true;
      },
    );
  }

  /// Register a new user
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final registerDto = RegisterDto(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    final result = await _authRepository.register(registerDto);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (authResponse) async {
        // Store tokens
        await _authRepository.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        return true;
      },
    );
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

    final result = await _authRepository.updateProfile(updateData);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedUser) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
        );
        return true;
      },
    );
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

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );
});

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
