import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get user bookings
  Future<List<Booking>> getUserBookings({
    BookingStatus? status,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (status != null) {
        queryParams['status'] = _bookingStatusToString(status);
      }
      
      final response = await _apiClient.get(
        AppConstants.bookingsEndpoint,
        queryParameters: queryParams,
      );
      
      return (response['data'] as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Get booking details
  Future<Booking> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.bookingsEndpoint}/$bookingId',
      );
      
      return Booking.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Create booking
  Future<Booking> createBooking({
    required String propertyId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    String? specialRequests,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.bookingsEndpoint,
        data: {
          'propertyId': propertyId,
          'checkInDate': checkInDate.toIso8601String(),
          'checkOutDate': checkOutDate.toIso8601String(),
          'numberOfGuests': numberOfGuests,
          'specialRequests': specialRequests,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails,
        },
      );
      
      return Booking.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Cancel booking
  Future<Booking> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _apiClient.patch(
        '${AppConstants.bookingsEndpoint}/$bookingId/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      
      return Booking.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Update booking
  Future<Booking> updateBooking(
    String bookingId, {
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    String? specialRequests,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (checkInDate != null) data['checkInDate'] = checkInDate.toIso8601String();
      if (checkOutDate != null) data['checkOutDate'] = checkOutDate.toIso8601String();
      if (numberOfGuests != null) data['numberOfGuests'] = numberOfGuests;
      if (specialRequests != null) data['specialRequests'] = specialRequests;
      
      final response = await _apiClient.patch(
        '${AppConstants.bookingsEndpoint}/$bookingId',
        data: data,
      );
      
      return Booking.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Helper method to convert BookingStatus enum to string
  String _bookingStatusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }
}
