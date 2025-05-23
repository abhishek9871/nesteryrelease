import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  User? _user;
  int _loyaltyPoints = 0;
  String _loyaltyTier = 'Silver';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      _user = User(
        id: 'user123',
        email: 'john.doe@example.com',
        name: 'John Doe',
        phone: '+1 (555) 123-4567',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );
      
      // Mock loyalty data
      _loyaltyPoints = 750;
      _loyaltyTier = 'Gold';
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${error.toString()}'),
          backgroundColor: Constants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform logout
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed(Constants.loginRoute);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Loyalty'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: _user == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Profile tab
                  _buildProfileTab(),
                  
                  // Loyalty tab
                  _buildLoyaltyTab(),
                  
                  // Settings tab
                  _buildSettingsTab(),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(Constants.searchRoute);
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(Constants.bookingsRoute);
                break;
              case 3:
                // Already on profile screen
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_outlined),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Constants.primaryColor.withOpacity(0.1),
                  child: Text(
                    _user!.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // User name
                Text(
                  _user!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Member since
                Text(
                  'Member since ${_user!.createdAt.year}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Loyalty tier badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLoyaltyColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Constants.smallRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: _getLoyaltyColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_loyaltyTier Member',
                        style: TextStyle(
                          color: _getLoyaltyColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Personal information
          const Text(
            'Personal Information',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Information card
          Container(
            padding: const EdgeInsets.all(Constants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: _user!.email,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: _user!.phone ?? 'Not provided',
                ),
                if (_user!.phone != null) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: 'Not provided',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Edit profile button
          CustomButton(
            text: 'Edit Profile',
            onPressed: () {
              // TODO: Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loyalty points card
          Container(
            padding: const EdgeInsets.all(Constants.mediumPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getLoyaltyColor(),
                  _getLoyaltyColor().withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Loyalty Points',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Constants.smallRadius),
                      ),
                      child: Text(
                        _loyaltyTier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '$_loyaltyPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Points available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Progress to next tier
                if (_loyaltyTier != 'Platinum') ...[
                  const Text(
                    'Progress to next tier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getProgressToNextTier(),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getNextTierMessage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tier benefits
          const Text(
            'Your Benefits',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Benefits list
          Container(
            padding: const EdgeInsets.all(Constants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: _getLoyaltyBenefits().map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getLoyaltyColor().withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          benefit.icon,
                          color: _getLoyaltyColor(),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              benefit.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          // How to earn points
          const Text(
            'How to Earn Points',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Earning methods
          Container(
            padding: const EdgeInsets.all(Constants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildEarningMethod(
                  icon: Icons.hotel,
                  title: 'Book a Stay',
                  description: 'Earn 10 points for every \$100 spent',
                ),
                const Divider(height: 24),
                _buildEarningMethod(
                  icon: Icons.star,
                  title: 'Book Premium Properties',
                  description: 'Earn 2x points on premium properties',
                ),
                const Divider(height: 24),
                _buildEarningMethod(
                  icon: Icons.share,
                  title: 'Refer a Friend',
                  description: 'Earn 100 points for each friend who books',
                ),
                const Divider(height: 24),
                _buildEarningMethod(
                  icon: Icons.rate_review,
                  title: 'Write a Review',
                  description: 'Earn 20 points for each verified review',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account settings
          const Text(
            'Account Settings',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Settings list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to change password screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Change password functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  onTap: () {
                    // TODO: Navigate to notification settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification settings functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  value: 'English',
                  onTap: () {
                    // TODO: Navigate to language settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language settings functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  value: 'USD',
                  onTap: () {
                    // TODO: Navigate to currency settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Currency settings functionality coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // App settings
          const Text(
            'App Settings',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Settings list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement dark mode
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dark mode functionality coming soon'),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location Services',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement location services toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location services toggle functionality coming soon'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Support and about
          const Text(
            'Support & About',
            style: Constants.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Settings list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.mediumRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    // TODO: Navigate to help center screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help center functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Navigate to privacy policy screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Navigate to terms of service screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of service functionality coming soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  value: 'Version 1.0.0',
                  onTap: () {
                    // TODO: Navigate to about screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('About functionality coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Logout button
          CustomButton(
            text: 'Logout',
            onPressed: _logout,
            backgroundColor: Colors.red,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Constants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningMethod({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Constants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Constants.primaryColor,
      ),
      title: Text(title),
      subtitle: value != null ? Text(value) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Color _getLoyaltyColor() {
    switch (_loyaltyTier) {
      case 'Bronze':
        return Colors.brown;
      case 'Silver':
        return Colors.blueGrey;
      case 'Gold':
        return Colors.amber;
      case 'Platinum':
        return Colors.blueAccent;
      default:
        return Constants.primaryColor;
    }
  }

  double _getProgressToNextTier() {
    switch (_loyaltyTier) {
      case 'Bronze':
        return _loyaltyPoints / 500; // 500 points to reach Silver
      case 'Silver':
        return (_loyaltyPoints - 500) / 500; // 1000 points to reach Gold
      case 'Gold':
        return (_loyaltyPoints - 1000) / 1000; // 2000 points to reach Platinum
      default:
        return 1.0;
    }
  }

  String _getNextTierMessage() {
    switch (_loyaltyTier) {
      case 'Bronze':
        return '${500 - _loyaltyPoints} more points to reach Silver';
      case 'Silver':
        return '${1000 - _loyaltyPoints} more points to reach Gold';
      case 'Gold':
        return '${2000 - _loyaltyPoints} more points to reach Platinum';
      default:
        return 'You have reached the highest tier!';
    }
  }

  List<LoyaltyBenefit> _getLoyaltyBenefits() {
    final List<LoyaltyBenefit> benefits = [];
    
    // Basic benefits for all tiers
    benefits.add(
      LoyaltyBenefit(
        icon: Icons.star,
        title: 'Points on Every Booking',
        description: 'Earn 10 points for every \$100 spent',
      ),
    );
    
    // Silver tier and above
    if (_loyaltyTier == 'Silver' || _loyaltyTier == 'Gold' || _loyaltyTier == 'Platinum') {
      benefits.add(
        LoyaltyBenefit(
          icon: Icons.access_time,
          title: 'Early Check-in',
          description: 'Subject to availability',
        ),
      );
    }
    
    // Gold tier and above
    if (_loyaltyTier == 'Gold' || _loyaltyTier == 'Platinum') {
      benefits.add(
        LoyaltyBenefit(
          icon: Icons.upgrade,
          title: 'Room Upgrades',
          description: 'Free upgrades when available',
        ),
      );
      benefits.add(
        LoyaltyBenefit(
          icon: Icons.local_dining,
          title: 'Welcome Amenities',
          description: 'Special welcome gift at check-in',
        ),
      );
    }
    
    // Platinum tier only
    if (_loyaltyTier == 'Platinum') {
      benefits.add(
        LoyaltyBenefit(
          icon: Icons.support_agent,
          title: 'Dedicated Support',
          description: 'Priority customer service',
        ),
      );
      benefits.add(
        LoyaltyBenefit(
          icon: Icons.free_breakfast,
          title: 'Free Breakfast',
          description: 'Complimentary breakfast at select properties',
        ),
      );
    }
    
    return benefits;
  }
}

class LoyaltyBenefit {
  final IconData icon;
  final String title;
  final String description;
  
  LoyaltyBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}
