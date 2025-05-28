import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/enums.dart';

class Booking {
  final String id;
  final String propertyId;
  final String propertyName;
  final String? propertyThumbnail;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final String currency;
  final BookingStatus status;
  final String confirmationCode;
  final Map<String, dynamic>? paymentDetails;
  final String? externalBookingId;
  final String? supplierId;
  final String? supplierBookingReference;
  final DateTime createdAt;

  // Additional fields expected by UI
  final String? paymentMethod;
  final String? paymentStatus;
  final String? specialRequests;

  // Optional related objects
  final Property? property;
  final User? user;

  Booking({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    this.propertyThumbnail,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.confirmationCode,
    this.paymentDetails,
    this.externalBookingId,
    this.supplierId,
    this.supplierBookingReference,
    required this.createdAt,
    this.paymentMethod,
    this.paymentStatus,
    this.specialRequests,
    this.property,
    this.user,
  });

  // Number of nights getter
  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  // Additional getters that UI expects
  double get totalAmount => totalPrice;
  DateTime get bookingDate => createdAt;

  // Check if booking is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return checkInDate.isAfter(now);
  }

  // Check if booking is active (currently staying)
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(checkInDate) && now.isBefore(checkOutDate);
  }

  // Check if booking is past
  bool get isPast {
    final now = DateTime.now();
    return checkOutDate.isBefore(now);
  }

  // Factory constructor to create a Booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      propertyId: json['propertyId'],
      propertyName: json['propertyName'],
      propertyThumbnail: json['propertyThumbnail'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfGuests: json['numberOfGuests'],
      totalPrice: json['totalPrice'] is int
          ? (json['totalPrice'] as int).toDouble()
          : json['totalPrice'],
      currency: json['currency'],
      status: _parseStatus(json['status']),
      confirmationCode: json['confirmationCode'],
      paymentDetails: json['paymentDetails'],
      externalBookingId: json['externalBookingId'],
      supplierId: json['supplierId'],
      supplierBookingReference: json['supplierBookingReference'],
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      specialRequests: json['specialRequests'],
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
    return BookingStatusExtension.fromString(status);
  }

  // Helper method to convert enum to string
  static String _statusToString(BookingStatus status) {
    return status.value;
  }

  // Convert Booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyThumbnail': propertyThumbnail,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': _statusToString(status),
      'confirmationCode': confirmationCode,
      'paymentDetails': paymentDetails,
      'externalBookingId': externalBookingId,
      'supplierId': supplierId,
      'supplierBookingReference': supplierBookingReference,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'specialRequests': specialRequests,
      // Don't include nested objects in JSON by default
    };
  }

  // Create a copy of Booking with updated fields
  Booking copyWith({
    String? id,
    String? propertyId,
    String? propertyName,
    String? propertyThumbnail,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    String? currency,
    BookingStatus? status,
    String? confirmationCode,
    Map<String, dynamic>? paymentDetails,
    String? externalBookingId,
    String? supplierId,
    String? supplierBookingReference,
    DateTime? createdAt,
    String? paymentMethod,
    String? paymentStatus,
    String? specialRequests,
    Property? property,
    User? user,
  }) {
    return Booking(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      propertyThumbnail: propertyThumbnail ?? this.propertyThumbnail,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      externalBookingId: externalBookingId ?? this.externalBookingId,
      supplierId: supplierId ?? this.supplierId,
      supplierBookingReference: supplierBookingReference ?? this.supplierBookingReference,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      specialRequests: specialRequests ?? this.specialRequests,
      property: property ?? this.property,
      user: user ?? this.user,
    );
  }
}
