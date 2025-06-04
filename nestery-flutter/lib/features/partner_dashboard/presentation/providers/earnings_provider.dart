import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_report_model.dart';

// Placeholder for earnings data
final earningsProvider = FutureProvider<List<EarningsReportModel>>((ref) async {
  // TODO: Fetch actual earnings reports from repository
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return [
    EarningsReportModel(reportId: '1', periodStart: DateTime.now().subtract(const Duration(days: 30)), periodEnd: DateTime.now(), totalEarnings: 500.75),
  ];
});
