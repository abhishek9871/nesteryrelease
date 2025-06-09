import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF039BE5);

  // Additional UI Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF212121);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Loyalty Tier Colors
  static const Color bronzeTierColor = Color(0xFFCD7F32);
  static const Color silverTierColor = Color(0xFFC0C0C0);
  static const Color goldTierColor = Color(0xFFFFD700);
  static const Color platinumTierColor = Color(0xFFE5E4E2);

  // API Constants
  static late String apiBaseUrl;
  static late String googleMapsApiKey;
  static late String stripePublishableKey;
  static late String bookingComApiKey;
  static late String oyoApiKey;
  static late String oyoPartnerId;
  static late String hotelbedsApiKey;
  static late String hotelbedsApiSecret;
  static late String environment;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String userProfileEndpoint = '/users/profile';
  static const String propertiesEndpoint = '/properties';
  static const String bookingsEndpoint = '/bookings';
  static const String reviewsEndpoint = '/reviews';
  static const String loyaltyStatusEndpoint = '/loyalty/status';
  static const String loyaltyCheckInEndpoint = '/loyalty/check-in';
  static const String loyaltyTransactionsEndpoint = '/loyalty/transactions';
  // static const String loyaltyEndpoint = '/loyalty'; // Old, replaced by specific endpoints
  static const String socialSharingEndpoint = '/social';
  static const String recommendationsEndpoint = '/recommendations';
  static const String pricePredictionEndpoint = '/price-prediction';

  // Pagination
  static const int defaultPageSize = 20;
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Padding Constants
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border Radius Constants
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: onSurfaceColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: onSurfaceColor,
  );

  // Asset Paths
  static const String logoImage = 'assets/images/splash_logo.png';
  static const String appIconPath = 'assets/icons/app_icon.png';

  // Route Names
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String bookingsRoute = '/bookings';
  static const String profileRoute = '/profile';
  static const String propertyDetailsRoute = '/home/property';
  static const String bookingRoute = '/home/property/book';
  static const String bookingConfirmationRoute = '/home/property/confirmation';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute = '/reset-password';
  static const String termsConditionsRoute = '/terms-conditions';
  // Partner Dashboard Routes
  static const String partnerDashboardRoute = '/partner-dashboard';
  static const String partnerDashboardOffersRoute = '/partner-dashboard/offers';
  static const String partnerDashboardLinksRoute = '/partner-dashboard/links';
  static const String partnerDashboardEarningsRoute = '/partner-dashboard/earnings';
  static const String partnerDashboardSettingsRoute = '/partner-dashboard/settings';

  // Initialize constants from environment variables
  static void initialize() {
    try {
      apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/v1';
      googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
      bookingComApiKey = dotenv.env['BOOKING_COM_API_KEY'] ?? '';
      oyoApiKey = dotenv.env['OYO_API_KEY'] ?? '';
      oyoPartnerId = dotenv.env['OYO_PARTNER_ID'] ?? '';
      hotelbedsApiKey = dotenv.env['HOTELBEDS_API_KEY'] ?? '';
      hotelbedsApiSecret = dotenv.env['HOTELBEDS_API_SECRET'] ?? '';
      environment = dotenv.env['ENVIRONMENT'] ?? 'development';
    } catch (e) {
      // If dotenv is not initialized (e.g., in tests), use default values
      apiBaseUrl = 'http://localhost:3000/v1';
      googleMapsApiKey = '';
      stripePublishableKey = '';
      bookingComApiKey = '';
      oyoApiKey = '';
      oyoPartnerId = '';
      hotelbedsApiKey = '';
      hotelbedsApiSecret = '';
      environment = 'test';
    }
  }

  // Validation Patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );
  static final RegExp phonePattern = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordInvalid = 'Password must be at least 8 characters with letters and numbers';
  static const String nameRequired = 'Name is required';
  static const String phoneInvalid = 'Please enter a valid phone number';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection and try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Your session has expired. Please login again.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String bookingSuccess = 'Booking confirmed successfully';
  static const String profileUpdateSuccess = 'Profile updated successfully';

  // Feature Flags
  static bool get isLoyaltyEnabled => true;
  static bool get isPricePredictionEnabled => true;
  static bool get isRecommendationEnabled => true;
  static bool get isSocialSharingEnabled => true;

  // Property Types
  static const List<String> propertyTypes = [
    'Hotel',
    'Apartment',
    'Villa',
    'Resort',
    'Hostel',
    'Guesthouse',
    'Bed & Breakfast',
    'Vacation Rental',
  ];

  // Common Amenities
  static const List<Map<String, dynamic>> commonAmenities = [
    {'id': 'wifi', 'name': 'WiFi', 'icon': 'wifi'},
    {'id': 'pool', 'name': 'Swimming Pool', 'icon': 'pool'},
    {'id': 'parking', 'name': 'Parking', 'icon': 'local_parking'},
    {'id': 'ac', 'name': 'Air Conditioning', 'icon': 'ac_unit'},
    {'id': 'gym', 'name': 'Fitness Center', 'icon': 'fitness_center'},
    {'id': 'breakfast', 'name': 'Breakfast', 'icon': 'restaurant'},
    {'id': 'spa', 'name': 'Spa', 'icon': 'spa'},
    {'id': 'tv', 'name': 'TV', 'icon': 'tv'},
    {'id': 'kitchen', 'name': 'Kitchen', 'icon': 'kitchen'},
    {'id': 'washer', 'name': 'Laundry', 'icon': 'local_laundry_service'},
    {'id': 'balcony', 'name': 'Balcony', 'icon': 'balcony'},
    {'id': 'pets', 'name': 'Pet Friendly', 'icon': 'pets'},
  ];

  // Loyalty Tiers
  static const List<Map<String, dynamic>> loyaltyTiers = [
    {
      'name': 'Bronze',
      'color': bronzeTierColor,
      'minPoints': 0,
      'benefits': ['Basic support', '1x points earning'],
    },
    {
      'name': 'Silver',
      'color': silverTierColor,
      'minPoints': 1000,
      'benefits': ['Priority support', '1.25x points earning', 'Early access to deals'],
    },
    {
      'name': 'Gold',
      'color': goldTierColor,
      'minPoints': 5000,
      'benefits': ['Premium support', '1.5x points earning', 'Exclusive deals', 'Free cancellation'],
    },
    {
      'name': 'Platinum',
      'color': platinumTierColor,
      'minPoints': 15000,
      'benefits': ['VIP support', '2x points earning', 'Premium features', 'Concierge service'],
    },
  ];

  // App Configuration
  static const String appName = 'Nestery';
  static const String appTagline = 'Find your perfect stay';
  static const String appVersion = '1.0.0';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/nestery';
  static const String twitterUrl = 'https://twitter.com/nestery';
  static const String instagramUrl = 'https://instagram.com/nestery';
  static const String linkedinUrl = 'https://linkedin.com/company/nestery';

  // Support
  static const String supportEmail = 'support@nestery.com';
  static const String supportPhone = '+1-800-NESTERY';
  static const String privacyPolicyUrl = 'https://nestery.com/privacy';
  static const String termsOfServiceUrl = 'https://nestery.com/terms';

  // Cache Constants
  static const String cacheDbName = 'nestery_cache.db';
  static const String cacheDbKey = 'nestery_cache_secure_key'; // For potential encryption
  static const Duration defaultCacheTTL = Duration(hours: 1);
  static const Duration userProfileCacheTTL = Duration(days: 1);
  static const Duration propertyListCacheTTL = Duration(minutes: 30);
  // Add other specific TTLs as needed
  // static const Duration loyaltyStatusCacheTTL = Duration(minutes: 15);
}
