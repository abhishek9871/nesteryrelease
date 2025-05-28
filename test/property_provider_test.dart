import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';

void main() {
  group('Property Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Property model should be correctly instantiated', () {
      final property = Property(
        id: '1',
        name: 'Luxury Hotel',
        description: 'A luxury hotel in the heart of the city',
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
        latitude: 40.7128,
        longitude: -74.0060,
        propertyType: 'hotel',
        basePrice: 200.0,
        currency: 'USD',
        maxGuests: 4,
        sourceType: 'booking_com',
        starRating: 5,
        amenities: ['WiFi', 'Pool', 'Spa'],
        images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        thumbnailImage: 'https://example.com/image1.jpg',
        externalId: 'booking_123',
      );

      expect(property.id, '1');
      expect(property.name, 'Luxury Hotel');
      expect(property.description, 'A luxury hotel in the heart of the city');
      expect(property.address, '123 Main St');
      expect(property.city, 'New York');
      expect(property.country, 'USA');
      expect(property.latitude, 40.7128);
      expect(property.longitude, -74.0060);
      expect(property.propertyType, 'hotel');
      expect(property.basePrice, 200.0);
      expect(property.currency, 'USD');
      expect(property.maxGuests, 4);
      expect(property.sourceType, 'booking_com');
      expect(property.starRating, 5);
      expect(property.amenities!.length, 3);
      expect(property.images!.length, 2);
      expect(property.thumbnailImage, 'https://example.com/image1.jpg');
      expect(property.externalId, 'booking_123');
    });

    test('Property fromJson should parse correctly', () {
      final json = {
        'id': '1',
        'name': 'Luxury Hotel',
        'description': 'A luxury hotel in the heart of the city',
        'address': '123 Main St',
        'city': 'New York',
        'country': 'USA',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'propertyType': 'hotel',
        'basePrice': 200.0,
        'currency': 'USD',
        'maxGuests': 4,
        'sourceType': 'booking_com',
        'starRating': 5,
        'amenities': ['WiFi', 'Pool', 'Spa'],
        'images': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        'thumbnailImage': 'https://example.com/image1.jpg',
        'externalId': 'booking_123',
      };

      final property = Property.fromJson(json);

      expect(property.id, '1');
      expect(property.name, 'Luxury Hotel');
      expect(property.propertyType, 'hotel');
      expect(property.basePrice, 200.0);
      expect(property.amenities!.length, 3);
      expect(property.images!.length, 2);
    });

    test('Property toJson should convert correctly', () {
      final property = Property(
        id: '1',
        name: 'Luxury Hotel',
        description: 'A luxury hotel in the heart of the city',
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
        latitude: 40.7128,
        longitude: -74.0060,
        propertyType: 'hotel',
        basePrice: 200.0,
        currency: 'USD',
        maxGuests: 4,
        sourceType: 'booking_com',
        starRating: 5,
        amenities: ['WiFi', 'Pool', 'Spa'],
        images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        thumbnailImage: 'https://example.com/image1.jpg',
        externalId: 'booking_123',
      );

      final json = property.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Luxury Hotel');
      expect(json['propertyType'], 'hotel');
      expect(json['basePrice'], 200.0);
      expect(json['amenities'].length, 3);
      expect(json['images'].length, 2);
    });

    test('Property copyWith should work correctly', () {
      final property = Property(
        id: '1',
        name: 'Luxury Hotel',
        description: 'A luxury hotel in the heart of the city',
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
        latitude: 40.7128,
        longitude: -74.0060,
        propertyType: 'hotel',
        basePrice: 200.0,
        currency: 'USD',
        maxGuests: 4,
        sourceType: 'booking_com',
        starRating: 5,
        amenities: ['WiFi', 'Pool', 'Spa'],
        images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        thumbnailImage: 'https://example.com/image1.jpg',
        externalId: 'booking_123',
      );

      final updatedProperty = property.copyWith(
        name: 'Updated Hotel',
        basePrice: 250.0,
        starRating: 4,
      );

      expect(updatedProperty.id, '1');
      expect(updatedProperty.name, 'Updated Hotel');
      expect(updatedProperty.basePrice, 250.0);
      expect(updatedProperty.starRating, 4);
      expect(updatedProperty.city, 'New York');
      expect(updatedProperty.country, 'USA');
      expect(updatedProperty.propertyType, 'hotel');
    });

    test('Property should handle null optional fields correctly', () {
      final property = Property(
        id: '1',
        name: 'Basic Hotel',
        description: 'A basic hotel',
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
        latitude: 40.7128,
        longitude: -74.0060,
        propertyType: 'hotel',
        basePrice: 100.0,
        currency: 'USD',
        maxGuests: 2,
        sourceType: 'booking_com',
      );

      expect(property.id, '1');
      expect(property.name, 'Basic Hotel');
      expect(property.amenities, null);
      expect(property.images, null);
      expect(property.thumbnailImage, null);
      expect(property.starRating, null);
      expect(property.externalId, null);
    });
  });
}
