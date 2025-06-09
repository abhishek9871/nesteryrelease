import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/data/repositories/booking_repository.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/models/search_dtos.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

// Booking state
class BookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final BookingStatus? filterStatus;

  BookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.filterStatus,
  });

  // Create a new instance with updated values
  BookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    BookingStatus? filterStatus,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

// Bookings provider
class BookingsNotifier extends StateNotifier<BookingsState> {
  final BookingRepository _bookingRepository;

  BookingsNotifier({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingsState());

  // Load user bookings
  Future<void> loadBookings({
    BookingStatus? status,
    bool reset = true,
  }) async {
    try {
      // If reset is true, start a new search
      if (reset) {
        state = BookingsState(
          isLoading: true,
          filterStatus: status,
        );
      } else {
        // Otherwise, load more results
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final result = await _bookingRepository.getUserBookings(
        status: status ?? state.filterStatus,
        page: reset ? 1 : state.currentPage + 1,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (bookings) {
          // Update state with new results
          if (reset) {
            state = state.copyWith(
              bookings: bookings,
              isLoading: false,
              hasMore: bookings.length >= 10, // Assuming page size is 10
              currentPage: 1,
            );
          } else {
            state = state.copyWith(
              bookings: [...state.bookings, ...bookings],
              isLoading: false,
              hasMore: bookings.length >= 10, // Assuming page size is 10
              currentPage: state.currentPage + 1,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load more bookings
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    await loadBookings(
      status: state.filterStatus,
      reset: false,
    );
  }

  // Filter bookings by status
  Future<void> filterByStatus(BookingStatus? status) async {
    if (state.filterStatus == status && state.bookings.isNotEmpty) return;

    await loadBookings(status: status);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Booking details state
class BookingDetailsState {
  final Booking? booking;
  final bool isLoading;
  final String? error;

  BookingDetailsState({
    this.booking,
    this.isLoading = false,
    this.error,
  });

  // Create a new instance with updated values
  BookingDetailsState copyWith({
    Booking? booking,
    bool? isLoading,
    String? error,
  }) {
    return BookingDetailsState(
      booking: booking ?? this.booking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Booking details provider
class BookingDetailsNotifier extends StateNotifier<BookingDetailsState> {
  final BookingRepository _bookingRepository;

  BookingDetailsNotifier({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingDetailsState());

  // Load booking details
  Future<void> loadBookingDetails(String bookingId) async {
    state = BookingDetailsState(isLoading: true);

    final result = await _bookingRepository.getBookingDetails(bookingId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (booking) {
        state = state.copyWith(
          booking: booking,
          isLoading: false,
        );
      },
    );
  }

  // Cancel booking
  Future<bool> cancelBooking({String? reason}) async {
    if (state.booking == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _bookingRepository.cancelBooking(
      state.booking!.id,
      reason: reason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (updatedBooking) {
        state = state.copyWith(
          booking: updatedBooking,
          isLoading: false,
        );
        return true;
      },
    );
  }

  // Update booking
  Future<bool> updateBooking({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    String? specialRequests,
  }) async {
    if (state.booking == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    final updateDto = UpdateBookingDto(
      checkIn: checkInDate,
      checkOut: checkOutDate,
      guests: numberOfGuests,
      specialRequests: specialRequests,
    );

    final result = await _bookingRepository.updateBooking(
      state.booking!.id,
      updateDto,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (updatedBooking) {
        state = state.copyWith(
          booking: updatedBooking,
          isLoading: false,
        );
        return true;
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear state
  void clearState() {
    state = BookingDetailsState();
  }
}

// Create booking state - Updated to handle redirect flow
class CreateBookingState {
  final Booking? booking;
  final String? redirectUrl;
  final String? sourceType;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final bool isRedirect;

  CreateBookingState({
    this.booking,
    this.redirectUrl,
    this.sourceType,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.isRedirect = false,
  });

  // Create a new instance with updated values
  CreateBookingState copyWith({
    Booking? booking,
    String? redirectUrl,
    String? sourceType,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool? isRedirect,
  }) {
    return CreateBookingState(
      booking: booking ?? this.booking,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      sourceType: sourceType ?? this.sourceType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      isRedirect: isRedirect ?? this.isRedirect,
    );
  }
}

// Create booking provider
class CreateBookingNotifier extends StateNotifier<CreateBookingState> {
  final BookingRepository _bookingRepository;

  CreateBookingNotifier({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(CreateBookingState());

  // Create booking - Updated to handle Booking.com redirect flow
  Future<bool> createBooking({
    required String propertyId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String paymentMethod,
    String? specialRequests,
    Map<String, dynamic>? paymentDetails,
    String? sourceType,
  }) async {
    state = CreateBookingState(isLoading: true);

    final createDto = CreateBookingDto(
      propertyId: propertyId,
      checkIn: checkInDate,
      checkOut: checkOutDate,
      guests: numberOfGuests,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      paymentMethod: paymentMethod,
      specialRequests: specialRequests,
      cardDetails: paymentDetails,
      sourceType: sourceType,
    );

    final result = await _bookingRepository.createBooking(createDto);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isSuccess: false,
        );
        return false;
      },
      (response) {
        // Check if response is a redirect (for Booking.com)
        if (response is Map<String, dynamic> &&
            response.containsKey('redirectUrl') &&
            response.containsKey('sourceType')) {
          state = state.copyWith(
            redirectUrl: response['redirectUrl'],
            sourceType: response['sourceType'],
            isLoading: false,
            isSuccess: true,
            isRedirect: true,
          );
          return true;
        } else {
          // Normal booking response (for other OTAs)
          state = state.copyWith(
            booking: response as Booking,
            isLoading: false,
            isSuccess: true,
            isRedirect: false,
          );
          return true;
        }
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void resetState() {
    state = CreateBookingState();
  }
}

// Providers
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient: apiClient);
});

final bookingsProvider = StateNotifierProvider<BookingsNotifier, BookingsState>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return BookingsNotifier(bookingRepository: bookingRepository);
});

final bookingDetailsProvider = StateNotifierProvider.family<BookingDetailsNotifier, BookingDetailsState, String>((ref, bookingId) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final notifier = BookingDetailsNotifier(bookingRepository: bookingRepository);
  notifier.loadBookingDetails(bookingId);
  return notifier;
});

final createBookingProvider = StateNotifierProvider<CreateBookingNotifier, CreateBookingState>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return CreateBookingNotifier(bookingRepository: bookingRepository);
});
