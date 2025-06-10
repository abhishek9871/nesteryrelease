import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

part 'affiliate_offers_state.freezed.dart';

@freezed
sealed class AffiliateOffersState with _$AffiliateOffersState {
  const factory AffiliateOffersState.loading() = _Loading;
  const factory AffiliateOffersState.success({
    required List<OfferCardViewModel> offers,
    required int currentPage,
    required bool hasMore,
    required int totalCount,
  }) = _Success;
  const factory AffiliateOffersState.error({
    required String message,
    List<OfferCardViewModel>? cachedOffers,
  }) = _Error;
}

@freezed
sealed class LinkGenerationState with _$LinkGenerationState {
  const factory LinkGenerationState.idle() = _Idle;
  const factory LinkGenerationState.loading() = _LinkLoading;
  const factory LinkGenerationState.success({
    required String trackableUrl,
    String? qrCodeDataUrl,
    required String uniqueCode,
  }) = _LinkSuccess;
  const factory LinkGenerationState.error({
    required String message,
  }) = _LinkError;
}

@freezed
sealed class OfferDetailState with _$OfferDetailState {
  const factory OfferDetailState.loading() = _DetailLoading;
  const factory OfferDetailState.success({
    required OfferCardViewModel offer,
  }) = _DetailSuccess;
  const factory OfferDetailState.error({
    required String message,
  }) = _DetailError;
}
