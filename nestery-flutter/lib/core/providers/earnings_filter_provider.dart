import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/partner_dashboard/data/models/earnings_filter.dart';

/// Provider for earnings filter
final earningsFilterProvider = StateProvider<EarningsFilter>((ref) => const EarningsFilter());
