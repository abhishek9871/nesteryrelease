import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/screens/splash_screen.dart';
import 'package:nestery_flutter/screens/login_screen.dart';
import 'package:nestery_flutter/screens/register_screen.dart';
import 'package:nestery_flutter/screens/home_screen.dart';
import 'package:nestery_flutter/screens/property_details_screen.dart';
import 'package:nestery_flutter/screens/booking_screen.dart';
import 'package:nestery_flutter/screens/booking_confirmation_screen.dart';
import 'package:nestery_flutter/screens/bookings_screen.dart';
import 'package:nestery_flutter/screens/search_screen.dart';
import 'package:nestery_flutter/screens/profile_screen.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/screens/loyalty_dashboard_screen.dart';
import 'package:nestery_flutter/screens/loyalty_transactions_screen.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/partner_dashboard_shell.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/dashboard_overview_screen.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/offer_list_screen.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/link_generation_screen.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/earnings_report_screen.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/partner_settings_screen.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/screens/offer_edit_screen.dart';
import 'package:nestery_flutter/utils/constants.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    // TODO: Consider adding /partner-dashboard to publicPaths if it has a separate login or is accessible before main app login.
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Redirect logic based on authentication state
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ProviderScope.containerOf(context).read(authProvider);
      final isLoggedIn = authState.isAuthenticated;

      // Paths that don't require authentication
      final publicPaths = ['/login', '/register', '/'];

      // If the user is not logged in and trying to access a protected route
      if (!isLoggedIn && !publicPaths.contains(state.matchedLocation)) {
        return '/login';
      }

      // If the user is logged in and trying to access login/register
      if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/home';
      }

      // No redirection needed
      return null;
    },

    // Route configuration
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Property details (nested under home)
              GoRoute(
                path: 'property/:id',
                builder: (context, state) {
                  final propertyId = state.pathParameters['id']!;
                  return PropertyDetailsScreen(propertyId: propertyId);
                },
                routes: [
                  // Booking flow (nested under property details)
                  GoRoute(
                    path: 'book',
                    builder: (context, state) {
                      final propertyId = state.pathParameters['id']!;
                      final bookingData = state.extra as Map<String, dynamic>? ?? {
                        'propertyId': propertyId,
                        'checkInDate': DateTime.now().add(const Duration(days: 1)),
                        'checkOutDate': DateTime.now().add(const Duration(days: 3)),
                        'guestCount': 1,
                        'totalPrice': 0.0,
                      };
                      return BookingScreen(bookingData: bookingData);
                    },
                  ),
                  // Booking confirmation (nested under property details)
                  GoRoute(
                    path: 'confirmation/:bookingId',
                    builder: (context, state) {
                      final booking = state.extra as Booking?;
                      if (booking != null) {
                        return BookingConfirmationScreen(booking: booking);
                      } else {
                        // Fallback: create a minimal booking object from bookingId
                        final bookingId = state.pathParameters['bookingId']!;
                        return BookingConfirmationScreen(
                          booking: Booking(
                            id: bookingId,
                            propertyId: 'unknown',
                            propertyName: 'Unknown Property',
                            checkInDate: DateTime.now(),
                            checkOutDate: DateTime.now().add(const Duration(days: 1)),
                            numberOfGuests: 1,
                            totalPrice: 0.0,
                            currency: 'USD',
                            status: BookingStatus.confirmed,
                            confirmationCode: 'CONF-$bookingId',
                            createdAt: DateTime.now(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // Search tab
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
            routes: [
              // Property details (nested under search)
              GoRoute(
                path: 'property/:id',
                builder: (context, state) {
                  final propertyId = state.pathParameters['id']!;
                  return PropertyDetailsScreen(propertyId: propertyId);
                },
              ),
            ],
          ),

          // Bookings tab
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
            routes: [
              // Booking details (nested under bookings)
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final booking = state.extra as Booking?;
                  if (booking != null) {
                    return BookingConfirmationScreen(booking: booking);
                  } else {
                    // Fallback: create a minimal booking object from bookingId
                    final bookingId = state.pathParameters['id']!;
                    return BookingConfirmationScreen(
                      booking: Booking(
                        id: bookingId,
                        propertyId: 'unknown',
                        propertyName: 'Unknown Property',
                        checkInDate: DateTime.now(),
                        checkOutDate: DateTime.now().add(const Duration(days: 1)),
                        numberOfGuests: 1,
                        totalPrice: 0.0,
                        currency: 'USD',
                        status: BookingStatus.confirmed,
                        confirmationCode: 'CONF-$bookingId',
                        createdAt: DateTime.now(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Loyalty Program Routes (can be accessed from profile or other parts of the app)
           GoRoute(
            path: '/loyalty',
            builder: (context, state) => const LoyaltyDashboardScreen(),
            routes: [
              GoRoute(path: 'transactions', builder: (context, state) => const LoyaltyTransactionsScreen()),
            ]
          ),
        ],
      ),

      // Partner Dashboard Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PartnerDashboardShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Constants.partnerDashboardRoute, // '/partner-dashboard'
                builder: (context, state) => const DashboardOverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Constants.partnerDashboardOffersRoute, // '/partner-dashboard/offers'
                builder: (context, state) => const OfferListScreen(),
                routes: [
                  GoRoute(
                    path: 'new', // '/partner-dashboard/offers/new'
                    builder: (context, state) => OfferEditScreen(offerId: 'new'),
                  ),
                  GoRoute(
                    path: ':offerId/edit', // '/partner-dashboard/offers/:offerId/edit'
                    builder: (context, state) => OfferEditScreen(offerId: state.pathParameters['offerId']!),
                  ),
                ]
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Constants.partnerDashboardLinksRoute, builder: (context, state) => const LinkGenerationScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Constants.partnerDashboardEarningsRoute, builder: (context, state) => const EarningsReportScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Constants.partnerDashboardSettingsRoute, builder: (context, state) => const PartnerSettingsScreen())],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops! The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Scaffold with bottom navigation bar for main app shell
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Calculate the current selected index based on the current route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/search')) {
      return 1;
    }
    if (location.startsWith('/bookings')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  // Handle bottom navigation item tap
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
