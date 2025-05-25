import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final dynamic data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.code,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = 'An error occurred';
    int statusCode = 500;
    String? code;
    dynamic data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        statusCode = 408;
        code = 'timeout';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid SSL certificate. Please contact support.';
        statusCode = 495;
        code = 'bad_certificate';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode ?? 500;
        // Try to extract error message from response
        if (error.response?.data != null) {
          if (error.response!.data is Map) {
            message = error.response!.data['message'] ?? 
                     error.response!.data['error'] ?? 
                     'Server error';
            code = error.response!.data['code'];
            data = error.response!.data;
          } else if (error.response!.data is String) {
            message = error.response!.data;
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        statusCode = 499;
        code = 'cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        statusCode = 503;
        code = 'connection_error';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = 'No internet connection. Please check your network.';
          statusCode = 503;
          code = 'no_connection';
        } else {
          message = error.message ?? 'An unexpected error occurred';
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: code,
      data: data,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode, Code: $code)';
  }

  // Helper method to check if this is a network-related error
  bool get isNetworkError {
    return statusCode == 408 || 
           statusCode == 503 || 
           code == 'timeout' || 
           code == 'connection_error' || 
           code == 'no_connection';
  }

  // Helper method to check if this is an authentication error
  bool get isAuthError {
    return statusCode == 401 || statusCode == 403;
  }

  // Helper method to check if this is a server error
  bool get isServerError {
    return statusCode >= 500 && statusCode < 600;
  }

  // Helper method to check if this is a client error
  bool get isClientError {
    return statusCode >= 400 && statusCode < 500 && !isAuthError;
  }
}
