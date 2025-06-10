import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_offer_dto.freezed.dart';
part 'partner_offer_dto.g.dart';

@freezed
class PartnerOfferDto with _$PartnerOfferDto {
  const factory PartnerOfferDto({
    required String id,
    required String partnerId,
    required String title,
    required String description,
    required Map<String, dynamic> commissionStructure,
    required DateTime validFrom,
    required DateTime validTo,
    required String termsConditions,
    required bool isActive,
    String? originalUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PartnerOfferDto;

  factory PartnerOfferDto.fromJson(Map<String, dynamic> json) =>
      _$PartnerOfferDtoFromJson(json);
}

@freezed
class CreatePartnerOfferDto with _$CreatePartnerOfferDto {
  const factory CreatePartnerOfferDto({
    required String title,
    required String description,
    required Map<String, dynamic> commissionStructure,
    required DateTime validFrom,
    required DateTime validTo,
    required String termsConditions,
    String? originalUrl,
  }) = _CreatePartnerOfferDto;

  factory CreatePartnerOfferDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePartnerOfferDtoFromJson(json);
}

@freezed
class UpdatePartnerOfferDto with _$UpdatePartnerOfferDto {
  const factory UpdatePartnerOfferDto({
    String? title,
    String? description,
    Map<String, dynamic>? commissionStructure,
    DateTime? validFrom,
    DateTime? validTo,
    String? termsConditions,
    String? originalUrl,
    bool? isActive,
  }) = _UpdatePartnerOfferDto;

  factory UpdatePartnerOfferDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePartnerOfferDtoFromJson(json);
}
