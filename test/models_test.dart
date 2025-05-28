import 'package:flutter_test/flutter_test.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/enums.dart';

void main() {
  group('Property Model Tests', () {
    test('Property should be correctly instantiated', () {
      final property = Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        propertyType: 'hotel',
        basePrice: 100.0,
        currency: 'USD',
        maxGuests: 4,
        sourceType: 'booking_com',
        starRating: 4,
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        externalId: 'bcom_123',
      );
      
      expect(property.id, 'prop1');
      expect(property.name, 'Test Property');
      expect(property.propertyType, 'hotel');
      expect(property.basePrice, 100.0);
      expect(property.amenities!.length, 2);
      expect(property.starRating, 4);
    });
    
    test('Property fromJson should parse correctly', () {
      final json = {
        'id': 'prop1',
        'name': 'Test Property',
        'description': 'A test property',
        'address': '123 Test St',
        'city': 'Test City',
        'country': 'Test Country',
        'latitude': 0.0,
        'longitude': 0.0,
        'propertyType': 'hotel',
        'basePrice': 100.0,
        'currency': 'USD',
        'maxGuests': 4,
        'sourceType': 'booking_com',
        'starRating': 4,
        'amenities': ['WiFi', 'Pool'],
        'images': ['https://example.com/image.jpg'],
        'thumbnailImage': 'https://example.com/thumb.jpg',
        'externalId': 'bcom_123',
      };
      
      final property = Property.fromJson(json);
      
      expect(property.id, 'prop1');
      expect(property.name, 'Test Property');
      expect(property.propertyType, 'hotel');
      expect(property.basePrice, 100.0);
      expect(property.amenities!.length, 2);
      expect(property.starRating, 4);
    });
    
    test('Property toJson should convert correctly', () {
      final property = Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        propertyType: 'hotel',
        basePrice: 100.0,
        currency: 'USD',
        maxGuests: 4,
        sourceType: 'booking_com',
        starRating: 4,
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        externalId: 'bcom_123',
      );
      
      final json = property.toJson();
      
      expect(json['id'], 'prop1');
      expect(json['name'], 'Test Property');
      expect(json['propertyType'], 'hotel');
      expect(json['basePrice'], 100.0);
      expect(json['amenities'].length, 2);
      expect(json['starRating'], 4);
    });
  });
  
  group('Booking Model Tests', () {
    test('Booking should be correctly instantiated', () {
      final checkInDate = DateTime.now().add(const Duration(days: 10));
      final checkOutDate = DateTime.now().add(const Duration(days: 15));
      
      final booking = Booking(
        id: 'booking1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: 2,
        totalPrice: 500.0,
        currency: 'USD',
        status: BookingStatus.confirmed,
        confirmationCode: 'TEST123',
        createdAt: DateTime.now(),
      );
      
      expect(booking.id, 'booking1');
      expect(booking.propertyId, 'prop1');
      expect(booking.checkInDate, checkInDate);
      expect(booking.checkOutDate, checkOutDate);
      expect(booking.totalPrice, 500.0);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.isUpcoming, true);
      expect(booking.isActive, false);
      expect(booking.isPast, false);
    });
    
    test('Booking status helpers should work correctly', () {
      // Past booking (completed)
      final pastBooking = Booking(
        id: 'booking1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().subtract(const Duration(days: 15)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 10)),
        numberOfGuests: 2,
        totalPrice: 500.0,
        currency: 'USD',
        status: BookingStatus.completed,
        confirmationCode: 'TEST123',
        createdAt: DateTime.now(),
      );
      
      expect(pastBooking.isUpcoming, false);
      expect(pastBooking.isActive, false);
      expect(pastBooking.isPast, true);
      
      // Current booking (active)
      final currentBooking = Booking(
        id: 'booking2',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().subtract(const Duration(days: 2)),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        numberOfGuests: 2,
        totalPrice: 500.0,
        currency: 'USD',
        status: BookingStatus.confirmed,
        confirmationCode: 'TEST123',
        createdAt: DateTime.now(),
      );
      
      expect(currentBooking.isUpcoming, false);
      expect(currentBooking.isActive, true);
      expect(currentBooking.isPast, false);
      
      // Future booking (upcoming)
      final futureBooking = Booking(
        id: 'booking3',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().add(const Duration(days: 10)),
        checkOutDate: DateTime.now().add(const Duration(days: 15)),
        numberOfGuests: 2,
        totalPrice: 500.0,
        currency: 'USD',
        status: BookingStatus.confirmed,
        confirmationCode: 'TEST123',
        createdAt: DateTime.now(),
      );
      
      expect(futureBooking.isUpcoming, true);
      expect(futureBooking.isActive, false);
      expect(futureBooking.isPast, false);
    });
  });
}
