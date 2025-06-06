import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for selected time range
final selectedTimeRangeProvider = StateProvider<String>((ref) => '30d');
