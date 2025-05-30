import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/search_dtos.dart';
import 'package:nestery_flutter/models/response_models.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/either.dart';

class PropertyRepository {
  final ApiClient _apiClient;

  PropertyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get featured properties
  Future<Either<ApiException, List<Property>>> getFeaturedProperties() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    try {
      Options? requestOptions;
      if (!isOnline) {
        requestOptions = CacheOptions(
          store: _apiClient.cacheStore,
          policy: CachePolicy.forceCache,
          hitCacheOnNetworkFailure: true,
        ).toOptions();
      } else {
        // Example: Shorter TTL for featured properties list
        requestOptions = CacheOptions(
          store: _apiClient.cacheStore,
          maxStale: Constants.propertyListCacheTTL,
        ).toOptions();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/featured',
        options: requestOptions,
      );

      if (response.data != null && response.data!['data'] != null) {
        final properties = (response.data!['data'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
        return Either.right(properties);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      if (!isOnline && e.error.toString().contains('cache')) {
        return Either.left(ApiException(
          message: "Offline and no cached featured properties available.",
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

  // Search properties
  Future<Either<ApiException, List<Property>>> searchProperties(SearchPropertiesDto searchParams) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.propertiesEndpoint,
        queryParameters: searchParams.toQueryParams(),
      );

      if (response.data != null && response.data!['data'] != null) {
        final properties = (response.data!['data'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
        return Either.right(properties);
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

  // Get property details
  Future<Either<ApiException, Property>> getPropertyDetails(String propertyId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/$propertyId',
      );

      if (response.data != null) {
        final property = Property.fromJson(response.data!);
        return Either.right(property);
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

  // Get property availability
  Future<Either<ApiException, List<PropertyAvailability>>> getPropertyAvailability(
    String propertyId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validate date range
      if (startDate.isAfter(endDate)) {
        return Either.left(ApiException(
          message: 'Start date must be before end date',
          statusCode: 400,
        ));
      }

      if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return Either.left(ApiException(
          message: 'Start date cannot be in the past',
          statusCode: 400,
        ));
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/$propertyId/availability',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.data != null && response.data!['data'] != null) {
        final availability = (response.data!['data'] as List)
            .map((json) => PropertyAvailability.fromJson(json))
            .toList();
        return Either.right(availability);
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

  // Get property reviews
  Future<Either<ApiException, Map<String, dynamic>>> getPropertyReviews(
    String propertyId, {
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/$propertyId/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
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

  // Get similar properties
  Future<Either<ApiException, List<Property>>> getSimilarProperties(String propertyId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/$propertyId/similar',
      );

      if (response.data != null && response.data!['data'] != null) {
        final properties = (response.data!['data'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
        return Either.right(properties);
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



  // Get trending destinations
  Future<Either<ApiException, List<TrendingDestination>>> getTrendingDestinations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.propertiesEndpoint}/trending-destinations',
      );

      if (response.data != null && response.data!['data'] != null) {
        final destinations = (response.data!['data'] as List)
            .map((json) => TrendingDestination.fromJson(json))
            .toList();
        return Either.right(destinations);
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
