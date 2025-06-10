import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_state.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';

class AffiliateOffersNotifier extends StateNotifier<AffiliateOffersState> {
  final AffiliateOffersRepository _repository;

  AffiliateOffersNotifier(this._repository) : super(const AffiliateOffersState.loading());

  Future<void> loadOffers({
    bool refresh = false,
    int page = 1,
    int limit = 10,
    String? partnerId,
    bool? isActive,
    String? title,
    bool? currentlyValid,
  }) async {
    if (refresh || page == 1) {
      state = const AffiliateOffersState.loading();
    }

    final result = await _repository.getActiveOffers(
      page: page,
      limit: limit,
      partnerId: partnerId,
      isActive: isActive,
      title: title,
      currentlyValid: currentlyValid,
    );

    result.fold(
      (error) => state = AffiliateOffersState.error(
        message: error.message,
        cachedOffers: state.maybeWhen(
          success: (offers, _, __, ___) => offers,
          orElse: () => null,
        ),
      ),
      (offers) {
        final currentOffers = page == 1
            ? offers
            : [
                ...state.maybeWhen(
                  success: (existingOffers, _, __, ___) => existingOffers,
                  orElse: () => <OfferCardViewModel>[],
                ),
                ...offers,
              ];

        state = AffiliateOffersState.success(
          offers: currentOffers,
          currentPage: page,
          hasMore: offers.length >= limit,
          totalCount: currentOffers.length,
        );
      },
    );
  }

  Future<void> refreshOffers() async {
    await loadOffers(refresh: true);
  }

  Future<void> loadMoreOffers() async {
    state.maybeWhen(
      success: (offers, currentPage, hasMore, totalCount) {
        if (hasMore) {
          loadOffers(page: currentPage + 1);
        }
      },
      orElse: () {},
    );
  }
}

class OfferDetailNotifier extends StateNotifier<OfferDetailState> {
  final AffiliateOffersRepository _repository;

  OfferDetailNotifier(this._repository) : super(const OfferDetailState.loading());

  Future<void> loadOfferDetail(String offerId) async {
    state = const OfferDetailState.loading();

    final result = await _repository.getOfferById(offerId);

    result.fold(
      (error) => state = OfferDetailState.error(message: error.message),
      (offer) => state = OfferDetailState.success(offer: offer),
    );
  }
}

final affiliateOffersProvider = StateNotifierProvider<AffiliateOffersNotifier, AffiliateOffersState>((ref) {
  final repository = ref.watch(affiliateOffersRepositoryProvider);
  return AffiliateOffersNotifier(repository);
});

final offerDetailProvider = StateNotifierProvider.family<OfferDetailNotifier, OfferDetailState, String>((ref, offerId) {
  final repository = ref.watch(affiliateOffersRepositoryProvider);
  final notifier = OfferDetailNotifier(repository);
  notifier.loadOfferDetail(offerId);
  return notifier;
});

final filteredOffersProvider = Provider<List<OfferCardViewModel>>((ref) {
  final offersState = ref.watch(affiliateOffersProvider);
  final filter = ref.watch(offerFilterProvider);

  return offersState.maybeWhen(
    success: (offers, _, __, ___) => offers.where((offer) {
      if (filter.activeOnly && !offer.isActive) return false;
      if (filter.selectedCategory != null && offer.category != filter.selectedCategory) return false;
      if (offer.commissionRateMax < filter.minCommissionRate || offer.commissionRateMin > filter.maxCommissionRate) return false;
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        return offer.title.toLowerCase().contains(query) ||
               offer.description.toLowerCase().contains(query) ||
               offer.partnerName.toLowerCase().contains(query);
      }
      return true;
    }).toList(),
    orElse: () => [],
  );
});
