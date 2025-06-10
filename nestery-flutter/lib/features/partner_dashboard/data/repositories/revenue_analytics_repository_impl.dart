import 'package:dio/dio.dart';
import '../../../../utils/api_exception.dart';
import '../../../../utils/either.dart';
import '../../../../core/network/api_client.dart';
import '../models/revenue_metrics_model.dart';
import 'revenue_analytics_repository.dart';

class RevenueAnalyticsRepositoryImpl implements RevenueAnalyticsRepository {
  final ApiClient _apiClient;

  RevenueAnalyticsRepositoryImpl(this._apiClient);

  @override
  Future<Either<ApiException, RevenueMetricsModel>> getPartnerRevenueMetrics({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/analytics/partner',
        queryParameters: {'days': days},
      );
      
      final metrics = RevenueMetricsModel.fromJson(response.data);
      return Either.right(metrics);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<RevenueTrendModel>>> getPartnerRevenueTrends({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/trends/partner',
        queryParameters: {'days': days},
      );

      final trends = (response.data as List)
          .map((json) => RevenueTrendModel.fromJson(json))
          .toList();
      return Either.right(trends);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<CommissionBatchModel>>> getCommissionBatches({
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/commission/batches',
        queryParameters: {'limit': limit},
      );

      final batches = (response.data as List)
          .map((json) => CommissionBatchModel.fromJson(json))
          .toList();
      return Either.right(batches);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, RevenueMetricsModel>> getRevenueSummary({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/analytics/summary',
        queryParameters: {'days': days},
      );

      final metrics = RevenueMetricsModel.fromJson(response.data);
      return Either.right(metrics);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<PartnerPerformanceModel>>> getPartnerPerformance({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/partner/performance',
        queryParameters: {'limit': limit},
      );

      final performance = (response.data as List)
          .map((json) => PartnerPerformanceModel.fromJson(json))
          .toList();
      return Either.right(performance);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<RevenueTrendModel>>> getRevenueTrends({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/trends',
        queryParameters: {'days': days},
      );

      final trends = (response.data as List)
          .map((json) => RevenueTrendModel.fromJson(json))
          .toList();
      return Either.right(trends);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> processCommissions() async {
    try {
      final response = await _apiClient.post('/v1/revenue/commission/process');
      return Either.right(response.data);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, Map<String, String>>> clearAnalyticsCache() async {
    try {
      final response = await _apiClient.post('/v1/revenue/analytics/cache/clear');
      return Either.right(Map<String, String>.from(response.data));
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }
}
