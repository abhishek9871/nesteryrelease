import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';

/// Service to check backend health and connectivity
class BackendHealthService {
  final Dio _dio;

  BackendHealthService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Check if the Railway backend is healthy and accessible
  Future<BackendHealthStatus> checkBackendHealth() async {
    try {
      // Remove /v1 from base URL for health check since it's excluded from prefix
      final healthUrl = Constants.apiBaseUrl.replaceAll('/v1', '') + Constants.healthEndpoint;
      
      final response = await _dio.get(healthUrl);
      
      if (response.statusCode == 200) {
        final data = response.data;
        return BackendHealthStatus(
          isHealthy: true,
          status: data['status'] ?? 'unknown',
          version: data['version'] ?? 'unknown',
          database: data['database'] ?? 'unknown',
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
          message: 'Backend is healthy and operational',
        );
      } else {
        return BackendHealthStatus(
          isHealthy: false,
          status: 'error',
          message: 'Backend returned status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout - Backend may be starting up';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout - Backend is slow to respond';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error - Check internet connection';
      } else {
        errorMessage = 'Backend error: ${e.message}';
      }
      
      return BackendHealthStatus(
        isHealthy: false,
        status: 'error',
        message: errorMessage,
      );
    } catch (e) {
      return BackendHealthStatus(
        isHealthy: false,
        status: 'error',
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Test API connectivity with a simple endpoint
  Future<bool> testApiConnectivity() async {
    try {
      final healthStatus = await checkBackendHealth();
      return healthStatus.isHealthy;
    } catch (e) {
      return false;
    }
  }
}

/// Backend health status model
class BackendHealthStatus {
  final bool isHealthy;
  final String status;
  final String? version;
  final String? database;
  final String? timestamp;
  final String message;

  BackendHealthStatus({
    required this.isHealthy,
    required this.status,
    this.version,
    this.database,
    this.timestamp,
    required this.message,
  });

  @override
  String toString() {
    return 'BackendHealthStatus(isHealthy: $isHealthy, status: $status, database: $database, message: $message)';
  }
}

/// Provider for backend health service
final backendHealthServiceProvider = Provider<BackendHealthService>((ref) {
  return BackendHealthService();
});

/// Provider for backend health status
final backendHealthStatusProvider = FutureProvider<BackendHealthStatus>((ref) async {
  final healthService = ref.read(backendHealthServiceProvider);
  return await healthService.checkBackendHealth();
});
