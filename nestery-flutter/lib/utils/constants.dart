import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Colors
  static final Color primaryColor = Color(0xFF1E88E5);
  static final Color secondaryColor = Color(0xFF26A69A);
  static final Color accentColor = Color(0xFFFF9800);
  static final Color errorColor = Color(0xFFE53935);
  static final Color successColor = Color(0xFF43A047);
  static final Color warningColor = Color(0xFFFFA000);
  static final Color infoColor = Color(0xFF039BE5);
  
  // API Constants
  static late String apiBaseUrl;
  static late String googleMapsApiKey;
  static late String stripePublishableKey;
  static late String environment;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String propertiesEndpoint = '/properties';
  static const String bookingsEndpoint = '/bookings';
  static const String userProfileEndpoint = '/users/profile';
  static const String loyaltyEndpoint = '/features/loyalty';
  static const String recommendationsEndpoint = '/features/recommendation';
  static const String pricePredictionEndpoint = '/features/price-prediction';
  static const String socialSharingEndpoint = '/features/social-sharing';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Initialize constants from environment variables
  static void initialize() {
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    environment = dotenv.env['ENVIRONMENT'] ?? 'development';
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
}
