import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/generated_link_dto.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_dashboard_data_dto.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

abstract class PartnerDashboardRepository {
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers();
  // Future<Either<ApiException, PartnerOfferModel>> createOffer(PartnerOfferModel offer);
  // Future<Either<ApiException, PartnerOfferModel>> updateOffer(String offerId, PartnerOfferModel offer);
  // Future<Either<ApiException, void>> deleteOffer(String offerId);
  // Future<Either<ApiException, EarningsReportModel>> getEarningsReport(DateTimeRange dateRange);
  Future<Either<ApiException, GeneratedAffiliateLinkResponseDto>> generateTrackableLink(String offerId);

  Future<Either<ApiException, PartnerDashboardDataDto>> getDashboardData({
    String timeRange = '30d',
    String? status,
  });
}

class PartnerDashboardRepositoryImpl implements PartnerDashboardRepository {
  final ApiClient _apiClient;

  PartnerDashboardRepositoryImpl(this._apiClient);

  @override
  Future<Either<ApiException, GeneratedAffiliateLinkResponseDto>> generateTrackableLink(String offerId) async {
    try {
      final response = await _apiClient.get('/v1/affiliates/offers/$offerId/trackable-link');
      final linkData = GeneratedAffiliateLinkResponseDto.fromJson(response.data);
      return Either.right(linkData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to generate trackable link: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, PartnerDashboardDataDto>> getDashboardData({
    String timeRange = '30d',
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'timeRange': timeRange,
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get('/v1/affiliates/dashboard', queryParameters: queryParams);
      final dashboardData = PartnerDashboardDataDto.fromJson(response.data);
      return Either.right(dashboardData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to fetch dashboard data: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  // TODO: Implement other repository methods using _apiClient
  // Example:
  // @override
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers() async { ... }
}

// Provider for the repository
final partnerDashboardRepositoryProvider = Provider<PartnerDashboardRepository>((ref) {
  return PartnerDashboardRepositoryImpl(ref.watch(apiClientProvider));
});
