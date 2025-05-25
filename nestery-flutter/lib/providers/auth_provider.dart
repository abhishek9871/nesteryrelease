import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

// Auth state class to manage authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  // Create a new instance with updated values
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// Auth provider to manage authentication state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier({
    required ApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        super(AuthState()) {
    // Check if user is already authenticated on initialization
    checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
        return;
      }
      
      // Get user profile
      final userData = await _apiClient.get(AppConstants.userProfileEndpoint);
      final user = User.fromJson(userData);
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
    } on ApiException catch (e) {
      // If token is invalid, clear it
      if (e.isAuthError) {
        await _secureStorage.delete(key: AppConstants.tokenKey);
        await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      }
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Save tokens
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response['accessToken'],
      );
      
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: response['refreshToken'],
      );
      
      // Get user profile
      final userData = await _apiClient.get(AppConstants.userProfileEndpoint);
      final user = User.fromJson(userData);
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Register user
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
      
      // Save tokens
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response['accessToken'],
      );
      
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: response['refreshToken'],
      );
      
      // Get user profile
      final userData = await _apiClient.get(AppConstants.userProfileEndpoint);
      final user = User.fromJson(userData);
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Clear tokens
      await _apiClient.clearTokens();
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiClient.put(
        AppConstants.userProfileEndpoint,
        data: userData,
      );
      
      final updatedUser = User.fromJson(response);
      
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ApiClient();
  return AuthNotifier(apiClient: apiClient);
});
