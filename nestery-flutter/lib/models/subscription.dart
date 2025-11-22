/// Subscription models for premium features

class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancelAt;
  final bool autoRenew;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;

  Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.endDate,
    this.cancelAt,
    required this.autoRenew,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      tier: SubscriptionTier.fromString(json['tier']),
      status: SubscriptionStatus.fromString(json['status']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      cancelAt: json['cancelAt'] != null ? DateTime.parse(json['cancelAt']) : null,
      autoRenew: json['autoRenew'] ?? true,
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripeCustomerId: json['stripeCustomerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.value,
      'status': status.value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cancelAt': cancelAt?.toIso8601String(),
      'autoRenew': autoRenew,
      'stripeSubscriptionId': stripeSubscriptionId,
      'stripeCustomerId': stripeCustomerId,
    };
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPremium => tier != SubscriptionTier.free && isActive;
}

enum SubscriptionTier {
  free('free', 'Free', 0.0, 'Basic features'),
  plus('plus', 'Nestery Plus', 4.99, 'Enhanced features'),
  premium('premium', 'Nestery Premium', 9.99, 'All features unlocked');

  final String value;
  final String displayName;
  final double monthlyPrice;
  final String description;

  const SubscriptionTier(this.value, this.displayName, this.monthlyPrice, this.description);

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.value == value,
      orElse: () => SubscriptionTier.free,
    );
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          'Search and compare hotels',
          'Basic property details',
          'Standard customer support',
          'Limited search history',
        ];
      case SubscriptionTier.plus:
        return [
          'All Free features',
          'Unlimited search history',
          'Price drop alerts',
          'Priority customer support',
          '2x loyalty miles earning',
          'Advanced filters',
          'Save favorite properties',
        ];
      case SubscriptionTier.premium:
        return [
          'All Plus features',
          '3x loyalty miles earning',
          'Exclusive deals and discounts',
          'Early access to new features',
          '24/7 premium support',
          'Price freeze guarantee',
          'Concierge booking service',
          'Ad-free experience',
          'VIP status badge',
        ];
    }
  }

  String get priceDisplay {
    if (monthlyPrice == 0) return 'Free';
    return '\$${monthlyPrice.toStringAsFixed(2)}/month';
  }

  double get annualPrice => monthlyPrice * 10; // 2 months free
  String get annualPriceDisplay {
    if (monthlyPrice == 0) return 'Free';
    return '\$${annualPrice.toStringAsFixed(2)}/year';
  }
}

enum SubscriptionStatus {
  active('active'),
  canceled('canceled'),
  pastDue('past_due'),
  expired('expired'),
  trial('trial');

  final String value;
  const SubscriptionStatus(this.value);

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }
}

enum BillingPeriod {
  monthly('monthly', 'Monthly'),
  annual('annual', 'Annual');

  final String value;
  final String displayName;
  const BillingPeriod(this.value, this.displayName);
}
