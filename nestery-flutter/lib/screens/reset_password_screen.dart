import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.resetPassword(
        token: widget.token,
        newPassword: _passwordController.text,
      );

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
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully! Please login with your new password.'),
                backgroundColor: Constants.successColor,
              ),
            );

            // Navigate to login screen
            context.go(Constants.loginRoute);
          }
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
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.mediumPadding),
          child: Form(
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
                  'Create New Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.smallPadding),

                Text(
                  'Your new password must be different from your previous password.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.extraLargePadding),

                // New password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Constants.passwordRequired;
                    }
                    if (!Constants.passwordPattern.hasMatch(value)) {
                      return Constants.passwordInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Constants.mediumPadding),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm your new password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _resetPassword(),
                ),
                const SizedBox(height: Constants.largePadding),

                // Reset password button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: () {
                    if (!_isLoading) {
                      _resetPassword();
                    }
                  },
                  isLoading: _isLoading,
                ),
                const SizedBox(height: Constants.mediumPadding),

                // Back to login
                TextButton(
                  onPressed: () => context.go(Constants.loginRoute),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
