import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isLoading = false;
  List<Property> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Hotel', 'Apartment', 'Villa', 'Resort', 'Hostel'];
  
  RangeValues _priceRange = const RangeValues(50, 500);
  double _minPrice = 0;
  double _maxPrice = 1000;
  
  int _starRating = 0;
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    _performSearch();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call with search parameters
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock search results
      _searchResults = [
        Property(
          id: 'prop1',
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
          id: 'prop2',
          name: 'Downtown Luxury Apartment',
          description: 'Modern apartment in the heart of downtown',
          type: 'Apartment',
          sourceType: 'oyo',
          sourceId: 'oyo_456',
          address: '456 Main Street',
          city: 'New York',
          country: 'USA',
          latitude: 40.7128,
          longitude: -74.0060,
          starRating: 4,
          basePrice: 199.99,
          currency: 'USD',
          amenities: ['WiFi', 'Kitchen', 'Washer', 'Dryer', 'TV'],
          images: [
            'https://example.com/apt1_1.jpg',
            'https://example.com/apt1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/apt1_thumb.jpg',
          rating: 4.5,
          reviewCount: 189,
          isFeatured: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Property(
          id: 'prop3',
          name: 'Mountain View Cabin',
          description: 'Cozy cabin with stunning mountain views',
          type: 'Villa',
          sourceType: 'booking_com',
          sourceId: 'bcom_789',
          address: '789 Mountain Road',
          city: 'Aspen',
          country: 'USA',
          latitude: 39.1911,
          longitude: -106.8175,
          starRating: 3,
          basePrice: 149.99,
          currency: 'USD',
          amenities: ['WiFi', 'Fireplace', 'Kitchen', 'Parking', 'Heating'],
          images: [
            'https://example.com/cabin1_1.jpg',
            'https://example.com/cabin1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/cabin1_thumb.jpg',
          rating: 4.7,
          reviewCount: 156,
          isFeatured: true,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Property(
          id: 'prop4',
          name: 'Beachfront Resort',
          description: 'All-inclusive resort on a private beach',
          type: 'Resort',
          sourceType: 'booking_com',
          sourceId: 'bcom_101',
          address: '101 Beach Boulevard',
          city: 'Cancun',
          country: 'Mexico',
          latitude: 21.1619,
          longitude: -86.8515,
          starRating: 5,
          basePrice: 399.99,
          currency: 'USD',
          amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Bar', 'Beach Access'],
          images: [
            'https://example.com/resort1_1.jpg',
            'https://example.com/resort1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/resort1_thumb.jpg',
          rating: 4.9,
          reviewCount: 312,
          isFeatured: true,
          isPremium: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Property(
          id: 'prop5',
          name: 'Budget Friendly Hostel',
          description: 'Clean and comfortable hostel for budget travelers',
          type: 'Hostel',
          sourceType: 'oyo',
          sourceId: 'oyo_202',
          address: '202 Traveler Street',
          city: 'Barcelona',
          country: 'Spain',
          latitude: 41.3851,
          longitude: 2.1734,
          starRating: 2,
          basePrice: 49.99,
          currency: 'USD',
          amenities: ['WiFi', 'Shared Kitchen', 'Lounge', 'Laundry'],
          images: [
            'https://example.com/hostel1_1.jpg',
            'https://example.com/hostel1_2.jpg',
          ],
          thumbnailImage: 'https://example.com/hostel1_thumb.jpg',
          rating: 4.2,
          reviewCount: 98,
          isFeatured: false,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Apply filters
      if (_selectedFilter != 'All') {
        _searchResults = _searchResults.where((property) => property.type == _selectedFilter).toList();
      }
      
      // Apply price range
      _searchResults = _searchResults.where((property) => 
        property.basePrice >= _priceRange.start && property.basePrice <= _priceRange.end
      ).toList();
      
      // Apply star rating
      if (_starRating > 0) {
        _searchResults = _searchResults.where((property) => property.starRating >= _starRating).toList();
      }
      
      // Apply search text
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        _searchResults = _searchResults.where((property) => 
          property.name.toLowerCase().contains(searchText) ||
          property.description.toLowerCase().contains(searchText) ||
          property.city.toLowerCase().contains(searchText) ||
          property.country.toLowerCase().contains(searchText)
        ).toList();
      }
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching properties: ${error.toString()}'),
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
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(Constants.mediumPadding),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Search destinations, properties...',
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: _showFilters ? Constants.primaryColor : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Filters
            if (_showFilters)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.mediumPadding,
                  vertical: Constants.smallPadding,
                ),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property type filter
                    const Text(
                      'Property Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                  _performSearch();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price range filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Range',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: _minPrice,
                      max: _maxPrice,
                      divisions: 20,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                      onChangeEnd: (_) => _performSearch(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Star rating filter
                    const Text(
                      'Star Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(6, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _starRating = index;
                            });
                            _performSearch();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _starRating == index
                                  ? Constants.primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(Constants.smallRadius),
                            ),
                            child: Text(
                              index == 0 ? 'Any' : '$index+',
                              style: TextStyle(
                                color: _starRating == index ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    
                    // Reset filters button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'All';
                            _priceRange = RangeValues(_minPrice, _maxPrice);
                            _starRating = 0;
                          });
                          _performSearch();
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Search results
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No properties found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _performSearch,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(Constants.mediumPadding),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return PropertyCard(
                            property: _searchResults[index],
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Constants.propertyDetailsRoute,
                                arguments: {'propertyId': _searchResults[index].id},
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacementNamed(Constants.homeRoute);
                break;
              case 1:
                // Already on search screen
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(Constants.bookingsRoute);
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
}
