/// Model for trending destinations
class TrendingDestination {
  final String destination;
  final int propertyCount;
  final double averagePrice;
  final String? thumbnailImage;

  const TrendingDestination({
    required this.destination,
    required this.propertyCount,
    required this.averagePrice,
    this.thumbnailImage,
  });

  factory TrendingDestination.fromJson(Map<String, dynamic> json) {
    return TrendingDestination(
      destination: json['destination'] as String,
      propertyCount: json['propertyCount'] as int,
      averagePrice: (json['averagePrice'] as num).toDouble(),
      thumbnailImage: json['thumbnailImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'propertyCount': propertyCount,
      'averagePrice': averagePrice,
      if (thumbnailImage != null) 'thumbnailImage': thumbnailImage,
    };
  }

  @override
  String toString() {
    return 'TrendingDestination(destination: $destination, propertyCount: $propertyCount, averagePrice: $averagePrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendingDestination &&
        other.destination == destination &&
        other.propertyCount == propertyCount &&
        other.averagePrice == averagePrice &&
        other.thumbnailImage == thumbnailImage;
  }

  @override
  int get hashCode {
    return destination.hashCode ^
        propertyCount.hashCode ^
        averagePrice.hashCode ^
        thumbnailImage.hashCode;
  }
}

/// Model for price prediction responses
class PricePrediction {
  final String propertyId;
  final double predictedPrice;
  final double confidence;
  final String currency;
  final DateTime validUntil;
  final Map<String, dynamic>? factors;

  const PricePrediction({
    required this.propertyId,
    required this.predictedPrice,
    required this.confidence,
    required this.currency,
    required this.validUntil,
    this.factors,
  });

  factory PricePrediction.fromJson(Map<String, dynamic> json) {
    return PricePrediction(
      propertyId: json['propertyId'] as String,
      predictedPrice: (json['predictedPrice'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      currency: json['currency'] as String,
      validUntil: DateTime.parse(json['validUntil'] as String),
      factors: json['factors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'predictedPrice': predictedPrice,
      'confidence': confidence,
      'currency': currency,
      'validUntil': validUntil.toIso8601String(),
      if (factors != null) 'factors': factors,
    };
  }
}

/// Model for referral link information
class ReferralLinkInfo {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final double totalEarnings;
  final String currency;

  const ReferralLinkInfo({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.currency,
  });

  factory ReferralLinkInfo.fromJson(Map<String, dynamic> json) {
    return ReferralLinkInfo(
      referralCode: json['referralCode'] as String,
      referralLink: json['referralLink'] as String,
      totalReferrals: json['totalReferrals'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'referralLink': referralLink,
      'totalReferrals': totalReferrals,
      'totalEarnings': totalEarnings,
      'currency': currency,
    };
  }
}

/// Model for social sharing responses
class ShareResponse {
  final bool success;
  final String platform;
  final String? shareUrl;
  final String? message;

  const ShareResponse({
    required this.success,
    required this.platform,
    this.shareUrl,
    this.message,
  });

  factory ShareResponse.fromJson(Map<String, dynamic> json) {
    return ShareResponse(
      success: json['success'] as bool,
      platform: json['platform'] as String,
      shareUrl: json['shareUrl'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'platform': platform,
      if (shareUrl != null) 'shareUrl': shareUrl,
      if (message != null) 'message': message,
    };
  }
}

/// Model for loyalty reward redemption responses
class RedeemRewardResponse {
  final bool success;
  final int pointsRedeemed;
  final int remainingPoints;
  final String rewardType;
  final String? rewardDetails;

  const RedeemRewardResponse({
    required this.success,
    required this.pointsRedeemed,
    required this.remainingPoints,
    required this.rewardType,
    this.rewardDetails,
  });

  factory RedeemRewardResponse.fromJson(Map<String, dynamic> json) {
    return RedeemRewardResponse(
      success: json['success'] as bool,
      pointsRedeemed: json['pointsRedeemed'] as int,
      remainingPoints: json['remainingPoints'] as int,
      rewardType: json['rewardType'] as String,
      rewardDetails: json['rewardDetails'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'pointsRedeemed': pointsRedeemed,
      'remainingPoints': remainingPoints,
      'rewardType': rewardType,
      if (rewardDetails != null) 'rewardDetails': rewardDetails,
    };
  }
}

/// Model for property availability responses
class PropertyAvailability {
  final DateTime date;
  final bool available;
  final double? price;
  final String? currency;
  final int? minStay;
  final int? maxStay;

  const PropertyAvailability({
    required this.date,
    required this.available,
    this.price,
    this.currency,
    this.minStay,
    this.maxStay,
  });

  factory PropertyAvailability.fromJson(Map<String, dynamic> json) {
    return PropertyAvailability(
      date: DateTime.parse(json['date'] as String),
      available: json['available'] as bool,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      minStay: json['minStay'] as int?,
      maxStay: json['maxStay'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'available': available,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (minStay != null) 'minStay': minStay,
      if (maxStay != null) 'maxStay': maxStay,
    };
  }
}

/// Pagination metadata model
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}
