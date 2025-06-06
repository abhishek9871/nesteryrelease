import 'package:freezed_annotation/freezed_annotation.dart';
import 'dashboard_metrics_dto.dart';
import 'earnings_report_dto.dart';
import 'partner_offers_dto.dart';

part 'partner_dashboard_data_dto.freezed.dart';
part 'partner_dashboard_data_dto.g.dart';

@freezed
class PartnerDashboardDataDto with _$PartnerDashboardDataDto {
  const factory PartnerDashboardDataDto({
    required DashboardMetricsDto dashboardMetrics,
    required EarningsReportDataDto earningsReport,
    required List<OfferListItemDto> partnerOffers,
  }) = _PartnerDashboardDataDto;

  factory PartnerDashboardDataDto.fromJson(Map<String, dynamic> json) =>
      _$PartnerDashboardDataDtoFromJson(json);
}
