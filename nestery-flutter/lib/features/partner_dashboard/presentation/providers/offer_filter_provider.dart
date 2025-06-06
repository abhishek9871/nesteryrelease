// nestery-flutter/lib/features/partner_dashboard/presentation/providers/offer_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OfferFilterStatus { all, active, inactive, pending, expired }

final offerFilterStatusProvider =
    StateProvider<OfferFilterStatus>((ref) => OfferFilterStatus.all);
