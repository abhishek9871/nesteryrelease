import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OyoService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final OyoService _instance = OyoService._internal();

  factory OyoService() {
    return _instance;
  }

  OyoService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.baseUrl = 'https://partner-api.oyorooms.com/v2';
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
        final apiKey = dotenv.env['OYO_API_KEY'] ?? Constants.oyoApiKey;
        options.headers['X-API-KEY'] = apiKey;

        // Add partner ID to all requests
        final partnerId = dotenv.env['OYO_PARTNER_ID'] ?? Constants.oyoPartnerId;
        options.headers['X-PARTNER-ID'] = partnerId;

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
        '/hotels/search',
        queryParameters: {
          'city': location,
          'check_in': _formatDate(checkInDate),
          'check_out': _formatDate(checkOutDate),
          'guests': adults + (children ?? 0),
          'rooms': rooms ?? 1,
          'price_min': minPrice,
          'price_max': maxPrice,
          'amenities': amenities?.join(','),
          'category': propertyType,
          'rating_min': minRating,
          'include_details': true,
        },
      );

      return response.data;
    } on DioException catch (e) {
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'searchHotels',
          params: {
            'location': location,
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'adults': adults,
            'children': children,
            'rooms': rooms,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'amenities': amenities,
            'propertyType': propertyType,
            'minRating': minRating,
          },
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to search hotels: $e', statusCode: 500);
    }
  }

  // Get hotel details
  Future<Map<String, dynamic>> getHotelDetails({
    required String hotelId,
  }) async {
    try {
      final response = await _dio.get(
        '/hotels/$hotelId',
        queryParameters: {
          'include_rooms': true,
          'include_amenities': true,
          'include_photos': true,
          'include_policies': true,
        },
      );

      return response.data;
    } on DioException catch (e) {
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'getHotelDetails',
          params: {
            'hotelId': hotelId,
          },
        );
      }
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
  }) async {
    try {
      final response = await _dio.get(
        '/hotels/$hotelId/availability',
        queryParameters: {
          'check_in': _formatDate(checkInDate),
          'check_out': _formatDate(checkOutDate),
          'guests': adults + (children ?? 0),
          'rooms': rooms ?? 1,
        },
      );

      return response.data;
    } on DioException catch (e) {
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'getRoomAvailability',
          params: {
            'hotelId': hotelId,
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'adults': adults,
            'children': children,
            'rooms': rooms,
          },
        );
      }
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
  }) async {
    try {
      final response = await _dio.post(
        '/bookings',
        data: {
          'hotel_id': hotelId,
          'room_id': roomId,
          'check_in': _formatDate(checkInDate),
          'check_out': _formatDate(checkOutDate),
          'guests': adults + (children ?? 0),
          'rooms': rooms ?? 1,
          'guest_details': {
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone,
          },
          'special_requests': specialRequests,
        },
      );

      return response.data;
    } on DioException catch (e) {
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'createBooking',
          params: {
            'hotelId': hotelId,
            'roomId': roomId,
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'adults': adults,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phone': phone,
            'children': children,
            'rooms': rooms,
            'specialRequests': specialRequests,
          },
        );
      }
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
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'getBookingDetails',
          params: {
            'bookingId': bookingId,
          },
        );
      }
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
      // Fallback to B2B aggregator if OYO API fails
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return _fallbackToAggregator(
          method: 'cancelBooking',
          params: {
            'bookingId': bookingId,
          },
        );
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to cancel booking: $e', statusCode: 500);
    }
  }

  // Fallback to B2B aggregator
  Future<Map<String, dynamic>> _fallbackToAggregator({
    required String method,
    required Map<String, dynamic> params,
  }) async {
    // Create a new Dio instance for the aggregator
    final aggregatorDio = Dio();
    aggregatorDio.options.baseUrl = 'https://api.hotelbeds.com/hotel-api/1.0';
    aggregatorDio.options.connectTimeout = const Duration(seconds: 10);
    aggregatorDio.options.receiveTimeout = const Duration(seconds: 10);
    aggregatorDio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add API key and secret to all requests
    final apiKey = dotenv.env['HOTELBEDS_API_KEY'] ?? Constants.hotelbedsApiKey;
    final apiSecret = dotenv.env['HOTELBEDS_API_SECRET'] ?? Constants.hotelbedsApiSecret;

    // Generate signature (X-Signature) based on API key, secret, and timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateSignature(apiKey, apiSecret, timestamp);

    aggregatorDio.options.headers['Api-Key'] = apiKey;
    aggregatorDio.options.headers['X-Signature'] = signature;

    try {
      // Map OYO method to Hotelbeds method
      switch (method) {
        case 'searchHotels':
          final response = await aggregatorDio.post(
            '/hotels',
            data: {
              'stay': {
                'checkIn': _formatDate(params['checkInDate']),
                'checkOut': _formatDate(params['checkOutDate']),
              },
              'occupancies': [
                {
                  'rooms': params['rooms'] ?? 1,
                  'adults': params['adults'],
                  'children': params['children'] ?? 0,
                }
              ],
              'destination': {
                'code': params['location'],
              },
              'filter': {
                'minRate': params['minPrice'],
                'maxRate': params['maxPrice'],
                'minCategory': params['minRating'] != null ? (params['minRating'] * 2).round() : null,
                'amenities': params['amenities'],
              },
            },
          );
          return _mapHotelbedsToOyoResponse(response.data, 'searchHotels');

        case 'getHotelDetails':
          final response = await aggregatorDio.get(
            '/hotels/${params['hotelId']}',
          );
          return _mapHotelbedsToOyoResponse(response.data, 'getHotelDetails');

        case 'getRoomAvailability':
          final response = await aggregatorDio.post(
            '/hotels',
            data: {
              'stay': {
                'checkIn': _formatDate(params['checkInDate']),
                'checkOut': _formatDate(params['checkOutDate']),
              },
              'occupancies': [
                {
                  'rooms': params['rooms'] ?? 1,
                  'adults': params['adults'],
                  'children': params['children'] ?? 0,
                }
              ],
              'hotels': {
                'hotel': [params['hotelId']],
              },
            },
          );
          return _mapHotelbedsToOyoResponse(response.data, 'getRoomAvailability');

        case 'createBooking':
          final response = await aggregatorDio.post(
            '/bookings',
            data: {
              'holder': {
                'name': params['firstName'],
                'surname': params['lastName'],
                'email': params['email'],
                'phone': params['phone'],
              },
              'rooms': [
                {
                  'rateKey': params['roomId'],
                  'paxes': [
                    {
                      'roomId': 1,
                      'type': 'AD',
                      'name': params['firstName'],
                      'surname': params['lastName'],
                    }
                  ],
                }
              ],
              'clientReference': 'NESTERY-${DateTime.now().millisecondsSinceEpoch}',
              'remark': params['specialRequests'],
            },
          );
          return _mapHotelbedsToOyoResponse(response.data, 'createBooking');

        case 'getBookingDetails':
          final response = await aggregatorDio.get(
            '/bookings/${params['bookingId']}',
          );
          return _mapHotelbedsToOyoResponse(response.data, 'getBookingDetails');

        case 'cancelBooking':
          final response = await aggregatorDio.delete(
            '/bookings/${params['bookingId']}',
          );
          return _mapHotelbedsToOyoResponse(response.data, 'cancelBooking');

        default:
          throw ApiException(message: 'Unsupported method: $method', statusCode: 400);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to fallback to aggregator: $e', statusCode: 500);
    }
  }

  // Map Hotelbeds response to OYO response format
  Map<String, dynamic> _mapHotelbedsToOyoResponse(Map<String, dynamic> data, String method) {
    // This is a simplified mapping, in a real implementation this would be more comprehensive
    switch (method) {
      case 'searchHotels':
        return {
          'status': 'success',
          'hotels': data['hotels']['hotels'].map((hotel) => {
            'id': hotel['code'],
            'name': hotel['name'],
            'description': hotel['description'],
            'address': hotel['address'],
            'city': hotel['city'],
            'country': hotel['country'],
            'rating': hotel['categoryCode'] / 2,
            'price': hotel['minRate'],
            'currency': hotel['currency'],
            'images': hotel['images'],
            'amenities': hotel['facilities'],
          }).toList(),
        };

      case 'getHotelDetails':
        final hotel = data['hotel'];
        return {
          'status': 'success',
          'hotel': {
            'id': hotel['code'],
            'name': hotel['name'],
            'description': hotel['description'],
            'address': hotel['address'],
            'city': hotel['city'],
            'country': hotel['country'],
            'rating': hotel['categoryCode'] / 2,
            'images': hotel['images'],
            'amenities': hotel['facilities'],
            'rooms': hotel['rooms'],
            'policies': hotel['policies'],
          },
        };

      case 'getRoomAvailability':
        return {
          'status': 'success',
          'rooms': data['hotels']['hotels'][0]['rooms'].map((room) => {
            'id': room['code'],
            'name': room['name'],
            'description': room['description'],
            'price': room['rates'][0]['net'],
            'currency': room['rates'][0]['currency'],
            'capacity': room['capacity'],
            'amenities': room['facilities'],
          }).toList(),
        };

      case 'createBooking':
        return {
          'status': 'success',
          'booking': {
            'id': data['booking']['reference'],
            'hotel_id': data['booking']['hotel']['code'],
            'room_id': data['booking']['rooms'][0]['code'],
            'check_in': data['booking']['hotel']['checkIn'],
            'check_out': data['booking']['hotel']['checkOut'],
            'guest_name': '${data['booking']['holder']['name']} ${data['booking']['holder']['surname']}',
            'guest_email': data['booking']['holder']['email'],
            'guest_phone': data['booking']['holder']['phone'],
            'status': 'confirmed',
            'total_price': data['booking']['totalNet'],
            'currency': data['booking']['currency'],
          },
        };

      case 'getBookingDetails':
        return {
          'status': 'success',
          'booking': {
            'id': data['booking']['reference'],
            'hotel_id': data['booking']['hotel']['code'],
            'room_id': data['booking']['rooms'][0]['code'],
            'check_in': data['booking']['hotel']['checkIn'],
            'check_out': data['booking']['hotel']['checkOut'],
            'guest_name': '${data['booking']['holder']['name']} ${data['booking']['holder']['surname']}',
            'guest_email': data['booking']['holder']['email'],
            'guest_phone': data['booking']['holder']['phone'],
            'status': data['booking']['status'],
            'total_price': data['booking']['totalNet'],
            'currency': data['booking']['currency'],
          },
        };

      case 'cancelBooking':
        return {
          'status': 'success',
          'message': 'Booking cancelled successfully',
          'booking_id': data['booking']['reference'],
          'cancellation_fee': data['booking']['cancellationFee'],
          'refund_amount': data['booking']['refundAmount'],
        };

      default:
        return data;
    }
  }

  // Generate signature for Hotelbeds API
  String _generateSignature(String apiKey, String apiSecret, String timestamp) {
    // In a real implementation, this would use a proper hashing algorithm
    // For now, we'll just return a placeholder
    return 'signature-placeholder';
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
