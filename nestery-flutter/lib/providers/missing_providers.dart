import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/models/search_dtos.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';
import 'package:nestery_flutter/data/repositories/booking_repository.dart';

/// Missing providers that are referenced in UI but not yet implemented

/// User Bookings State
class UserBookingsState {
  final bool isLoading;
  final String? error;
  final List<Booking> upcomingBookings;
  final List<Booking> pastBookings;
  final List<Booking> cancelledBookings;

  const UserBookingsState({
    this.isLoading = false,
    this.error,
    this.upcomingBookings = const [],
    this.pastBookings = const [],
    this.cancelledBookings = const [],
  });

  UserBookingsState copyWith({
    bool? isLoading,
    String? error,
    List<Booking>? upcomingBookings,
    List<Booking>? pastBookings,
    List<Booking>? cancelledBookings,
  }) {
    return UserBookingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
    );
  }
}

/// User Bookings Notifier
class UserBookingsNotifier extends StateNotifier<UserBookingsState> {
  final BookingRepository _bookingRepository;

  UserBookingsNotifier(this._bookingRepository) : super(const UserBookingsState());

  Future<void> loadUserBookings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all bookings
      final upcomingResult = await _bookingRepository.getUserBookings(status: BookingStatus.confirmed);
      final pastResult = await _bookingRepository.getUserBookings(status: BookingStatus.completed);
      final cancelledResult = await _bookingRepository.getUserBookings(status: BookingStatus.cancelled);

      final upcoming = upcomingResult.fold((error) => <Booking>[], (bookings) => bookings);
      final past = pastResult.fold((error) => <Booking>[], (bookings) => bookings);
      final cancelled = cancelledResult.fold((error) => <Booking>[], (bookings) => bookings);

      state = state.copyWith(
        isLoading: false,
        upcomingBookings: upcoming,
        pastBookings: past,
        cancelledBookings: cancelled,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// User Bookings Provider - provides list of user's bookings
final userBookingsProvider = StateNotifierProvider<UserBookingsNotifier, UserBookingsState>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return UserBookingsNotifier(bookingRepository);
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

/// Cancel Booking State Notifier
class CancelBookingNotifier extends AsyncNotifier<bool> {
  late BookingRepository _bookingRepository;

  void setRepository(BookingRepository repository) {
    _bookingRepository = repository;
  }

  Future<bool> cancelBooking(String bookingId) async {
    await execute(() async {
      final result = await _bookingRepository.cancelBooking(bookingId);
      return result.fold(
        (error) => throw error,
        (booking) => true,
      );
    });
    return state.data ?? false;
  }
}

/// Cancel Booking Provider - handles booking cancellation
final cancelBookingProvider = StateNotifierProvider<CancelBookingNotifier, AsyncNotifierState<bool>>((ref) {
  final notifier = CancelBookingNotifier();
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  notifier.setRepository(bookingRepository);
  return notifier;
});

/// Submit Review State Notifier
class SubmitReviewNotifier extends AsyncNotifier<bool> {
  Future<bool> submitReview({
    required String bookingId,
    required String propertyId,
    required double rating,
    required String comment,
  }) async {
    await execute(() async {
      // TODO: Implement review submission when ReviewRepository is created
      // For now, simulate success
      await Future.delayed(const Duration(seconds: 1));
      return true;
    });
    return state.data ?? false;
  }
}

/// Submit Review Provider - handles review submission
final submitReviewProvider = StateNotifierProvider<SubmitReviewNotifier, AsyncNotifierState<bool>>((ref) {
  return SubmitReviewNotifier();
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
