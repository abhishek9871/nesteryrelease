import 'package:freezed_annotation/freezed_annotation.dart';
part 'earnings_summary_data.freezed.dart';

@freezed
class EarningsSummaryData with _$EarningsSummaryData {
  const factory EarningsSummaryData({
    required double totalEarnings,
    required double pendingPayout,
    required double thisMonthEarnings,
    required double lastPayoutAmount,
    DateTime? lastPayoutDate,
    @Default('USD') String currency,
  }) = _EarningsSummaryData;
}
