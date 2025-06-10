import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/generated_link_dto.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_dashboard_data_dto.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_offer_dto.dart';
import 'package:nestery_flutter/utils/either.dart';
import 'package:nestery_flutter/utils/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

abstract class PartnerDashboardRepository {
  Future<Either<ApiException, PartnerOfferDto>> createOffer(CreatePartnerOfferDto offer);
  Future<Either<ApiException, PartnerOfferDto>> updateOffer(String offerId, UpdatePartnerOfferDto offer);
  Future<Either<ApiException, void>> deleteOffer(String offerId);
  Future<Either<ApiException, List<PartnerOfferDto>>> getPartnerOffers({
    int page = 1,
    int limit = 10,
    String? status,
  });
  Future<Either<ApiException, GeneratedAffiliateLinkResponseDto>> generateTrackableLink(String offerId);

  Future<Either<ApiException, PartnerDashboardDataDto>> getDashboardData({
    String timeRange = '30d',
    String? status,
  });
}

class PartnerDashboardRepositoryImpl implements PartnerDashboardRepository {
  final ApiClient _apiClient;

  PartnerDashboardRepositoryImpl(this._apiClient);

  @override
  Future<Either<ApiException, GeneratedAffiliateLinkResponseDto>> generateTrackableLink(String offerId) async {
    try {
      final response = await _apiClient.get('/v1/affiliates/offers/$offerId/trackable-link');
      final linkData = GeneratedAffiliateLinkResponseDto.fromJson(response.data);
      return Either.right(linkData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to generate trackable link: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, PartnerDashboardDataDto>> getDashboardData({
    String timeRange = '30d',
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'timeRange': timeRange,
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get('/v1/affiliates/dashboard', queryParameters: queryParams);
      final dashboardData = PartnerDashboardDataDto.fromJson(response.data);
      return Either.right(dashboardData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to fetch dashboard data: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, PartnerOfferDto>> createOffer(CreatePartnerOfferDto offer) async {
    try {
      final response = await _apiClient.post('/v1/affiliates/offers', data: offer.toJson());
      final offerData = PartnerOfferDto.fromJson(response.data);
      return Either.right(offerData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to create offer: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, PartnerOfferDto>> updateOffer(String offerId, UpdatePartnerOfferDto offer) async {
    try {
      final response = await _apiClient.put('/v1/affiliates/offers/$offerId', data: offer.toJson());
      final offerData = PartnerOfferDto.fromJson(response.data);
      return Either.right(offerData);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to update offer: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteOffer(String offerId) async {
    try {
      await _apiClient.delete('/v1/affiliates/offers/$offerId');
      return Either.right(null);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to delete offer: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<ApiException, List<PartnerOfferDto>>> getPartnerOffers({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get('/v1/affiliates/offers', queryParameters: queryParams);
      final List<dynamic> offersJson = response.data['data'] ?? response.data;
      final offers = offersJson.map((json) => PartnerOfferDto.fromJson(json)).toList();
      return Either.right(offers);
    } catch (e) {
      if (e is ApiException) {
        return Either.left(e);
      }
      return Either.left(ApiException(
        message: 'Failed to fetch partner offers: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }
}

// Provider for the repository
final partnerDashboardRepositoryProvider = Provider<PartnerDashboardRepository>((ref) {
  return PartnerDashboardRepositoryImpl(ref.watch(apiClientProvider));
});
