Hello Augment Coder,

We are applying the LFS: **LFS-01: Implement Affiliate Offer Browser Screen (UI & Placeholder State)**. This is a complex task requiring new file creation and a code generation step. Follow these steps sequentially and do not proceed to the next step until the current one is verified.

**Base Commit:** `646eac7` on branch `shivji`.

### Step 1: Create New Directories ###
1.1. Navigate to the `nestery-flutter/lib/features/` directory.
1.2. Create a new directory named `affiliate_offers_browser`.
1.3. Inside `affiliate_offers_browser`, create the following subdirectories: `data`, `domain`, `presentation`.
1.4. Inside `data`, create `models` and `repositories`.
1.5. Inside `domain`, create `entities` and `repositories`.
1.6. Inside `presentation`, create `providers`, `screens`, and `widgets`.
1.7. VERIFY & REPORT: Confirm that the following directory structure exists: `nestery-flutter/lib/features/affiliate_offers_browser/{data/{models,repositories},domain/{entities,repositories},presentation/{providers,screens,widgets}}`.

### Step 2: Create New Files ###
2.1. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/data/models/partner_category.dart`. Paste the following exact content:
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
2.2. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart`. Paste the following exact content:
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
2.3. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart`. Paste the following exact content:
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
2.4. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart`. Paste the following exact content:
     ```dart
     import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

     abstract class AffiliateOffersRepository {
       Future<List<OfferCardViewModel>> getOffers();
     }
     ```
2.5. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart`. Paste the following exact content:
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
2.6. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart`. Paste the following exact content:
     ```dart
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
     ```
2.7. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart`. Paste the following exact content:
     ```dart
     import 'package:cached_network_image/cached_network_image.dart';
     import 'package:flutter/material.dart';
     import 'package:intl/intl.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

     class OfferCardWidget extends StatelessWidget {
       final OfferCardViewModel offer;

       const OfferCardWidget({super.key, required this.offer});

       @override
       Widget build(BuildContext context) {
         final theme = Theme.of(context);
         final commissionText = offer.commissionRateMin == offer.commissionRateMax
             ? '${offer.commissionRateMin.toStringAsFixed(1)}%'
             : '${offer.commissionRateMin.toStringAsFixed(1)}% - ${offer.commissionRateMax.toStringAsFixed(1)}%';

         return Card(
           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           elevation: 2,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           child: Padding(
             padding: const EdgeInsets.all(12.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 ListTile(
                   contentPadding: EdgeInsets.zero,
                   leading: CachedNetworkImage(
                     imageUrl: offer.partnerLogoUrl ?? 'https://placehold.co/100x100/e0e0e0/000000.png?text=Logo',
                     placeholder: (context, url) => const CircleAvatar(
                       backgroundColor: Colors.grey,
                       child: CircularProgressIndicator(),
                     ),
                     errorWidget: (context, url, error) => const CircleAvatar(
                       backgroundColor: Colors.grey,
                       child: Icon(Icons.business),
                     ),
                     imageBuilder: (context, imageProvider) => CircleAvatar(
                       backgroundImage: imageProvider,
                     ),
                   ),
                   title: Text(offer.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                   subtitle: Text(offer.partnerName, style: theme.textTheme.bodyMedium),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   offer.description,
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                   style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                 ),
                 const SizedBox(height: 12),
                 Wrap(
                   spacing: 8.0,
                   runSpacing: 4.0,
                   children: [
                     Chip(
                       avatar: Icon(offer.category.icon, size: 18),
                       label: Text(offer.category.displayName),
                       padding: const EdgeInsets.symmetric(horizontal: 8),
                     ),
                     Chip(
                       avatar: const Icon(Icons.percent, size: 18),
                       label: Text('Commission: $commissionText'),
                       backgroundColor: Colors.green.shade100,
                     ),
                     Chip(
                       avatar: const Icon(Icons.calendar_today, size: 18),
                       label: Text('Expires: ${DateFormat.yMMMd().format(offer.validTo)}'),
                       backgroundColor: Colors.orange.shade100,
                     ),
                   ],
                 ),
               ],
             ),
           ),
         );
       }
     }
     ```
2.8. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart`. Paste the following exact content:
     ```dart
     import 'package:flutter/material.dart';
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';

     class OfferFilterWidgets extends ConsumerWidget {
       const OfferFilterWidgets({super.key});

       @override
       Widget build(BuildContext context, WidgetRef ref) {
         final filterNotifier = ref.read(offerFilterProvider.notifier);

         return Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             children: [
               TextField(
                 decoration: const InputDecoration(
                   labelText: 'Search Offers',
                   hintText: 'Search by title, partner, or description...',
                   prefixIcon: Icon(Icons.search),
                   border: OutlineInputBorder(),
                 ),
                 onChanged: (query) => filterNotifier.updateSearchQuery(query),
               ),
               const SizedBox(height: 12),
               DropdownButtonFormField<PartnerCategoryEnum?>(
                 value: ref.watch(offerFilterProvider).selectedCategory,
                 decoration: const InputDecoration(
                   labelText: 'Category',
                   border: OutlineInputBorder(),
                 ),
                 items: [
                   const DropdownMenuItem<PartnerCategoryEnum?>(
                     value: null,
                     child: Text('All Categories'),
                   ),
                   ...PartnerCategoryEnum.values.map((category) {
                     return DropdownMenuItem<PartnerCategoryEnum?>(
                       value: category,
                       child: Row(
                         children: [
                           Icon(category.icon, size: 20),
                           const SizedBox(width: 8),
                           Text(category.displayName),
                         ],
                       ),
                     );
                   }).toList(),
                 ],
                 onChanged: (category) => filterNotifier.updateCategory(category),
               ),
             ],
           ),
         );
       }
     }
     ```
