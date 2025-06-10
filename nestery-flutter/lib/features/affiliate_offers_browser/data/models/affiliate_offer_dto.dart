import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';

part 'affiliate_offer_dto.freezed.dart';
part 'affiliate_offer_dto.g.dart';

@freezed
class AffiliateOfferDto with _$AffiliateOfferDto {
  const factory AffiliateOfferDto({
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
    // Additional fields for partner information
    String? partnerName,
    String? partnerLogoUrl,
    PartnerCategoryEnum? partnerCategory,
  }) = _AffiliateOfferDto;

  factory AffiliateOfferDto.fromJson(Map<String, dynamic> json) =>
      _$AffiliateOfferDtoFromJson(json);
}

// Custom commission structure handling without freezed
class CommissionStructure {
  final String type;
  final double? value;
  final List<CommissionTier>? tiers;

  const CommissionStructure._({
    required this.type,
    this.value,
    this.tiers,
  });

  const CommissionStructure.percentage({required double value})
      : type = 'percentage',
        value = value,
        tiers = null;

  const CommissionStructure.fixed({required double value})
      : type = 'fixed',
        value = value,
        tiers = null;

  const CommissionStructure.tiered({required List<CommissionTier> tiers})
      : type = 'tiered',
        value = null,
        tiers = tiers;

  factory CommissionStructure.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'percentage':
        return CommissionStructure.percentage(value: (json['value'] as num).toDouble());
      case 'fixed':
        return CommissionStructure.fixed(value: (json['value'] as num).toDouble());
      case 'tiered':
        final tiers = (json['tiers'] as List)
            .map((tier) => CommissionTier.fromJson(tier as Map<String, dynamic>))
            .toList();
        return CommissionStructure.tiered(tiers: tiers);
      default:
        throw ArgumentError('Unknown commission type: $type');
    }
  }

  Map<String, dynamic> toJson() {
    switch (type) {
      case 'percentage':
      case 'fixed':
        return {'type': type, 'value': value};
      case 'tiered':
        return {
          'type': type,
          'tiers': tiers?.map((tier) => tier.toJson()).toList(),
        };
      default:
        throw ArgumentError('Unknown commission type: $type');
    }
  }

  T when<T>({
    required T Function(double value) percentage,
    required T Function(double value) fixed,
    required T Function(List<CommissionTier> tiers) tiered,
  }) {
    switch (type) {
      case 'percentage':
        return percentage(value!);
      case 'fixed':
        return fixed(value!);
      case 'tiered':
        return tiered(tiers!);
      default:
        throw ArgumentError('Unknown commission type: $type');
    }
  }
}

@freezed
class CommissionTier with _$CommissionTier {
  const factory CommissionTier({
    required double threshold,
    required double value,
    required String valueType, // 'percentage' or 'fixed'
  }) = _CommissionTier;

  factory CommissionTier.fromJson(Map<String, dynamic> json) =>
      _$CommissionTierFromJson(json);
}

@freezed
class PaginatedOffersResponse with _$PaginatedOffersResponse {
  const factory PaginatedOffersResponse({
    required List<AffiliateOfferDto> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _PaginatedOffersResponse;

  factory PaginatedOffersResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOffersResponseFromJson(json);
}
