import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/widgets/property_card.dart';

void main() {
  final mockProperty = Property(
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

  testWidgets('PropertyCard should render correctly', (WidgetTester tester) async {
    bool onTapCalled = false;

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: mockProperty,
            onTap: () {
              onTapCalled = true;
            },
          ),
        ),
      ),
    );

    // Verify that the property card displays the correct information
    expect(find.text('Test Property'), findsOneWidget);
    expect(find.text('Test City, Test Country'), findsOneWidget);
    expect(find.text('USD 100'), findsOneWidget); // Price format is "USD 100" not "$100.00"

    // Verify that the star rating is displayed
    expect(find.byIcon(Icons.star), findsWidgets);

    // Verify that the source badge is displayed (sourceType, not propertyType)
    expect(find.text('booking_com'), findsOneWidget); // sourceType is displayed as badge

    // Tap the card and verify that onTap is called
    await tester.tap(find.byType(PropertyCard));
    expect(onTapCalled, true);
  });

  testWidgets('PropertyCard should display source badge correctly', (WidgetTester tester) async {
    final bookingProperty = Property(
      id: 'prop2',
      name: 'Booking Property',
      description: 'A booking.com property',
      address: '456 Booking St',
      city: 'Booking City',
      country: 'Booking Country',
      latitude: 0.0,
      longitude: 0.0,
      propertyType: 'resort',
      basePrice: 500.0,
      currency: 'USD',
      maxGuests: 6,
      sourceType: 'booking.com',
      starRating: 5,
      amenities: ['WiFi', 'Pool', 'Spa'],
      images: ['https://example.com/booking.jpg'],
      thumbnailImage: 'https://example.com/booking_thumb.jpg',
      externalId: 'bcom_456',
    );

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: bookingProperty,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the source badge is displayed
    expect(find.text('Booking.com'), findsOneWidget);
  });

  testWidgets('PropertyCard should display direct source badge', (WidgetTester tester) async {
    final directProperty = mockProperty.copyWith(sourceType: 'direct');

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: directProperty,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the direct source badge is displayed
    expect(find.text('Direct'), findsOneWidget);
  });
}
