import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

abstract class AffiliateOffersRepository {
  Future<List<OfferCardViewModel>> getOffers();
}
