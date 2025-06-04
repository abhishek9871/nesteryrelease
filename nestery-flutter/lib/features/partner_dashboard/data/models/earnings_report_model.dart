import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_report_model.freezed.dart';

@freezed
class EarningsReportModel with _$EarningsReportModel {
  const factory EarningsReportModel({
    required String reportId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalEarnings,
    // TODO: Add more fields as per FRS (clicks, conversions, commissions by offer/link)
    // Example: List<EarningDetail> details,
  }) = _EarningsReportModel;
}
