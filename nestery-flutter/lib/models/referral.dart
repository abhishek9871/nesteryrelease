/// Referral system models for tracking user referrals and rewards
class Referral {
  final String id;
  final String referrerId;
  final String referredUserId;
  final String? referredUserEmail;
  final String? referredUserName;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? rewardMiles;
  final String? rewardDescription;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    this.referredUserEmail,
    this.referredUserName,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.rewardMiles,
    this.rewardDescription,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'],
      referrerId: json['referrerId'],
      referredUserId: json['referredUserId'],
      referredUserEmail: json['referredUserEmail'],
      referredUserName: json['referredUserName'],
      status: ReferralStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      rewardMiles: json['rewardMiles'],
      rewardDescription: json['rewardDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referredUserId': referredUserId,
      'referredUserEmail': referredUserEmail,
      'referredUserName': referredUserName,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rewardMiles': rewardMiles,
      'rewardDescription': rewardDescription,
    };
  }
}

enum ReferralStatus {
  pending('pending'),
  completed('completed'),
  expired('expired');

  final String value;
  const ReferralStatus(this.value);

  static ReferralStatus fromString(String value) {
    return ReferralStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReferralStatus.pending,
    );
  }
}

class ReferralStats {
  final String userId;
  final String referralCode;
  final int totalReferrals;
  final int completedReferrals;
  final int pendingReferrals;
  final int totalMilesEarned;
  final List<Referral> recentReferrals;

  ReferralStats({
    required this.userId,
    required this.referralCode,
    required this.totalReferrals,
    required this.completedReferrals,
    required this.pendingReferrals,
    required this.totalMilesEarned,
    required this.recentReferrals,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      userId: json['userId'],
      referralCode: json['referralCode'],
      totalReferrals: json['totalReferrals'] ?? 0,
      completedReferrals: json['completedReferrals'] ?? 0,
      pendingReferrals: json['pendingReferrals'] ?? 0,
      totalMilesEarned: json['totalMilesEarned'] ?? 0,
      recentReferrals: json['recentReferrals'] != null
          ? (json['recentReferrals'] as List)
              .map((r) => Referral.fromJson(r))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'totalReferrals': totalReferrals,
      'completedReferrals': completedReferrals,
      'pendingReferrals': pendingReferrals,
      'totalMilesEarned': totalMilesEarned,
      'recentReferrals': recentReferrals.map((r) => r.toJson()).toList(),
    };
  }
}
