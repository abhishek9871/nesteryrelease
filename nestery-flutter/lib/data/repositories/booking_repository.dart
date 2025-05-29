import 'package:dio/dio.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/search_dtos.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/either.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get user bookings
  Future<Either<ApiException, List<Booking>>> getUserBookings({
    BookingStatus? status,
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = _bookingStatusToString(status);
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.bookingsEndpoint,
        queryParameters: queryParams,
      );

      if (response.data != null && response.data!['data'] != null) {
        final bookings = (response.data!['data'] as List)
            .map((json) => Booking.fromJson(json))
            .toList();
        return Either.right(bookings);
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

  // Get booking details
  Future<Either<ApiException, Booking>> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${Constants.bookingsEndpoint}/$bookingId',
      );

      if (response.data != null) {
        final booking = Booking.fromJson(response.data!);
        return Either.right(booking);
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

  // Create booking - Updated to handle Booking.com redirect flow
  Future<Either<ApiException, dynamic>> createBooking(CreateBookingDto bookingData) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.bookingsEndpoint,
        data: bookingData.toJson(),
      );

      if (response.data != null) {
        // Check if response contains redirect URL (for Booking.com)
        if (response.data!.containsKey('redirectUrl') && response.data!.containsKey('sourceType')) {
          // Return redirect response for Booking.com
          return Either.right({
            'redirectUrl': response.data!['redirectUrl'],
            'sourceType': response.data!['sourceType'],
          });
        } else {
          // Return normal booking for other OTAs
          final booking = Booking.fromJson(response.data!);
          return Either.right(booking);
        }
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

  // Cancel booking
  Future<Either<ApiException, Booking>> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '${Constants.bookingsEndpoint}/$bookingId/cancel',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.data != null) {
        final booking = Booking.fromJson(response.data!);
        return Either.right(booking);
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

  // Update booking
  Future<Either<ApiException, Booking>> updateBooking(String bookingId, UpdateBookingDto updateData) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '${Constants.bookingsEndpoint}/$bookingId',
        data: updateData.toJson(),
      );

      if (response.data != null) {
        final booking = Booking.fromJson(response.data!);
        return Either.right(booking);
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