2.9. Create file at `nestery-flutter/lib/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart`. Paste the following exact content:
     ```dart
     import 'package:flutter/material.dart';
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart';
     import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart';
     import 'package:shimmer/shimmer.dart';

     class AffiliateOffersBrowserScreen extends ConsumerWidget {
       const AffiliateOffersBrowserScreen({super.key});

       @override
       Widget build(BuildContext context, WidgetRef ref) {
         final offersAsync = ref.watch(affiliateOffersProvider);
         final filteredOffers = ref.watch(filteredOffersProvider);

         return Scaffold(
           appBar: AppBar(
             title: const Text('Discover Offers'),
           ),
           body: Column(
             children: [
               const OfferFilterWidgets(),
               Expanded(
                 child: offersAsync.when(
                   loading: () => _buildLoadingShimmer(),
                   error: (error, stackTrace) => _buildErrorWidget(context, ref, error),
                   data: (_) {
                     if (filteredOffers.isEmpty) {
                       return _buildEmptyState(context, ref);
                     }
                     return ListView.builder(
                       itemCount: filteredOffers.length,
                       itemBuilder: (context, index) {
                         final offer = filteredOffers[index];
                         return OfferCardWidget(offer: offer);
                       },
                     );
                   },
                 ),
               ),
             ],
           ),
         );
       }

       Widget _buildLoadingShimmer() {
         return ListView.builder(
           itemCount: 4,
           itemBuilder: (context, index) {
             return Shimmer.fromColors(
               baseColor: Colors.grey!,
               highlightColor: Colors.grey!,
               child: Card(
                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Padding(
                   padding: const EdgeInsets.all(12.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           const CircleAvatar(radius: 24),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Container(width: double.infinity, height: 16, color: Colors.white),
                                 const SizedBox(height: 8),
                                 Container(width: 100, height: 14, color: Colors.white),
                               ],
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 12),
                       Container(width: double.infinity, height: 14, color: Colors.white),
                       const SizedBox(height: 8),
                       Container(width: double.infinity, height: 14, color: Colors.white),
                       const SizedBox(height: 12),
                       Row(
                         children: [
                           Container(width: 80, height: 30, color: Colors.white, margin: const EdgeInsets.only(right: 8)),
                           Container(width: 120, height: 30, color: Colors.white),
                         ],
                       )
                     ],
                   ),
                 ),
               ),
             );
           },
         );
       }

       Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
         return Center(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.error_outline, color: Colors.red, size: 60),
                 const SizedBox(height: 16),
                 Text(
                   'Failed to load offers',
                   style: Theme.of(context).textTheme.headlineSmall,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 8),
                 Text(
                   error.toString(),
                   style: Theme.of(context).textTheme.bodyMedium,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 24),
                 ElevatedButton.icon(
                   onPressed: () => ref.refresh(affiliateOffersProvider),
                   icon: const Icon(Icons.refresh),
                   label: const Text('Retry'),
                 ),
               ],
             ),
           ),
         );
       }

       Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
         return Center(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.search_off, size: 80, color: Colors.grey),
                 const SizedBox(height: 16),
                 Text(
                   'No Offers Found',
                   style: Theme.of(context).textTheme.headlineSmall,
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'Try adjusting your search or filters.',
                   style: Theme.of(context).textTheme.bodyMedium,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 24),
                 ElevatedButton(
                   onPressed: () => ref.read(offerFilterProvider.notifier).clearFilters(),
                   child: const Text('Clear Filters'),
                 ),
               ],
             ),
           ),
         );
       }
     }
     ```
2.10. VERIFY & REPORT: Confirm all 9 new files have been created successfully.

### Step 3: Run Build/Generation Commands ###
3.1. CRITICAL: In the `nestery-flutter` directory, run the command: `flutter pub run build_runner build --delete-conflicting-outputs`.
3.2. VERIFY & REPORT: Did the command succeed? Do the files `offer_card_view_model.freezed.dart` and `offer_filter_provider.freezed.dart` now exist in their respective directories? **If it failed, STOP and report the full error.**

### Step 4: Modify Existing File ###
4.1. Open file at `nestery-flutter/lib/core/routing/app_router.dart`.
4.2. Apply the following specific changes:
    *   Add the import: `import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart';`
    *   Add the new `GoRoute` for `/discover` inside the `StatefulShellRoute`.
    *   Add the new `BottomNavigationBarItem` for "Discover" at index 3.
    *   Update the `_calculateSelectedIndex` method to handle the new `'/discover'` path at index 3 and shift `'/profile'` to index 4.
    *   Update the `_onItemTapped` method to handle the `go('/discover')` for case 3 and shift `go('/profile')` to case 4.
    *   The final file should reflect the changes from the diff provided in ` ' @diff.md ' `.
4.3. VERIFY & REPORT: Confirm all changes have been applied correctly to `app_router.dart`.

### Step 5: Final Verification ###
5.1. Run `flutter analyze` in the `nestery-flutter` directory.
5.2. Run all existing Flutter tests to ensure zero regressions.
5.3. Build the application in debug mode (`flutter build apk --debug`).
5.4. Manually run the app on an emulator or device.
5.5. VERIFY & REPORT: Does `flutter analyze` report zero issues? Do all tests pass? Does the app build successfully? When running the app, is the new "Discover" tab present in the bottom navigation? Does tapping it navigate to the new screen and display the offers correctly after a brief loading shimmer? Do the search and filter controls work?