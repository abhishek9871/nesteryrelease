import 'package:flutter/material.dart';

class Constants {
  // API Endpoints
  static const String apiBaseUrl = 'https://api.nestery.com';
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String propertyDetailsRoute = '/property-details';
  static const String bookingRoute = '/booking';
  static const String bookingConfirmationRoute = '/booking-confirmation';
  static const String bookingsRoute = '/bookings';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String loyaltyRoute = '/loyalty';
  static const String searchRoute = '/search';
  
  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color accentColor = Color(0xFF26A69A);
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color textColor = Colors.black87;
  static const Color secondaryTextColor = Colors.black54;
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: secondaryTextColor,
  );
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Padding and Margins
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Border Radius
  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 12.0;
  static const double extraLargeRadius = 24.0;
  
  // Image Assets
  static const String logoImage = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String errorImage = 'assets/images/error.png';
  
  // Loyalty Tiers
  static const Map<String, Color> loyaltyTierColors = {
    'bronze': Color(0xFFCD7F32),
    'silver': Color(0xFFC0C0C0),
    'gold': Color(0xFFFFD700),
    'platinum': Color(0xFFE5E4E2),
  };
  
  // Property Types
  static const List<String> propertyTypes = [
    'Hotel',
    'Apartment',
    'Resort',
    'Villa',
    'Hostel',
    'Guesthouse',
  ];
  
  // Common Amenities
  static const List<String> commonAmenities = [
    'WiFi',
    'Pool',
    'Parking',
    'Air Conditioning',
    'Restaurant',
    'Fitness Center',
    'Spa',
    'Room Service',
    'Bar',
    'Breakfast',
  ];
}
