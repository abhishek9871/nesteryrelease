import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/affiliate_link_dto.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

abstract class AffiliateOffersRepository {
  Future<Either<ApiException, List<OfferCardViewModel>>> getActiveOffers({
    int page = 1,
    int limit = 10,
    String? partnerId,
    bool? isActive,
    String? title,
    bool? currentlyValid,
  });

  Future<Either<ApiException, OfferCardViewModel>> getOfferById(String offerId);

  Future<Either<ApiException, GeneratedAffiliateLinkDto>> generateTrackableLink({
    required String offerId,
    String? userId,
  });
}
