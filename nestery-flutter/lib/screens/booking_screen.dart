import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String propertyId;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const BookingScreen({
    Key? key,
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isLoading = false;
  Property? _property;
  int _guestCount = 2;
  int _roomCount = 1;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  bool _agreeToTerms = false;
  String? _paymentMethod;
  final List<String> _paymentMethods = ['Credit Card', 'PayPal', 'Apple Pay', 'Google Pay'];

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _loadProperty() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock property data
      _property = Property(
        id: widget.propertyId,
        name: 'Luxury Ocean View Suite',
        description: 'Experience luxury living with breathtaking ocean views',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_123',
        address: '123 Beach Road',
        city: 'Miami',
        country: 'USA',
        latitude: 25.7617,
        longitude: -80.1918,
        starRating: 5,
        basePrice: 299.99,
        currency: 'USD',
        amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Gym'],
        images: [
          'https://example.com/hotel1_1.jpg',
          'https://example.com/hotel1_2.jpg',
        ],
        thumbnailImage: 'https://example.com/hotel1_thumb.jpg',
        rating: 4.8,
        reviewCount: 245,
        isFeatured: true,
        isPremium: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading property: ${error.toString()}'),
          backgroundColor: Constants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _numberOfNights {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  double get _totalPrice {
    return _property != null 
        ? _property!.basePrice * _numberOfNights * _roomCount
        : 0.0;
  }

  int get _loyaltyPointsToEarn {
    return (_totalPrice / 10).round();
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Constants.errorColor,
        ),
      );
      return;
    }

    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Constants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock booking confirmation
      final booking = Booking(
        id: 'BK${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123',
        propertyId: widget.propertyId,
        propertyName: _property!.name,
        propertyThumbnail: _property!.thumbnailImage,
        checkInDate: widget.checkInDate,
        checkOutDate: widget.checkOutDate,
        numberOfGuests: _guestCount,
        numberOfRooms: _roomCount,
        totalPrice: _totalPrice,
        currency: _property!.currency,
        status: 'confirmed',
        confirmationCode: 'CONF${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        loyaltyPointsEarned: _loyaltyPointsToEarn,
        isPremiumBooking: _property!.isPremium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Navigate to confirmation screen
      Navigator.of(context).pushReplacementNamed(
        Constants.bookingConfirmationRoute,
        arguments: {'bookingId': booking.id},
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming booking: ${error.toString()}'),
          backgroundColor: Constants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Booking'),
        ),
        body: _property == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(Constants.mediumPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property summary
                      Container(
                        padding: const EdgeInsets.all(Constants.mediumPadding),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(Constants.mediumRadius),
                        ),
                        child: Row(
                          children: [
                            // Property image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Constants.smallRadius),
                              child: Image.network(
                                _property!.thumbnailImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Property details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _property!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_property!.city}, ${_property!.country}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < _property!.starRating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Booking details
                      const Text(
                        'Booking Details',
                        style: Constants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-in',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(widget.checkInDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-out',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(widget.checkOutDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Guests and rooms
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Guests',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: _guestCount > 1
                                          ? () {
                                              setState(() {
                                                _guestCount--;
                                              });
                                            }
                                          : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Constants.primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        _guestCount.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: _guestCount < 10
                                          ? () {
                                              setState(() {
                                                _guestCount++;
                                              });
                                            }
                                          : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Constants.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rooms',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: _roomCount > 1
                                          ? () {
                                              setState(() {
                                                _roomCount--;
                                              });
                                            }
                                          : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Constants.primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        _roomCount.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: _roomCount < 5
                                          ? () {
                                              setState(() {
                                                _roomCount++;
                                              });
                                            }
                                          : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Constants.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Divider
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Guest information
                      const Text(
                        'Guest Information',
                        style: Constants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
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
                      
                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Special requests
                      TextFormField(
                        controller: _specialRequestsController,
                        decoration: const InputDecoration(
                          labelText: 'Special Requests (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      
                      // Divider
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Payment method
                      const Text(
                        'Payment Method',
                        style: Constants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      // Payment options
                      Column(
                        children: _paymentMethods.map((method) {
                          return RadioListTile<String>(
                            title: Text(method),
                            value: method,
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Price breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(Constants.mediumRadius),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${_property!.basePrice.toStringAsFixed(2)} x $_numberOfNights nights',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${(_property!.basePrice * _numberOfNights).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Room count',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$_roomCount',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${_totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Loyalty points to earn',
                                  style: TextStyle(
                                    color: Constants.primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '+$_loyaltyPointsToEarn points',
                                  style: const TextStyle(
                                    color: Constants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Terms and conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // TODO: Implement terms and conditions screen
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Confirm booking button
                      CustomButton(
                        text: 'Confirm Booking',
                        onPressed: _confirmBooking,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
