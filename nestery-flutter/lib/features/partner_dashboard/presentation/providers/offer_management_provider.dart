import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/models/partner_offer_list_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_filter_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/partner_dashboard_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/repositories/partner_dashboard_repository.dart';

// Provider for offer list using the new DTO
final offerListProvider = Provider((ref) {
  final partnerOffersData = ref.watch(partnerOffersDataProvider);

  return partnerOffersData.when(
    data: (offers) => AsyncValue.data(offers),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final partnerOfferListProvider = FutureProvider<List<PartnerOfferListItem>>((ref) async {
  final filter = ref.watch(offerFilterStatusProvider);
  final repository = ref.watch(partnerDashboardRepositoryProvider);

  try {
    // Get offers from API
    final result = await repository.getPartnerOffers(
      page: 1,
      limit: 100, // Get all offers for now
      status: filter == OfferFilterStatus.all ? null : filter.name,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (offers) {
        // Convert PartnerOfferDto to PartnerOfferListItem
        final allOffers = offers.map((offer) {
          return PartnerOfferListItem(
            id: offer.id,
            title: offer.title,
            status: _mapStatusFromApi(offer.isActive),
            partnerCategory: _extractCategoryFromCommission(offer.commissionStructure),
            validFrom: offer.validFrom,
            validTo: offer.validTo,
            thumbnailUrl: offer.originalUrl, // Use originalUrl as thumbnail for now
          );
        }).toList();

        // Apply additional filtering if needed
        if (filter == OfferFilterStatus.all) {
          return allOffers;
        }

        return allOffers.where((offer) {
          switch (filter) {
            case OfferFilterStatus.active:
              return offer.status == OfferStatus.active;
            case OfferFilterStatus.inactive:
              return offer.status == OfferStatus.inactive;
            case OfferFilterStatus.pending:
              return offer.status == OfferStatus.pending;
            case OfferFilterStatus.expired:
              return offer.status == OfferStatus.expired;
            default:
              return true;
          }
        }).toList();
      },
    );
  } catch (e) {
    // Return empty list on error - UI will handle error display
    return <PartnerOfferListItem>[];
  }
});

// Helper function to map API status to OfferStatus enum
OfferStatus _mapStatusFromApi(bool isActive) {
  if (!isActive) {
    return OfferStatus.inactive;
  }

  // For now, assume active offers are active
  // In a real implementation, you'd check validity dates
  return OfferStatus.active;
}

// Helper function to extract category from commission structure
String _extractCategoryFromCommission(Map<String, dynamic> commissionStructure) {
  return commissionStructure['category']?.toString() ?? 'TOUR_OPERATOR';
}
