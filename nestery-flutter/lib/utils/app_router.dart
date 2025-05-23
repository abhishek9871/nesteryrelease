import 'package:flutter/material.dart';
import 'package:nestery_flutter/screens/home_screen.dart';
import 'package:nestery_flutter/screens/login_screen.dart';
import 'package:nestery_flutter/screens/register_screen.dart';
import 'package:nestery_flutter/screens/property_details_screen.dart';
import 'package:nestery_flutter/screens/booking_screen.dart';
import 'package:nestery_flutter/screens/booking_confirmation_screen.dart';
import 'package:nestery_flutter/screens/bookings_screen.dart';
import 'package:nestery_flutter/screens/profile_screen.dart';
import 'package:nestery_flutter/screens/settings_screen.dart';
import 'package:nestery_flutter/screens/loyalty_screen.dart';
import 'package:nestery_flutter/screens/search_screen.dart';
import 'package:nestery_flutter/utils/constants.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Constants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case Constants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case Constants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case Constants.propertyDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PropertyDetailsScreen(propertyId: args['propertyId']),
        );
        
      case Constants.bookingRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingScreen(
            propertyId: args['propertyId'],
            checkInDate: args['checkInDate'],
            checkOutDate: args['checkOutDate'],
          ),
        );
        
      case Constants.bookingConfirmationRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(bookingId: args['bookingId']),
        );
        
      case Constants.bookingsRoute:
        return MaterialPageRoute(builder: (_) => const BookingsScreen());
        
      case Constants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case Constants.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case Constants.loyaltyRoute:
        return MaterialPageRoute(builder: (_) => const LoyaltyScreen());
        
      case Constants.searchRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SearchScreen(
            initialQuery: args?['initialQuery'],
            initialFilters: args?['initialFilters'],
          ),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
