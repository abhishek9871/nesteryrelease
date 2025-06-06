import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_link_dto.freezed.dart';
part 'generated_link_dto.g.dart';

@freezed
class GeneratedAffiliateLinkResponseDto with _$GeneratedAffiliateLinkResponseDto {
  const factory GeneratedAffiliateLinkResponseDto({
    required String fullTrackableUrl,
    required String qrCodeData,
  }) = _GeneratedAffiliateLinkResponseDto;

  factory GeneratedAffiliateLinkResponseDto.fromJson(Map<String, dynamic> json) => _$GeneratedAffiliateLinkResponseDtoFromJson(json);
}
