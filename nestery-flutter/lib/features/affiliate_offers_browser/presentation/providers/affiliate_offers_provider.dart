import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';

final affiliateOffersProvider = FutureProvider<List<OfferCardViewModel>>((ref) async {
  final repository = ref.watch(affiliateOffersRepositoryProvider);
  return repository.getOffers();
});

final filteredOffersProvider = Provider<List<OfferCardViewModel>>((ref) {
  final offersAsync = ref.watch(affiliateOffersProvider);
  final filter = ref.watch(offerFilterProvider);

  return offersAsync.maybeWhen(
    data: (offers) => offers.where((offer) {
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

final offerDetailProvider = FutureProvider.family<OfferCardViewModel, String>((ref, offerId) async {
  final allOffers = await ref.watch(affiliateOffersProvider.future);
  // In a real app, this would be an API call. Here we find from the mock list.
  try {
    return allOffers.firstWhere((offer) => offer.offerId == offerId);
  } catch (e) {
    throw Exception('Offer not found');
  }
});
