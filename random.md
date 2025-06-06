**Primary Objective:** Implement the main Flutter screen where Nestery users can browse, search, and filter available affiliate offers. This initial implementation will be for the UI and placeholder state management only, using mock data. The feature should integrate seamlessly into the existing app navigation.

**I. General Requirements:**
*   **Target Commit:** `646eac7` on branch `shivji`.
*   **Dependencies:** No new dependencies are required. All necessary packages (`flutter_riverpod`, `freezed`, `shimmer`, `go_router`) are already in `pubspec.yaml`.
*   **File Structure Mandate:** All new files MUST be created in the exact paths specified below within the new feature directory: `nestery-flutter/lib/features/affiliate_offers_browser/`.

**II. Data Models & State Management (By File):**

**A. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/data/models/partner_category.dart`
**Exact Content:**
```dart
import 'package:flutter/material.dart';

enum PartnerCategoryEnum {
  TOUR_OPERATOR,
  ACTIVITY_PROVIDER,
  RESTAURANT,
  TRANSPORTATION,
  ECOMMERCE,
}

extension PartnerCategoryExtension on PartnerCategoryEnum {
  String get displayName {
    switch (this) {
      case PartnerCategoryEnum.TOUR_OPERATOR:
        return 'Tours';
      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
        return 'Activities';
      case PartnerCategoryEnum.RESTAURANT:
        return 'Restaurants';
      case PartnerCategoryEnum.TRANSPORTATION:
        return 'Transport';
      case PartnerCategoryEnum.ECOMMERCE:
        return 'Gear';
    }
  }

  IconData get icon {
    switch (this) {
      case PartnerCategoryEnum.TOUR_OPERATOR:
        return Icons.tour;
      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
        return Icons.local_activity;
      case PartnerCategoryEnum.RESTAURANT:
        return Icons.restaurant;
      case PartnerCategoryEnum.TRANSPORTATION:
        return Icons.directions_car;
      case PartnerCategoryEnum.ECOMMERCE:
        return Icons.shopping_bag;
    }
  }
}
```

**B. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart`
**Exact Content:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';

part 'offer_card_view_model.freezed.dart';

@freezed
class OfferCardViewModel with _$OfferCardViewModel {
  const factory OfferCardViewModel({
    required String offerId,
    required String title,
    required String partnerName,
    required PartnerCategoryEnum category,
    required String description,
    required double commissionRateMin,
    required double commissionRateMax,
    required DateTime validTo,
    String? partnerLogoUrl,
    required bool isActive,
  }) = _OfferCardViewModel;
}
```

**C. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart`
**Exact Content:**
```dart
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
```

**D. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart`
**Exact Content:**
```dart
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

abstract class AffiliateOffersRepository {
  Future<List<OfferCardViewModel>> getOffers();
}
```

**E. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart`
**Exact Content:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';

final affiliateOffersRepositoryProvider = Provider<AffiliateOffersRepository>((ref) {
  return AffiliateOffersRepositoryImpl();
});

class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
  @override
  Future<List<OfferCardViewModel>> getOffers() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return _mockOfferData;
  }
}

