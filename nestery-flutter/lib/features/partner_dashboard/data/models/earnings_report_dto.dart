import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_report_dto.freezed.dart';
part 'earnings_report_dto.g.dart';

@freezed
class EarningsSummaryDto with _$EarningsSummaryDto {
  const factory EarningsSummaryDto({
    required double totalEarnings,
    required double pendingPayout,
    required double thisMonthEarnings,
    required double lastPayoutAmount,
    DateTime? lastPayoutDate,
    @Default('USD') String currency,
  }) = _EarningsSummaryDto;

  factory EarningsSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryDtoFromJson(json);
}

@freezed
class EarningTransactionDto with _$EarningTransactionDto {
  const factory EarningTransactionDto({
    required String id,
    required DateTime transactionDate,
    required String offerTitle,
    required String offerId,
    required double amountEarned,
    required String currency,
    required String status,
  }) = _EarningTransactionDto;

  factory EarningTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$EarningTransactionDtoFromJson(json);
}

@freezed
class EarningsReportDataDto with _$EarningsReportDataDto {
  const factory EarningsReportDataDto({
    required EarningsSummaryDto summary,
    required List<EarningTransactionDto> transactions,
  }) = _EarningsReportDataDto;

  factory EarningsReportDataDto.fromJson(Map<String, dynamic> json) =>
      _$EarningsReportDataDtoFromJson(json);
}
