import 'dart:developer' as developer;
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/utils/constants.dart';

/// Service for managing API cache programmatically.
class ApiCacheService {
  final ApiClient _apiClient;

  ApiCacheService(this._apiClient);

  /// Invalidates a specific cache entry by its URL (path part).
  /// The URL should be the path part of the endpoint, e.g., Constants.userProfileEndpoint.
  Future<void> invalidateCacheEntry(String endpointPath) async {
    try {
      // Construct the full URL as it's used as the cache key by default.
      final fullUrl = endpointPath.startsWith('http') ? endpointPath : Constants.apiBaseUrl + endpointPath;
      await _apiClient.cacheStore.delete(fullUrl);
      developer.log('Cache invalidated for: $fullUrl', name: 'ApiCacheService');
    } catch (e) {
      developer.log('Error invalidating cache for $endpointPath: $e', name: 'ApiCacheService', level: 1000);
    }
  }

  /// Clears all entries from the cache.
  Future<void> clearAllCache() async {
    try {
      await _apiClient.cacheStore.clean();
      developer.log('All API cache cleared.', name: 'ApiCacheService');
    } catch (e) {
      developer.log('Error clearing all API cache: $e', name: 'ApiCacheService', level: 1000);
    }
  }
}
