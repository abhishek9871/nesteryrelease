import 'package:nestery_flutter/models/enums.dart';

/// DTO for property search parameters
class SearchPropertiesDto {
  final String? city;
  final String? country;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final double? priceMin;
  final double? priceMax;
  final PropertyType? propertyType;
  final List<String>? amenities;
  final int page;
  final int limit;

  const SearchPropertiesDto({
    this.city,
    this.country,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.priceMin,
    this.priceMax,
    this.propertyType,
    this.amenities,
    this.page = 1,
    this.limit = 10,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };

    if (city != null) params['city'] = city;
    if (country != null) params['country'] = country;
    if (checkIn != null) params['checkIn'] = checkIn!.toIso8601String().split('T')[0];
    if (checkOut != null) params['checkOut'] = checkOut!.toIso8601String().split('T')[0];
    if (guests != null) params['guests'] = guests;
    if (priceMin != null) params['priceMin'] = priceMin;
    if (priceMax != null) params['priceMax'] = priceMax;
    if (propertyType != null) params['propertyType'] = propertyType!.name;
    if (amenities != null && amenities!.isNotEmpty) {
      params['amenities'] = amenities!.join(',');
    }

    return params;
  }

  SearchPropertiesDto copyWith({
    String? city,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? priceMin,
    double? priceMax,
    PropertyType? propertyType,
    List<String>? amenities,
    int? page,
    int? limit,
  }) {
    return SearchPropertiesDto(
      city: city ?? this.city,
      country: country ?? this.country,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      propertyType: propertyType ?? this.propertyType,
      amenities: amenities ?? this.amenities,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// DTO for creating a booking
class CreateBookingDto {
  final String propertyId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String? specialRequests;

  const CreateBookingDto({
    required this.propertyId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'checkIn': checkIn.toIso8601String().split('T')[0],
      'checkOut': checkOut.toIso8601String().split('T')[0],
      'guests': guests,
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }
}

/// DTO for updating a booking
class UpdateBookingDto {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final String? specialRequests;
  final String? status;

  const UpdateBookingDto({
    this.checkIn,
    this.checkOut,
    this.guests,
    this.specialRequests,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (checkIn != null) data['checkIn'] = checkIn!.toIso8601String().split('T')[0];
    if (checkOut != null) data['checkOut'] = checkOut!.toIso8601String().split('T')[0];
    if (guests != null) data['guests'] = guests;
    if (specialRequests != null) data['specialRequests'] = specialRequests;
    if (status != null) data['status'] = status;

    return data;
  }
}

/// DTO for redeeming loyalty points
class RedeemPointsDto {
  final int points;
  final String rewardType;
  final String? description;

  const RedeemPointsDto({
    required this.points,
    required this.rewardType,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'rewardType': rewardType,
      if (description != null) 'description': description,
    };
  }
}

/// DTO for price prediction requests
class PricePredictionDto {
  final String propertyId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  const PricePredictionDto({
    required this.propertyId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'checkIn': checkIn.toIso8601String().split('T')[0],
      'checkOut': checkOut.toIso8601String().split('T')[0],
      'guests': guests,
    };
  }
}

/// DTO for sharing properties on social media
class SharePropertyDto {
  final String propertyId;
  final String platform;
  final String? message;

  const SharePropertyDto({
    required this.propertyId,
    required this.platform,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'platform': platform,
      if (message != null) 'message': message,
    };
  }
}

/// DTO for creating reviews
class CreateReviewDto {
  final String propertyId;
  final int rating;
  final String comment;
  final List<String>? images;

  const CreateReviewDto({
    required this.propertyId,
    required this.rating,
    required this.comment,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'rating': rating,
      'comment': comment,
      if (images != null) 'images': images,
    };
  }
}
