import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/auth_dtos.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/either.dart';

/// Repository for handling authentication-related API calls
class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Register a new user
  Future<Either<ApiException, AuthResponse>> register(RegisterDto data) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.registerEndpoint,
        data: data.toJson(),
      );

      if (response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        return Either.right(authResponse);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Login user
  Future<Either<ApiException, AuthResponse>> login(LoginDto data) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.loginEndpoint,
        data: data.toJson(),
      );

      if (response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        return Either.right(authResponse);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Refresh access token
  Future<Either<ApiException, AuthResponse>> refreshToken(RefreshTokenDto data) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.refreshTokenEndpoint,
        data: data.toJson(),
      );

      if (response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        return Either.right(authResponse);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Get current user profile
  Future<Either<ApiException, User>> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.userProfileEndpoint,
      );

      if (response.data != null) {
        final user = User.fromJson(response.data!);
        return Either.right(user);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Update user profile
  Future<Either<ApiException, User>> updateProfile(UpdateUserDto data) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        Constants.userProfileEndpoint,
        data: data.toJson(),
      );

      if (response.data != null) {
        final user = User.fromJson(response.data!);
        return Either.right(user);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Store authentication tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: Constants.tokenKey, value: accessToken);
    await _secureStorage.write(key: Constants.refreshTokenKey, value: refreshToken);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: Constants.tokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: Constants.refreshTokenKey);
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: Constants.tokenKey);
    await _secureStorage.delete(key: Constants.refreshTokenKey);
    await _apiClient.clearTokens();
  }

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Attempt to refresh token automatically
  Future<Either<ApiException, AuthResponse>> attemptTokenRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return Either.left(ApiException(
        message: 'No refresh token available',
        statusCode: 401,
      ));
    }

    return await this.refreshToken(RefreshTokenDto(refreshToken: refreshToken));
  }

  /// Send forgot password email
  Future<Either<ApiException, Map<String, dynamic>>> forgotPassword(String email) async {
    try {
      // Validate email format
      if (email.trim().isEmpty) {
        return Either.left(ApiException(
          message: 'Email is required',
          statusCode: 400,
        ));
      }

      if (!Constants.emailPattern.hasMatch(email.trim())) {
        return Either.left(ApiException(
          message: 'Please enter a valid email address',
          statusCode: 400,
        ));
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.forgotPasswordEndpoint,
        data: {'email': email.trim()},
      );

      if (response.data != null) {
        return Either.right(response.data!);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  /// Reset password with token
  Future<Either<ApiException, Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // Validate inputs
      if (token.trim().isEmpty) {
        return Either.left(ApiException(
          message: 'Reset token is required',
          statusCode: 400,
        ));
      }

      if (newPassword.trim().isEmpty) {
        return Either.left(ApiException(
          message: 'New password is required',
          statusCode: 400,
        ));
      }

      if (!Constants.passwordPattern.hasMatch(newPassword)) {
        return Either.left(ApiException(
          message: 'Password must be at least 8 characters with letters and numbers',
          statusCode: 400,
        ));
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.resetPasswordEndpoint,
        data: {
          'token': token.trim(),
          'newPassword': newPassword,
        },
      );

      if (response.data != null) {
        return Either.right(response.data!);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }
}
