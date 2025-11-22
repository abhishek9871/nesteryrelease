import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:nestery_flutter/utils/constants.dart';

/// Onboarding screen shown to first-time users
///
/// Research shows onboarding improves retention by 35%
///
/// Features:
/// - 3-screen progressive disclosure
/// - Skip button (always available)
/// - Visual animations
/// - Value-first messaging
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _completeOnboarding() async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: theme.colorScheme.surface,

      pages: [
        // Page 1: Find Your Perfect Stay
        PageViewModel(
          title: "Find Your Perfect Stay",
          body: "Browse thousands of hotels from top booking platforms - all in one place. Compare prices and find the best deals instantly.",
          image: _buildImage('search'),
          decoration: _getPageDecoration(theme),
        ),

        // Page 2: Compare & Save
        PageViewModel(
          title: "Compare & Save Money",
          body: "Get the best prices by comparing offers from Booking.com, OYO, and more. We show you where to save the most.",
          image: _buildImage('compare'),
          decoration: _getPageDecoration(theme),
        ),

        // Page 3: Earn Rewards
        PageViewModel(
          title: "Earn Loyalty Rewards",
          body: "Collect Nestery Miles with every booking and unlock exclusive perks, discounts, and premium features.",
          image: _buildImage('rewards'),
          decoration: _getPageDecoration(theme),
        ),
      ],

      onDone: () => _completeOnboarding(),
      onSkip: () => _completeOnboarding(),

      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),

      next: Icon(
        Icons.arrow_forward,
        color: theme.colorScheme.primary,
      ),

      done: Text(
        'Get Started',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),

      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(24.0, 10.0),
        activeColor: Constants.primaryColor,
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        spacing: const EdgeInsets.symmetric(horizontal: 4.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),

      animationDuration: 300,
      curve: Curves.easeOutCubic,

      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    );
  }

  Widget _buildImage(String type) {
    // Use brand-colored icons for onboarding
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'search':
        iconData = Icons.search;
        iconColor = Constants.primaryColor;
        break;
      case 'compare':
        iconData = Icons.compare_arrows;
        iconColor = Constants.secondaryColor;
        break;
      case 'rewards':
        iconData = Icons.star;
        iconColor = Constants.accentColor;
        break;
      default:
        iconData = Icons.hotel;
        iconColor = Constants.primaryColor;
    }

    return Center(
      child: Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.only(top: 40, bottom: 20),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: 100,
          color: iconColor,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration(ThemeData theme) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 18,
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: theme.colorScheme.surface,
      imagePadding: const EdgeInsets.all(24),
      bodyFlex: 2,
      imageFlex: 3,
    );
  }
}
