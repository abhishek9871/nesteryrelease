import 'package:nestery_flutter/core/network/api_client.dart';
// import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_offer_model.dart';
// import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_report_model.dart';
// import 'package:nestery_flutter/utils/either.dart';
// import 'package:nestery_flutter/utils/api_exception.dart';

abstract class PartnerDashboardRepository {
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers();
  // Future<Either<ApiException, PartnerOfferModel>> createOffer(PartnerOfferModel offer);
  // Future<Either<ApiException, PartnerOfferModel>> updateOffer(String offerId, PartnerOfferModel offer);
  // Future<Either<ApiException, void>> deleteOffer(String offerId);
  // Future<Either<ApiException, EarningsReportModel>> getEarningsReport(DateTimeRange dateRange);
  // Future<Either<ApiException, String>> generateTrackableLink(String offerId);
}

class PartnerDashboardRepositoryImpl implements PartnerDashboardRepository {
  final ApiClient _apiClient;

  PartnerDashboardRepositoryImpl(this._apiClient);

  // TODO: Implement repository methods using _apiClient
  // Example:
  // @override
  // Future<Either<ApiException, List<PartnerOfferModel>>> getOffers() async { ... }
}
