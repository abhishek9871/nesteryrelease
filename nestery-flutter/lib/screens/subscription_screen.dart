import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/subscription.dart';
import 'package:nestery_flutter/providers/subscription_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Premium subscription paywall screen
///
/// Research shows subscription models can:
/// - Generate 5-7x more revenue per user than ads
/// - Increase customer lifetime value by 300-400%
/// - Improve retention rates by 2-3x
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BillingPeriod _selectedPeriod = BillingPeriod.monthly;
  SubscriptionTier? _selectedTier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load subscription data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadSubscription();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _subscribe(SubscriptionTier tier) async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscribe to ${tier.displayName}?'),
        content: Text(
          'You will be charged ${_selectedPeriod == BillingPeriod.monthly ? tier.priceDisplay : tier.annualPriceDisplay}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Create Stripe checkout session
    final sessionUrl = await ref
        .read(subscriptionProvider.notifier)
        .createCheckoutSession(tier: tier, period: _selectedPeriod);

    if (sessionUrl != null && mounted) {
      // Launch Stripe checkout
      final uri = Uri.parse(sessionUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start checkout process'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionState = ref.watch(subscriptionProvider);
    final currentTier = subscriptionState.currentTier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Plans'),
        centerTitle: true,
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Hero section
                  _buildHeroSection(theme),

                  // Current plan indicator
                  if (currentTier != SubscriptionTier.free)
                    _buildCurrentPlanBanner(theme, currentTier),

                  // Billing period toggle
                  _buildBillingPeriodToggle(theme),

                  // Subscription tiers
                  _buildSubscriptionTiers(theme, currentTier),

                  // Feature comparison
                  _buildFeatureComparison(theme),

                  // FAQ
                  _buildFAQ(theme),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Constants.primaryColor, Constants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Unlock Premium Features',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get exclusive deals, earn more miles, and enjoy VIP perks',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanBanner(ThemeData theme, SubscriptionTier currentTier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Current Plan: ${currentTier.displayName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPeriodToggle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = BillingPeriod.monthly;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedPeriod == BillingPeriod.monthly
                        ? Constants.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Monthly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedPeriod == BillingPeriod.monthly
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = BillingPeriod.annual;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedPeriod == BillingPeriod.annual
                        ? Constants.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Annual',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedPeriod == BillingPeriod.annual
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Save 17%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTiers(ThemeData theme, SubscriptionTier currentTier) {
    final tiers = [
      SubscriptionTier.plus,
      SubscriptionTier.premium,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: tiers.map((tier) => _buildTierCard(theme, tier, currentTier)).toList(),
      ),
    );
  }

  Widget _buildTierCard(ThemeData theme, SubscriptionTier tier, SubscriptionTier currentTier) {
    final isCurrentTier = tier == currentTier;
    final isRecommended = tier == SubscriptionTier.premium;
    final price = _selectedPeriod == BillingPeriod.monthly
        ? tier.priceDisplay
        : tier.annualPriceDisplay;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isRecommended ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? const BorderSide(color: Constants.accentColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Constants.accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                '⭐ MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tier.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Constants.primaryColor,
                          ),
                        ),
                        if (_selectedPeriod == BillingPeriod.annual)
                          Text(
                            '\$${(tier.annualPrice / 12).toStringAsFixed(2)}/mo',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...tier.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: isCurrentTier
                      ? OutlinedButton(
                          onPressed: () {},
                          child: const Text('Current Plan'),
                        )
                      : GradientButton(
                          text: 'Subscribe',
                          onPressed: () => _subscribe(tier),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Comparison',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(theme, 'Miles Earning Rate', '1x', '2x', '3x'),
          _buildComparisonRow(theme, 'Price Alerts', '❌', '✅', '✅'),
          _buildComparisonRow(theme, 'Priority Support', '❌', '✅', '✅'),
          _buildComparisonRow(theme, 'Exclusive Deals', '❌', '❌', '✅'),
          _buildComparisonRow(theme, 'Concierge Service', '❌', '❌', '✅'),
          _buildComparisonRow(theme, 'Ad-Free', '❌', '❌', '✅'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    ThemeData theme,
    String feature,
    String free,
    String plus,
    String premium,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              plus,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Constants.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            theme,
            'Can I cancel anytime?',
            'Yes! You can cancel your subscription at any time. Your premium features will remain active until the end of your billing period.',
          ),
          _buildFAQItem(
            theme,
            'What payment methods do you accept?',
            'We accept all major credit cards, debit cards, and digital wallets through our secure Stripe payment processor.',
          ),
          _buildFAQItem(
            theme,
            'Can I upgrade or downgrade my plan?',
            'Absolutely! You can change your plan anytime. When upgrading, you\'ll get immediate access to new features. When downgrading, changes take effect at the next billing cycle.',
          ),
          _buildFAQItem(
            theme,
            'Is there a free trial?',
            'New users get a 7-day free trial of Nestery Premium to experience all our premium features risk-free!',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(ThemeData theme, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
