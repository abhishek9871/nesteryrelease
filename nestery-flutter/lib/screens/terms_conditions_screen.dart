import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsScreen extends StatefulWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const TermsConditionsScreen({
    super.key,
    this.showAcceptButton = false,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAcceptButton) {
      _scrollController.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(Constants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Terms and Conditions',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: Constants.smallPadding),

                  Text(
                    'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Constants.largePadding),

                  // Introduction
                  _buildSection(
                    theme,
                    '1. Introduction',
                    'Welcome to Nestery, a hotel booking platform that connects travelers with accommodations worldwide. By using our service, you agree to these terms and conditions.',
                  ),

                  // Acceptance of Terms
                  _buildSection(
                    theme,
                    '2. Acceptance of Terms',
                    'By accessing and using Nestery, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                  ),

                  // User Accounts
                  _buildSection(
                    theme,
                    '3. User Accounts',
                    'To access certain features of our service, you must register for an account. You are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer.',
                  ),

                  // Booking Terms
                  _buildSection(
                    theme,
                    '4. Booking Terms',
                    'All bookings are subject to availability and confirmation. Prices are subject to change without notice. Cancellation policies vary by property and are clearly stated during the booking process.',
                  ),

                  // Payment Terms
                  _buildSection(
                    theme,
                    '5. Payment Terms',
                    'Payment is required at the time of booking unless otherwise specified. We accept major credit cards and other payment methods as indicated on our platform. All transactions are processed securely.',
                  ),

                  // Privacy Policy
                  _buildSection(
                    theme,
                    '6. Privacy Policy',
                    'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your information when you use our service.',
                    linkText: 'Read our Privacy Policy',
                    onLinkTap: () => _launchUrl(Constants.privacyPolicyUrl),
                  ),

                  // User Conduct
                  _buildSection(
                    theme,
                    '7. User Conduct',
                    'You agree not to use the service for any unlawful purpose or in any way that could damage, disable, overburden, or impair our servers or networks.',
                  ),

                  // Intellectual Property
                  _buildSection(
                    theme,
                    '8. Intellectual Property',
                    'All content on Nestery, including text, graphics, logos, and software, is the property of Nestery or its content suppliers and is protected by copyright and other intellectual property laws.',
                  ),

                  // Limitation of Liability
                  _buildSection(
                    theme,
                    '9. Limitation of Liability',
                    'Nestery shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
                  ),

                  // Termination
                  _buildSection(
                    theme,
                    '10. Termination',
                    'We may terminate or suspend your account and bar access to the service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever.',
                  ),

                  // Changes to Terms
                  _buildSection(
                    theme,
                    '11. Changes to Terms',
                    'We reserve the right to modify these terms at any time. We will notify users of any material changes via email or through our platform.',
                  ),

                  // Contact Information
                  _buildSection(
                    theme,
                    '12. Contact Information',
                    'If you have any questions about these Terms and Conditions, please contact us at ${Constants.supportEmail}.',
                    linkText: 'Contact Support',
                    onLinkTap: () => _launchUrl('mailto:${Constants.supportEmail}'),
                  ),

                  const SizedBox(height: Constants.extraLargePadding),
                ],
              ),
            ),
          ),

          // Accept/Decline buttons (if shown)
          if (widget.showAcceptButton) ...[
            Container(
              padding: const EdgeInsets.all(Constants.mediumPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: Constants.mediumPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasScrolledToBottom ? widget.onAccept : null,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    String content, {
    String? linkText,
    VoidCallback? onLinkTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Constants.smallPadding),

        RichText(
          text: TextSpan(
            text: content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            children: linkText != null && onLinkTap != null
                ? [
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: linkText,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: Constants.largePadding),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
