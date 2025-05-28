import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.forgotPassword(_emailController.text.trim());

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Constants.errorColor,
              ),
            );
          }
        },
        (response) {
          setState(() {
            _emailSent = true;
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.mediumPadding),
          child: _emailSent ? _buildEmailSentView(theme) : _buildEmailForm(theme),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Constants.largePadding),

          // Header
          Icon(
            Icons.lock_reset,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Constants.mediumPadding),

          Text(
            'Reset Your Password',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.smallPadding),

          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.extraLargePadding),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Constants.mediumRadius),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return Constants.emailRequired;
              }
              if (!Constants.emailPattern.hasMatch(value.trim())) {
                return Constants.emailInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _sendResetEmail(),
          ),
          const SizedBox(height: Constants.largePadding),

          // Send reset email button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: () {
              if (!_isLoading) {
                _sendResetEmail();
              }
            },
            isLoading: _isLoading,
          ),
          const SizedBox(height: Constants.mediumPadding),

          // Back to login
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Constants.extraLargePadding),

        // Success icon
        const Icon(
          Icons.mark_email_read,
          size: 100,
          color: Constants.successColor,
        ),
        const SizedBox(height: Constants.mediumPadding),

        Text(
          'Check Your Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.smallPadding),

        Text(
          'We\'ve sent a password reset link to:',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.smallPadding),

        Text(
          _emailController.text.trim(),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.mediumPadding),

        Text(
          'Please check your email and click the link to reset your password. The link will expire in 24 hours.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.extraLargePadding),

        // Resend email button
        OutlinedButton(
          onPressed: _isLoading ? null : () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Send Another Email'),
        ),
        const SizedBox(height: Constants.mediumPadding),

        // Back to login
        CustomButton(
          text: 'Back to Login',
          onPressed: () => context.go(Constants.loginRoute),
        ),
      ],
    );
  }
}
