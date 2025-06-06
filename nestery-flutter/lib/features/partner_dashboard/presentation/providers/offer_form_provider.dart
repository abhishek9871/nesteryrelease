import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/models/offer_form_state.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_management_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/utils/validators.dart';

final offerFormStateNotifierProvider = StateNotifierProvider.family<
    OfferFormStateNotifier, OfferFormState, String?>(
  (ref, offerId) => OfferFormStateNotifier(ref, offerId),
);

class OfferFormStateNotifier extends StateNotifier<OfferFormState> {
  final Ref _ref;
  final String? offerId;

  OfferFormStateNotifier(this._ref, this.offerId)
      : super(const OfferFormState()) {
    initialize();
  }

  void initialize() async {
    if (offerId != null && offerId != 'new') {
      state = state.copyWith(isEditing: true);
      final offers = await _ref.read(partnerOfferListProvider.future);
      try {
        final offer = offers.firstWhere((o) => o.id == offerId);
        state = state.copyWith(
          id: offer.id,
          title: offer.title,
          description: 'This is a sample description for an existing offer.', // Placeholder
          partnerCategory: offer.partnerCategory,
          commissionRate: '15.0', // Placeholder
          validFrom: offer.validFrom,
          validTo: offer.validTo,
          imageUrl: offer.thumbnailUrl,
          isInitialized: true,
        );
      } catch (e) {
        state = state.copyWith(isInitialized: true, isEditing: false); // Offer not found, treat as new
      }
    } else {
      state = state.copyWith(isInitialized: true, isEditing: false);
    }
  }

  void updateTitle(String title) {
    state = state.copyWith(
        title: title, titleError: title.trim().isEmpty ? 'Title is required' : null);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updatePartnerCategory(String category) {
    state = state.copyWith(partnerCategory: category);
    updateCommissionRate(state.commissionRate); // Re-validate
  }

  void updateCommissionRate(String rate) {
    final error = FRSCommissionValidator.validateCommission(rate, state.partnerCategory);
    state = state.copyWith(commissionRate: rate, commissionRateError: error);
  }

  void updateValidFrom(DateTime date) {
    String? dateError;
    if (state.validTo != null && date.isAfter(state.validTo!)) {
      dateError = 'Start date must be before end date';
    } else {
      dateError = null; // Clear previous error
    }
    state = state.copyWith(validFrom: date, dateError: dateError);
  }

  void updateValidTo(DateTime date) {
    String? dateError;
    if (state.validFrom != null && date.isBefore(state.validFrom!)) {
      dateError = 'End date must be after start date';
    } else {
      dateError = null; // Clear previous error
    }
    state = state.copyWith(validTo: date, dateError: dateError);
  }

  Future<void> saveOffer() async {
    state = state.copyWith(isSubmitting: true);
    updateTitle(state.title);
    updateCommissionRate(state.commissionRate);
    if (state.validFrom == null || state.validTo == null || state.validTo!.isBefore(state.validFrom!)) {
       state = state.copyWith(dateError: 'Please select a valid date range.');
    }
    
    if(state.titleError != null || state.commissionRateError != null || state.dateError != null) {
       state = state.copyWith(isSubmitting: false);
       return;
    }

    // In a real app, here you would call your repository to save the data.
    await Future.delayed(const Duration(seconds: 1)); 
    state = state.copyWith(isSubmitting: false);
  }
}
