import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Singleton pattern
  static final GoogleMapsService _instance = GoogleMapsService._internal();
  
  factory GoogleMapsService() {
    return _instance;
  }
  
  GoogleMapsService._internal() {
    _initializeDio();
  }
  
  void _initializeDio() {
    _dio.options.baseUrl = 'https://maps.googleapis.com/maps/api';
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
        final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? AppConstants.googleMapsApiKey;
        options.queryParameters['key'] = apiKey;
        
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
  
  // Geocode an address to get coordinates
  Future<Map<String, dynamic>> geocodeAddress(String address) async {
    try {
      final response = await _dio.get(
        '/geocode/json',
        queryParameters: {
          'address': address,
        },
      );
      
      if (response.data['status'] != 'OK') {
        throw ApiException(message: 'Geocoding failed: ${response.data['status']}');
      }
      
      final results = response.data['results'];
      if (results.isEmpty) {
        throw ApiException(message: 'No results found for address: $address');
      }
      
      final location = results[0]['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
        'formatted_address': results[0]['formatted_address'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to geocode address: $e');
    }
  }
  
  // Reverse geocode coordinates to get address
  Future<Map<String, dynamic>> reverseGeocode(LatLng coordinates) async {
    try {
      final response = await _dio.get(
        '/geocode/json',
        queryParameters: {
          'latlng': '${coordinates.latitude},${coordinates.longitude}',
        },
      );
      
      if (response.data['status'] != 'OK') {
        throw ApiException(message: 'Reverse geocoding failed: ${response.data['status']}');
      }
      
      final results = response.data['results'];
      if (results.isEmpty) {
        throw ApiException(message: 'No results found for coordinates: $coordinates');
      }
      
      return {
        'formatted_address': results[0]['formatted_address'],
        'address_components': results[0]['address_components'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to reverse geocode: $e');
    }
  }
  
  // Get directions between two points
  Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
    List<LatLng>? waypoints,
    bool alternatives = false,
    String units = 'metric',
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get(
        '/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': mode,
          'alternatives': alternatives.toString(),
          'units': units,
          'language': language,
          'waypoints': waypoints != null
              ? waypoints.map((point) => '${point.latitude},${point.longitude}').join('|')
              : null,
        },
      );
      
      if (response.data['status'] != 'OK') {
        throw ApiException(message: 'Directions request failed: ${response.data['status']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get directions: $e');
    }
  }
  
  // Get places nearby
  Future<Map<String, dynamic>> getNearbyPlaces({
    required LatLng location,
    required double radius,
    String? type,
    String? keyword,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get(
        '/place/nearbysearch/json',
        queryParameters: {
          'location': '${location.latitude},${location.longitude}',
          'radius': radius.toString(),
          'type': type,
          'keyword': keyword,
          'language': language,
        },
      );
      
      if (response.data['status'] != 'OK' && response.data['status'] != 'ZERO_RESULTS') {
        throw ApiException(message: 'Nearby places request failed: ${response.data['status']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get nearby places: $e');
    }
  }
  
  // Get place details
  Future<Map<String, dynamic>> getPlaceDetails({
    required String placeId,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get(
        '/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'language': language,
          'fields': 'name,formatted_address,geometry,photos,rating,reviews,types,website,formatted_phone_number,opening_hours',
        },
      );
      
      if (response.data['status'] != 'OK') {
        throw ApiException(message: 'Place details request failed: ${response.data['status']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get place details: $e');
    }
  }
  
  // Get distance matrix
  Future<Map<String, dynamic>> getDistanceMatrix({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    String mode = 'driving',
    String units = 'metric',
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get(
        '/distancematrix/json',
        queryParameters: {
          'origins': origins.map((point) => '${point.latitude},${point.longitude}').join('|'),
          'destinations': destinations.map((point) => '${point.latitude},${point.longitude}').join('|'),
          'mode': mode,
          'units': units,
          'language': language,
        },
      );
      
      if (response.data['status'] != 'OK') {
        throw ApiException(message: 'Distance matrix request failed: ${response.data['status']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get distance matrix: $e');
    }
  }
  
  // Get autocomplete predictions
  Future<Map<String, dynamic>> getPlaceAutocomplete({
    required String input,
    String? sessionToken,
    LatLng? location,
    double? radius,
    String? types,
    String? components,
    bool strictbounds = false,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get(
        '/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'sessiontoken': sessionToken,
          'location': location != null ? '${location.latitude},${location.longitude}' : null,
          'radius': radius?.toString(),
          'types': types,
          'components': components,
          'strictbounds': strictbounds.toString(),
          'language': language,
        },
      );
      
      if (response.data['status'] != 'OK' && response.data['status'] != 'ZERO_RESULTS') {
        throw ApiException(message: 'Place autocomplete request failed: ${response.data['status']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get place autocomplete: $e');
    }
  }
  
  // Get static map image URL
  String getStaticMapUrl({
    required LatLng center,
    required int zoom,
    required int width,
    required int height,
    List<Map<String, dynamic>>? markers,
    List<Map<String, dynamic>>? paths,
    String mapType = 'roadmap',
    String format = 'png',
    String language = 'en',
  }) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? AppConstants.googleMapsApiKey;
    
    String url = 'https://maps.googleapis.com/maps/api/staticmap?';
    url += 'center=${center.latitude},${center.longitude}';
    url += '&zoom=$zoom';
    url += '&size=${width}x$height';
    url += '&maptype=$mapType';
    url += '&format=$format';
    url += '&language=$language';
    
    // Add markers
    if (markers != null && markers.isNotEmpty) {
      for (final marker in markers) {
        url += '&markers=';
        if (marker['color'] != null) url += 'color:${marker['color']}|';
        if (marker['label'] != null) url += 'label:${marker['label']}|';
        url += '${marker['lat']},${marker['lng']}';
      }
    }
    
    // Add paths
    if (paths != null && paths.isNotEmpty) {
      for (final path in paths) {
        url += '&path=';
        if (path['color'] != null) url += 'color:${path['color']}|';
        if (path['weight'] != null) url += 'weight:${path['weight']}|';
        
        final points = path['points'] as List<LatLng>;
        url += points.map((point) => '${point.latitude},${point.longitude}').join('|');
      }
    }
    
    url += '&key=$apiKey';
    
    return url;
  }
  
  // Get route using the new Routes API (replacing Directions API)
  Future<Map<String, dynamic>> getRoute({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'DRIVE',
    List<LatLng>? intermediates,
    String routingPreference = 'TRAFFIC_AWARE',
    String units = 'METRIC',
    String language = 'en',
  }) async {
    try {
      // Note: Routes API uses POST instead of GET
      final response = await _dio.post(
        '/routes/v2:computeRoutes',
        data: {
          'origin': {
            'location': {
              'latLng': {
                'latitude': origin.latitude,
                'longitude': origin.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': destination.latitude,
                'longitude': destination.longitude,
              },
            },
          },
          'travelMode': travelMode,
          'routingPreference': routingPreference,
          'computeAlternativeRoutes': true,
          'routeModifiers': {
            'avoidTolls': false,
            'avoidHighways': false,
            'avoidFerries': false,
          },
          'languageCode': language,
          'units': units,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to get route: $e');
    }
  }
}
