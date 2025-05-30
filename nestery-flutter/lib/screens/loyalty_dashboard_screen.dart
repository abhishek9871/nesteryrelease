import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/loyalty.dart';
import 'package:nestery_flutter/providers/loyalty_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

class LoyaltyDashboardScreen extends ConsumerStatefulWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  ConsumerState<LoyaltyDashboardScreen> createState() => _LoyaltyDashboardScreenState();
}

class _LoyaltyDashboardScreenState extends ConsumerState<LoyaltyDashboardScreen> {

  Future<void> _performCheckIn(WidgetRef ref, BuildContext context) async {
    await ref.read(dailyCheckInNotifierProvider.notifier).performCheckIn();
    final updatedState = ref.read(dailyCheckInNotifierProvider);
    if (updatedState.message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedState.message!),
          backgroundColor: updatedState.status == DailyCheckInStatus.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyState = ref.watch(loyaltyStatusProvider);
    final dailyCheckInState = ref.watch(dailyCheckInNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nestery Navigator Club'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: loyaltyState.isLoading,
        child: loyaltyState.error != null
            ? Center(child: Text('Error: ${loyaltyState.error}'))
            : loyaltyState.status == null
                ? const Center(child: Text('No loyalty data available.'))
                : _buildDashboardContent(context, theme, loyaltyState.status!, dailyCheckInState, ref),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    ThemeData theme,
    LoyaltyStatus status,
    DailyCheckInState dailyCheckInState,
    WidgetRef ref,
  ) {
    final progress = (status.milesToNextTier != null && status.milesToNextTier! > 0 && status.nextTierName != null)
        ? (status.loyaltyMilesBalance - _getMinMilesForTier(status.loyaltyTier, status.earningMultiplier)) /
            (status.milesToNextTier! + (status.loyaltyMilesBalance - _getMinMilesForTier(status.loyaltyTier, status.earningMultiplier)))
        : 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Miles Balance Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(Constants.largePadding),
              child: Column(
                children: [
                  Text(
                    'Your Miles Balance',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: Constants.smallPadding),
                  Text(
                    '${status.loyaltyMilesBalance} Miles',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Constants.largePadding),

          // Tier Information Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(Constants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Tier: ${status.tierName}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Constants.smallPadding),
                  if (status.tierBenefits != null)
                    Text(status.tierBenefits!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: Constants.mediumPadding),
                  if (status.nextTierName != null && status.milesToNextTier != null && status.milesToNextTier! > 0) ...[
                    Text(
                      '${status.milesToNextTier} Miles to ${status.nextTierName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Constants.smallPadding),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ] else if (status.nextTierName == null) ...[
                     Text('You are at the highest tier!', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: Constants.smallPadding),
                  Text('Earning Multiplier: ${status.earningMultiplier}x', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: Constants.largePadding),

          // Daily Check-in
          CustomButton(
            text: dailyCheckInState.status == DailyCheckInStatus.loading
                ? 'Checking in...'
                : dailyCheckInState.status == DailyCheckInStatus.alreadyCheckedIn
                    ? 'Checked-in Today'
                    : 'Daily Check-in (+5 Miles)',
            onPressed: () {
              if (dailyCheckInState.status == DailyCheckInStatus.initial || dailyCheckInState.status == DailyCheckInStatus.error) {
                _performCheckIn(ref, context);
              }
            },
            isLoading: dailyCheckInState.status == DailyCheckInStatus.loading,
          ),
          const SizedBox(height: Constants.largePadding),

          // How to Earn Miles
          const SectionTitle(title: 'How to Earn Miles', showSeeAll: false),
          _buildInfoList([
            'Book Stays: Earn 1 Mile per \$1 of Nestery\'s commission.',
            'Refer Friends: Earn 250 Miles for each successful referral.',
            'Write Reviews: Earn 50 Miles for approved reviews.',
            'Daily Check-in: Earn 5 Miles for checking in daily.',
            'Complete Profile: Earn 50 Miles for full profile completion.',
            'Premium Subscription: Earn 500 Miles (one-time bonus).',
            'Engage with Partner Offers: Earn variable Miles.',
          ]),
          const SizedBox(height: Constants.largePadding),

          // Redeem Your Miles
          const SectionTitle(title: 'Redeem Your Miles', showSeeAll: false),
          _buildInfoList([
            'Discounts on Nestery Premium.',
            'Temporary access to Premium features.',
            'Exclusive profile badges & customizations.',
            'Entry into prize draws.',
            'Discounts on partner services.',
          ]),
          const SizedBox(height: Constants.largePadding),

          // Transaction History Button
          CustomButton(
            text: 'View Transaction History',
            onPressed: () => context.go('/loyalty/transactions'),
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(List<String> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(Constants.mediumRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Constants.mediumPadding),
        child: Column(
          children: items.map((item) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Constants.primaryColor),
            title: Text(item, style: const TextStyle(fontSize: 14)),
            dense: true,
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ),
      ),
    );
  }

  // Helper to get min miles for a tier, needed for progress calculation
  // This should ideally come from backend or be in sync with tier definitions
  int _getMinMilesForTier(LoyaltyTier tier, double currentMultiplier) {
    // This is a simplified version. A more robust solution would fetch tier definitions.
    switch (tier) {
      case LoyaltyTier.scout:
        return 0;
      case LoyaltyTier.explorer:
        return 1000;
      case LoyaltyTier.navigator:
        return 5000;
      case LoyaltyTier.globetrotter:
        return 20000;
      default:
        return 0;
    }
  }
}
