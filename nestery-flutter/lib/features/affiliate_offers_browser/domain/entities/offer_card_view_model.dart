import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';

part 'offer_card_view_model.freezed.dart';

@freezed
class OfferCardViewModel with _$OfferCardViewModel {
  const factory OfferCardViewModel({
    required String offerId,
    required String title,
    required String partnerName,
    required PartnerCategoryEnum category,
    required String description,
    required double commissionRateMin,
    required double commissionRateMax,
    required DateTime validTo,
    String? partnerLogoUrl,
    required bool isActive,
  }) = _OfferCardViewModel;
}
