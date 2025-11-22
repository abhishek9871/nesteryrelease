import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Central error handling service for user-friendly error messages
class ErrorHandler {
  /// Get a user-friendly error message from any error
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      return _getDioErrorMessage(error);
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please check your internet connection and try again.';
    }

    // Generic error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get error message from Dio exception
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';

      case DioExceptionType.badResponse:
        return _getResponseErrorMessage(error.response);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'Network error occurred. Please try again.';
    }
  }

  /// Get error message from HTTP response
  static String _getResponseErrorMessage(Response? response) {
    if (response == null) {
      return 'Server error occurred. Please try again later.';
    }

    final statusCode = response.statusCode ?? 0;

    // Client errors (4xx)
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input and try again.';
        case 401:
          return 'Authentication required. Please log in again.';
        case 403:
          return 'Access denied. You don\'t have permission for this action.';
        case 404:
          return 'The requested resource was not found.';
        case 409:
          return 'Conflict occurred. This action cannot be completed.';
        case 422:
          return 'Validation error. Please check your input.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        default:
          return 'Request failed. Please try again.';
      }
    }

    // Server errors (5xx)
    if (statusCode >= 500) {
      return 'Server error occurred. Our team has been notified. Please try again later.';
    }

    return 'An error occurred. Please try again.';
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    final message = getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final message = getUserFriendlyMessage(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title ?? 'Error'),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }

  /// Check if error is a server error (5xx)
  static bool isServerError(dynamic error) {
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      return statusCode >= 500 && statusCode < 600;
    }
    return false;
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    return false;
  }
}
