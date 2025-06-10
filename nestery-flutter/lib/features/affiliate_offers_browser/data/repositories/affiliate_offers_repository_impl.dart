import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/affiliate_link_dto.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/affiliate_offer_dto.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:nestery_flutter/utils/either.dart';

final affiliateOffersRepositoryProvider = Provider<AffiliateOffersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AffiliateOffersRepositoryImpl(apiClient);
});

class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
  final ApiClient _apiClient;

  AffiliateOffersRepositoryImpl(this._apiClient);

  @override
  Future<Either<ApiException, List<OfferCardViewModel>>> getActiveOffers({
    int page = 1,
    int limit = 10,
    String? partnerId,
    bool? isActive,
    String? title,
    bool? currentlyValid,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (partnerId != null) queryParams['partnerId'] = partnerId;
      if (isActive != null) queryParams['isActive'] = isActive;
      if (title != null) queryParams['title'] = title;
      if (currentlyValid != null) queryParams['currentlyValid'] = currentlyValid;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/affiliates/offers/active',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedOffersResponse.fromJson(response.data!);
        final offers = paginatedResponse.data
            .map((dto) => _mapDtoToViewModel(dto))
            .toList();

        return Either.right(offers);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, OfferCardViewModel>> getOfferById(String offerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/affiliates/offers/$offerId',
      );

      if (response.data != null) {
        final dto = AffiliateOfferDto.fromJson(response.data!);
        final offer = _mapDtoToViewModel(dto);
        return Either.right(offer);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, GeneratedAffiliateLinkDto>> generateTrackableLink({
    required String offerId,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/affiliates/offers/$offerId/trackable-link',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data != null) {
        final linkDto = GeneratedAffiliateLinkDto.fromJson(response.data!);
        return Either.right(linkDto);
      } else {
        return Either.left(ApiException(
          message: 'Invalid response from server',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    } catch (e) {
      return Either.left(ApiException(
        message: e.toString(),
        statusCode: 500,
      ));
    }
  }

  OfferCardViewModel _mapDtoToViewModel(AffiliateOfferDto dto) {
    // Extract commission rates from commission structure
    double minRate = 0.0;
    double maxRate = 0.0;

    final commissionStructure = CommissionStructure.fromJson(dto.commissionStructure);
    commissionStructure.when(
      percentage: (value) {
        minRate = value;
        maxRate = value;
      },
      fixed: (value) {
        // For fixed commissions, we'll show as percentage for UI consistency
        minRate = value;
        maxRate = value;
      },
      tiered: (tiers) {
        if (tiers.isNotEmpty) {
          minRate = tiers.first.value;
          maxRate = tiers.last.value;
        }
      },
    );

    return OfferCardViewModel(
      offerId: dto.id,
      title: dto.title,
      partnerName: dto.partnerName ?? 'Unknown Partner',
      category: dto.partnerCategory ?? PartnerCategoryEnum.ECOMMERCE,
      description: dto.description,
      commissionRateMin: minRate,
      commissionRateMax: maxRate,
      validTo: dto.validTo,
      partnerLogoUrl: dto.partnerLogoUrl,
      isActive: dto.isActive,
    );
  }

}
