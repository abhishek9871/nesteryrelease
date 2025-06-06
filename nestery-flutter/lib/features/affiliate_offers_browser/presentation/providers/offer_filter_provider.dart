import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';

part 'offer_filter_provider.freezed.dart';

@freezed
class OfferFilterState with _$OfferFilterState {
  const factory OfferFilterState({
    String? searchQuery,
    PartnerCategoryEnum? selectedCategory,
    @Default(true) bool activeOnly,
    @Default(8.0) double minCommissionRate,
    @Default(20.0) double maxCommissionRate,
  }) = _OfferFilterState;
}

class OfferFilterNotifier extends StateNotifier<OfferFilterState> {
  OfferFilterNotifier() : super(const OfferFilterState());

  void updateSearchQuery(String? query) => state = state.copyWith(searchQuery: query);
  void updateCategory(PartnerCategoryEnum? category) => state = state.copyWith(selectedCategory: category);
  void updateCommissionRange(double min, double max) => state = state.copyWith(minCommissionRate: min, maxCommissionRate: max);
  void clearFilters() => state = const OfferFilterState();
}

final offerFilterProvider = StateNotifierProvider<OfferFilterNotifier, OfferFilterState>(
  (ref) => OfferFilterNotifier(),
);
