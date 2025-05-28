import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingComService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final BookingComService _instance = BookingComService._internal();

  factory BookingComService() {
    return _instance;
  }

  BookingComService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.baseUrl = 'https://distribution-xml.booking.com/3.1';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors for logging, error handling, etc.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add API key to all requests
        final apiKey = dotenv.env['BOOKING_COM_API_KEY'] ?? Constants.bookingComApiKey;
        options.queryParameters['apiKey'] = apiKey;

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  // Search for hotels
  Future<Map<String, dynamic>> searchHotels({
    required String location,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adults,
    int? children,
    int? rooms,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? propertyType,
    double? minRating,
  }) async {
    try {
      final response = await _dio.get(
        '/hotels',
        queryParameters: {
          'city_ids': location,
          'checkin': _formatDate(checkInDate),
          'checkout': _formatDate(checkOutDate),
          'adults': adults,
          'children': children,
          'rooms': rooms ?? 1,
          'min_price': minPrice,
          'max_price': maxPrice,
          'amenities': amenities?.join(','),
          'property_type': propertyType,
          'min_rating': minRating,
          'extras': 'hotel_info,room_info,hotel_photos,hotel_facilities',
          'language': 'en-us',
          'currency': 'USD',
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to search hotels: $e', statusCode: 500);
    }
  }

  // Get hotel details
  Future<Map<String, dynamic>> getHotelDetails({
    required String hotelId,
    String? language,
    String? currency,
  }) async {
    try {
      final response = await _dio.get(
        '/hotels/$hotelId',
        queryParameters: {
          'extras': 'hotel_info,room_info,hotel_photos,hotel_facilities,hotel_policies,hotel_description',
          'language': language ?? 'en-us',
          'currency': currency ?? 'USD',
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get hotel details: $e', statusCode: 500);
    }
  }

  // Get room availability
  Future<Map<String, dynamic>> getRoomAvailability({
    required String hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adults,
    int? children,
    int? rooms,
    String? currency,
  }) async {
    try {
      final response = await _dio.get(
        '/hotels/$hotelId/availability',
        queryParameters: {
          'checkin': _formatDate(checkInDate),
          'checkout': _formatDate(checkOutDate),
          'adults': adults,
          'children': children,
          'rooms': rooms ?? 1,
          'currency': currency ?? 'USD',
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get room availability: $e', statusCode: 500);
    }
  }

  // Create booking
  Future<Map<String, dynamic>> createBooking({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adults,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    int? children,
    int? rooms,
    String? specialRequests,
    String? currency,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings',
        data: {
          'hotel_id': hotelId,
          'room_id': roomId,
          'checkin': _formatDate(checkInDate),
          'checkout': _formatDate(checkOutDate),
          'adults': adults,
          'children': children,
          'rooms': rooms ?? 1,
          'guest': {
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone,
          },
          'special_requests': specialRequests,
          'currency': currency ?? 'USD',
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to create booking: $e', statusCode: 500);
    }
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails({
    required String bookingId,
  }) async {
    try {
      final response = await _dio.get(
        '/bookings/$bookingId',
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get booking details: $e', statusCode: 500);
    }
  }

  // Cancel booking
  Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
  }) async {
    try {
      final response = await _dio.delete(
        '/bookings/$bookingId',
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to cancel booking: $e', statusCode: 500);
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
