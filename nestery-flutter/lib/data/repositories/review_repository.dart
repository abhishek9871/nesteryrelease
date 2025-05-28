import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/models/review.dart';
import 'package:dio/dio.dart';

class ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Submit a new review for a property
  Future<Either<ApiException, Review>> submitReview({
    required String propertyId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        return Either.left(ApiException(
          message: 'Rating must be between 1 and 5',
          statusCode: 400,
        ));
      }

      // Validate comment length
      if (comment.trim().isEmpty) {
        return Either.left(ApiException(
          message: 'Comment cannot be empty',
          statusCode: 400,
        ));
      }

      if (comment.length > 1000) {
        return Either.left(ApiException(
          message: 'Comment cannot exceed 1000 characters',
          statusCode: 400,
        ));
      }

      final requestData = {
        'propertyId': propertyId,
        'rating': rating,
        'comment': comment.trim(),
        if (bookingId != null) 'bookingId': bookingId,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        Constants.reviewsEndpoint,
        data: requestData,
      );

      if (response.data != null) {
        final review = Review.fromJson(response.data!);
        return Either.right(review);
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

  /// Get reviews for a specific property
  Future<Either<ApiException, Map<String, dynamic>>> getPropertyReviews(
    String propertyId, {
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.reviewsEndpoint,
        queryParameters: {
          'propertyId': propertyId,
          'page': page,
          'limit': limit,
        },
      );

      if (response.data != null) {
        return Either.right(response.data!);
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

  /// Get reviews by user
  Future<Either<ApiException, Map<String, dynamic>>> getUserReviews({
    int page = 1,
    int limit = Constants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        Constants.reviewsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data != null) {
        return Either.right(response.data!);
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

  /// Update an existing review
  Future<Either<ApiException, Review>> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        return Either.left(ApiException(
          message: 'Rating must be between 1 and 5',
          statusCode: 400,
        ));
      }

      // Validate comment length
      if (comment.trim().isEmpty) {
        return Either.left(ApiException(
          message: 'Comment cannot be empty',
          statusCode: 400,
        ));
      }

      if (comment.length > 1000) {
        return Either.left(ApiException(
          message: 'Comment cannot exceed 1000 characters',
          statusCode: 400,
        ));
      }

      final requestData = {
        'rating': rating,
        'comment': comment.trim(),
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        '${Constants.reviewsEndpoint}/$reviewId',
        data: requestData,
      );

      if (response.data != null) {
        final review = Review.fromJson(response.data!);
        return Either.right(review);
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

  /// Delete a review
  Future<Either<ApiException, bool>> deleteReview(String reviewId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${Constants.reviewsEndpoint}/$reviewId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Either.right(true);
      } else {
        return Either.left(ApiException(
          message: 'Failed to delete review',
          statusCode: response.statusCode ?? 500,
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
}
