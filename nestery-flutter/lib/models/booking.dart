class Booking {
  final String id;
  final String userId;
  final String propertyId;
  final String propertyName;
  final String propertyThumbnail;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int numberOfRooms;
  final double totalPrice;
  final String currency;
  final String status; // pending, confirmed, cancelled, completed
  final String confirmationCode;
  final int loyaltyPointsEarned;
  final bool isPremiumBooking;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyThumbnail,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.numberOfRooms,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.confirmationCode,
    required this.loyaltyPointsEarned,
    required this.isPremiumBooking,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      propertyName: json['propertyName'],
      propertyThumbnail: json['propertyThumbnail'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfGuests: json['numberOfGuests'],
      numberOfRooms: json['numberOfRooms'],
      totalPrice: json['totalPrice'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      confirmationCode: json['confirmationCode'],
      loyaltyPointsEarned: json['loyaltyPointsEarned'] ?? 0,
      isPremiumBooking: json['isPremiumBooking'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyThumbnail': propertyThumbnail,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'numberOfRooms': numberOfRooms,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'confirmationCode': confirmationCode,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'isPremiumBooking': isPremiumBooking,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculate number of nights
  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  // Check if booking is upcoming
  bool get isUpcoming {
    return checkInDate.isAfter(DateTime.now()) && status != 'cancelled';
  }

  // Check if booking is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(checkInDate) && 
           now.isBefore(checkOutDate) && 
           status == 'confirmed';
  }

  // Check if booking is completed
  bool get isCompleted {
    return checkOutDate.isBefore(DateTime.now()) || status == 'completed';
  }
}
