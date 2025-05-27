import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/data/repositories/booking_repository.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

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

      final bookings = await _bookingRepository.getUserBookings(
        status: status ?? state.filterStatus,
        page: reset ? 1 : state.currentPage + 1,
      );

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
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
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
    try {
      state = BookingDetailsState(isLoading: true);

      final booking = await _bookingRepository.getBookingDetails(bookingId);

      state = state.copyWith(
        booking: booking,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cancel booking
  Future<bool> cancelBooking({String? reason}) async {
    try {
      if (state.booking == null) return false;

      state = state.copyWith(isLoading: true, error: null);

      final updatedBooking = await _bookingRepository.cancelBooking(
        state.booking!.id,
        reason: reason,
      );

      state = state.copyWith(
        booking: updatedBooking,
        isLoading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update booking
  Future<bool> updateBooking({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    String? specialRequests,
  }) async {
    try {
      if (state.booking == null) return false;

      state = state.copyWith(isLoading: true, error: null);

      final updatedBooking = await _bookingRepository.updateBooking(
        state.booking!.id,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        specialRequests: specialRequests,
      );

      state = state.copyWith(
        booking: updatedBooking,
        isLoading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
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

// Create booking state
class CreateBookingState {
  final Booking? booking;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CreateBookingState({
    this.booking,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  // Create a new instance with updated values
  CreateBookingState copyWith({
    Booking? booking,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CreateBookingState(
      booking: booking ?? this.booking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Create booking provider
class CreateBookingNotifier extends StateNotifier<CreateBookingState> {
  final BookingRepository _bookingRepository;

  CreateBookingNotifier({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(CreateBookingState());

  // Create booking
  Future<bool> createBooking({
    required String propertyId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    String? specialRequests,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      state = CreateBookingState(isLoading: true);

      final booking = await _bookingRepository.createBooking(
        propertyId: propertyId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        specialRequests: specialRequests,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
      );

      state = state.copyWith(
        booking: booking,
        isLoading: false,
        isSuccess: true,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isSuccess: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
      return false;
    }
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
  final apiClient = ref.watch(Provider<ApiClient>((ref) => ApiClient()));
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
