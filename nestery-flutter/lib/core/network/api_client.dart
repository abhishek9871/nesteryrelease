import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl = Constants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add request interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: Constants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        // Handle 401 Unauthorized errors (token expired)
        if (error.response?.statusCode == 401) {
          // Attempt to refresh token
          _refreshToken().then((success) {
            if (success) {
              // Retry the original request
              _dio.fetch(error.requestOptions).then(
                (response) => handler.resolve(response),
                onError: (e) => handler.reject(e),
              );
            } else {
              // Token refresh failed, propagate the error
              handler.next(error);
            }
          });
        } else {
          // Transform DioException to ApiException for consistent error handling
          final apiException = ApiException.fromDioError(error);
          handler.next(DioException(
            requestOptions: error.requestOptions,
            error: apiException,
            response: error.response,
            type: error.type,
            message: apiException.message,
          ));
        }
      },
    ));

    // Add logging interceptor for development
    if (Constants.environment == 'development') {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // POST request
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // PUT request
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // PATCH request
  Future<dynamic> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // DELETE request
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  // Token refresh logic
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: Constants.refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }

      // Create a new Dio instance to avoid interceptors loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data['accessToken'] != null) {
        await _secureStorage.write(
          key: Constants.tokenKey,
          value: response.data['accessToken'],
        );

        if (response.data['refreshToken'] != null) {
          await _secureStorage.write(
            key: Constants.refreshTokenKey,
            value: response.data['refreshToken'],
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      // If refresh fails, clear tokens and return false
      await _secureStorage.delete(key: Constants.tokenKey);
      await _secureStorage.delete(key: Constants.refreshTokenKey);
      return false;
    }
  }

  // Method to clear all auth tokens (for logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: Constants.tokenKey);
    await _secureStorage.delete(key: Constants.refreshTokenKey);
  }
}
