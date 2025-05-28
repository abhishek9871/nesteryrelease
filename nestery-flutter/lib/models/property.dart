import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/review.dart';

class Property {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String? state;
  final String country;
  final String? zipCode;
  final double latitude;
  final double longitude;
  final String propertyType;
  final double? starRating;
  final double basePrice;
  final String currency;
  final int maxGuests;
  final int? bedrooms;
  final int? bathrooms;
  final List<String>? amenities;
  final String? thumbnailImage;
  final String sourceType;
  final String? externalId;
  final String? externalUrl;
  final Map<String, dynamic>? metadata;

  // Additional fields expected by UI
  final List<String>? images;
  final double? area;
  final User? host;
  final bool? smokingAllowed;
  final bool? petsAllowed;
  final bool? partiesAllowed;
  final String? checkInTime;
  final String? checkOutTime;
  final String? cancellationPolicy;
  final List<Review>? reviews;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    this.state,
    required this.country,
    this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.propertyType,
    this.starRating,
    required this.basePrice,
    required this.currency,
    required this.maxGuests,
    this.bedrooms,
    this.bathrooms,
    this.amenities,
    this.thumbnailImage,
    required this.sourceType,
    this.externalId,
    this.externalUrl,
    this.metadata,
    this.images,
    this.area,
    this.host,
    this.smokingAllowed,
    this.petsAllowed,
    this.partiesAllowed,
    this.checkInTime,
    this.checkOutTime,
    this.cancellationPolicy,
    this.reviews,
  });

  // Full address getter
  String get fullAddress {
    final parts = [address, city];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    parts.add(country);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  // Factory constructor to create a Property from JSON
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
      latitude: json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'],
      longitude: json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'],
      propertyType: json['propertyType'],
      starRating: json['starRating'] != null
          ? (json['starRating'] is int
              ? (json['starRating'] as int).toDouble()
              : json['starRating'])
          : null,
      basePrice: json['basePrice'] is int
          ? (json['basePrice'] as int).toDouble()
          : json['basePrice'],
      currency: json['currency'],
      maxGuests: json['maxGuests'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      thumbnailImage: json['thumbnailImage'],
      sourceType: json['sourceType'],
      externalId: json['externalId'],
      externalUrl: json['externalUrl'],
      metadata: json['metadata'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      area: json['area'] != null
          ? (json['area'] is int
              ? (json['area'] as int).toDouble()
              : json['area'])
          : null,
      host: json['host'] != null
          ? User.fromJson(json['host'])
          : null,
      smokingAllowed: json['smokingAllowed'],
      petsAllowed: json['petsAllowed'],
      partiesAllowed: json['partiesAllowed'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      cancellationPolicy: json['cancellationPolicy'],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList()
          : null,
    );
  }

  // Convert Property to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'propertyType': propertyType,
      'starRating': starRating,
      'basePrice': basePrice,
      'currency': currency,
      'maxGuests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'thumbnailImage': thumbnailImage,
      'sourceType': sourceType,
      'externalId': externalId,
      'externalUrl': externalUrl,
      'metadata': metadata,
      'images': images,
      'area': area,
      'host': host?.toJson(),
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
      'partiesAllowed': partiesAllowed,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'cancellationPolicy': cancellationPolicy,
      'reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }

  // Create a copy of Property with updated fields
  Property copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    double? latitude,
    double? longitude,
    String? propertyType,
    double? starRating,
    double? basePrice,
    String? currency,
    int? maxGuests,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    String? thumbnailImage,
    String? sourceType,
    String? externalId,
    String? externalUrl,
    Map<String, dynamic>? metadata,
    List<String>? images,
    double? area,
    User? host,
    bool? smokingAllowed,
    bool? petsAllowed,
    bool? partiesAllowed,
    String? checkInTime,
    String? checkOutTime,
    String? cancellationPolicy,
    List<Review>? reviews,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      propertyType: propertyType ?? this.propertyType,
      starRating: starRating ?? this.starRating,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      sourceType: sourceType ?? this.sourceType,
      externalId: externalId ?? this.externalId,
      externalUrl: externalUrl ?? this.externalUrl,
      metadata: metadata ?? this.metadata,
      images: images ?? this.images,
      area: area ?? this.area,
      host: host ?? this.host,
      smokingAllowed: smokingAllowed ?? this.smokingAllowed,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      partiesAllowed: partiesAllowed ?? this.partiesAllowed,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      reviews: reviews ?? this.reviews,
    );
  }
}
