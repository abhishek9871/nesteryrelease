### **FINALIZED & APPROVED: Comprehensive LFS Implementation Blueprint**
### **LFS-01: Affiliate Offer Browser Screen**

*   **Objective:** Implement the main screen where Nestery users can browse, search, and filter all available affiliate offers. This initial implementation will focus on the UI and placeholder state management, pending a future LFS for backend API integration.
*   **Base Commit:** `646eac7` on branch `shivji`.

---

**1. File & Module Structure (Refined for Architectural Purity)**

*   **Feature Directory:** A new feature module will be created at:
    `nestery-flutter/lib/features/affiliate_offers_browser/`
*   **Sub-directory Structure:** This structure strictly follows Clean Architecture principles.
    ```
    nestery-flutter/lib/features/affiliate_offers_browser/
    ├── data/
    │   ├── models/
    │   │   └── partner_category.dart
    │   └── repositories/
    │       └── affiliate_offers_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── offer_card_view_model.dart
    │   └── repositories/
    │       └── affiliate_offers_repository.dart
    └── presentation/
        ├── providers/
        │   ├── affiliate_offers_provider.dart
        │   └── offer_filter_provider.dart
        ├── screens/
        │   └── affiliate_offers_browser_screen.dart
        └── widgets/
            ├── offer_card_widget.dart
            └── offer_filter_widgets.dart
    ```

**2. Data Models & State Management (Riverpod) (Refined for Completeness)**

*   **Partner Category Enum (`data/models/partner_category.dart`):**
    ```dart
    import 'package:flutter/material.dart';

    enum PartnerCategoryEnum {
      TOUR_OPERATOR, ACTIVITY_PROVIDER, RESTAURANT, TRANSPORTATION, ECOMMERCE,
    }

    extension PartnerCategoryExtension on PartnerCategoryEnum {
      String get displayName {
        switch (this) {
          case PartnerCategoryEnum.TOUR_OPERATOR: return 'Tours';
          case PartnerCategoryEnum.ACTIVITY_PROVIDER: return 'Activities';
          case PartnerCategoryEnum.RESTAURANT: return 'Restaurants';
          case PartnerCategoryEnum.TRANSPORTATION: return 'Transport';
          case PartnerCategoryEnum.ECOMMERCE: return 'Gear';
        }
      }

      IconData get icon {
        switch (this) {
          case PartnerCategoryEnum.TOUR_OPERATOR: return Icons.tour;
          case PartnerCategoryEnum.ACTIVITY_PROVIDER: return Icons.local_activity;
          case PartnerCategoryEnum.RESTAURANT: return Icons.restaurant;
          case PartnerCategoryEnum.TRANSPORTATION: return Icons.directions_car;
          case PartnerCategoryEnum.ECOMMERCE: return Icons.shopping_bag;
        }
      }
    }
    ```
*   **Offer Card View Model (`domain/entities/offer_card_view_model.dart`):**
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
*   **Filter State & Provider (`presentation/providers/offer_filter_provider.dart`):**
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
*   **Offers Data Provider (`presentation/providers/affiliate_offers_provider.dart`):**
    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    // ... other imports

    final affiliateOffersProvider = FutureProvider<List<OfferCardViewModel>>((ref) async {
      final repository = ref.watch(affiliateOffersRepositoryProvider);
      return repository.getOffers(); // Will fetch mock data for this LFS
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

**3. Repository Layer**

*   **Abstract Repository (`domain/repositories/affiliate_offers_repository.dart`):**
    ```dart
    import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

    abstract class AffiliateOffersRepository {
      Future<List<OfferCardViewModel>> getOffers();
    }
    ```
*   **Repository Implementation (`data/repositories/affiliate_offers_repository_impl.dart`):**
    ```dart
    import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
    import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
    import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';

    class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
      @override
      Future<List<OfferCardViewModel>> getOffers() async {
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
        // In a future LFS, this will make a real API call.
        // For now, return mock data.
        return _mockOfferData;
      }
    }
    
    // For this LFS, mock data can live here.
    final List<OfferCardViewModel> _mockOfferData = [
      // ... Paste full mock data list from Augment Coder response here ...
    ];
    ```

**4. UI Implementation**

*   **Screen & Widgets:** The implementation will follow the UI descriptions from the Augment Coder proposal. The main screen (`affiliate_offers_browser_screen.dart`) will use a `Consumer` on `filteredOffersProvider` to display the list, and will handle loading/empty/error states gracefully.
*   **Screen States UX:**
    *   **Loading:** Use `shimmer` package for placeholder cards.
    *   **Empty:** Display centered column with `Icons.search_off`, "No offers found", and "Clear Filters" button.
    *   **Error:** Display centered column with `Icons.error_outline`, "Unable to load offers", and a "Retry" button.

**5. Navigation Integration (`app_router.dart`) (Refined for Clarity)**

*   **Entry Point:** A new "Discover" item will be added to the bottom navigation bar.
*   **Navigation Indexing Change:**
    *   **Before:** Home (0), Search (1), Bookings (2), Profile (3)
    *   **After:** Home (0), Search (1), Bookings (2), **Discover (3)**, Profile (4)
*   **`GoRouter` Configuration Changes:**
    1.  Add a new route to the `ShellRoute`:
        ```dart
        GoRoute(
          path: '/discover',
          builder: (context, state) => const AffiliateOffersBrowserScreen(),
        ),
        ```
    2.  Update the bottom navigation bar widget to have 5 items in the new order.
    3.  Update the `_calculateSelectedIndex` method to correctly reflect the new indices:
        ```dart
        // ... inside _calculateSelectedIndex ...
        if (location.startsWith('/bookings')) return 2;
        if (location.startsWith('/discover')) return 3; // New
        if (location.startsWith('/profile')) return 4;  // Updated
        return 0; // Default
        ```
    4.  Update the `_onItemTapped` method for the new indices:
        ```dart
        // ... inside _onItemTapped ...
        case 2: context.go('/bookings'); break;
        case 3: context.go('/discover'); break; // New
        case 4: context.go('/profile'); break;  // Updated
        ```

**6. Dependencies & Build Steps**

*   **Dependencies:** No new packages required.
*   **Build Command:** After creating/modifying `freezed` models, run `flutter pub run build_runner build --delete-conflicting-outputs`.