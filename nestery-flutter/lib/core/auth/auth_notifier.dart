import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/auth/auth_repository.dart';
import 'package:nestery_flutter/core/auth/auth_state.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    final token = await _ref.read(authRepositoryProvider).getAccessToken();
    if (token != null) {
      try {
        final userEither = await _ref.read(userRepositoryProvider).getUserProfile();
        userEither.fold(
          (l) => throw l,
          (user) => state = AuthState.authenticated(user: user),
        );
      } catch (e) {
        await logout('Session expired. Please log in again.');
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    // Placeholder for a future LFS
  }

  Future<void> logout([String? message]) async {
    await _ref.read(authRepositoryProvider).clearTokens();
    state = AuthState.unauthenticated(message: message);
  }
}
