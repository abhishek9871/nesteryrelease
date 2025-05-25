import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/data/repositories/property_repository.dart';

@GenerateMocks([PropertyRepository])
void main() {
  late MockPropertyRepository mockPropertyRepository;
  late ProviderContainer container;

  setUp(() {
    mockPropertyRepository = MockPropertyRepository();
    container = ProviderContainer(
      overrides: [
        propertyRepositoryProvider.overrideWithValue(mockPropertyRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FeaturedPropertiesProvider', () {
    test('initial state is loading with empty properties list', () {
      final state = container.read(featuredPropertiesProvider);
      expect(state.isLoading, true);
      expect(state.properties, isEmpty);
      expect(state.error, null);
    });

    test('loadFeaturedProperties updates state correctly on success', () async {
      // Arrange
      final testProperties = [
        Property(
          id: '1',
          name: 'Luxury Hotel',
          description: 'A luxury hotel in the heart of the city',
          city: 'New York',
          country: 'USA',
          price: 200,
          currency: 'USD',
          rating: 4.5,
          reviewCount: 120,
          thumbnailImage: 'https://example.com/image1.jpg',
          images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
          amenities: ['WiFi', 'Pool', 'Spa'],
          sourceType: 'Booking.com',
        ),
        Property(
          id: '2',
          name: 'Beach Resort',
          description: 'A beautiful beach resort',
          city: 'Miami',
          country: 'USA',
          price: 300,
          currency: 'USD',
          rating: 4.8,
          reviewCount: 200,
          thumbnailImage: 'https://example.com/image3.jpg',
          images: ['https://example.com/image3.jpg', 'https://example.com/image4.jpg'],
          amenities: ['WiFi', 'Pool', 'Beach Access'],
          sourceType: 'OYO',
        ),
      ];
      
      when(mockPropertyRepository.getFeaturedProperties())
          .thenAnswer((_) async => testProperties);

      // Act
      await container.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();

      // Assert
      final state = container.read(featuredPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, testProperties);
      expect(state.error, null);
    });

    test('loadFeaturedProperties updates state correctly on failure', () async {
      // Arrange
      when(mockPropertyRepository.getFeaturedProperties())
          .thenThrow(Exception('Network error'));

      // Act
      await container.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();

      // Assert
      final state = container.read(featuredPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, isEmpty);
      expect(state.error, 'Failed to load featured properties: Exception: Network error');
    });
  });

  group('RecommendedPropertiesProvider', () {
    test('initial state is loading with empty properties list', () {
      final state = container.read(recommendedPropertiesProvider);
      expect(state.isLoading, true);
      expect(state.properties, isEmpty);
      expect(state.error, null);
    });

    test('loadRecommendedProperties updates state correctly on success', () async {
      // Arrange
      final testProperties = [
        Property(
          id: '3',
          name: 'Mountain Cabin',
          description: 'A cozy cabin in the mountains',
          city: 'Aspen',
          country: 'USA',
          price: 150,
          currency: 'USD',
          rating: 4.2,
          reviewCount: 80,
          thumbnailImage: 'https://example.com/image5.jpg',
          images: ['https://example.com/image5.jpg', 'https://example.com/image6.jpg'],
          amenities: ['WiFi', 'Fireplace', 'Mountain View'],
          sourceType: 'Booking.com',
        ),
        Property(
          id: '4',
          name: 'City Apartment',
          description: 'A modern apartment in downtown',
          city: 'Chicago',
          country: 'USA',
          price: 120,
          currency: 'USD',
          rating: 4.0,
          reviewCount: 65,
          thumbnailImage: 'https://example.com/image7.jpg',
          images: ['https://example.com/image7.jpg', 'https://example.com/image8.jpg'],
          amenities: ['WiFi', 'Kitchen', 'City View'],
          sourceType: 'OYO',
        ),
      ];
      
      when(mockPropertyRepository.getRecommendedProperties())
          .thenAnswer((_) async => testProperties);

      // Act
      await container.read(recommendedPropertiesProvider.notifier).loadRecommendedProperties();

      // Assert
      final state = container.read(recommendedPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, testProperties);
      expect(state.error, null);
    });

    test('loadRecommendedProperties updates state correctly on failure', () async {
      // Arrange
      when(mockPropertyRepository.getRecommendedProperties())
          .thenThrow(Exception('Network error'));

      // Act
      await container.read(recommendedPropertiesProvider.notifier).loadRecommendedProperties();

      // Assert
      final state = container.read(recommendedPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, isEmpty);
      expect(state.error, 'Failed to load recommended properties: Exception: Network error');
    });
  });

  group('PropertyDetailsProvider', () {
    test('initial state is loading with null property', () {
      final state = container.read(propertyDetailsProvider('1'));
      expect(state.isLoading, true);
      expect(state.property, null);
      expect(state.error, null);
    });

    test('loadPropertyDetails updates state correctly on success', () async {
      // Arrange
      final testProperty = Property(
        id: '1',
        name: 'Luxury Hotel',
        description: 'A luxury hotel in the heart of the city',
        city: 'New York',
        country: 'USA',
        price: 200,
        currency: 'USD',
        rating: 4.5,
        reviewCount: 120,
        thumbnailImage: 'https://example.com/image1.jpg',
        images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        amenities: ['WiFi', 'Pool', 'Spa'],
        sourceType: 'Booking.com',
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001',
        cancellationPolicy: 'Free cancellation up to 24 hours before check-in',
      );
      
      when(mockPropertyRepository.getPropertyDetails('1'))
          .thenAnswer((_) async => testProperty);

      // Act
      await container.read(propertyDetailsProvider('1').notifier).loadPropertyDetails();

      // Assert
      final state = container.read(propertyDetailsProvider('1'));
      expect(state.isLoading, false);
      expect(state.property, testProperty);
      expect(state.error, null);
    });

    test('loadPropertyDetails updates state correctly on failure', () async {
      // Arrange
      when(mockPropertyRepository.getPropertyDetails('999'))
          .thenThrow(Exception('Property not found'));

      // Act
      await container.read(propertyDetailsProvider('999').notifier).loadPropertyDetails();

      // Assert
      final state = container.read(propertyDetailsProvider('999'));
      expect(state.isLoading, false);
      expect(state.property, null);
      expect(state.error, 'Failed to load property details: Exception: Property not found');
    });
  });

  group('SearchPropertiesProvider', () {
    test('initial state is not loading with empty properties list', () {
      final state = container.read(searchPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, isEmpty);
      expect(state.error, null);
    });

    test('searchProperties updates state correctly on success', () async {
      // Arrange
      final testProperties = [
        Property(
          id: '5',
          name: 'Paris Hotel',
          description: 'A charming hotel in Paris',
          city: 'Paris',
          country: 'France',
          price: 180,
          currency: 'EUR',
          rating: 4.3,
          reviewCount: 150,
          thumbnailImage: 'https://example.com/image9.jpg',
          images: ['https://example.com/image9.jpg', 'https://example.com/image10.jpg'],
          amenities: ['WiFi', 'Breakfast', 'City View'],
          sourceType: 'Booking.com',
        ),
        Property(
          id: '6',
          name: 'Paris Apartment',
          description: 'A cozy apartment near Eiffel Tower',
          city: 'Paris',
          country: 'France',
          price: 120,
          currency: 'EUR',
          rating: 4.1,
          reviewCount: 90,
          thumbnailImage: 'https://example.com/image11.jpg',
          images: ['https://example.com/image11.jpg', 'https://example.com/image12.jpg'],
          amenities: ['WiFi', 'Kitchen', 'Eiffel Tower View'],
          sourceType: 'OYO',
        ),
      ];
      
      final searchParams = {
        'query': 'Paris',
        'checkInDate': DateTime(2025, 6, 1),
        'checkOutDate': DateTime(2025, 6, 5),
        'guestCount': 2,
      };
      
      when(mockPropertyRepository.searchProperties(searchParams))
          .thenAnswer((_) async => testProperties);

      // Act
      await container.read(searchPropertiesProvider.notifier).searchProperties(searchParams);

      // Assert
      final state = container.read(searchPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, testProperties);
      expect(state.error, null);
    });

    test('searchProperties updates state correctly on failure', () async {
      // Arrange
      final searchParams = {
        'query': 'NonExistentLocation',
        'checkInDate': DateTime(2025, 6, 1),
        'checkOutDate': DateTime(2025, 6, 5),
        'guestCount': 2,
      };
      
      when(mockPropertyRepository.searchProperties(searchParams))
          .thenThrow(Exception('Network error'));

      // Act
      await container.read(searchPropertiesProvider.notifier).searchProperties(searchParams);

      // Assert
      final state = container.read(searchPropertiesProvider);
      expect(state.isLoading, false);
      expect(state.properties, isEmpty);
      expect(state.error, 'Failed to search properties: Exception: Network error');
    });
  });

  group('PropertyAvailabilityProvider', () {
    test('initial state is not loading with null availability', () {
      final state = container.read(propertyAvailabilityProvider('1'));
      expect(state.isLoading, false);
      expect(state.availability, null);
      expect(state.error, null);
    });

    test('checkAvailability updates state correctly on success', () async {
      // Arrange
      final availabilityParams = {
        'propertyId': '1',
        'checkInDate': DateTime(2025, 6, 1),
        'checkOutDate': DateTime(2025, 6, 5),
        'guestCount': 2,
      };
      
      final availabilityResult = {
        'available': true,
        'rooms': [
          {
            'id': 'room1',
            'name': 'Deluxe Room',
            'price': 220,
            'currency': 'USD',
            'available': true,
          },
          {
            'id': 'room2',
            'name': 'Suite',
            'price': 350,
            'currency': 'USD',
            'available': true,
          },
        ],
        'totalPrice': 880,
        'currency': 'USD',
        'nights': 4,
      };
      
      when(mockPropertyRepository.checkAvailability(availabilityParams))
          .thenAnswer((_) async => availabilityResult);

      // Act
      await container.read(propertyAvailabilityProvider('1').notifier).checkAvailability(
        checkInDate: DateTime(2025, 6, 1),
        checkOutDate: DateTime(2025, 6, 5),
        guestCount: 2,
      );

      // Assert
      final state = container.read(propertyAvailabilityProvider('1'));
      expect(state.isLoading, false);
      expect(state.availability, availabilityResult);
      expect(state.error, null);
    });

    test('checkAvailability updates state correctly on failure', () async {
      // Arrange
      when(mockPropertyRepository.checkAvailability(any))
          .thenThrow(Exception('Service unavailable'));

      // Act
      await container.read(propertyAvailabilityProvider('1').notifier).checkAvailability(
        checkInDate: DateTime(2025, 6, 1),
        checkOutDate: DateTime(2025, 6, 5),
        guestCount: 2,
      );

      // Assert
      final state = container.read(propertyAvailabilityProvider('1'));
      expect(state.isLoading, false);
      expect(state.availability, null);
      expect(state.error, 'Failed to check availability: Exception: Service unavailable');
    });
  });
}
