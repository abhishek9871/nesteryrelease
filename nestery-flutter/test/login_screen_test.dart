import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/screens/login_screen.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';

// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _storage.clear();
  }
}

void main() {
  group('LoginScreen Widget Tests', () {
    setUpAll(() {
      // Initialize Flutter bindings for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      // Initialize Constants for tests
      Constants.initialize();
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });
    testWidgets('LoginScreen should render correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the secure storage provider with our mock
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify that the login form elements are present
      expect(find.text('Welcome to Nestery'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields (inside CustomTextField)
      expect(find.text('Login'), findsOneWidget); // Login button
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('LoginScreen should validate form fields', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Try to trigger form validation by tapping the button
      await tester.tap(find.text('Login'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Alternative approach: Find the form and trigger validation directly
      final formFinder = find.byType(Form);
      expect(formFinder, findsOneWidget);

      final form = tester.widget<Form>(formFinder);
      final formState = form.key as GlobalKey<FormState>;
      formState.currentState!.validate();
      await tester.pumpAndSettle();

      // Now check for validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LoginScreen should accept valid input', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Fill the form with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Verify that the text was entered correctly
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('LoginScreen should show email validation error for invalid email', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Trigger form validation
      final formFinder = find.byType(Form);
      final form = tester.widget<Form>(formFinder);
      final formState = form.key as GlobalKey<FormState>;
      formState.currentState!.validate();
      await tester.pumpAndSettle();

      // Verify that email validation error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('LoginScreen should show password validation error for short password', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');

      // Trigger form validation
      final formFinder = find.byType(Form);
      final form = tester.widget<Form>(formFinder);
      final formState = form.key as GlobalKey<FormState>;
      formState.currentState!.validate();
      await tester.pumpAndSettle();

      // Verify that password validation error is shown
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('LoginScreen should toggle password visibility', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Find the password field
      final passwordField = find.byType(TextFormField).at(1);

      // Enter password
      await tester.enterText(passwordField, 'password123');

      // Find the visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityToggle, findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Verify that the icon changed to visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('LoginScreen should have proper form structure', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify form structure
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      // CustomButton contains an ElevatedButton, so we should find it
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Verify that the form has proper labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
