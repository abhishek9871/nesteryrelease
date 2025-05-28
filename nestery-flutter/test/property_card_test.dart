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
    expect(find.text('\$100.00'), findsOneWidget);

    // Verify that the star rating is displayed
    expect(find.byIcon(Icons.star), findsWidgets);

    // Verify that the property type is displayed
    expect(find.text('Hotel'), findsOneWidget);

    // Tap the card and verify that onTap is called
    await tester.tap(find.byType(PropertyCard));
    expect(onTapCalled, true);
  });

  testWidgets('PropertyCard should display premium badge when property is premium', (WidgetTester tester) async {
    final premiumProperty = Property(
      id: 'prop2',
      name: 'Premium Property',
      description: 'A premium property',
      address: '456 Premium St',
      city: 'Luxury City',
      country: 'Premium Country',
      latitude: 0.0,
      longitude: 0.0,
      propertyType: 'resort',
      basePrice: 500.0,
      currency: 'USD',
      maxGuests: 6,
      sourceType: 'booking_com',
      starRating: 5,
      amenities: ['WiFi', 'Pool', 'Spa'],
      images: ['https://example.com/premium.jpg'],
      thumbnailImage: 'https://example.com/premium_thumb.jpg',
      externalId: 'bcom_456',
    );

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: premiumProperty,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the premium badge is displayed
    expect(find.text('PREMIUM'), findsOneWidget);
  });

  testWidgets('PropertyCard should not display premium badge when property is not premium', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: mockProperty, // Not premium
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the premium badge is not displayed
    expect(find.text('PREMIUM'), findsNothing);
  });
}
