import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/partner_offer_model.dart';

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
