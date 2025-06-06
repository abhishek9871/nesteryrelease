import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_offer_model.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/models/partner_offer_list_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_filter_provider.dart';

// Placeholder for offer list
final offerListProvider = FutureProvider<List<PartnerOfferModel>>((ref) async {
  // TODO: Fetch actual offers from repository
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return [
    PartnerOfferModel(id: '1', title: 'Sample Offer 1', partnerCategory: 'TOUR_OPERATOR', commissionStructure: {'type': 'percentage', 'value': 0.15}, validFrom: DateTime.now(), validTo: DateTime.now().add(const Duration(days: 30)), isActive: true),
    PartnerOfferModel(id: '2', title: 'Sample Offer 2', partnerCategory: 'RESTAURANT', commissionStructure: {'type': 'fixed', 'value': 5.0}, validFrom: DateTime.now(), validTo: DateTime.now().add(const Duration(days: 60)), isActive: false),
  ];
});

// Placeholder for managing form state for creating/editing offers
class OfferFormState {
  // TODO: Define form fields and validation logic
}

class OfferFormStateNotifier extends StateNotifier<OfferFormState> {
  OfferFormStateNotifier() : super(OfferFormState());
}

final offerFormStateNotifierProvider = StateNotifierProvider<OfferFormStateNotifier, OfferFormState>((ref) {
  return OfferFormStateNotifier();
});

final partnerOfferListProvider = FutureProvider<List<PartnerOfferListItem>>((ref) async {
  final filter = ref.watch(offerFilterStatusProvider);

  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Generate a static list of sample PartnerOfferListItem objects
  final List<PartnerOfferListItem> allOffers = [
    PartnerOfferListItem(id: '1', title: 'Goa Beach Adventure Tour (Active)', status: OfferStatus.active, partnerCategory: 'TOUR_OPERATOR', validFrom: DateTime.now().subtract(const Duration(days: 5)), validTo: DateTime.now().add(const Duration(days: 25)), thumbnailUrl: 'https://via.placeholder.com/150/008000/FFFFFF?Text=NesteryTour'),
    PartnerOfferListItem(id: '2', title: 'City Food Walk (Pending)', status: OfferStatus.pending, partnerCategory: 'ACTIVITY_PROVIDER', validFrom: DateTime.now().add(const Duration(days: 2)), validTo: DateTime.now().add(const Duration(days: 12)), thumbnailUrl: 'https://via.placeholder.com/150/FFA500/FFFFFF?Text=NesteryFood'),
    PartnerOfferListItem(id: '3', title: 'Airport Shuttle Discount (Expired)', status: OfferStatus.expired, partnerCategory: 'TRANSPORTATION', validFrom: DateTime.now().subtract(const Duration(days: 30)), validTo: DateTime.now().subtract(const Duration(days: 1))),
    PartnerOfferListItem(id: '4', title: 'Restaurant Special Dinner (Inactive)', status: OfferStatus.inactive, partnerCategory: 'RESTAURANT', validFrom: DateTime.now(), validTo: DateTime.now().add(const Duration(days: 60)), thumbnailUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=NesteryDining'),
    PartnerOfferListItem(id: '5', title: 'Travel Gear Sale (Active ECOM)', status: OfferStatus.active, partnerCategory: 'ECOMMERCE', validFrom: DateTime.now().subtract(const Duration(days: 1)), validTo: DateTime.now().add(const Duration(days: 15))),
    PartnerOfferListItem(id: '6', title: 'Luxury Spa Day (Active)', status: OfferStatus.active, partnerCategory: 'ACTIVITY_PROVIDER', validFrom: DateTime.now().subtract(const Duration(days: 10)), validTo: DateTime.now().add(const Duration(days: 20)), thumbnailUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?Text=NesterySpa'),
    PartnerOfferListItem(id: '7', title: 'Historical City Tour (Pending)', status: OfferStatus.pending, partnerCategory: 'TOUR_OPERATOR', validFrom: DateTime.now().add(const Duration(days: 5)), validTo: DateTime.now().add(const Duration(days: 35)), thumbnailUrl: 'https://via.placeholder.com/150/FFFF00/000000?Text=NesteryHistory'),
  ];

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
      default: // OfferFilterStatus.all already handled
        return true;
    }
  }).toList();
});
