import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nestery_flutter/utils/app_router.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nestery_flutter/providers/repository_providers.dart'; // Ensure apiClientProvider is accessible

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep splash screen until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize app constants
  Constants.initialize();

  // Initialize ApiClient and its cache
  final apiClient = ApiClient();
  await apiClient.initializeCache();

  // Remove splash screen
  FlutterNativeSplash.remove();

  runApp(
    // Enable Riverpod for the entire app
    ProviderScope(
      overrides: [
        // Override the apiClientProvider to provide the initialized instance
        // This ensures that the apiClientProvider in repository_providers.dart (and auth_provider.dart)
        // uses the *same* instance of ApiClient that had its cache initialized.
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: const NesteryApp(),
    ),
  );
}

class NesteryApp extends ConsumerWidget {
  const NesteryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode changes
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Nestery',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // Light theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Use GoRouter for navigation
      routerConfig: AppRouter.router,
    );
  }
}
