import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nestery_flutter/models/referral.dart';
import 'package:nestery_flutter/providers/referral_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:intl/intl.dart';

/// Referral screen for sharing referral codes and tracking referrals
///
/// Research shows referral programs can:
/// - Increase user acquisition by 25-30%
/// - Have 3-5x higher conversion rates than other channels
/// - Generate users with 16% higher lifetime value
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    // Load referral stats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(referralProvider.notifier).loadReferralStats();
    });
  }

  Future<void> _shareReferralCode(String referralCode) async {
    HapticFeedback.mediumImpact();

    final message = '''
🎁 Join Nestery and get 500 bonus miles!

Use my referral code: $referralCode

Download Nestery - the best hotel booking aggregator:
• Compare prices from top booking platforms
• Save money on every booking
• Earn loyalty rewards

Get the app: https://nestery.com/app
''';

    await Share.share(message, subject: 'Join Nestery with my referral code!');
  }

  Future<void> _copyReferralCode(String referralCode) async {
    HapticFeedback.lightImpact();

    await Clipboard.setData(ClipboardData(text: referralCode));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral code copied to clipboard!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referralState = ref.watch(referralProvider);
    final stats = referralState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(referralProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: referralState.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(referralProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero section
                    _buildHeroSection(theme),
                    const SizedBox(height: 24),

                    // Referral code card
                    if (stats != null) _buildReferralCodeCard(theme, stats.referralCode),
                    const SizedBox(height: 24),

                    // Stats cards
                    if (stats != null) _buildStatsCards(theme, stats),
                    const SizedBox(height: 24),

                    // How it works
                    _buildHowItWorks(theme),
                    const SizedBox(height: 24),

                    // Recent referrals
                    if (stats != null && stats.recentReferrals.isNotEmpty)
                      _buildRecentReferrals(theme, stats.recentReferrals),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Constants.primaryColor, Constants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Earn 500 Miles per Friend!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Share your referral code and both you and your friend get 500 bonus miles when they make their first booking!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(ThemeData theme, String referralCode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Referral Code',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Constants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Constants.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                referralCode,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyReferralCode(referralCode),
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text('Copy Code'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    text: 'Share',
                    icon: Icons.share,
                    onPressed: () => _shareReferralCode(referralCode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, ReferralStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.people,
                '${stats.totalReferrals}',
                'Total Referrals',
                Constants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.check_circle,
                '${stats.completedReferrals}',
                'Completed',
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.hourglass_empty,
                '${stats.pendingReferrals}',
                'Pending',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                Icons.stars,
                '${stats.totalMilesEarned}',
                'Miles Earned',
                Constants.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'How It Works'),
        const SizedBox(height: 16),
        _buildHowItWorksStep(
          theme,
          1,
          'Share Your Code',
          'Send your unique referral code to friends via WhatsApp, email, or social media.',
          Icons.share,
          Constants.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildHowItWorksStep(
          theme,
          2,
          'Friend Signs Up',
          'Your friend downloads Nestery and enters your code during registration.',
          Icons.person_add,
          Constants.secondaryColor,
        ),
        const SizedBox(height: 12),
        _buildHowItWorksStep(
          theme,
          3,
          'Both Earn Miles',
          'When they make their first booking, you both receive 500 bonus miles!',
          Icons.celebration,
          Constants.accentColor,
        ),
      ],
    );
  }

  Widget _buildHowItWorksStep(
    ThemeData theme,
    int step,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReferrals(ThemeData theme, List<Referral> referrals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Recent Referrals'),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: referrals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final referral = referrals[index];
            return _buildReferralCard(theme, referral);
          },
        ),
      ],
    );
  }

  Widget _buildReferralCard(ThemeData theme, Referral referral) {
    final statusColor = referral.status == ReferralStatus.completed
        ? Colors.green
        : referral.status == ReferralStatus.pending
            ? Colors.orange
            : Colors.grey;

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.1),
              child: Icon(
                referral.status == ReferralStatus.completed
                    ? Icons.check_circle
                    : Icons.hourglass_empty,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.referredUserName ?? referral.referredUserEmail ?? 'Friend',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    referral.rewardDescription ?? 'Referral',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(referral.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (referral.rewardMiles != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${referral.rewardMiles} Miles',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
