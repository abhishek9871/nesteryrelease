import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/generated_link_dto.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
// import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_offer_model.dart';
// import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_report_model.dart';

abstract class PartnerDashboardRepository {
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers();
  // Future<Either<ApiException, PartnerOfferModel>> createOffer(PartnerOfferModel offer);
  // Future<Either<ApiException, PartnerOfferModel>> updateOffer(String offerId, PartnerOfferModel offer);
  // Future<Either<ApiException, void>> deleteOffer(String offerId);
  // Future<Either<ApiException, EarningsReportModel>> getEarningsReport(DateTimeRange dateRange);
  Future<Either<ApiException, GeneratedAffiliateLinkResponseDto>> generateTrackableLink(String offerId);
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

  // TODO: Implement other repository methods using _apiClient
  // Example:
  // @override
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers() async { ... }
}
