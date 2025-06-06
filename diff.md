diff --git a/lib/core/routing/app_router.dart b/lib/core/routing/app_router.dart
index 0313851..8861619 100644
--- a/lib/core/routing/app_router.dart
+++ b/lib/core/routing/app_router.dart
@@ -16,6 +16,7 @@
 import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/earnings_report_screen.dart';
 import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/partner_settings_screen.dart';
 import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/offer_edit_screen.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart';
 import 'package:nestery_flutter/utils/constants.dart';
 
 class AppRouter {
@@ -141,6 +142,12 @@
             ]
           ),
 
+          // Discover tab
+          GoRoute(
+            path: '/discover',
+            builder: (context, state) => const AffiliateOffersBrowserScreen(),
+          ),
+
           // Profile tab
           GoRoute(
             path: '/profile',
@@ -232,6 +239,11 @@
             activeIcon: Icon(Icons.book),
             label: 'Bookings',
           ),
+          BottomNavigationBarItem(
+            icon: Icon(Icons.explore_outlined),
+            activeIcon: Icon(Icons.explore),
+            label: 'Discover',
+          ),
           BottomNavigationBarItem(
             icon: Icon(Icons.person_outline),
             activeIcon: Icon(Icons.person),
             label: 'Profile',
@@ -253,8 +265,11 @@
     if (location.startsWith('/bookings')) {
       return 2;
     }
+    if (location.startsWith('/discover')) {
+      return 3;
+    }
     if (location.startsWith('/profile')) {
-      return 3;
+      return 4;
     }
     return 0;
   }
@@ -271,7 +286,10 @@
       case 2:
         context.go('/bookings');
         break;
       case 3:
+        context.go('/discover');
+        break;
+      case 4:
         context.go('/profile');
         break;
     }
