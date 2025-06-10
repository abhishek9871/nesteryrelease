import 'package:dio/dio.dart';
import '../../../../utils/api_exception.dart';
import '../../../../utils/either.dart';
import '../../../../core/network/api_client.dart';
import '../models/earnings_history_model.dart';
import 'commission_tracking_repository.dart';

class CommissionTrackingRepositoryImpl implements CommissionTrackingRepository {
  final ApiClient _apiClient;

  CommissionTrackingRepositoryImpl(this._apiClient);

  @override
  Future<Either<ApiException, List<EarningsHistoryModel>>> getEarningsHistory({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? offerId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (offerId != null) queryParams['offerId'] = offerId;

      final response = await _apiClient.get(
        '/v1/partners/earnings/history',
        queryParameters: queryParams,
      );

      final earnings = (response.data['data'] as List)
          .map((json) => EarningsHistoryModel.fromJson(json))
          .toList();
      
      return Either.right(earnings);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, UserAnalyticsModel>> getUserAnalytics({
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/revenue/analytics/partner',
        queryParameters: {'days': days},
      );

      // Transform the revenue metrics to user analytics format
      final data = response.data;
      final analytics = UserAnalyticsModel(
        totalEarnings: data['totalCommissions']?.toDouble() ?? 0.0,
        pendingEarnings: data['pendingCommissions']?.toDouble() ?? 0.0,
        paidEarnings: data['paidCommissions']?.toDouble() ?? 0.0,
        totalConversions: data['totalConversions'] ?? 0,
        conversionRate: data['conversionRate']?.toDouble() ?? 0.0,
        averageCommission: data['averageCommission']?.toDouble() ?? 0.0,
        clickCount: data['clickCount'] ?? 0,
        topPerformingOffer: data['topPerformingOffer'] != null
            ? OfferPerformanceModel.fromJson(data['topPerformingOffer'])
            : null,
        monthlyEarnings: (data['monthlyEarnings'] as List? ?? [])
            .map((json) => MonthlyEarningsModel.fromJson(json))
            .toList(),
      );

      return Either.right(analytics);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<PayoutRequestModel>>> getPayoutRequests({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/v1/partners/payouts',
        queryParameters: queryParams,
      );

      final payouts = (response.data['data'] as List)
          .map((json) => PayoutRequestModel.fromJson(json))
          .toList();

      return Either.right(payouts);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, PayoutRequestModel>> createPayoutRequest(
    CreatePayoutRequestModel request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/v1/partners/payouts',
        data: request.toJson(),
      );

      final payout = PayoutRequestModel.fromJson(response.data);
      return Either.right(payout);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, PayoutRequestModel>> cancelPayoutRequest(
    String payoutId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/v1/partners/payouts/$payoutId/cancel',
      );

      final payout = PayoutRequestModel.fromJson(response.data);
      return Either.right(payout);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getPayoutInfo() async {
    try {
      final response = await _apiClient.get('/v1/partners/payouts/info');
      return Either.right(response.data);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, List<EarningsHistoryModel>>> getOfferEarnings(
    String offerId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/partners/offers/$offerId/earnings',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final earnings = (response.data['data'] as List)
          .map((json) => EarningsHistoryModel.fromJson(json))
          .toList();

      return Either.right(earnings);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> getEarningsSummary() async {
    try {
      final response = await _apiClient.get('/v1/partners/earnings/summary');
      return Either.right(response.data);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(message: e.toString(), statusCode: 500));
    }
  }
}
