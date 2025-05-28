import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen should render correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify that the login form elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Login'), findsOneWidget); // Login button
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('LoginScreen should validate form fields', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Tap the login button without filling the form
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify that validation errors are shown
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LoginScreen should accept valid input', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify that email validation error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('LoginScreen should show password validation error for short password', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify that password validation error is shown
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('LoginScreen should toggle password visibility', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Find the password field
      final passwordField = find.byType(TextFormField).at(1);

      // Enter password
      await tester.enterText(passwordField, 'password123');

      // Find the visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility_off);
      expect(visibilityToggle, findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Verify that the icon changed to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('LoginScreen should have proper form structure', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify form structure
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Verify that the form has proper labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
