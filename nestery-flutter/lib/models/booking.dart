import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/user.dart';

enum BookingStatus {
  confirmed,
  completed,
  cancelled
}

class Booking {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final String currency;
  final BookingStatus status;
  final String confirmationCode;
  final String? specialRequests;
  final String paymentMethod;
  final Map<String, dynamic>? paymentDetails;
  final int loyaltyPointsEarned;
  final String sourceType;
  final String? externalBookingId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional related objects
  final Property? property;
  final User? user;

  Booking({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.confirmationCode,
    this.specialRequests,
    required this.paymentMethod,
    this.paymentDetails,
    required this.loyaltyPointsEarned,
    required this.sourceType,
    this.externalBookingId,
    required this.createdAt,
    required this.updatedAt,
    this.property,
    this.user,
  });

  // Number of nights getter
  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  // Factory constructor to create a Booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      propertyId: json['propertyId'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfGuests: json['numberOfGuests'],
      totalPrice: json['totalPrice'] is int 
          ? (json['totalPrice'] as int).toDouble() 
          : json['totalPrice'],
      currency: json['currency'],
      status: _parseStatus(json['status']),
      confirmationCode: json['confirmationCode'],
      specialRequests: json['specialRequests'],
      paymentMethod: json['paymentMethod'],
      paymentDetails: json['paymentDetails'],
      loyaltyPointsEarned: json['loyaltyPointsEarned'] ?? 0,
      sourceType: json['sourceType'],
      externalBookingId: json['externalBookingId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      property: json['property'] != null 
          ? Property.fromJson(json['property']) 
          : null,
      user: json['user'] != null 
          ? User.fromJson(json['user']) 
          : null,
    );
  }

  // Helper method to parse status string to enum
  static BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.confirmed;
    }
  }

  // Helper method to convert enum to string
  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  // Convert Booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': _statusToString(status),
      'confirmationCode': confirmationCode,
      'specialRequests': specialRequests,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'sourceType': sourceType,
      'externalBookingId': externalBookingId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Don't include nested objects in JSON by default
    };
  }

  // Create a copy of Booking with updated fields
  Booking copyWith({
    String? id,
    String? userId,
    String? propertyId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    String? currency,
    BookingStatus? status,
    String? confirmationCode,
    String? specialRequests,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
    int? loyaltyPointsEarned,
    String? sourceType,
    String? externalBookingId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Property? property,
    User? user,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      specialRequests: specialRequests ?? this.specialRequests,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      sourceType: sourceType ?? this.sourceType,
      externalBookingId: externalBookingId ?? this.externalBookingId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      property: property ?? this.property,
      user: user ?? this.user,
    );
  }
}
