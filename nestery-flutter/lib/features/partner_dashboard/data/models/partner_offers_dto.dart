import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_offers_dto.freezed.dart';
part 'partner_offers_dto.g.dart';

@freezed
class OfferListItemDto with _$OfferListItemDto {
  const factory OfferListItemDto({
    required String id,
    required String title,
    required String status,
    required String partnerCategory,
    required DateTime validFrom,
    required DateTime validTo,
    String? thumbnailUrl,
  }) = _OfferListItemDto;

  factory OfferListItemDto.fromJson(Map<String, dynamic> json) =>
      _$OfferListItemDtoFromJson(json);
}
