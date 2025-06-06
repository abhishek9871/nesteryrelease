import 'package:freezed_annotation/freezed_annotation.dart';
import 'earnings_summary_data.dart';
import 'earning_transaction_item.dart';
part 'earnings_report_data.freezed.dart';

@freezed
class EarningsReportData with _$EarningsReportData {
  const factory EarningsReportData({
    required EarningsSummaryData summary,
    required List<EarningTransactionItem> transactions,
  }) = _EarningsReportData;
}
