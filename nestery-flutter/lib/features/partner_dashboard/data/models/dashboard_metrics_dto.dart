import 'package:freezed_annotation/freezed_annotation.dart';
import 'chart_data_dto.dart';

part 'dashboard_metrics_dto.freezed.dart';
part 'dashboard_metrics_dto.g.dart';

@freezed
class RevenueCardDataDto with _$RevenueCardDataDto {
  const factory RevenueCardDataDto({
    required double netEarnings,
    required double grossRevenueForCalc,
    required double partnerCommissionRate,
    required double previousPeriodNetEarnings,
  }) = _RevenueCardDataDto;

  factory RevenueCardDataDto.fromJson(Map<String, dynamic> json) =>
      _$RevenueCardDataDtoFromJson(json);
}

@freezed
class MonthlySalesCardDataDto with _$MonthlySalesCardDataDto {
  const factory MonthlySalesCardDataDto({
    required double monthlyGrossSales,
    required double nesteryCommissionRateForDisplay,
    required double previousPeriodGrossSales,
  }) = _MonthlySalesCardDataDto;

  factory MonthlySalesCardDataDto.fromJson(Map<String, dynamic> json) =>
      _$MonthlySalesCardDataDtoFromJson(json);
}

@freezed
class TrafficQualityCardDataDto with _$TrafficQualityCardDataDto {
  const factory TrafficQualityCardDataDto({
    required double conversionRateValue,
    required double previousPeriodConversionRate,
    required String qualityLabel,
    required int totalClicks,
    required int totalConversions,
  }) = _TrafficQualityCardDataDto;

  factory TrafficQualityCardDataDto.fromJson(Map<String, dynamic> json) =>
      _$TrafficQualityCardDataDtoFromJson(json);
}

@freezed
class ConversionRateCardDataDto with _$ConversionRateCardDataDto {
  const factory ConversionRateCardDataDto({
    required double conversionRateValue,
    required double previousPeriodConversionRate,
  }) = _ConversionRateCardDataDto;

  factory ConversionRateCardDataDto.fromJson(Map<String, dynamic> json) =>
      _$ConversionRateCardDataDtoFromJson(json);
}

@freezed
class DashboardMetricsDto with _$DashboardMetricsDto {
  const factory DashboardMetricsDto({
    required RevenueCardDataDto revenue,
    required MonthlySalesCardDataDto monthlySales,
    required TrafficQualityCardDataDto trafficQuality,
    required ConversionRateCardDataDto conversionRate,
    required DashboardChartDataDto chartData,
  }) = _DashboardMetricsDto;

  factory DashboardMetricsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsDtoFromJson(json);
}
