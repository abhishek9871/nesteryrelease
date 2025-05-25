import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get user profile
  Future<User> getUserProfile() async {
    try {
      final response = await _apiClient.get(
        AppConstants.userProfileEndpoint,
      );
      
      return User.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Update user profile
  Future<User> updateUserProfile({
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
      
      final response = await _apiClient.put(
        AppConstants.userProfileEndpoint,
        data: data,
      );
      
      return User.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        '${AppConstants.userProfileEndpoint}/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get loyalty points
  Future<Map<String, dynamic>> getLoyaltyPoints() async {
    try {
      final response = await _apiClient.get(
        AppConstants.loyaltyEndpoint,
      );
      
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get loyalty transactions
  Future<List<Map<String, dynamic>>> getLoyaltyTransactions({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.loyaltyEndpoint}/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      return List<Map<String, dynamic>>.from(response['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get available rewards
  Future<List<Map<String, dynamic>>> getAvailableRewards() async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.loyaltyEndpoint}/rewards',
      );
      
      return List<Map<String, dynamic>>.from(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Redeem reward
  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    try {
      final response = await _apiClient.post(
        '${AppConstants.loyaltyEndpoint}/rewards/$rewardId/redeem',
      );
      
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get user's referral code
  Future<String> getReferralCode() async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.socialSharingEndpoint}/referral-code',
      );
      
      return response['referralCode'];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Apply referral code
  Future<bool> applyReferralCode(String referralCode) async {
    try {
      await _apiClient.post(
        '${AppConstants.socialSharingEndpoint}/apply-referral',
        data: {
          'referralCode': referralCode,
        },
      );
      
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }
}
