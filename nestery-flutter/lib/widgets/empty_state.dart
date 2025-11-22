import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nestery_flutter/utils/constants.dart';

/// Empty state types for different scenarios
enum EmptyStateType {
  noResults,
  noBookings,
  error,
  noFavorites,
  offline,
}

/// Reusable empty state widget with Lottie animations
///
/// Usage:
/// ```dart
/// EmptyState(
///   type: EmptyStateType.noResults,
///   onAction: () => resetFilters(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getConfig();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                config.animationPath,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title ?? config.defaultTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message ?? config.defaultMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(config.actionIcon),
                label: Text(actionText ?? config.defaultActionText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getConfig() {
    switch (type) {
      case EmptyStateType.noResults:
        return _EmptyStateConfig(
          animationPath: 'assets/animations/empty_state_no_results.json',
          defaultTitle: 'No Properties Found',
          defaultMessage: 'We couldn\'t find any properties matching your search. Try adjusting your filters or search in a different location.',
          actionIcon: Icons.refresh,
          defaultActionText: 'Reset Filters',
        );
      case EmptyStateType.noBookings:
        return _EmptyStateConfig(
          animationPath: 'assets/animations/empty_state_no_bookings.json',
          defaultTitle: 'No Bookings Yet',
          defaultMessage: 'You haven\'t made any bookings yet. Start exploring amazing properties and book your next adventure!',
          actionIcon: Icons.explore,
          defaultActionText: 'Explore Properties',
        );
      case EmptyStateType.error:
        return _EmptyStateConfig(
          animationPath: 'assets/animations/error_server.json',
          defaultTitle: 'Oops! Something Went Wrong',
          defaultMessage: 'We encountered an error while loading your content. Please try again in a moment.',
          actionIcon: Icons.refresh,
          defaultActionText: 'Try Again',
        );
      case EmptyStateType.noFavorites:
        return _EmptyStateConfig(
          animationPath: 'assets/animations/empty_state_no_favorites.json',
          defaultTitle: 'No Favorites Yet',
          defaultMessage: 'Start saving properties you love to find them easily later. Tap the heart icon on any property to add it to your favorites.',
          actionIcon: Icons.search,
          defaultActionText: 'Find Properties',
        );
      case EmptyStateType.offline:
        return _EmptyStateConfig(
          animationPath: 'assets/animations/error_network_offline.json',
          defaultTitle: 'No Internet Connection',
          defaultMessage: 'It looks like you\'re offline. Please check your internet connection and try again.',
          actionIcon: Icons.wifi,
          defaultActionText: 'Retry',
        );
    }
  }
}

/// Configuration for empty state types
class _EmptyStateConfig {
  final String animationPath;
  final String defaultTitle;
  final String defaultMessage;
  final IconData actionIcon;
  final String defaultActionText;

  _EmptyStateConfig({
    required this.animationPath,
    required this.defaultTitle,
    required this.defaultMessage,
    required this.actionIcon,
    required this.defaultActionText,
  });
}
