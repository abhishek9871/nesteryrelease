import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/loyalty.dart'; // Import loyalty models for extension methods
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/providers/profile_provider.dart';
import 'package:nestery_flutter/providers/theme_provider.dart';
import 'package:nestery_flutter/providers/loyalty_provider.dart'; // Import new loyalty provider
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/custom_text_field.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nestery_flutter/services/ad_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load user profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUserProfile();
      // Preload interstitial ad for settings navigation
      ref.read(adServiceProvider.notifier).preloadInterstitialAd(placementIdentifier: 'profile_to_settings_interstitial');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFormFields(User user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleEditMode(User user) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _populateFormFields(user);
      }
    });
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'profileImage': _profileImage,
    };

    // Use the profile provider to update profile
    ref.read(userProfileProvider.notifier).updateUserProfile(
      firstName: updatedProfile['firstName'] as String?,
      lastName: updatedProfile['lastName'] as String?,
      phoneNumber: updatedProfile['phone'] as String?,
      profilePicture: (_profileImage?.path),
    ).then((success) {
      if (success) {
        setState(() {
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              navigator.pop();
              ref.read(authProvider.notifier).logout().then((_) {
                if (mounted) {
                  router.go('/login');
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);
    final loyaltyState = ref.watch(loyaltyStatusProvider); // Watch new loyalty provider
    final adService = ref.watch(adServiceProvider.notifier);
    final user = profileState.user;
    // Remove the updateState watch since we're using userProfileProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading || profileState.isUpdating,
        child: user == null && !profileState.isLoading
            ? _buildErrorState(profileState.error ?? loyaltyState.error ?? 'Failed to load profile')
            : Column(
                children: [
                  // Profile header
                  _buildProfileHeader(user, theme),

                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Settings'),
                      Tab(text: 'Support'),
                    ],
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Profile tab
                        _isEditing
                            ? _buildEditProfileForm(user, theme)
                            : _buildProfileDetails(user, theme, loyaltyState),

                        // Settings tab
                        _buildSettingsTab(theme),

                        // Support tab
                        _buildSupportTab(theme),
                      ],
                    ),
                  ),
                  // Banner Ad
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: adService.createBannerAdWidget(
                      context,
                      placementIdentifier: 'profile_bottom_banner',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user, ThemeData theme) {
    if (user == null) return const SizedBox(height: 200);

    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Constants.primaryColor,
            Constants.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile image
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) as ImageProvider
                    : user.profilePicture != null
                        ? NetworkImage(user.profilePicture!) as ImageProvider
                        : null,
                child: user.profilePicture == null && _profileImage == null
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Constants.primaryColor,
                        ),
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // User name
          Text(
            '${user.firstName} ${user.lastName}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // User email
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(User? user, ThemeData theme, LoyaltyStatusState loyaltyState) {
    if (user == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: 'Edit Profile',
                onPressed: () => _toggleEditMode(user),
                icon: Icons.edit,
                height: 40,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Personal information
          const SectionTitle(
            title: 'Personal Information',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            theme,
            'First Name',
            user.firstName,
          ),
          _buildInfoItem(
            theme,
            'Last Name',
            user.lastName,
          ),
          _buildInfoItem(
            theme,
            'Email',
            user.email,
          ),
          _buildInfoItem(
            theme,
            'Phone',
            user.phone ?? 'Not provided',
            isLast: true,
          ),
          const SizedBox(height: 24),

          // Account information
          const SectionTitle(
            title: 'Account Information',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            theme,
            'Member Since',
            '${user.createdAt.month}/${user.createdAt.day}/${user.createdAt.year}',
          ),
          _buildInfoItem(
            theme,
            'Account Type',
            user.role.toUpperCase(),
          ),
          _buildInfoItem(
            theme,
            'Loyalty Points',
            '${user.loyaltyMilesBalance} Miles', // Updated to loyaltyMilesBalance
            isLast: true,
          ),
          const SizedBox(height: 24),

          // Preferences
          const SectionTitle(
            title: 'Preferences',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            theme,
            'Currency',
            user.preferences?['currency'] ?? 'USD', // Assuming preferences holds this
          ),
          _buildInfoItem(
            theme,
            'Language',
            user.preferences?['language'] ?? 'English', // Assuming preferences holds this
            isLast: true,
          ),
          const SizedBox(height: 24),

          // Stats
          const SectionTitle(
            title: 'Stats',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Bookings',
                  '${user.bookingsCount ?? 0}', // This field might not be directly on User model anymore
                  Icons.hotel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme, // Updated to show loyalty tier
                  'Loyalty Tier',
                  loyaltyState.status?.tierName ?? user.loyaltyTier.displayName,
                  Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Saved',
                  '${user.savedPropertiesCount ?? 0}', // This field might not be directly on User model
                  Icons.favorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Loyalty Program Section
          const SectionTitle(
            title: 'Nestery Navigator Club',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_membership, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Current Tier: ${loyaltyState.status?.tierName ?? user.loyaltyTier.displayName}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Miles Balance: ${loyaltyState.status?.loyaltyMilesBalance ?? user.loyaltyMilesBalance}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'View Loyalty Dashboard',
                    onPressed: () => context.go('/loyalty'),
                    isOutlined: true,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm(User? user, ThemeData theme) {
    if (user == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cancel and save buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: 'Cancel',
                  onPressed: () => _toggleEditMode(user),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  textColor: theme.colorScheme.onSurface,
                  height: 40,
                ),
                GradientButton(
                  text: 'Save',
                  onPressed: _saveProfile,
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form fields
            CustomTextField(
              label: 'First Name',
              controller: _firstNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Last Name',
              controller: _lastNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              enabled: false, // Email cannot be changed
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Password change section
            const SectionTitle(
              title: 'Change Password',
              showSeeAll: false,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Current Password',
              controller: TextEditingController(),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'New Password',
              controller: TextEditingController(),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirm New Password',
              controller: TextEditingController(),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Change Password',
              onPressed: () {
                // Handle password change
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    final isDarkMode = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance
          const SectionTitle(
            title: 'Appearance',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            theme,
            'Dark Mode',
            'Switch between light and dark theme',
            trailing: Switch(
              value: isDarkMode == ThemeMode.dark,
              onChanged: (value) { // Example of interstitial ad on a non-critical action
                ref.read(adServiceProvider.notifier).showInterstitialAd(
                  placementIdentifier: 'profile_to_settings_interstitial',
                  onAdDismissed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  onAdFailedToShow: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  }
                );
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            'Text Size',
            'Adjust the text size',
            trailing: DropdownButton<String>(
              value: 'Medium',
              onChanged: (value) {
                // Handle text size change
              },
              items: ['Small', 'Medium', 'Large'].map((size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              underline: const SizedBox(),
            ),
          ),

          // Notifications
          const SectionTitle(
            title: 'Notifications',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            theme,
            'Push Notifications',
            'Receive push notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle push notifications toggle
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            'Email Notifications',
            'Receive email notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle email notifications toggle
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            'Marketing Communications',
            'Receive marketing emails',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle marketing communications toggle
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),

          // Privacy
          const SectionTitle(
            title: 'Privacy',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            theme,
            'Location Services',
            'Allow access to your location',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle location services toggle
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            'Data Collection',
            'Allow data collection for better experience',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle data collection toggle
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),

          // App info
          const SectionTitle(
            title: 'App Info',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            theme,
            'Version',
            '1.0.0',
          ),
          _buildSettingItem(
            theme,
            'Terms of Service',
            'Read our terms of service',
            onTap: () {
              // Open terms of service
              launchUrl(Uri.parse('https://nestery.com/terms'));
            },
          ),
          _buildSettingItem(
            theme,
            'Privacy Policy',
            'Read our privacy policy',
            onTap: () {
              // Open privacy policy
              launchUrl(Uri.parse('https://nestery.com/privacy'));
            },
          ),
          _buildSettingItem(
            theme,
            'Licenses',
            'View open source licenses',
            onTap: () {
              // Show licenses
              showLicensePage(
                context: context,
                applicationName: 'Nestery',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Help center
          const SectionTitle(
            title: 'Help Center',
            showSeeAll: false,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            theme,
            'FAQs',
            'Find answers to common questions',
            Icons.help_outline,
            onTap: () {
              // Open FAQs
              launchUrl(Uri.parse('https://nestery.com/faq'));
            },
          ),
          _buildSupportItem(
            theme,
            'Contact Support',
            'Get help from our support team',
            Icons.support_agent,
            onTap: () {
              // Contact support
              launchUrl(Uri.parse('https://nestery.com/support'));
            },
          ),
          _buildSupportItem(
            theme,
            'Report an Issue',
            'Report a problem with the app',
            Icons.bug_report,
            onTap: () {
              // Report issue
              launchUrl(Uri.parse('https://nestery.com/report'));
            },
          ),

          // Feedback
          const SectionTitle(
            title: 'Feedback',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            theme,
            'Rate the App',
            'Share your experience with others',
            Icons.star_outline,
            onTap: () {
              // Rate app
              launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.nestery.app'));
            },
          ),
          _buildSupportItem(
            theme,
            'Send Feedback',
            'Help us improve the app',
            Icons.feedback_outlined,
            onTap: () {
              // Send feedback
              launchUrl(Uri.parse('https://nestery.com/feedback'));
            },
          ),

          // Share
          const SectionTitle(
            title: 'Share',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            theme,
            'Share the App',
            'Invite friends to use Nestery',
            Icons.share,
            onTap: () {
              // Share app
              Share.share(
                'Check out Nestery, the best app for booking hotels and accommodations! Download it now: https://nestery.com/app',
                subject: 'Nestery - Hotel Booking App',
              );
            },
          ),
          _buildSupportItem(
            theme,
            'Refer a Friend',
            'Get rewards for referring friends',
            Icons.card_giftcard,
            onTap: () {
              // Refer a friend
              launchUrl(Uri.parse('https://nestery.com/refer'));
            },
          ),

          // Social media
          const SectionTitle(
            title: 'Follow Us',
            showSeeAll: false,
            padding: EdgeInsets.only(top: 24),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                theme,
                'Facebook',
                Icons.facebook,
                Colors.blue,
                () {
                  launchUrl(Uri.parse('https://facebook.com/nestery'));
                },
              ),
              _buildSocialButton(
                theme,
                'Twitter',
                Icons.flutter_dash,
                Colors.lightBlue,
                () {
                  launchUrl(Uri.parse('https://twitter.com/nestery'));
                },
              ),
              _buildSocialButton(
                theme,
                'Instagram',
                Icons.camera_alt,
                Colors.purple,
                () {
                  launchUrl(Uri.parse('https://instagram.com/nestery'));
                },
              ),
              _buildSocialButton(
                theme,
                'YouTube',
                Icons.play_arrow,
                Colors.red,
                () {
                  launchUrl(Uri.parse('https://youtube.com/nestery'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    ThemeData theme,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSupportItem(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSocialButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(userProfileProvider.notifier).loadUserProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
