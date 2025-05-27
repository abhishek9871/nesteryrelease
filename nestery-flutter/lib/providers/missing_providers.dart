import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/review.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/models/search_dtos.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

/// Missing providers that are referenced in UI but not yet implemented

/// User Bookings Provider - provides list of user's bookings
final userBookingsProvider = FutureProvider.family<List<Booking>, BookingStatus?>((ref, status) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final result = await bookingRepository.getUserBookings(status: status);
  
  return result.fold(
    (error) => throw error,
    (bookings) => bookings,
  );
});

/// Recommended Properties Provider - provides personalized property recommendations
final recommendedPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.getFeaturedProperties(); // Using featured as fallback for recommendations
  
  return result.fold(
    (error) => throw error,
    (properties) => properties,
  );
});

/// Cancel Booking Provider - handles booking cancellation
final cancelBookingProvider = FutureProvider.family<Booking, String>((ref, bookingId) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final result = await bookingRepository.cancelBooking(bookingId);
  
  return result.fold(
    (error) => throw error,
    (booking) => booking,
  );
});

/// Submit Review Provider - handles review submission
final submitReviewProvider = FutureProvider.family<bool, CreateReviewDto>((ref, reviewData) async {
  // TODO: Implement review submission when ReviewRepository is created
  // For now, return success
  await Future.delayed(const Duration(seconds: 1));
  return true;
});

/// Update Profile Provider - handles profile updates
final updateProfileProvider = FutureProvider.family<User, Map<String, dynamic>>((ref, profileData) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final result = await userRepository.updateUserProfile(
    firstName: profileData['firstName'],
    lastName: profileData['lastName'],
    phoneNumber: profileData['phoneNumber'],
    profilePicture: profileData['profilePicture'],
    preferences: profileData['preferences'],
  );
  
  return result.fold(
    (error) => throw error,
    (user) => user,
  );
});

/// Search Properties Provider - handles property search
final searchPropertiesProvider = FutureProvider.family<List<Property>, SearchPropertiesDto>((ref, searchParams) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.searchProperties(searchParams);
  
  return result.fold(
    (error) => throw error,
    (properties) => properties,
  );
});

/// Property Details Provider - provides detailed property information
final propertyDetailsProvider = FutureProvider.family<Property, String>((ref, propertyId) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.getPropertyDetails(propertyId);
  
  return result.fold(
    (error) => throw error,
    (property) => property,
  );
});

/// Booking Details Provider - provides detailed booking information
final bookingDetailsProvider = FutureProvider.family<Booking, String>((ref, bookingId) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final result = await bookingRepository.getBookingDetails(bookingId);
  
  return result.fold(
    (error) => throw error,
    (booking) => booking,
  );
});

/// User Profile Provider - provides user profile information
final userProfileProvider = FutureProvider<User>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final result = await userRepository.getUserProfile();
  
  return result.fold(
    (error) => throw error,
    (user) => user,
  );
});

/// Property Availability Provider - provides property availability information
final propertyAvailabilityProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  // TODO: Implement when PropertyRepository.getPropertyAvailability is fixed
  // For now, return empty availability
  return <String, dynamic>{};
});

/// Featured Properties Provider - provides featured properties
final featuredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.getFeaturedProperties();
  
  return result.fold(
    (error) => throw error,
    (properties) => properties,
  );
});

/// Trending Destinations Provider - provides trending destinations
final trendingDestinationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: Implement when TrendingDestination model is properly integrated
  // For now, return empty list
  return <Map<String, dynamic>>[];
});

/// Create Booking Provider - handles booking creation
final createBookingProvider = FutureProvider.family<Booking, CreateBookingDto>((ref, bookingData) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final result = await bookingRepository.createBooking(bookingData);
  
  return result.fold(
    (error) => throw error,
    (booking) => booking,
  );
});

/// Similar Properties Provider - provides similar properties
final similarPropertiesProvider = FutureProvider.family<List<Property>, String>((ref, propertyId) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.getSimilarProperties(propertyId);
  
  return result.fold(
    (error) => throw error,
    (properties) => properties,
  );
});

/// Property Reviews Provider - provides property reviews
final propertyReviewsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, propertyId) async {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final result = await propertyRepository.getPropertyReviews(propertyId);
  
  return result.fold(
    (error) => throw error,
    (reviews) => reviews,
  );
});

/// State notifier for managing loading states and errors
class AsyncNotifierState<T> {
  final bool isLoading;
  final T? data;
  final String? error;

  const AsyncNotifierState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  AsyncNotifierState<T> copyWith({
    bool? isLoading,
    T? data,
    String? error,
  }) {
    return AsyncNotifierState<T>(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

/// Generic async notifier for handling async operations
class AsyncNotifier<T> extends StateNotifier<AsyncNotifierState<T>> {
  AsyncNotifier() : super(const AsyncNotifierState());

  Future<void> execute(Future<T> Function() operation) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await operation();
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const AsyncNotifierState();
  }
}
