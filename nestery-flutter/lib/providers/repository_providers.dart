import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/data/repositories/property_repository.dart';
import 'package:nestery_flutter/data/repositories/booking_repository.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';
import 'package:nestery_flutter/data/repositories/review_repository.dart';
import 'package:nestery_flutter/data/repositories/loyalty_repository.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/services/api_cache_service.dart';

/// Provider for ApiClient (if not already defined in auth_provider.dart or similar)
/// This ensures ApiClient is available for all repositories.
/// If ApiClient needs async initialization (like for cache), this might need to be a FutureProvider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Repository providers for dependency injection

/// Property Repository Provider
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyRepository(apiClient: apiClient);
});

/// Booking Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient: apiClient);
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiCacheService = ref.watch(apiCacheServiceProvider);
  return UserRepository(apiClient: apiClient, apiCacheService: apiCacheService);
});

/// Review Repository Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // Reviews are typically not cached aggressively or might have specific caching needs.
  // For now, not passing ApiCacheService, but it could be added if needed.
  return ReviewRepository(apiClient: apiClient);
});

/// Loyalty Repository Provider
final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiCacheService = ref.watch(apiCacheServiceProvider);
  return LoyaltyRepository(apiClient: apiClient, apiCacheService: apiCacheService);
});

/// ApiCacheService Provider
final apiCacheServiceProvider = Provider<ApiCacheService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiCacheService(apiClient); // Pass the ApiClient instance
});
