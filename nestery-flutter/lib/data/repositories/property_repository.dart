import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

class PropertyRepository {
  final ApiClient _apiClient;

  PropertyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get featured properties
  Future<List<Property>> getFeaturedProperties() async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/featured',
      );

      return (response as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Search properties
  Future<List<Property>> searchProperties({
    String? location,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? propertyType,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (location != null) queryParams['location'] = location;
      if (checkIn != null) queryParams['checkIn'] = checkIn.toIso8601String();
      if (checkOut != null) queryParams['checkOut'] = checkOut.toIso8601String();
      if (guests != null) queryParams['guests'] = guests;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (amenities != null) queryParams['amenities'] = amenities.join(',');
      if (propertyType != null) queryParams['propertyType'] = propertyType;
      if (minRating != null) queryParams['minRating'] = minRating;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        Constants.propertiesEndpoint,
        queryParameters: queryParams,
      );

      return (response['data'] as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get property details
  Future<Property> getPropertyDetails(String propertyId) async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/$propertyId',
      );

      return Property.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get property availability
  Future<Map<String, dynamic>> getPropertyAvailability(
    String propertyId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/$propertyId/availability',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get property reviews
  Future<Map<String, dynamic>> getPropertyReviews(
    String propertyId, {
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/$propertyId/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get similar properties
  Future<List<Property>> getSimilarProperties(String propertyId) async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/$propertyId/similar',
      );

      return (response as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get trending destinations
  Future<List<Map<String, dynamic>>> getTrendingDestinations() async {
    try {
      final response = await _apiClient.get(
        '${Constants.propertiesEndpoint}/trending-destinations',
      );

      return List<Map<String, dynamic>>.from(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }
}
