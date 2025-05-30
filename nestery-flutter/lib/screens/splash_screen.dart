import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: Constants.longAnimationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();

    // Check authentication status after a delay
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _checkAuthAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Check authentication status and navigate accordingly
  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.isAuthenticated) {
      // User is authenticated, navigate to home screen
      Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
    } else {
      // User is not authenticated, navigate to login screen
      Navigator.of(context).pushReplacementNamed(Constants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                Constants.logoImage,
                height: 150,
              ),
              const SizedBox(height: Constants.largePadding),

              // App name
              const Text(
                'Nestery',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
              const SizedBox(height: Constants.smallPadding),

              // Tagline
              const Text(
                'Find your perfect stay',
                style: Constants.subheadingStyle,
              ),
              const SizedBox(height: Constants.extraLargePadding),

              // Loading indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
