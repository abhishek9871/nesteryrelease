import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliate_link_dto.freezed.dart';
part 'affiliate_link_dto.g.dart';

@freezed
class AffiliateLinkDto with _$AffiliateLinkDto {
  const factory AffiliateLinkDto({
    required String id,
    required String offerId,
    String? userId,
    required String uniqueCode,
    String? qrCodeDataUrl,
    required int clicks,
    required int conversions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AffiliateLinkDto;

  factory AffiliateLinkDto.fromJson(Map<String, dynamic> json) =>
      _$AffiliateLinkDtoFromJson(json);
}

@freezed
class GeneratedAffiliateLinkDto with _$GeneratedAffiliateLinkDto {
  const factory GeneratedAffiliateLinkDto({
    required AffiliateLinkDto linkEntity,
    required String fullTrackableUrl,
    String? qrCodeDataUrl,
  }) = _GeneratedAffiliateLinkDto;

  factory GeneratedAffiliateLinkDto.fromJson(Map<String, dynamic> json) =>
      _$GeneratedAffiliateLinkDtoFromJson(json);
}

@freezed
class LinkGenerationRequest with _$LinkGenerationRequest {
  const factory LinkGenerationRequest({
    required String offerId,
    String? userId,
  }) = _LinkGenerationRequest;

  factory LinkGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$LinkGenerationRequestFromJson(json);
}
