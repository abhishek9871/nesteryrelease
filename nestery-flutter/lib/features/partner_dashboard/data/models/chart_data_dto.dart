import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data_dto.freezed.dart';
part 'chart_data_dto.g.dart';

@freezed
class ChartDataPointDto with _$ChartDataPointDto {
  const factory ChartDataPointDto({
    required DateTime date,
    required double value,
  }) = _ChartDataPointDto;

  factory ChartDataPointDto.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointDtoFromJson(json);
}

@freezed
class DashboardChartDataDto with _$DashboardChartDataDto {
  const factory DashboardChartDataDto({
    required List<ChartDataPointDto> netEarningsData,
    required List<ChartDataPointDto> conversionRateData,
  }) = _DashboardChartDataDto;

  factory DashboardChartDataDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardChartDataDtoFromJson(json);
}
