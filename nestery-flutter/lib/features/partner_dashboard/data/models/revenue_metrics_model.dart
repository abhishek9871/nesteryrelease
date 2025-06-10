import 'package:freezed_annotation/freezed_annotation.dart';

part 'revenue_metrics_model.freezed.dart';
part 'revenue_metrics_model.g.dart';

@freezed
class RevenueMetricsModel with _$RevenueMetricsModel {
  const factory RevenueMetricsModel({
    @JsonKey(name: 'totalRevenue') required double totalRevenue,
    @JsonKey(name: 'totalCommissions') required double totalCommissions,
    @JsonKey(name: 'totalConversions') required int totalConversions,
    @JsonKey(name: 'averageCommission') required double averageCommission,
    @JsonKey(name: 'growthPercentage') required double growthPercentage,
  }) = _RevenueMetricsModel;

  factory RevenueMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueMetricsModelFromJson(json);
}

@freezed
class RevenueTrendModel with _$RevenueTrendModel {
  const factory RevenueTrendModel({
    @JsonKey(name: 'date') required String date,
    @JsonKey(name: 'revenue') required double revenue,
    @JsonKey(name: 'commissions') required double commissions,
    @JsonKey(name: 'conversions') required int conversions,
  }) = _RevenueTrendModel;

  factory RevenueTrendModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueTrendModelFromJson(json);
}

@freezed
class PartnerPerformanceModel with _$PartnerPerformanceModel {
  const factory PartnerPerformanceModel({
    @JsonKey(name: 'partnerId') required String partnerId,
    @JsonKey(name: 'partnerName') required String partnerName,
    @JsonKey(name: 'totalEarnings') required double totalEarnings,
    @JsonKey(name: 'conversions') required int conversions,
    @JsonKey(name: 'conversionRate') required double conversionRate,
    @JsonKey(name: 'category') required String category,
  }) = _PartnerPerformanceModel;

  factory PartnerPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerPerformanceModelFromJson(json);
}

@freezed
class CommissionBatchModel with _$CommissionBatchModel {
  const factory CommissionBatchModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'batchDate') required String batchDate,
    @JsonKey(name: 'totalCommissions') required double totalCommissions,
    @JsonKey(name: 'processedEarnings') required int processedEarnings,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'errorMessage') String? errorMessage,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _CommissionBatchModel;

  factory CommissionBatchModel.fromJson(Map<String, dynamic> json) =>
      _$CommissionBatchModelFromJson(json);
}
