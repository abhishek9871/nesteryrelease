import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/widgets/search_bar.dart';
import 'package:nestery_flutter/widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<Property> _featuredProperties = [];
  List<Property> _recommendedProperties = [];
  List<Map<String, dynamic>> _trendingDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, these would be API calls
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for featured properties
      _featuredProperties = [
        Property(
          id: '1',
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
        ),
        Property(
          id: '2',
          name: 'Downtown Luxury Apartment',
          description: 'Modern apartment in the heart of the city',
          type: 'Apartment',
          sourceType: 'booking_com',
          sourceId: 'bcom_456',
          address: '456 Main Street',
          city: 'New York',
          country: 'USA',
          latitude: 40.7128,
          longitude: -74.0060,
          starRating: 4,
          basePrice: 199.99,
          currency: 'USD',
          amenities: ['WiFi', 'Kitchen', 'Washer', 'TV', 'Air Conditioning'],
          images: [
            'https://example.com/apt1_1.jpg',
            'https://example.com/apt1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/apt1_thumb.jpg',
          rating: 4.6,
          reviewCount: 189,
          isFeatured: true,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Mock data for recommended properties
      _recommendedProperties = [
        Property(
          id: '3',
          name: 'Beachfront Resort',
          description: 'Relax and unwind at this beautiful beachfront resort',
          type: 'Resort',
          sourceType: 'oyo',
          sourceId: 'oyo_789',
          address: '789 Coastal Highway',
          city: 'Los Angeles',
          country: 'USA',
          latitude: 34.0522,
          longitude: -118.2437,
          starRating: 4,
          basePrice: 249.99,
          currency: 'USD',
          amenities: ['WiFi', 'Pool', 'Beach Access', 'Restaurant', 'Bar'],
          images: [
            'https://example.com/resort1_1.jpg',
            'https://example.com/resort1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/resort1_thumb.jpg',
          rating: 4.5,
          reviewCount: 210,
          isFeatured: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Property(
          id: '4',
          name: 'Mountain View Cabin',
          description: 'Cozy cabin with stunning mountain views',
          type: 'Cabin',
          sourceType: 'booking_com',
          sourceId: 'bcom_101',
          address: '101 Mountain Road',
          city: 'Denver',
          country: 'USA',
          latitude: 39.7392,
          longitude: -104.9903,
          starRating: 3,
          basePrice: 149.99,
          currency: 'USD',
          amenities: ['WiFi', 'Fireplace', 'Kitchen', 'Parking', 'Hiking Trails'],
          images: [
            'https://example.com/cabin1_1.jpg',
            'https://example.com/cabin1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/cabin1_thumb.jpg',
          rating: 4.7,
          reviewCount: 156,
          isFeatured: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Mock data for trending destinations
      _trendingDestinations = [
        {
          'city': 'Miami',
          'country': 'USA',
          'image': 'https://example.com/miami.jpg',
          'properties': 1245,
        },
        {
          'city': 'New York',
          'country': 'USA',
          'image': 'https://example.com/newyork.jpg',
          'properties': 3567,
        },
        {
          'city': 'Los Angeles',
          'country': 'USA',
          'image': 'https://example.com/losangeles.jpg',
          'properties': 2189,
        },
      ];
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${error.toString()}'),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar with profile
                  Padding(
                    padding: const EdgeInsets.all(Constants.mediumPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name.split(' ')[0] ?? 'Guest'}',
                              style: Constants.subheadingStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find your perfect stay',
                              style: Constants.captionStyle,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Constants.profileRoute);
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Constants.primaryColor,
                            backgroundImage: user?.profileImage != null
                                ? NetworkImage(user!.profileImage!)
                                : null,
                            child: user?.profileImage == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.mediumPadding,
                      vertical: Constants.smallPadding,
                    ),
                    child: CustomSearchBar(
                      hintText: 'Search destinations, hotels...',
                      onTap: () {
                        Navigator.of(context).pushNamed(Constants.searchRoute);
                      },
                    ),
                  ),
                  
                  // Featured properties carousel
                  const SizedBox(height: Constants.mediumPadding),
                  const SectionTitle(title: 'Featured Properties'),
                  const SizedBox(height: Constants.smallPadding),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 0.9,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      autoPlay: true,
                    ),
                    items: _featuredProperties.map((property) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Constants.propertyDetailsRoute,
                                arguments: {'propertyId': property.id},
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Constants.mediumRadius),
                                image: DecorationImage(
                                  image: NetworkImage(property.thumbnailImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Constants.mediumRadius),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(Constants.mediumPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${property.city}, ${property.country}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Constants.primaryColor,
                                            borderRadius: BorderRadius.circular(Constants.smallRadius),
                                          ),
                                          child: Text(
                                            '\$${property.basePrice.toStringAsFixed(0)}/night',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          property.rating.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  
                  // Trending destinations
                  const SizedBox(height: Constants.largePadding),
                  const SectionTitle(title: 'Trending Destinations'),
                  const SizedBox(height: Constants.smallPadding),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                      itemCount: _trendingDestinations.length,
                      itemBuilder: (context, index) {
                        final destination = _trendingDestinations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Constants.searchRoute,
                              arguments: {
                                'initialQuery': destination['city'],
                                'initialFilters': {'city': destination['city']},
                              },
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: Constants.mediumPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Constants.mediumRadius),
                              image: DecorationImage(
                                image: NetworkImage(destination['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Constants.mediumRadius),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(Constants.mediumPadding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination['city'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${destination['properties']} properties',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Recommended properties
                  const SizedBox(height: Constants.largePadding),
                  const SectionTitle(title: 'Recommended for You'),
                  const SizedBox(height: Constants.smallPadding),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                    itemCount: _recommendedProperties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(
                        property: _recommendedProperties[index],
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            Constants.propertyDetailsRoute,
                            arguments: {'propertyId': _recommendedProperties[index].id},
                          );
                        },
                      );
                    },
                  ),
                  
                  // Loyalty program banner
                  const SizedBox(height: Constants.largePadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                    child: Container(
                      padding: const EdgeInsets.all(Constants.mediumPadding),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(Constants.mediumRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nestery Loyalty Program',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Earn points with every booking and unlock exclusive rewards!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'View Rewards',
                            onPressed: () {
                              Navigator.of(context).pushNamed(Constants.loyaltyRoute);
                            },
                            backgroundColor: Colors.white,
                            textColor: Constants.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Constants.extraLargePadding),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on home screen
                break;
              case 1:
                Navigator.of(context).pushNamed(Constants.searchRoute);
                break;
              case 2:
                Navigator.of(context).pushNamed(Constants.bookingsRoute);
                break;
              case 3:
                Navigator.of(context).pushNamed(Constants.profileRoute);
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
}
