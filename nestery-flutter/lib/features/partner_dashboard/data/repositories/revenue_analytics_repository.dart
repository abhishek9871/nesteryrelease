import '../../../../utils/api_exception.dart';
import '../../../../utils/either.dart';
import '../models/revenue_metrics_model.dart';

abstract class RevenueAnalyticsRepository {
  /// Get partner-specific revenue metrics
  Future<Either<ApiException, RevenueMetricsModel>> getPartnerRevenueMetrics({
    int days = 30,
  });

  /// Get partner-specific revenue trends
  Future<Either<ApiException, List<RevenueTrendModel>>> getPartnerRevenueTrends({
    int days = 30,
  });

  /// Get commission batches (admin only)
  Future<Either<ApiException, List<CommissionBatchModel>>> getCommissionBatches({
    int limit = 20,
  });

  /// Get overall revenue summary (admin only)
  Future<Either<ApiException, RevenueMetricsModel>> getRevenueSummary({
    int days = 30,
  });

  /// Get partner performance metrics (admin only)
  Future<Either<ApiException, List<PartnerPerformanceModel>>> getPartnerPerformance({
    int limit = 10,
  });

  /// Get overall revenue trends (admin only)
  Future<Either<ApiException, List<RevenueTrendModel>>> getRevenueTrends({
    int days = 30,
  });

  /// Manually trigger commission processing (admin only)
  Future<Either<ApiException, Map<String, dynamic>>> processCommissions();

  /// Clear analytics cache (admin only)
  Future<Either<ApiException, Map<String, String>>> clearAnalyticsCache();
}
