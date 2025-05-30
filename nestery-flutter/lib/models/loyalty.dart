enum LoyaltyTier {
  scout,
  explorer,
  navigator,
  globetrotter,
  unknown // Fallback for unexpected values
}

extension LoyaltyTierExtension on LoyaltyTier {
  String get displayName {
    switch (this) {
      case LoyaltyTier.scout:
        return 'Scout';
      case LoyaltyTier.explorer:
        return 'Explorer';
      case LoyaltyTier.navigator:
        return 'Navigator';
      case LoyaltyTier.globetrotter:
        return 'Globetrotter';
      default:
        return 'Unknown Tier';
    }
  }

  static LoyaltyTier fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SCOUT':
        return LoyaltyTier.scout;
      case 'EXPLORER':
        return LoyaltyTier.explorer;
      case 'NAVIGATOR':
        return LoyaltyTier.navigator;
      case 'GLOBETROTTER':
        return LoyaltyTier.globetrotter;
      default:
        return LoyaltyTier.unknown;
    }
  }
}

enum LoyaltyTransactionType {
  bookingCommissionEarn,
  referralBonusEarn,
  reviewAwardEarn,
  dailyCheckinEarn,
  profileCompletionEarn,
  premiumSubscriptionBonusEarn,
  partnerOfferEarn,
  premiumDiscountRedeem,
  tempFeatureAccessRedeem,
  profileCustomizationRedeem,
  prizeDrawEntryRedeem,
  partnerServiceDiscountRedeem,
  adjustmentAdd,
  adjustmentSubtract,
  unknown // Fallback
}

extension LoyaltyTransactionTypeExtension on LoyaltyTransactionType {
  String get displayDescription {
    switch (this) {
      case LoyaltyTransactionType.bookingCommissionEarn: return 'Miles from Booking';
      case LoyaltyTransactionType.referralBonusEarn: return 'Referral Bonus';
      case LoyaltyTransactionType.reviewAwardEarn: return 'Review Award';
      case LoyaltyTransactionType.dailyCheckinEarn: return 'Daily Check-in Bonus';
      case LoyaltyTransactionType.profileCompletionEarn: return 'Profile Completion Bonus';
      case LoyaltyTransactionType.premiumSubscriptionBonusEarn: return 'Premium Subscription Bonus';
      case LoyaltyTransactionType.partnerOfferEarn: return 'Partner Offer Miles';
      case LoyaltyTransactionType.premiumDiscountRedeem: return 'Redeemed for Premium Discount';
      case LoyaltyTransactionType.tempFeatureAccessRedeem: return 'Redeemed for Feature Access';
      case LoyaltyTransactionType.profileCustomizationRedeem: return 'Redeemed for Profile Customization';
      case LoyaltyTransactionType.prizeDrawEntryRedeem: return 'Redeemed for Prize Draw Entry';
      case LoyaltyTransactionType.partnerServiceDiscountRedeem: return 'Redeemed for Partner Discount';
      case LoyaltyTransactionType.adjustmentAdd: return 'Miles Adjustment (Added)';
      case LoyaltyTransactionType.adjustmentSubtract: return 'Miles Adjustment (Subtracted)';
      default: return 'Loyalty Transaction';
    }
  }

  static LoyaltyTransactionType fromString(String? value) {
    return LoyaltyTransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoyaltyTransactionType.unknown,
    );
  }
}

class LoyaltyStatus {
  final int loyaltyMilesBalance;
  final LoyaltyTier loyaltyTier;
  final String tierName;
  final String? tierBenefits;
  final String? nextTierName;
  final int? milesToNextTier;
  final double earningMultiplier;

  LoyaltyStatus({
    required this.loyaltyMilesBalance,
    required this.loyaltyTier,
    required this.tierName,
    this.tierBenefits,
    this.nextTierName,
    this.milesToNextTier,
    required this.earningMultiplier,
  });

  factory LoyaltyStatus.fromJson(Map<String, dynamic> json) {
    return LoyaltyStatus(
      loyaltyMilesBalance: json['loyaltyMilesBalance'] as int,
      loyaltyTier: LoyaltyTierExtension.fromString(json['loyaltyTier'] as String?),
      tierName: json['tierName'] as String,
      tierBenefits: json['tierBenefits'] as String?,
      nextTierName: json['nextTier'] as String?,
      milesToNextTier: json['milesToNextTier'] as int?,
      earningMultiplier: (json['earningMultiplier'] as num).toDouble(),
    );
  }
}

class LoyaltyTransaction {
  final String id;
  final LoyaltyTransactionType transactionType;
  final int milesAmount;
  final String? description;
  final DateTime createdAt;
  final String? relatedBookingId;
  final String? relatedReferralId;
  final String? relatedSubscriptionId;
  final String? relatedReviewId;
  final String? relatedPartnerOfferId;

  LoyaltyTransaction({
    required this.id,
    required this.transactionType,
    required this.milesAmount,
    this.description,
    required this.createdAt,
    this.relatedBookingId,
    this.relatedReferralId,
    this.relatedSubscriptionId,
    this.relatedReviewId,
    this.relatedPartnerOfferId,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] as String,
      transactionType: LoyaltyTransactionTypeExtension.fromString(json['transactionType'] as String?),
      milesAmount: json['milesAmount'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedBookingId: json['relatedBookingId'] as String?,
      relatedReferralId: json['relatedReferralId'] as String?,
      relatedSubscriptionId: json['relatedSubscriptionId'] as String?,
      relatedReviewId: json['relatedReviewId'] as String?,
      relatedPartnerOfferId: json['relatedPartnerOfferId'] as String?,
    );
  }
}
