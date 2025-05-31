import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Cache specific fields
  late final DriftCacheStore _cacheStore;
  late final DioCacheInterceptor dioCacheInterceptor;

  ApiClient._internal({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio();
    _setupDio();
    _setupInterceptors();
  }

  factory ApiClient({FlutterSecureStorage? secureStorage}) {
    _instance ??= ApiClient._internal(secureStorage: secureStorage);
    return _instance!;
  }

  DriftCacheStore get cacheStore => _cacheStore;

  /// Initializes the cache. Must be called after ApiClient instantiation and before first API call.
  Future<void> initializeCache() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, Constants.cacheDbName);

    _cacheStore = DriftCacheStore(
      databasePath: dbPath,
    );

    final globalCacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request, // Default policy
      maxStale: Constants.defaultCacheTTL, // Default TTL for cached items
      hitCacheOnErrorCodes: [500], // Use cache on error for these codes
      hitCacheOnNetworkFailure: true, // Use cache on network failure
      priority: CachePriority.normal,
      cipher: null, // No encryption by default
      keyBuilder: CacheOptions.defaultCacheKeyBuilder, // Default cache key builder
    );

    dioCacheInterceptor = DioCacheInterceptor(options: globalCacheOptions);
    _dio.interceptors.add(dioCacheInterceptor);
  }

  void _setupDio() {
    _dio.options.baseUrl = Constants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: Constants.connectionTimeout);
    _dio.options.receiveTimeout = const Duration(milliseconds: Constants.receiveTimeout);
    _dio.options.sendTimeout = const Duration(milliseconds: Constants.connectionTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void _setupInterceptors() {
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth for public endpoints
        final publicEndpoints = [
          Constants.loginEndpoint,
          Constants.registerEndpoint,
          Constants.refreshTokenEndpoint,
        ];

        if (!publicEndpoints.contains(options.path)) {
          final token = await _secureStorage.read(key: Constants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
      onError: (err, handler) {
        // Transform DioException to ApiException for consistent error handling
        final apiException = ApiException.fromDioError(err);

        // For 401 errors, we'll let the repository handle token refresh
        // This is a simplified approach - full token refresh logic would be more complex
        if (err.response?.statusCode == 401) {
          // Pass through 401 errors to be handled by the repository layer
          handler.next(err);
          return;
        }

        // Create a new DioException with the ApiException as the error
        final newError = DioException(
          requestOptions: err.requestOptions,
          error: apiException,
          response: err.response,
          type: err.type,
          message: apiException.message,
        );

        handler.next(newError);
      },
    ));

    // Add logging interceptor for development
    if (Constants.environment == 'development') {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ));
    }
  }

  // Generic request methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CachePolicy? cachePolicy, // Allow overriding cache policy per request
  }) async {
    Options effectiveOptions = options ?? Options();
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: effectiveOptions,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Clear stored tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: Constants.tokenKey);
    await _secureStorage.delete(key: Constants.refreshTokenKey);
  }
}
