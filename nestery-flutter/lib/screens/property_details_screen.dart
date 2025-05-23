import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isLoading = false;
  Property? _property;
  final _carouselController = CarouselController();
  int _currentImageIndex = 0;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _guestCount = 2;
  int _roomCount = 1;

  @override
  void initState() {
    super.initState();
    _loadProperty();
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
        description: 'Experience luxury living with breathtaking ocean views. This spacious suite features a king-size bed, private balcony, and modern amenities. Enjoy direct beach access, a full-service spa, and world-class dining options. Perfect for couples or small families looking for a premium vacation experience.',
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
        amenities: [
          'WiFi',
          'Pool',
          'Spa',
          'Restaurant',
          'Gym',
          'Air Conditioning',
          'Room Service',
          'Beach Access',
          'Parking',
          'Bar',
          'Breakfast',
          'Concierge',
        ],
        images: [
          'https://example.com/hotel1_1.jpg',
          'https://example.com/hotel1_2.jpg',
          'https://example.com/hotel1_3.jpg',
          'https://example.com/hotel1_4.jpg',
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

  void _navigateToBooking() {
    Navigator.of(context).pushNamed(
      Constants.bookingRoute,
      arguments: {
        'propertyId': widget.propertyId,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
      },
    );
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // Ensure check-out date is after check-in date
        if (_checkOutDate.isBefore(_checkInDate) || 
            _checkOutDate.isAtSameMomentAs(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate.isAfter(_checkInDate) 
          ? _checkOutDate 
          : _checkInDate.add(const Duration(days: 1)),
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  int get _numberOfNights {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  double get _totalPrice {
    return _property != null 
        ? _property!.basePrice * _numberOfNights * _roomCount
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: _property == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // App bar with image carousel
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          // Image carousel
                          CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: 300,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                            ),
                            items: _property!.images.map((imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          
                          // Gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Page indicator
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedSmoothIndicator(
                                activeIndex: _currentImageIndex,
                                count: _property!.images.length,
                                effect: const ExpandingDotsEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.white,
                                  dotColor: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          
                          // Premium badge
                          if (_property!.isPremium)
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(Constants.smallRadius),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            // TODO: Implement favorite functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to favorites'),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            // TODO: Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share functionality coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Property details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Constants.mediumPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property name and rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _property!.name,
                                  style: Constants.headingStyle,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _property!.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    ' (${_property!.reviewCount})',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${_property!.address}, ${_property!.city}, ${_property!.country}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Property type and star rating
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(Constants.smallRadius),
                                ),
                                child: Text(
                                  _property!.type,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 24),
                          
                          // Divider
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Description
                          const Text(
                            'Description',
                            style: Constants.subheadingStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _property!.description,
                            style: const TextStyle(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Amenities
                          const Text(
                            'Amenities',
                            style: Constants.subheadingStyle,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _property!.amenities.map((amenity) {
                              IconData icon;
                              switch (amenity.toLowerCase()) {
                                case 'wifi':
                                  icon = Icons.wifi;
                                  break;
                                case 'pool':
                                  icon = Icons.pool;
                                  break;
                                case 'spa':
                                  icon = Icons.spa;
                                  break;
                                case 'restaurant':
                                  icon = Icons.restaurant;
                                  break;
                                case 'gym':
                                  icon = Icons.fitness_center;
                                  break;
                                case 'air conditioning':
                                  icon = Icons.ac_unit;
                                  break;
                                case 'room service':
                                  icon = Icons.room_service;
                                  break;
                                case 'beach access':
                                  icon = Icons.beach_access;
                                  break;
                                case 'parking':
                                  icon = Icons.local_parking;
                                  break;
                                case 'bar':
                                  icon = Icons.local_bar;
                                  break;
                                case 'breakfast':
                                  icon = Icons.free_breakfast;
                                  break;
                                case 'concierge':
                                  icon = Icons.support_agent;
                                  break;
                                default:
                                  icon = Icons.check_circle;
                              }
                              
                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 3 - 24,
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 16,
                                      color: Constants.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        amenity,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          
                          // Divider
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Booking details
                          const Text(
                            'Book Your Stay',
                            style: Constants.subheadingStyle,
                          ),
                          const SizedBox(height: 16),
                          
                          // Date selection
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectCheckInDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(Constants.smallRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Check-in',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(_checkInDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectCheckOutDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(Constants.smallRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Check-out',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(_checkOutDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Guest and room selection
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(Constants.smallRadius),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Guests',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(Constants.smallRadius),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Rooms',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
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
                              ),
                            ],
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Book now button
                          CustomButton(
                            text: 'Book Now',
                            onPressed: _navigateToBooking,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
