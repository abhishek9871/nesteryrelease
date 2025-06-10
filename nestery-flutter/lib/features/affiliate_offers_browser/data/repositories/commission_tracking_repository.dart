import '../../../../utils/api_exception.dart';
import '../../../../utils/either.dart';
import '../models/earnings_history_model.dart';

abstract class CommissionTrackingRepository {
  /// Get user's earnings history with optional filtering
  Future<Either<ApiException, List<EarningsHistoryModel>>> getEarningsHistory({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? offerId,
  });

  /// Get user's analytics and performance metrics
  Future<Either<ApiException, UserAnalyticsModel>> getUserAnalytics({
    int days = 30,
  });

  /// Get user's payout requests
  Future<Either<ApiException, List<PayoutRequestModel>>> getPayoutRequests({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Create a new payout request
  Future<Either<ApiException, PayoutRequestModel>> createPayoutRequest(
    CreatePayoutRequestModel request,
  );

  /// Cancel a payout request
  Future<Either<ApiException, PayoutRequestModel>> cancelPayoutRequest(
    String payoutId,
  );

  /// Get minimum payout threshold and available balance
  Future<Either<ApiException, Map<String, dynamic>>> getPayoutInfo();

  /// Get detailed earnings for a specific offer
  Future<Either<ApiException, List<EarningsHistoryModel>>> getOfferEarnings(
    String offerId, {
    int page = 1,
    int limit = 20,
  });

  /// Get earnings summary for dashboard
  Future<Either<ApiException, Map<String, dynamic>>> getEarningsSummary();
}
