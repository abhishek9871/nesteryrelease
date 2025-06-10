import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_history_model.freezed.dart';
part 'earnings_history_model.g.dart';

@freezed
class EarningsHistoryModel with _$EarningsHistoryModel {
  const factory EarningsHistoryModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'partnerId') required String partnerId,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'offerTitle') required String offerTitle,
    @JsonKey(name: 'commissionAmount') required double commissionAmount,
    @JsonKey(name: 'commissionRate') required double commissionRate,
    @JsonKey(name: 'bookingValue') required double bookingValue,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'earnedAt') required DateTime earnedAt,
    @JsonKey(name: 'paidAt') DateTime? paidAt,
    @JsonKey(name: 'trackingId') String? trackingId,
    @JsonKey(name: 'customerEmail') String? customerEmail,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    @JsonKey(name: 'updatedAt') required DateTime updatedAt,
  }) = _EarningsHistoryModel;

  factory EarningsHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsHistoryModelFromJson(json);
}

@freezed
class PayoutRequestModel with _$PayoutRequestModel {
  const factory PayoutRequestModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'partnerId') required String partnerId,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'requestedAt') required DateTime requestedAt,
    @JsonKey(name: 'processedAt') DateTime? processedAt,
    @JsonKey(name: 'paymentMethod') String? paymentMethod,
    @JsonKey(name: 'paymentDetails') Map<String, dynamic>? paymentDetails,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    @JsonKey(name: 'updatedAt') required DateTime updatedAt,
  }) = _PayoutRequestModel;

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestModelFromJson(json);
}

@freezed
class UserAnalyticsModel with _$UserAnalyticsModel {
  const factory UserAnalyticsModel({
    @JsonKey(name: 'totalEarnings') required double totalEarnings,
    @JsonKey(name: 'pendingEarnings') required double pendingEarnings,
    @JsonKey(name: 'paidEarnings') required double paidEarnings,
    @JsonKey(name: 'totalConversions') required int totalConversions,
    @JsonKey(name: 'conversionRate') required double conversionRate,
    @JsonKey(name: 'averageCommission') required double averageCommission,
    @JsonKey(name: 'clickCount') required int clickCount,
    @JsonKey(name: 'topPerformingOffer') OfferPerformanceModel? topPerformingOffer,
    @JsonKey(name: 'monthlyEarnings') required List<MonthlyEarningsModel> monthlyEarnings,
  }) = _UserAnalyticsModel;

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyticsModelFromJson(json);
}

@freezed
class OfferPerformanceModel with _$OfferPerformanceModel {
  const factory OfferPerformanceModel({
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'offerTitle') required String offerTitle,
    @JsonKey(name: 'totalEarnings') required double totalEarnings,
    @JsonKey(name: 'conversions') required int conversions,
    @JsonKey(name: 'clicks') required int clicks,
    @JsonKey(name: 'conversionRate') required double conversionRate,
  }) = _OfferPerformanceModel;

  factory OfferPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$OfferPerformanceModelFromJson(json);
}

@freezed
class MonthlyEarningsModel with _$MonthlyEarningsModel {
  const factory MonthlyEarningsModel({
    @JsonKey(name: 'month') required String month,
    @JsonKey(name: 'year') required int year,
    @JsonKey(name: 'earnings') required double earnings,
    @JsonKey(name: 'conversions') required int conversions,
  }) = _MonthlyEarningsModel;

  factory MonthlyEarningsModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyEarningsModelFromJson(json);
}

@freezed
class CreatePayoutRequestModel with _$CreatePayoutRequestModel {
  const factory CreatePayoutRequestModel({
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'paymentMethod') required String paymentMethod,
    @JsonKey(name: 'paymentDetails') required Map<String, dynamic> paymentDetails,
    @JsonKey(name: 'notes') String? notes,
  }) = _CreatePayoutRequestModel;

  factory CreatePayoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePayoutRequestModelFromJson(json);
}

// Enums for better type safety
enum EarningsStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('paid')
  paid,
  @JsonValue('cancelled')
  cancelled,
}

enum PayoutStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('paypal')
  paypal,
  @JsonValue('stripe')
  stripe,
  @JsonValue('crypto')
  crypto,
}

// Extensions for better UX
extension EarningsStatusExtension on EarningsStatus {
  String get displayName {
    switch (this) {
      case EarningsStatus.pending:
        return 'Pending';
      case EarningsStatus.confirmed:
        return 'Confirmed';
      case EarningsStatus.paid:
        return 'Paid';
      case EarningsStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case EarningsStatus.pending:
        return Colors.orange;
      case EarningsStatus.confirmed:
        return Colors.blue;
      case EarningsStatus.paid:
        return Colors.green;
      case EarningsStatus.cancelled:
        return Colors.red;
    }
  }
}

extension PayoutStatusExtension on PayoutStatus {
  String get displayName {
    switch (this) {
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.approved:
        return 'Approved';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.rejected:
        return 'Rejected';
      case PayoutStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case PayoutStatus.pending:
        return Colors.orange;
      case PayoutStatus.approved:
        return Colors.blue;
      case PayoutStatus.processing:
        return Colors.purple;
      case PayoutStatus.completed:
        return Colors.green;
      case PayoutStatus.rejected:
        return Colors.red;
      case PayoutStatus.cancelled:
        return Colors.grey;
    }
  }
}
