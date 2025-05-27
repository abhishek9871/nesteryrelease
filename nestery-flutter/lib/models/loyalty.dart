import 'package:nestery_flutter/models/enums.dart';

class Loyalty {
  final String id;
  final String userId;
  final LoyaltyTier tier;
  final int points;
  final int pointsEarned;
  final int pointsRedeemed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loyalty({
    required this.id,
    required this.userId,
    required this.tier,
    required this.points,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Loyalty from JSON
  factory Loyalty.fromJson(Map<String, dynamic> json) {
    return Loyalty(
      id: json['id'],
      userId: json['userId'],
      tier: LoyaltyTierExtension.fromString(json['tier']),
      points: json['points'],
      pointsEarned: json['pointsEarned'],
      pointsRedeemed: json['pointsRedeemed'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert Loyalty to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.value,
      'points': points,
      'pointsEarned': pointsEarned,
      'pointsRedeemed': pointsRedeemed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of Loyalty with updated fields
  Loyalty copyWith({
    String? id,
    String? userId,
    LoyaltyTier? tier,
    int? points,
    int? pointsEarned,
    int? pointsRedeemed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loyalty(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      points: points ?? this.points,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  int get availablePoints => points;
  int get totalEarned => pointsEarned;
  int get totalRedeemed => pointsRedeemed;
  
  // Calculate points needed for next tier
  int get pointsToNextTier {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 1000 - points; // Assuming 1000 points for silver
      case LoyaltyTier.silver:
        return 2500 - points; // Assuming 2500 points for gold
      case LoyaltyTier.gold:
        return 5000 - points; // Assuming 5000 points for platinum
      case LoyaltyTier.platinum:
        return 0; // Already at highest tier
    }
  }

  @override
  String toString() {
    return 'Loyalty(id: $id, userId: $userId, tier: $tier, points: $points, pointsEarned: $pointsEarned, pointsRedeemed: $pointsRedeemed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loyalty &&
        other.id == id &&
        other.userId == userId &&
        other.tier == tier &&
        other.points == points &&
        other.pointsEarned == pointsEarned &&
        other.pointsRedeemed == pointsRedeemed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        tier.hashCode ^
        points.hashCode ^
        pointsEarned.hashCode ^
        pointsRedeemed.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