final List<OfferCardViewModel> _mockOfferData = [
  const OfferCardViewModel(
    offerId: 'tour-001',
    title: 'Goa Beach Adventure Tour',
    partnerName: 'Coastal Adventures',
    category: PartnerCategoryEnum.TOUR_OPERATOR,
    description: 'Experience the best beaches of Goa with our guided tour including water sports and local cuisine.',
    commissionRateMin: 15.0,
    commissionRateMax: 20.0,
    validTo: DateTime.now().add(const Duration(days: 30)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: true,
  ),
  const OfferCardViewModel(
    offerId: 'restaurant-001',
    title: '20% Off at Spice Garden Restaurant',
    partnerName: 'Spice Garden',
    category: PartnerCategoryEnum.RESTAURANT,
    description: 'Authentic Indian cuisine with a modern twist. Valid for dinner bookings.',
    commissionRateMin: 10.0,
    commissionRateMax: 10.0,
    validTo: DateTime.now().add(const Duration(days: 15)),
    partnerLogoUrl: null,
    isActive: true,
  ),
  const OfferCardViewModel(
    offerId: 'transport-001',
    title: 'Airport Transfer Service',
    partnerName: 'QuickRide Cabs',
    category: PartnerCategoryEnum.TRANSPORTATION,
    description: 'Reliable airport transfers with professional drivers. 24/7 availability.',
    commissionRateMin: 8.0,
    commissionRateMax: 12.0,
    validTo: DateTime.now().add(const Duration(days: 60)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: true,
  ),
  const OfferCardViewModel(
    offerId: 'ecommerce-001',
    title: 'Travel Gear Essentials',
    partnerName: 'TravelMart',
    category: PartnerCategoryEnum.ECOMMERCE,
    description: 'Premium travel accessories and luggage with free shipping on orders above ₹2000.',
    commissionRateMin: 8.0,
    commissionRateMax: 12.0,
    validTo: DateTime.now().add(const Duration(days: 45)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: false, // For testing the 'activeOnly' filter
  ),
];
```

**F. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart`
**Exact Content:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package.nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';

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
```

**III. UI Implementation (By File):**

**A. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart`
**Instructions:** Create a stateless widget that accepts an `OfferCardViewModel`. It should use `Card`, `ListTile`, and `Column`/`Row` widgets to display the offer's title, partner name, category (as a `Chip` with the category icon and name), a truncated description, commission range, and validity. Use `CachedNetworkImage` for the `partnerLogoUrl` with a fallback placeholder.

**B. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart`
**Instructions:** Create a stateful widget that contains a `TextField` for search and a `DropdownButtonFormField` for category filtering. On user input, it should call the appropriate methods on the `offerFilterProvider.notifier` obtained from a `Consumer`. The category dropdown should be populated from `PartnerCategoryEnum.values` and include a "All Categories" option.

**C. File to Create:** `nestery-flutter/lib/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart`
**Instructions:**
1.  Create a `ConsumerWidget`.
2.  Build a `Scaffold` with an `AppBar` titled "Discover Offers".
3.  The body will contain the `OfferFilterWidgets` at the top.
4.  Below the filters, use another `Consumer` to watch the `affiliateOffersProvider`.
5.  Use a `.when()` clause on the provider's `AsyncValue` to handle the UI states:
    *   `loading:`: Display a `ListView` of 3-4 `Shimmer` widgets that mimic the layout of the `OfferCardWidget`.
    *   `error:`: Display a centered `Column` with `Icons.error_outline`, an error message, and a "Retry" `ElevatedButton` that calls `ref.refresh(affiliateOffersProvider)`.
    *   `data:`: Watch the `filteredOffersProvider`. If the list is empty, display the "Empty State" UI (centered `Column` with `Icons.search_off`, message, and "Clear Filters" button). Otherwise, display a `ListView.builder` that creates an `OfferCardWidget` for each item in the filtered list.

**IV. Navigation Integration (File Modification):**

**A. File to Modify:** `nestery-flutter/lib/core/routing/app_router.dart`
**Instructions:**
1.  Add a new route to the `rootNavigatorKey`'s `GoRouter` instance within the `routes` list:
    ```dart
    GoRoute(
      path: '/discover',
      builder: (context, state) => const AffiliateOffersBrowserScreen(), // Import the new screen
    ),
    ```
2.  In the `StatefulShellRoute.indexedStack` builder, locate the `BottomNavigationBar`'s `items` list and add a new `BottomNavigationBarItem` at index 3:
    ```dart
    const BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: 'Discover',
    ),
    ```
3.  Update the `_calculateSelectedIndex` method to include the new route:
    ```diff
    --- a/lib/core/routing/app_router.dart
    +++ b/lib/core/routing/app_router.dart
    @@ -...
       if (location.startsWith('/bookings')) return 2;
    +  if (location.startsWith('/discover')) return 3;
    -  if (location.startsWith('/profile')) return 3;
    +  if (location.startsWith('/profile')) return 4;
       return 0;
     }
    ```
4.  Update the `_onItemTapped` method to handle the new index:
    ```diff
    --- a/lib/core/routing/app_router.dart
    +++ b/lib/core/routing/app_router.dart
    @@ -...
       case 2:
         context.go('/bookings');
         break;
    +  case 3:
    +    context.go('/discover');
    +    break;
    -  case 3:
    +  case 4:
         context.go('/profile');
         break;
     }
    ```

**V. Build/Generation Steps (Required):**
*   This task requires running `flutter pub run build_runner build --delete-conflicting-outputs` after all `freezed` models have been created to generate the necessary `.freezed.dart` and `.g.dart` part files.

**Critical Integration & Quality Mandate:** The new feature must integrate perfectly with the existing application. All code must adhere to existing project conventions for state management (Riverpod), architecture (Clean Architecture), and styling. All existing tests must continue to pass, and the app must build and run without regressions.

**Output Expectation:** Provide a single, consolidated `git diff` against the base commit (`646eac7`) containing all the changes described above.