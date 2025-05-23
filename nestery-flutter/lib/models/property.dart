class Property {
  final String id;
  final String name;
  final String description;
  final String type;
  final String sourceType; // booking_com, oyo, etc.
  final String sourceId;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final int starRating;
  final double basePrice;
  final String currency;
  final List<String> amenities;
  final List<String> images;
  final String thumbnailImage;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.sourceType,
    required this.sourceId,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.starRating,
    required this.basePrice,
    required this.currency,
    required this.amenities,
    required this.images,
    required this.thumbnailImage,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      sourceType: json['sourceType'],
      sourceId: json['sourceId'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      starRating: json['starRating'] ?? 0,
      basePrice: json['basePrice']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      thumbnailImage: json['thumbnailImage'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isPremium: json['isPremium'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'starRating': starRating,
      'basePrice': basePrice,
      'currency': currency,
      'amenities': amenities,
      'images': images,
      'thumbnailImage': thumbnailImage,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
