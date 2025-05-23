import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/screens/login_screen.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {
  @override
  bool get isAuthenticated => false;
  
  @override
  Future<void> login(String email, String password) async {
    return Future.value();
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  testWidgets('LoginScreen should render correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
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
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
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

  testWidgets('LoginScreen should call login when form is valid', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
        ),
      ),
    );

    // Fill the form
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that login was called
    verify(mockAuthProvider.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('LoginScreen should navigate to register screen', (WidgetTester tester) async {
    // Mock the Navigator
    final mockObserver = MockNavigatorObserver();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap the register link
    await tester.tap(find.text('Don\'t have an account? Register'));
    await tester.pumpAndSettle();

    // Verify that navigation occurred
    verify(mockObserver.didPush(any, any));
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}
}
