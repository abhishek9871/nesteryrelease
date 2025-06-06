import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earning_transaction_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_filter.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_report_data.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_summary_data.dart';

/// Manages the state of the earnings filters.
class EarningsFilterNotifier extends StateNotifier<EarningsFilter> {
  EarningsFilterNotifier() : super(const EarningsFilter());

  void updateDateRange(DateTimeRange? range) =>
      state = state.copyWith(dateRange: range);

  void updateStatus(EarningStatus? status) =>
      state = state.copyWith(status: status);

  void clearFilters() => state = const EarningsFilter();
}

final earningsFilterProvider =
    StateNotifierProvider<EarningsFilterNotifier, EarningsFilter>(
  (ref) => EarningsFilterNotifier(),
);

/// Provides the earnings report data, filtered by the `earningsFilterProvider`.
final earningsReportProvider = FutureProvider<EarningsReportData>((ref) async {
  final filter = ref.watch(earningsFilterProvider);

  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // --- Placeholder Data Generation ---

  // 1. Generate Summary Data
  final summary = EarningsSummaryData(
    totalEarnings: 12540.50,
    pendingPayout: 1850.75,
    thisMonthEarnings: 2130.25,
    lastPayoutAmount: 980.00,
    lastPayoutDate: DateTime.now().subtract(const Duration(days: 15)),
  );

  // 2. Generate a large list of sample transactions
  final random = Random();
  final allTransactions = List.generate(45, (i) {
    final date = DateTime.now().subtract(Duration(days: random.nextInt(90)));
    return EarningTransactionItem(
      id: 'TRN-00${i + 1}',
      transactionDate: date,
      offerTitle: 'Offer #${i + 1}: ${['Goa Tour', 'City Food Walk', 'Airport Shuttle', 'Travel Gear Sale'][random.nextInt(4)]}',
      offerId: 'OFF-${1000 + i}',
      amountEarned: 20.0 + random.nextDouble() * 150,
      currency: 'USD',
      status: EarningStatus.values[random.nextInt(EarningStatus.values.length)],
    );
  });

  // 3. Apply filters
  var filteredTransactions = allTransactions;

  // Apply date range filter
  if (filter.dateRange != null) {
    filteredTransactions = filteredTransactions.where((t) {
      return t.transactionDate.isAfter(filter.dateRange!.start) &&
          t.transactionDate.isBefore(filter.dateRange!.end);
    }).toList();
  }

  // Apply status filter
  if (filter.status != null) {
    filteredTransactions =
        filteredTransactions.where((t) => t.status == filter.status).toList();
  }

  // 4. Return the final data object
  return EarningsReportData(
    summary: summary,
    transactions: filteredTransactions,
  );
});
