import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_offer_model.freezed.dart';

@freezed
class PartnerOfferModel with _$PartnerOfferModel {
  const factory PartnerOfferModel({
    required String id,
    required String title,
    String? description,
    required String partnerCategory, // FRS: TOUR_OPERATOR, ACTIVITY_PROVIDER, etc.
    required Map<String, dynamic> commissionStructure, // FRS: percentage, fixed, tiered
    required DateTime validFrom,
    required DateTime validTo,
    String? termsAndConditions,
    String? imageUrl,
    required bool isActive,
  }) = _PartnerOfferModel;
}
