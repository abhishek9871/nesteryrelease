import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/data/repositories/property_repository.dart';
import 'package:nestery_flutter/data/repositories/booking_repository.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';
import 'package:nestery_flutter/data/repositories/review_repository.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';

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
  return UserRepository(apiClient: apiClient);
});

/// Review Repository Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRepository(apiClient: apiClient);
});
