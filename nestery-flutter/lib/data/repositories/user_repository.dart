import 'package:dio/dio.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/services/api_cache_service.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/either.dart';

class UserRepository {
  final ApiClient _apiClient;
  final ApiCacheService _apiCacheService;

  UserRepository({required ApiClient apiClient, required ApiCacheService apiCacheService})
      : _apiClient = apiClient,
        _apiCacheService = apiCacheService;

  // Get user profile
  Future<Either<ApiException, User>> getUserProfile() async {
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

  // Update user profile
  Future<Either<ApiException, User>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (profilePicture != null) data['profilePicture'] = profilePicture;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _apiClient.put<Map<String, dynamic>>(
        Constants.userProfileEndpoint,
        data: data,
      );

      if (response.data != null) {
        final user = User.fromJson(response.data!);
        // Invalidate user profile cache after successful update
        await _apiCacheService.invalidateCacheEntry(Constants.userProfileEndpoint);
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

  // Change password
  Future<Either<ApiException, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put<Map<String, dynamic>>(
        '${Constants.userProfileEndpoint}/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return Either.right(true);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }


  // Redeem reward
  Future<Either<ApiException, Map<String, dynamic>>> redeemReward(String rewardId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/loyalty/rewards/$rewardId/redeem',
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

  // Get user's referral code
  Future<Either<ApiException, String>> getReferralCode() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.socialSharingEndpoint}/referral-code',
      );

      if (response.data != null && response.data!['referralCode'] != null) {
        return Either.right(response.data!['referralCode']);
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

  // Apply referral code
  Future<Either<ApiException, bool>> applyReferralCode(String referralCode) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '${Constants.socialSharingEndpoint}/apply-referral',
        data: {
          'referralCode': referralCode,
        },
      );

      return Either.right(true);
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
