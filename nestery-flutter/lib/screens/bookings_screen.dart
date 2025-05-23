import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<Booking> _bookings = [];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock bookings data
      _bookings = [
        Booking(
          id: 'booking1',
          userId: 'user123',
          propertyId: 'prop123',
          propertyName: 'Luxury Ocean View Suite',
          propertyThumbnail: 'https://example.com/hotel1_thumb.jpg',
          checkInDate: DateTime.now().add(const Duration(days: 30)),
          checkOutDate: DateTime.now().add(const Duration(days: 33)),
          numberOfGuests: 2,
          numberOfRooms: 1,
          totalPrice: 899.97,
          currency: 'USD',
          status: 'confirmed',
          confirmationCode: 'CONF123456',
          loyaltyPointsEarned: 90,
          isPremiumBooking: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Booking(
          id: 'booking2',
          userId: 'user123',
          propertyId: 'prop456',
          propertyName: 'Downtown Luxury Apartment',
          propertyThumbnail: 'https://example.com/apt1_thumb.jpg',
          checkInDate: DateTime.now().add(const Duration(days: 60)),
          checkOutDate: DateTime.now().add(const Duration(days: 65)),
          numberOfGuests: 3,
          numberOfRooms: 1,
          totalPrice: 999.95,
          currency: 'USD',
          status: 'confirmed',
          confirmationCode: 'CONF789012',
          loyaltyPointsEarned: 100,
          isPremiumBooking: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Booking(
          id: 'booking3',
          userId: 'user123',
          propertyId: 'prop789',
          propertyName: 'Mountain View Cabin',
          propertyThumbnail: 'https://example.com/cabin1_thumb.jpg',
          checkInDate: DateTime.now().subtract(const Duration(days: 10)),
          checkOutDate: DateTime.now().subtract(const Duration(days: 7)),
          numberOfGuests: 4,
          numberOfRooms: 2,
          totalPrice: 599.98,
          currency: 'USD',
          status: 'completed',
          confirmationCode: 'CONF345678',
          loyaltyPointsEarned: 60,
          isPremiumBooking: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ];
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: ${error.toString()}'),
          backgroundColor: Constants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Booking> get _upcomingBookings {
    return _bookings.where((booking) => booking.isUpcoming).toList();
  }

  List<Booking> get _activeBookings {
    return _bookings.where((booking) => booking.isActive).toList();
  }

  List<Booking> get _completedBookings {
    return _bookings.where((booking) => booking.isCompleted).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Upcoming bookings tab
            _buildBookingsList(_upcomingBookings, 'No upcoming bookings'),
            
            // Active bookings tab
            _buildBookingsList(_activeBookings, 'No active bookings'),
            
            // Completed bookings tab
            _buildBookingsList(_completedBookings, 'No completed bookings'),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(Constants.searchRoute);
                break;
              case 2:
                // Already on bookings screen
                break;
              case 3:
                Navigator.of(context).pushReplacementNamed(Constants.profileRoute);
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

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Find Properties',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(Constants.searchRoute);
              },
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(Constants.mediumPadding),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    // Determine status color
    Color statusColor;
    switch (booking.status) {
      case 'confirmed':
        statusColor = Constants.primaryColor;
        break;
      case 'completed':
        statusColor = Constants.successColor;
        break;
      case 'cancelled':
        statusColor = Constants.errorColor;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: Constants.mediumPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.mediumRadius),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Constants.mediumRadius),
                ),
                child: Image.network(
                  booking.propertyThumbnail,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              
              // Property details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.mediumPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Constants.smallRadius),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Property name
                      Text(
                        booking.propertyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Dates
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${DateFormat('MMM dd').format(booking.checkInDate)} - ${DateFormat('MMM dd, yyyy').format(booking.checkOutDate)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Guests and rooms
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.numberOfGuests} guests, ${booking.numberOfRooms} ${booking.numberOfRooms > 1 ? 'rooms' : 'room'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Divider
          const Divider(height: 1),
          
          // Booking details and actions
          Padding(
            padding: const EdgeInsets.all(Constants.mediumPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                // Action button
                if (booking.isUpcoming)
                  CustomButton(
                    text: 'View Details',
                    onPressed: () {
                      // TODO: Navigate to booking details screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking details functionality coming soon'),
                        ),
                      );
                    },
                    height: 36,
                    isFullWidth: false,
                  )
                else if (booking.isCompleted)
                  CustomButton(
                    text: 'Book Again',
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        Constants.propertyDetailsRoute,
                        arguments: {'propertyId': booking.propertyId},
                      );
                    },
                    height: 36,
                    isFullWidth: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
