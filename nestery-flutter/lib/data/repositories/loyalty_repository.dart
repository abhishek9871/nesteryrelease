import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/loyalty.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/services/api_cache_service.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/either.dart';

class PaginatedLoyaltyTransactions {
  final List<LoyaltyTransaction> data;
  final int total;
  final int page;
  final int limit;

  PaginatedLoyaltyTransactions({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedLoyaltyTransactions.fromJson(Map<String, dynamic> json) {
    return PaginatedLoyaltyTransactions(
      data: (json['data'] as List<dynamic>)
          .map((e) => LoyaltyTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}

class LoyaltyRepository {
  final ApiClient _apiClient;
  final ApiCacheService _apiCacheService;

  LoyaltyRepository({required ApiClient apiClient, required ApiCacheService apiCacheService})
      : _apiClient = apiClient,
        _apiCacheService = apiCacheService;

  Future<Either<ApiException, LoyaltyStatus>> getLoyaltyStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    try {
      // Note: Caching functionality will be implemented in a future LFS
      Options? requestOptions;
      if (!isOnline) {
        // Handle offline case in future LFS
      } else {
        // Example: Shorter TTL for loyalty status as it might change more frequently.
        // For this example, we'll use the default policy (CachePolicy.request) and default TTL.
        // If specific TTL is needed:
        // requestOptions = const CacheOptions(maxStale: Duration(minutes: 15)).toOptions();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.loyaltyStatusEndpoint,
        options: requestOptions,
      );

      if (response.data != null) {
        final loyaltyStatus = LoyaltyStatus.fromJson(response.data!);
        return Either.right(loyaltyStatus);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server for loyalty status',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      if (!isOnline && e.error.toString().contains('cache')) {
        return Either.left(ApiException(
          message: "Offline and no cached loyalty status available.",
          statusCode: 0,
        ));
      }
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  Future<Either<ApiException, LoyaltyTransaction>> performDailyCheckIn() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.loyaltyCheckInEndpoint,
      );
      if (response.data != null) {
        final transaction = LoyaltyTransaction.fromJson(response.data!);
        // Invalidate loyalty status cache after successful check-in
        await _apiCacheService.invalidateCacheEntry(Constants.apiBaseUrl + Constants.loyaltyStatusEndpoint);
        return Either.right(transaction);
      }
      return Either.left(ApiException(message: 'Check-in failed', statusCode: response.statusCode ?? 500));
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  Future<Either<ApiException, PaginatedLoyaltyTransactions>> getLoyaltyTransactions({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.loyaltyTransactionsEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data != null) {
        final paginatedTransactions = PaginatedLoyaltyTransactions.fromJson(response.data!);
        return Either.right(paginatedTransactions);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server for loyalty transactions',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }
}