diff --git a/lib/features/affiliate_offers_browser/data/models/partner_category.dart b/lib/features/affiliate_offers_browser/data/models/partner_category.dart
new file mode 100644
index 0000000..6401314
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/data/models/partner_category.dart
@@ -0,0 +1,43 @@
+import 'package:flutter/material.dart';
+
+enum PartnerCategoryEnum {
+  TOUR_OPERATOR,
+  ACTIVITY_PROVIDER,
+  RESTAURANT,
+  TRANSPORTATION,
+  ECOMMERCE,
+}
+
+extension PartnerCategoryExtension on PartnerCategoryEnum {
+  String get displayName {
+    switch (this) {
+      case PartnerCategoryEnum.TOUR_OPERATOR:
+        return 'Tours';
+      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
+        return 'Activities';
+      case PartnerCategoryEnum.RESTAURANT:
+        return 'Restaurants';
+      case PartnerCategoryEnum.TRANSPORTATION:
+        return 'Transport';
+      case PartnerCategoryEnum.ECOMMERCE:
+        return 'Gear';
+    }
+  }
+
+  IconData get icon {
+    switch (this) {
+      case PartnerCategoryEnum.TOUR_OPERATOR:
+        return Icons.tour;
+      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
+        return Icons.local_activity;
+      case PartnerCategoryEnum.RESTAURANT:
+        return Icons.restaurant;
+      case PartnerCategoryEnum.TRANSPORTATION:
+        return Icons.directions_car;
+      case PartnerCategoryEnum.ECOMMERCE:
+        return Icons.shopping_bag;
+    }
+  }
+}
diff --git a/lib/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart b/lib/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart
new file mode 100644
index 0000000..6636735
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart
@@ -0,0 +1,71 @@
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';
+
+final affiliateOffersRepositoryProvider = Provider<AffiliateOffersRepository>((ref) {
+  return AffiliateOffersRepositoryImpl();
+});
+
+class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
+  @override
+  Future<List<OfferCardViewModel>> getOffers() async {
+    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
+    return _mockOfferData;
+  }
+}
+
+final List<OfferCardViewModel> _mockOfferData = [
+  const OfferCardViewModel(
+    offerId: 'tour-001',
+    title: 'Goa Beach Adventure Tour',
+    partnerName: 'Coastal Adventures',
+    category: PartnerCategoryEnum.TOUR_OPERATOR,
+    description: 'Experience the best beaches of Goa with our guided tour including water sports and local cuisine.',
+    commissionRateMin: 15.0,
+    commissionRateMax: 20.0,
+    validTo: DateTime.now().add(const Duration(days: 30)),
+    partnerLogoUrl: 'https://placehold.co/100x100.png',
+    isActive: true,
+  ),
+  const OfferCardViewModel(
+    offerId: 'restaurant-001',
+    title: '20% Off at Spice Garden Restaurant',
+    partnerName: 'Spice Garden',
+    category: PartnerCategoryEnum.RESTAURANT,
+    description: 'Authentic Indian cuisine with a modern twist. Valid for dinner bookings.',
+    commissionRateMin: 10.0,
+    commissionRateMax: 10.0,
+    validTo: DateTime.now().add(const Duration(days: 15)),
+    partnerLogoUrl: null,
+    isActive: true,
+  ),
+  const OfferCardViewModel(
+    offerId: 'transport-001',
+    title: 'Airport Transfer Service',
+    partnerName: 'QuickRide Cabs',
+    category: PartnerCategoryEnum.TRANSPORTATION,
+    description: 'Reliable airport transfers with professional drivers. 24/7 availability.',
+    commissionRateMin: 8.0,
+    commissionRateMax: 12.0,
+    validTo: DateTime.now().add(const Duration(days: 60)),
+    partnerLogoUrl: 'https://placehold.co/100x100.png',
+    isActive: true,
+  ),
+  const OfferCardViewModel(
+    offerId: 'ecommerce-001',
+    title: 'Travel Gear Essentials',
+    partnerName: 'TravelMart',
+    category: PartnerCategoryEnum.ECOMMERCE,
+    description: 'Premium travel accessories and luggage with free shipping on orders above ₹2000.',
+    commissionRateMin: 8.0,
+    commissionRateMax: 12.0,
+    validTo: DateTime.now().add(const Duration(days: 45)),
+    partnerLogoUrl: 'https://placehold.co/100x100.png',
+    isActive: false, // For testing the 'activeOnly' filter
+  ),
+];
diff --git a/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart b/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart
new file mode 100644
index 0000000..7451996
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart
@@ -0,0 +1,19 @@
+import 'package:freezed_annotation/freezed_annotation.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
+
+part 'offer_card_view_model.freezed.dart';
+
+@freezed
+class OfferCardViewModel with _$OfferCardViewModel {
+  const factory OfferCardViewModel({
+    required String offerId,
+    required String title,
+    required String partnerName,
+    required PartnerCategoryEnum category,
+    required String description,
+    required double commissionRateMin,
+    required double commissionRateMax,
+    required DateTime validTo,
+    String? partnerLogoUrl,
+    required bool isActive,
+  }) = _OfferCardViewModel;
+}
diff --git a/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.freezed.dart b/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.freezed.dart
new file mode 100644
index 0000000..35c755c
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/domain/entities/offer_card_view_model.freezed.dart
@@ -0,0 +1,223 @@
+// coverage:ignore-file
+// GENERATED CODE - DO NOT MODIFY BY HAND
+// ignore_for_file: type=lint
+// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
+
+part of 'offer_card_view_model.dart';
+
+// **************************************************************************
+// FreezedGenerator
+// **************************************************************************
+
+T _$identity<T>(T value) => value;
+
+final _privateConstructorUsedError = UnsupportedError(
+    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');
+
+/// @nodoc
+mixin _$OfferCardViewModel {
+  String get offerId => throw _privateConstructorUsedError;
+  String get title => throw _privateConstructorUsedError;
+  String get partnerName => throw _privateConstructorUsedError;
+  PartnerCategoryEnum get category => throw _privateConstructorUsedError;
+  String get description => throw _privateConstructorUsedError;
+  double get commissionRateMin => throw _privateConstructorUsedError;
+  double get commissionRateMax => throw _privateConstructorUsedError;
+  DateTime get validTo => throw _privateConstructorUsedError;
+  String? get partnerLogoUrl => throw _privateConstructorUsedError;
+  bool get isActive => throw _privateConstructorUsedError;
+
+  @JsonKey(ignore: true)
+  $OfferCardViewModelCopyWith<OfferCardViewModel> get copyWith =>
+      throw _privateConstructorUsedError;
+}
+
+/// @nodoc
+abstract class $OfferCardViewModelCopyWith<$Res> {
+  factory $OfferCardViewModelCopyWith(
+          OfferCardViewModel value, $Res Function(OfferCardViewModel) then) =
+      _$OfferCardViewModelCopyWithImpl<$Res, OfferCardViewModel>;
+  @useResult
+  $Res call(
+      {String offerId,
+      String title,
+      String partnerName,
+      PartnerCategoryEnum category,
+      String description,
+      double commissionRateMin,
+      double commissionRateMax,
+      DateTime validTo,
+      String? partnerLogoUrl,
+      bool isActive});
+}
+
+/// @nodoc
+class _$OfferCardViewModelCopyWithImpl<$Res, $Val extends OfferCardViewModel>
+    implements $OfferCardViewModelCopyWith<$Res> {
+  _$OfferCardViewModelCopyWithImpl(this._value, this._then);
+
+  // ignore: unused_field
+  final $Val _value;
+  // ignore: unused_field
+  final $Res Function($Val) _then;
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? offerId = null,
+    Object? title = null,
+    Object? partnerName = null,
+    Object? category = null,
+    Object? description = null,
+    Object? commissionRateMin = null,
+    Object? commissionRateMax = null,
+    Object? validTo = null,
+    Object? partnerLogoUrl = freezed,
+    Object? isActive = null,
+  }) {
+    return _then(_value.copyWith(
+      offerId: null == offerId
+          ? _value.offerId
+          : offerId // ignore: cast_nullable_to_non_nullable
+              as String,
+      title: null == title
+          ? _value.title
+          : title // ignore: cast_nullable_to_non_nullable
+              as String,
+      partnerName: null == partnerName
+          ? _value.partnerName
+          : partnerName // ignore: cast_nullable_to_non_nullable
+              as String,
+      category: null == category
+          ? _value.category
+          : category // ignore: cast_nullable_to_non_nullable
+              as PartnerCategoryEnum,
+      description: null == description
+          ? _value.description
+          : description // ignore: cast_nullable_to_non_nullable
+              as String,
+      commissionRateMin: null == commissionRateMin
+          ? _value.commissionRateMin
+          : commissionRateMin // ignore: cast_nullable_to_non_nullable
+              as double,
+      commissionRateMax: null == commissionRateMax
+          ? _value.commissionRateMax
+          : commissionRateMax // ignore: cast_nullable_to_non_nullable
+              as double,
+      validTo: null == validTo
+          ? _value.validTo
+          : validTo // ignore: cast_nullable_to_non_nullable
+              as DateTime,
+      partnerLogoUrl: freezed == partnerLogoUrl
+          ? _value.partnerLogoUrl
+          : partnerLogoUrl // ignore: cast_nullable_to_non_nullable
+              as String?,
+      isActive: null == isActive
+          ? _value.isActive
+          : isActive // ignore: cast_nullable_to_non_nullable
+              as bool,
+    ) as $Val);
+  }
+}
+
+/// @nodoc
+abstract class _$$OfferCardViewModelImplCopyWith<$Res>
+    implements $OfferCardViewModelCopyWith<$Res> {
+  factory _$$OfferCardViewModelImplCopyWith(_$OfferCardViewModelImpl value,
+          $Res Function(_$OfferCardViewModelImpl) then) =
+      __$$OfferCardViewModelImplCopyWithImpl<$Res>;
+  @override
+  @useResult
+  $Res call(
+      {String offerId,
+      String title,
+      String partnerName,
+      PartnerCategoryEnum category,
+      String description,
+      double commissionRateMin,
+      double commissionRateMax,
+      DateTime validTo,
+      String? partnerLogoUrl,
+      bool isActive});
+}
+
+/// @nodoc
+class __$$OfferCardViewModelImplCopyWithImpl<$Res>
+    extends _$OfferCardViewModelCopyWithImpl<$Res, _$OfferCardViewModelImpl>
+    implements _$$OfferCardViewModelImplCopyWith<$Res> {
+  __$$OfferCardViewModelImplCopyWithImpl(_$OfferCardViewModelImpl _value,
+      $Res Function(_$OfferCardViewModelImpl) _then)
+      : super(_value, _then);
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? offerId = null,
+    Object? title = null,
+    Object? partnerName = null,
+    Object? category = null,
+    Object? description = null,
+    Object? commissionRateMin = null,
+    Object? commissionRateMax = null,
+    Object? validTo = null,
+    Object? partnerLogoUrl = freezed,
+    Object? isActive = null,
+  }) {
+    return _then(_$OfferCardViewModelImpl(
+      offerId: null == offerId
+          ? _value.offerId
+          : offerId // ignore: cast_nullable_to_non_nullable
+              as String,
+      title: null == title
+          ? _value.title
+          : title // ignore: cast_nullable_to_non_nullable
+              as String,
+      partnerName: null == partnerName
+          ? _value.partnerName
+          : partnerName // ignore: cast_nullable_to_non_nullable
+              as String,
+      category: null == category
+          ? _value.category
+          : category // ignore: cast_nullable_to_non_nullable
+              as PartnerCategoryEnum,
+      description: null == description
+          ? _value.description
+          : description // ignore: cast_nullable_to_non_nullable
+              as String,
+      commissionRateMin: null == commissionRateMin
+          ? _value.commissionRateMin
+          : commissionRateMin // ignore: cast_nullable_to_non_nullable
+              as double,
+      commissionRateMax: null == commissionRateMax
+          ? _value.commissionRateMax
+          : commissionRateMax // ignore: cast_nullable_to_non_nullable
+              as double,
+      validTo: null == validTo
+          ? _value.validTo
+          : validTo // ignore: cast_nullable_to_non_nullable
+              as DateTime,
+      partnerLogoUrl: freezed == partnerLogoUrl
+          ? _value.partnerLogoUrl
+          : partnerLogoUrl // ignore: cast_nullable_to_non_nullable
+              as String?,
+      isActive: null == isActive
+          ? _value.isActive
+          : isActive // ignore: cast_nullable_to_non_nullable
+              as bool,
+    ));
+  }
+}
+
+/// @nodoc
+
+class _$OfferCardViewModelImpl implements _OfferCardViewModel {
+  const _$OfferCardViewModelImpl(
+      {required this.offerId,
+      required this.title,
+      required this.partnerName,
+      required this.category,
+      required this.description,
+      required this.commissionRateMin,
+      required this.commissionRateMax,
+      required this.validTo,
+      this.partnerLogoUrl,
+      required this.isActive});
+
+  @override
+  final String offerId;
+  @override
+  final String title;
+  @override
+  final String partnerName;
+  @override
+  final PartnerCategoryEnum category;
+  @override
+  final String description;
+  @override
+  final double commissionRateMin;
+  @override
+  final double commissionRateMax;
+  @override
+  final DateTime validTo;
+  @override
+  final String? partnerLogoUrl;
+  @override
+  final bool isActive;
+
+  @override
+  String toString() {
+    return 'OfferCardViewModel(offerId: $offerId, title: $title, partnerName: $partnerName, category: $category, description: $description, commissionRateMin: $commissionRateMin, commissionRateMax: $commissionRateMax, validTo: $validTo, partnerLogoUrl: $partnerLogoUrl, isActive: $isActive)';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType &&
+            other is _$OfferCardViewModelImpl &&
+            (identical(other.offerId, offerId) || other.offerId == offerId) &&
+            (identical(other.title, title) || other.title == title) &&
+            (identical(other.partnerName, partnerName) ||
+                other.partnerName == partnerName) &&
+            (identical(other.category, category) ||
+                other.category == category) &&
+            (identical(other.description, description) ||
+                other.description == description) &&
+            (identical(other.commissionRateMin, commissionRateMin) ||
+                other.commissionRateMin == commissionRateMin) &&
+            (identical(other.commissionRateMax, commissionRateMax) ||
+                other.commissionRateMax == commissionRateMax) &&
+            (identical(other.validTo, validTo) || other.validTo == validTo) &&
+            (identical(other.partnerLogoUrl, partnerLogoUrl) ||
+                other.partnerLogoUrl == partnerLogoUrl) &&
+            (identical(other.isActive, isActive) ||
+                other.isActive == isActive));
+  }
+
+  @override
+  int get hashCode => Object.hash(
+      runtimeType,
+      offerId,
+      title,
+      partnerName,
+      category,
+      description,
+      commissionRateMin,
+      commissionRateMax,
+      validTo,
+      partnerLogoUrl,
+      isActive);
+
+  @JsonKey(ignore: true)
+  @override
+  @pragma('vm:prefer-inline')
+  _$$OfferCardViewModelImplCopyWith<_$OfferCardViewModelImpl> get copyWith =>
+      __$$OfferCardViewModelImplCopyWithImpl<_$OfferCardViewModelImpl>(
+          this, _$identity);
+}
+
+abstract class _OfferCardViewModel implements OfferCardViewModel {
+  const factory _OfferCardViewModel(
+      {required final String offerId,
+      required final String title,
+      required final String partnerName,
+      required final PartnerCategoryEnum category,
+      required final String description,
+      required final double commissionRateMin,
+      required final double commissionRateMax,
+      required final DateTime validTo,
+      final String? partnerLogoUrl,
+      required final bool isActive}) = _$OfferCardViewModelImpl;
+
+  @override
+  String get offerId;
+  @override
+  String get title;
+  @override
+  String get partnerName;
+  @override
+  PartnerCategoryEnum get category;
+  @override
+  String get description;
+  @override
+  double get commissionRateMin;
+  @override
+  double get commissionRateMax;
+  @override
+  DateTime get validTo;
+  @override
+  String? get partnerLogoUrl;
+  @override
+  bool get isActive;
+  @override
+  @JsonKey(ignore: true)
+  _$$OfferCardViewModelImplCopyWith<_$OfferCardViewModelImpl> get copyWith =>
+      throw _privateConstructorUsedError;
+}
diff --git a/lib/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart b/lib/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart
new file mode 100644
index 0000000..836488a
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart
@@ -0,0 +1,5 @@
+import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
+
+abstract class AffiliateOffersRepository {
+  Future<List<OfferCardViewModel>> getOffers();
+}
diff --git a/lib/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart b/lib/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart
new file mode 100644
index 0000000..7458145
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart
@@ -0,0 +1,29 @@
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';
+
+final affiliateOffersProvider = FutureProvider<List<OfferCardViewModel>>((ref) async {
+  final repository = ref.watch(affiliateOffersRepositoryProvider);
+  return repository.getOffers();
+});
+
+final filteredOffersProvider = Provider<List<OfferCardViewModel>>((ref) {
+  final offersAsync = ref.watch(affiliateOffersProvider);
+  final filter = ref.watch(offerFilterProvider);
+
+  return offersAsync.maybeWhen(
+    data: (offers) => offers.where((offer) {
+      if (filter.activeOnly && !offer.isActive) return false;
+      if (filter.selectedCategory != null && offer.category != filter.selectedCategory) return false;
+      if (offer.commissionRateMax < filter.minCommissionRate || offer.commissionRateMin > filter.maxCommissionRate) return false;
+      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
+        final query = filter.searchQuery!.toLowerCase();
+        return offer.title.toLowerCase().contains(query) ||
+               offer.description.toLowerCase().contains(query) ||
+               offer.partnerName.toLowerCase().contains(query);
+      }
+      return true;
+    }).toList(),
+    orElse: () => [],
+  );
+});
diff --git a/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart b/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart
new file mode 100644
index 0000000..6064560
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart
@@ -0,0 +1,30 @@
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:freezed_annotation/freezed_annotation.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
+
+part 'offer_filter_provider.freezed.dart';
+
+@freezed
+class OfferFilterState with _$OfferFilterState {
+  const factory OfferFilterState({
+    String? searchQuery,
+    PartnerCategoryEnum? selectedCategory,
+    @Default(true) bool activeOnly,
+    @Default(8.0) double minCommissionRate,
+    @Default(20.0) double maxCommissionRate,
+  }) = _OfferFilterState;
+}
+
+class OfferFilterNotifier extends StateNotifier<OfferFilterState> {
+  OfferFilterNotifier() : super(const OfferFilterState());
+
+  void updateSearchQuery(String? query) => state = state.copyWith(searchQuery: query);
+  void updateCategory(PartnerCategoryEnum? category) => state = state.copyWith(selectedCategory: category);
+  void updateCommissionRange(double min, double max) => state = state.copyWith(minCommissionRate: min, maxCommissionRate: max);
+  void clearFilters() => state = const OfferFilterState();
+}
+
+final offerFilterProvider = StateNotifierProvider<OfferFilterNotifier, OfferFilterState>(
+  (ref) => OfferFilterNotifier(),
+);
diff --git a/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.freezed.dart b/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.freezed.dart
new file mode 100644
index 0000000..188c03d
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.freezed.dart
@@ -0,0 +1,215 @@
+// coverage:ignore-file
+// GENERATED CODE - DO NOT MODIFY BY HAND
+// ignore_for_file: type=lint
+// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
+
+part of 'offer_filter_provider.dart';
+
+// **************************************************************************
+// FreezedGenerator
+// **************************************************************************
+
+T _$identity<T>(T value) => value;
+
+final _privateConstructorUsedError = UnsupportedError(
+    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');
+
+/// @nodoc
+mixin _$OfferFilterState {
+  String? get searchQuery => throw _privateConstructorUsedError;
+  PartnerCategoryEnum? get selectedCategory =>
+      throw _privateConstructorUsedError;
+  bool get activeOnly => throw _privateConstructorUsedError;
+  double get minCommissionRate => throw _privateConstructorUsedError;
+  double get maxCommissionRate => throw _privateConstructorUsedError;
+
+  @JsonKey(ignore: true)
+  $OfferFilterStateCopyWith<OfferFilterState> get copyWith =>
+      throw _privateConstructorUsedError;
+}
+
+/// @nodoc
+abstract class $OfferFilterStateCopyWith<$Res> {
+  factory $OfferFilterStateCopyWith(
+          OfferFilterState value, $Res Function(OfferFilterState) then) =
+      _$OfferFilterStateCopyWithImpl<$Res, OfferFilterState>;
+  @useResult
+  $Res call(
+      {String? searchQuery,
+      PartnerCategoryEnum? selectedCategory,
+      bool activeOnly,
+      double minCommissionRate,
+      double maxCommissionRate});
+}
+
+/// @nodoc
+class _$OfferFilterStateCopyWithImpl<$Res, $Val extends OfferFilterState>
+    implements $OfferFilterStateCopyWith<$Res> {
+  _$OfferFilterStateCopyWithImpl(this._value, this._then);
+
+  // ignore: unused_field
+  final $Val _value;
+  // ignore: unused_field
+  final $Res Function($Val) _then;
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? searchQuery = freezed,
+    Object? selectedCategory = freezed,
+    Object? activeOnly = null,
+    Object? minCommissionRate = null,
+    Object? maxCommissionRate = null,
+  }) {
+    return _then(_value.copyWith(
+      searchQuery: freezed == searchQuery
+          ? _value.searchQuery
+          : searchQuery // ignore: cast_nullable_to_non_nullable
+              as String?,
+      selectedCategory: freezed == selectedCategory
+          ? _value.selectedCategory
+          : selectedCategory // ignore: cast_nullable_to_non_nullable
+              as PartnerCategoryEnum?,
+      activeOnly: null == activeOnly
+          ? _value.activeOnly
+          : activeOnly // ignore: cast_nullable_to_non_nullable
+              as bool,
+      minCommissionRate: null == minCommissionRate
+          ? _value.minCommissionRate
+          : minCommissionRate // ignore: cast_nullable_to_non_nullable
+              as double,
+      maxCommissionRate: null == maxCommissionRate
+          ? _value.maxCommissionRate
+          : maxCommissionRate // ignore: cast_nullable_to_non_nullable
+              as double,
+    ) as $Val);
+  }
+}
+
+/// @nodoc
+abstract class _$$OfferFilterStateImplCopyWith<$Res>
+    implements $OfferFilterStateCopyWith<$Res> {
+  factory _$$OfferFilterStateImplCopyWith(_$OfferFilterStateImpl value,
+          $Res Function(_$OfferFilterStateImpl) then) =
+      __$$OfferFilterStateImplCopyWithImpl<$Res>;
+  @override
+  @useResult
+  $Res call(
+      {String? searchQuery,
+      PartnerCategoryEnum? selectedCategory,
+      bool activeOnly,
+      double minCommissionRate,
+      double maxCommissionRate});
+}
+
+/// @nodoc
+class __$$OfferFilterStateImplCopyWithImpl<$Res>
+    extends _$OfferFilterStateCopyWithImpl<$Res, _$OfferFilterStateImpl>
+    implements _$$OfferFilterStateImplCopyWith<$Res> {
+  __$$OfferFilterStateImplCopyWithImpl(_$OfferFilterStateImpl _value,
+      $Res Function(_$OfferFilterStateImpl) _then)
+      : super(_value, _then);
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? searchQuery = freezed,
+    Object? selectedCategory = freezed,
+    Object? activeOnly = null,
+    Object? minCommissionRate = null,
+    Object? maxCommissionRate = null,
+  }) {
+    return _then(_$OfferFilterStateImpl(
+      searchQuery: freezed == searchQuery
+          ? _value.searchQuery
+          : searchQuery // ignore: cast_nullable_to_non_nullable
+              as String?,
+      selectedCategory: freezed == selectedCategory
+          ? _value.selectedCategory
+          : selectedCategory // ignore: cast_nullable_to_non_nullable
+              as PartnerCategoryEnum?,
+      activeOnly: null == activeOnly
+          ? _value.activeOnly
+          : activeOnly // ignore: cast_nullable_to_non_nullable
+              as bool,
+      minCommissionRate: null == minCommissionRate
+          ? _value.minCommissionRate
+          : minCommissionRate // ignore: cast_nullable_to_non_nullable
+              as double,
+      maxCommissionRate: null == maxCommissionRate
+          ? _value.maxCommissionRate
+          : maxCommissionRate // ignore: cast_nullable_to_non_nullable
+              as double,
+    ));
+  }
+}
+
+/// @nodoc
+
+class _$OfferFilterStateImpl implements _OfferFilterState {
+  const _$OfferFilterStateImpl(
+      {this.searchQuery,
+      this.selectedCategory,
+      this.activeOnly = true,
+      this.minCommissionRate = 8.0,
+      this.maxCommissionRate = 20.0});
+
+  @override
+  final String? searchQuery;
+  @override
+  final PartnerCategoryEnum? selectedCategory;
+  @override
+  @JsonKey()
+  final bool activeOnly;
+  @override
+  @JsonKey()
+  final double minCommissionRate;
+  @override
+  @JsonKey()
+  final double maxCommissionRate;
+
+  @override
+  String toString() {
+    return 'OfferFilterState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, activeOnly: $activeOnly, minCommissionRate: $minCommissionRate, maxCommissionRate: $maxCommissionRate)';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType &&
+            other is _$OfferFilterStateImpl &&
+            (identical(other.searchQuery, searchQuery) ||
+                other.searchQuery == searchQuery) &&
+            (identical(other.selectedCategory, selectedCategory) ||
+                other.selectedCategory == selectedCategory) &&
+            (identical(other.activeOnly, activeOnly) ||
+                other.activeOnly == activeOnly) &&
+            (identical(other.minCommissionRate, minCommissionRate) ||
+                other.minCommissionRate == minCommissionRate) &&
+            (identical(other.maxCommissionRate, maxCommissionRate) ||
+                other.maxCommissionRate == maxCommissionRate));
+  }
+
+  @override
+  int get hashCode => Object.hash(runtimeType, searchQuery, selectedCategory,
+      activeOnly, minCommissionRate, maxCommissionRate);
+
+  @JsonKey(ignore: true)
+  @override
+  @pragma('vm:prefer-inline')
+  _$$OfferFilterStateImplCopyWith<_$OfferFilterStateImpl> get copyWith =>
+      __$$OfferFilterStateImplCopyWithImpl<_$OfferFilterStateImpl>(
+          this, _$identity);
+}
+
+abstract class _OfferFilterState implements OfferFilterState {
+  const factory _OfferFilterState(
+      {final String? searchQuery,
+      final PartnerCategoryEnum? selectedCategory,
+      final bool activeOnly,
+      final double minCommissionRate,
+      final double maxCommissionRate}) = _$OfferFilterStateImpl;
+
+  @override
+  String? get searchQuery;
+  @override
+  PartnerCategoryEnum? get selectedCategory;
+  @override
+  bool get activeOnly;
+  @override
+  double get minCommissionRate;
+  @override
+  double get maxCommissionRate;
+  @override
+  @JsonKey(ignore: true)
+  _$$OfferFilterStateImplCopyWith<_$OfferFilterStateImpl> get copyWith =>
+      throw _privateConstructorUsedError;
+}
diff --git a/lib/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart b/lib/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart
new file mode 100644
index 0000000..3434190
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/screens/affiliate_offers_browser_screen.dart
@@ -0,0 +1,146 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart';
+import 'package:shimmer/shimmer.dart';
+
+class AffiliateOffersBrowserScreen extends ConsumerWidget {
+  const AffiliateOffersBrowserScreen({super.key});
+
+  @override
+  Widget build(BuildContext context, WidgetRef ref) {
+    final offersAsync = ref.watch(affiliateOffersProvider);
+    final filteredOffers = ref.watch(filteredOffersProvider);
+
+    return Scaffold(
+      appBar: AppBar(
+        title: const Text('Discover Offers'),
+      ),
+      body: Column(
+        children: [
+          const OfferFilterWidgets(),
+          Expanded(
+            child: offersAsync.when(
+              loading: () => _buildLoadingShimmer(),
+              error: (error, stackTrace) => _buildErrorWidget(context, ref, error),
+              data: (_) {
+                if (filteredOffers.isEmpty) {
+                  return _buildEmptyState(context, ref);
+                }
+                return ListView.builder(
+                  itemCount: filteredOffers.length,
+                  itemBuilder: (context, index) {
+                    final offer = filteredOffers[index];
+                    return OfferCardWidget(offer: offer);
+                  },
+                );
+              },
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildLoadingShimmer() {
+    return ListView.builder(
+      itemCount: 4,
+      itemBuilder: (context, index) {
+        return Shimmer.fromColors(
+          baseColor: Colors.grey[300]!,
+          highlightColor: Colors.grey[100]!,
+          child: Card(
+            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
+            child: Padding(
+              padding: const EdgeInsets.all(12.0),
+              child: Column(
+                crossAxisAlignment: CrossAxisAlignment.start,
+                children: [
+                  Row(
+                    children: [
+                      const CircleAvatar(radius: 24),
+                      const SizedBox(width: 12),
+                      Expanded(
+                        child: Column(
+                          crossAxisAlignment: CrossAxisAlignment.start,
+                          children: [
+                            Container(width: double.infinity, height: 16, color: Colors.white),
+                            const SizedBox(height: 8),
+                            Container(width: 100, height: 14, color: Colors.white),
+                          ],
+                        ),
+                      ),
+                    ],
+                  ),
+                  const SizedBox(height: 12),
+                  Container(width: double.infinity, height: 14, color: Colors.white),
+                  const SizedBox(height: 8),
+                  Container(width: double.infinity, height: 14, color: Colors.white),
+                  const SizedBox(height: 12),
+                  Row(
+                    children: [
+                      Container(width: 80, height: 30, color: Colors.white, margin: const EdgeInsets.only(right: 8)),
+                      Container(width: 120, height: 30, color: Colors.white),
+                    ],
+                  )
+                ],
+              ),
+            ),
+          ),
+        );
+      },
+    );
+  }
+
+  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
+    return Center(
+      child: Padding(
+        padding: const EdgeInsets.all(16.0),
+        child: Column(
+          mainAxisAlignment: MainAxisAlignment.center,
+          children: [
+            const Icon(Icons.error_outline, color: Colors.red, size: 60),
+            const SizedBox(height: 16),
+            Text(
+              'Failed to load offers',
+              style: Theme.of(context).textTheme.headlineSmall,
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 8),
+            Text(
+              error.toString(),
+              style: Theme.of(context).textTheme.bodyMedium,
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 24),
+            ElevatedButton.icon(
+              onPressed: () => ref.refresh(affiliateOffersProvider),
+              icon: const Icon(Icons.refresh),
+              label: const Text('Retry'),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
+    return Center(
+      child: Padding(
+        padding: const EdgeInsets.all(16.0),
+        child: Column(
+          mainAxisAlignment: MainAxisAlignment.center,
+          children: [
+            const Icon(Icons.search_off, size: 80, color: Colors.grey),
+            const SizedBox(height: 16),
+            Text(
+              'No Offers Found',
+              style: Theme.of(context).textTheme.headlineSmall,
+            ),
+            const SizedBox(height: 8),
+            Text(
+              'Try adjusting your search or filters.',
+              style: Theme.of(context).textTheme.bodyMedium,
+              textAlign: TextAlign.center,
+            ),
+            const SizedBox(height: 24),
+            ElevatedButton(
+              onPressed: () => ref.read(offerFilterProvider.notifier).clearFilters(),
+              child: const Text('Clear Filters'),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+}
diff --git a/lib/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart b/lib/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart
new file mode 100644
index 0000000..338634a
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart
@@ -0,0 +1,81 @@
+import 'package:cached_network_image/cached_network_image.dart';
+import 'package:flutter/material.dart';
+import 'package:intl/intl.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
+
+class OfferCardWidget extends StatelessWidget {
+  final OfferCardViewModel offer;
+
+  const OfferCardWidget({super.key, required this.offer});
+
+  @override
+  Widget build(BuildContext context) {
+    final theme = Theme.of(context);
+    final commissionText = offer.commissionRateMin == offer.commissionRateMax
+        ? '${offer.commissionRateMin.toStringAsFixed(1)}%'
+        : '${offer.commissionRateMin.toStringAsFixed(1)}% - ${offer.commissionRateMax.toStringAsFixed(1)}%';
+
+    return Card(
+      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
+      elevation: 2,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
+      child: Padding(
+        padding: const EdgeInsets.all(12.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            ListTile(
+              contentPadding: EdgeInsets.zero,
+              leading: CachedNetworkImage(
+                imageUrl: offer.partnerLogoUrl ?? 'https://placehold.co/100x100/e0e0e0/000000.png?text=Logo',
+                placeholder: (context, url) => const CircleAvatar(
+                  backgroundColor: Colors.grey,
+                  child: CircularProgressIndicator(),
+                ),
+                errorWidget: (context, url, error) => const CircleAvatar(
+                  backgroundColor: Colors.grey,
+                  child: Icon(Icons.business),
+                ),
+                imageBuilder: (context, imageProvider) => CircleAvatar(
+                  backgroundImage: imageProvider,
+                ),
+              ),
+              title: Text(offer.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
+              subtitle: Text(offer.partnerName, style: theme.textTheme.bodyMedium),
+            ),
+            const SizedBox(height: 8),
+            Text(
+              offer.description,
+              maxLines: 2,
+              overflow: TextOverflow.ellipsis,
+              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
+            ),
+            const SizedBox(height: 12),
+            Wrap(
+              spacing: 8.0,
+              runSpacing: 4.0,
+              children: [
+                Chip(
+                  avatar: Icon(offer.category.icon, size: 18),
+                  label: Text(offer.category.displayName),
+                  padding: const EdgeInsets.symmetric(horizontal: 8),
+                ),
+                Chip(
+                  avatar: const Icon(Icons.percent, size: 18),
+                  label: Text('Commission: $commissionText'),
+                  backgroundColor: Colors.green.shade100,
+                ),
+                Chip(
+                  avatar: const Icon(Icons.calendar_today, size: 18),
+                  label: Text('Expires: ${DateFormat.yMMMd().format(offer.validTo)}'),
+                  backgroundColor: Colors.orange.shade100,
+                ),
+              ],
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+}
diff --git a/lib/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart b/lib/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart
new file mode 100644
index 0000000..2020297
--- /dev/null
+++ b/lib/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart
@@ -0,0 +1,58 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
+import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';
+
+class OfferFilterWidgets extends ConsumerWidget {
+  const OfferFilterWidgets({super.key});
+
+  @override
+  Widget build(BuildContext context, WidgetRef ref) {
+    final filterNotifier = ref.read(offerFilterProvider.notifier);
+
+    return Padding(
+      padding: const EdgeInsets.all(16.0),
+      child: Column(
+        children: [
+          TextField(
+            decoration: const InputDecoration(
+              labelText: 'Search Offers',
+              hintText: 'Search by title, partner, or description...',
+              prefixIcon: Icon(Icons.search),
+              border: OutlineInputBorder(),
+            ),
+            onChanged: (query) => filterNotifier.updateSearchQuery(query),
+          ),
+          const SizedBox(height: 12),
+          DropdownButtonFormField<PartnerCategoryEnum?>(
+            value: ref.watch(offerFilterProvider).selectedCategory,
+            decoration: const InputDecoration(
+              labelText: 'Category',
+              border: OutlineInputBorder(),
+            ),
+            items: [
+              const DropdownMenuItem<PartnerCategoryEnum?>(
+                value: null,
+                child: Text('All Categories'),
+              ),
+              ...PartnerCategoryEnum.values.map((category) {
+                return DropdownMenuItem<PartnerCategoryEnum?>(
+                  value: category,
+                  child: Row(
+                    children: [
+                      Icon(category.icon, size: 20),
+                      const SizedBox(width: 8),
+                      Text(category.displayName),
+                    ],
+                  ),
+                );
+              }).toList(),
+            ],
+            onChanged: (category) => filterNotifier.updateCategory(category),
+          ),
+        ],
+      ),
+    );
+  }
+}