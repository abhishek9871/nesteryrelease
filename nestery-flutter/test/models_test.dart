import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/booking.dart';

class MockPropertyService extends Mock {
  Future<List<Property>> getProperties() async {
    return [
      Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_123',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        starRating: 4,
        basePrice: 100.0,
        currency: 'USD',
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        rating: 4.5,
        reviewCount: 100,
        isFeatured: true,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
  Future<Property> getPropertyById(String id) async {
    return Property(
      id: id,
      name: 'Test Property',
      description: 'A test property',
      type: 'Hotel',
      sourceType: 'booking_com',
      sourceId: 'bcom_123',
      address: '123 Test St',
      city: 'Test City',
      country: 'Test Country',
      latitude: 0.0,
      longitude: 0.0,
      starRating: 4,
      basePrice: 100.0,
      currency: 'USD',
      amenities: ['WiFi', 'Pool'],
      images: ['https://example.com/image.jpg'],
      thumbnailImage: 'https://example.com/thumb.jpg',
      rating: 4.5,
      reviewCount: 100,
      isFeatured: true,
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  Future<List<Property>> searchProperties(Map<String, dynamic> filters) async {
    return [
      Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_123',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        starRating: 4,
        basePrice: 100.0,
        currency: 'USD',
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        rating: 4.5,
        reviewCount: 100,
        isFeatured: true,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class MockBookingService extends Mock {
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    return Booking(
      id: 'booking1',
      userId: bookingData['userId'],
      propertyId: bookingData['propertyId'],
      propertyName: 'Test Property',
      propertyThumbnail: 'https://example.com/thumb.jpg',
      checkInDate: bookingData['checkInDate'],
      checkOutDate: bookingData['checkOutDate'],
      numberOfGuests: bookingData['numberOfGuests'],
      numberOfRooms: bookingData['numberOfRooms'],
      totalPrice: bookingData['totalPrice'],
      currency: 'USD',
      status: 'confirmed',
      confirmationCode: 'TEST123',
      loyaltyPointsEarned: 10,
      isPremiumBooking: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  Future<List<Booking>> getUserBookings(String userId) async {
    return [
      Booking(
        id: 'booking1',
        userId: userId,
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().add(const Duration(days: 10)),
        checkOutDate: DateTime.now().add(const Duration(days: 15)),
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 500.0,
        currency: 'USD',
        status: 'confirmed',
        confirmationCode: 'TEST123',
        loyaltyPointsEarned: 50,
        isPremiumBooking: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

void main() {
  group('Property Model Tests', () {
    test('Property should be correctly instantiated', () {
      final property = Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_123',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        starRating: 4,
        basePrice: 100.0,
        currency: 'USD',
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        rating: 4.5,
        reviewCount: 100,
        isFeatured: true,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(property.id, 'prop1');
      expect(property.name, 'Test Property');
      expect(property.type, 'Hotel');
      expect(property.basePrice, 100.0);
      expect(property.amenities.length, 2);
      expect(property.starRating, 4);
    });
    
    test('Property fromJson should parse correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'prop1',
        'name': 'Test Property',
        'description': 'A test property',
        'type': 'Hotel',
        'sourceType': 'booking_com',
        'sourceId': 'bcom_123',
        'address': '123 Test St',
        'city': 'Test City',
        'country': 'Test Country',
        'latitude': 0.0,
        'longitude': 0.0,
        'starRating': 4,
        'basePrice': 100.0,
        'currency': 'USD',
        'amenities': ['WiFi', 'Pool'],
        'images': ['https://example.com/image.jpg'],
        'thumbnailImage': 'https://example.com/thumb.jpg',
        'rating': 4.5,
        'reviewCount': 100,
        'isFeatured': true,
        'isPremium': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      
      final property = Property.fromJson(json);
      
      expect(property.id, 'prop1');
      expect(property.name, 'Test Property');
      expect(property.type, 'Hotel');
      expect(property.basePrice, 100.0);
      expect(property.amenities.length, 2);
      expect(property.starRating, 4);
    });
    
    test('Property toJson should convert correctly', () {
      final now = DateTime.now();
      final property = Property(
        id: 'prop1',
        name: 'Test Property',
        description: 'A test property',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_123',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        latitude: 0.0,
        longitude: 0.0,
        starRating: 4,
        basePrice: 100.0,
        currency: 'USD',
        amenities: ['WiFi', 'Pool'],
        images: ['https://example.com/image.jpg'],
        thumbnailImage: 'https://example.com/thumb.jpg',
        rating: 4.5,
        reviewCount: 100,
        isFeatured: true,
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      );
      
      final json = property.toJson();
      
      expect(json['id'], 'prop1');
      expect(json['name'], 'Test Property');
      expect(json['type'], 'Hotel');
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
        userId: 'user1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 500.0,
        currency: 'USD',
        status: 'confirmed',
        confirmationCode: 'TEST123',
        loyaltyPointsEarned: 50,
        isPremiumBooking: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(booking.id, 'booking1');
      expect(booking.userId, 'user1');
      expect(booking.propertyId, 'prop1');
      expect(booking.checkInDate, checkInDate);
      expect(booking.checkOutDate, checkOutDate);
      expect(booking.totalPrice, 500.0);
      expect(booking.status, 'confirmed');
      expect(booking.isUpcoming, true);
      expect(booking.isActive, false);
      expect(booking.isCompleted, false);
    });
    
    test('Booking status helpers should work correctly', () {
      // Past booking (completed)
      final pastBooking = Booking(
        id: 'booking1',
        userId: 'user1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().subtract(const Duration(days: 15)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 10)),
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 500.0,
        currency: 'USD',
        status: 'completed',
        confirmationCode: 'TEST123',
        loyaltyPointsEarned: 50,
        isPremiumBooking: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(pastBooking.isUpcoming, false);
      expect(pastBooking.isActive, false);
      expect(pastBooking.isCompleted, true);
      
      // Current booking (active)
      final currentBooking = Booking(
        id: 'booking2',
        userId: 'user1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().subtract(const Duration(days: 2)),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 500.0,
        currency: 'USD',
        status: 'confirmed',
        confirmationCode: 'TEST123',
        loyaltyPointsEarned: 50,
        isPremiumBooking: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(currentBooking.isUpcoming, false);
      expect(currentBooking.isActive, true);
      expect(currentBooking.isCompleted, false);
      
      // Future booking (upcoming)
      final futureBooking = Booking(
        id: 'booking3',
        userId: 'user1',
        propertyId: 'prop1',
        propertyName: 'Test Property',
        propertyThumbnail: 'https://example.com/thumb.jpg',
        checkInDate: DateTime.now().add(const Duration(days: 10)),
        checkOutDate: DateTime.now().add(const Duration(days: 15)),
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 500.0,
        currency: 'USD',
        status: 'confirmed',
        confirmationCode: 'TEST123',
        loyaltyPointsEarned: 50,
        isPremiumBooking: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(futureBooking.isUpcoming, true);
      expect(futureBooking.isActive, false);
      expect(futureBooking.isCompleted, false);
    });
  });
}
