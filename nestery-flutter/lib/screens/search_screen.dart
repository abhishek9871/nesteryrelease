import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/custom_text_field.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const SearchScreen({
    Key? key,
    this.initialFilters,
  }) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('MMM dd, yyyy');
  
  // Search filters
  String _location = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  RangeValues _priceRange = const RangeValues(0, 1000);
  List<String> _selectedAmenities = [];
  String _selectedPropertyType = 'All';
  double _minRating = 0;
  
  // Filter options
  final List<String> _propertyTypes = ['All', 'Hotel', 'Apartment', 'Villa', 'Resort', 'Hostel'];
  final List<Map<String, dynamic>> _amenities = [
    {'id': 'wifi', 'name': 'WiFi', 'icon': Icons.wifi},
    {'id': 'pool', 'name': 'Pool', 'icon': Icons.pool},
    {'id': 'parking', 'name': 'Parking', 'icon': Icons.local_parking},
    {'id': 'ac', 'name': 'Air Conditioning', 'icon': Icons.ac_unit},
    {'id': 'gym', 'name': 'Gym', 'icon': Icons.fitness_center},
    {'id': 'breakfast', 'name': 'Breakfast', 'icon': Icons.restaurant},
    {'id': 'spa', 'name': 'Spa', 'icon': Icons.spa},
    {'id': 'tv', 'name': 'TV', 'icon': Icons.tv},
    {'id': 'kitchen', 'name': 'Kitchen', 'icon': Icons.kitchen},
    {'id': 'washer', 'name': 'Washer', 'icon': Icons.local_laundry_service},
  ];
  
  bool _isFilterVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    // Apply initial filters if provided
    if (widget.initialFilters != null) {
      _applyInitialFilters();
    }
    
    // Set default dates if not provided
    if (_checkInDate == null) {
      _checkInDate = DateTime.now().add(const Duration(days: 1));
    }
    if (_checkOutDate == null) {
      _checkOutDate = DateTime.now().add(const Duration(days: 3));
    }
    
    // Load search results when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }
  
  void _applyInitialFilters() {
    final filters = widget.initialFilters!;
    
    if (filters.containsKey('location')) {
      _location = filters['location'];
      _searchController.text = _location;
    }
    
    if (filters.containsKey('checkInDate')) {
      _checkInDate = filters['checkInDate'];
    }
    
    if (filters.containsKey('checkOutDate')) {
      _checkOutDate = filters['checkOutDate'];
    }
    
    if (filters.containsKey('guestCount')) {
      _guestCount = filters['guestCount'];
    }
    
    if (filters.containsKey('priceRange')) {
      _priceRange = filters['priceRange'];
    }
    
    if (filters.containsKey('amenities')) {
      _selectedAmenities = List<String>.from(filters['amenities']);
    }
    
    if (filters.containsKey('propertyType')) {
      _selectedPropertyType = filters['propertyType'];
    }
    
    if (filters.containsKey('minRating')) {
      _minRating = filters['minRating'];
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _performSearch() {
    // Prepare search parameters
    final searchParams = {
      'query': _location,
      'checkInDate': _checkInDate,
      'checkOutDate': _checkOutDate,
      'guestCount': _guestCount,
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
      'amenities': _selectedAmenities,
      'propertyType': _selectedPropertyType == 'All' ? null : _selectedPropertyType,
      'minRating': _minRating,
    };
    
    // Perform search
    ref.read(searchPropertiesProvider.notifier).searchProperties(searchParams);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(searchPropertiesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: searchResults.isLoading,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _searchController,
                      hint: 'Search destinations',
                      prefixIcon: const Icon(Icons.search),
                      onSubmitted: (value) {
                        setState(() {
                          _location = value;
                        });
                        _performSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: _isFilterVisible
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFilterVisible = !_isFilterVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Filters
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isFilterVisible ? 320 : 0,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dates and guests
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check-in',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _checkInDate ?? now.add(const Duration(days: 1)),
                                      firstDate: now,
                                      lastDate: now.add(const Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _checkInDate = picked;
                                        // Ensure check-out is after check-in
                                        if (_checkOutDate == null || _checkOutDate!.isBefore(_checkInDate!)) {
                                          _checkOutDate = _checkInDate!.add(const Duration(days: 2));
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _checkInDate != null
                                              ? _dateFormat.format(_checkInDate!)
                                              : 'Select date',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const Icon(Icons.calendar_today, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check-out',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _checkOutDate ?? now.add(const Duration(days: 3)),
                                      firstDate: _checkInDate ?? now,
                                      lastDate: now.add(const Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _checkOutDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _checkOutDate != null
                                              ? _dateFormat.format(_checkOutDate!)
                                              : 'Select date',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const Icon(Icons.calendar_today, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Guests
                      Text(
                        'Guests',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_guestCount ${_guestCount == 1 ? 'Guest' : 'Guests'}',
                              style: theme.textTheme.bodyMedium,
                            ),
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$_guestCount',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _guestCount++;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Price range
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Range',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels(
                          '\$${_priceRange.start.toInt()}',
                          '\$${_priceRange.end.toInt()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      
                      // Property type
                      Text(
                        'Property Type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _propertyTypes.length,
                          itemBuilder: (context, index) {
                            final type = _propertyTypes[index];
                            final isSelected = _selectedPropertyType == type;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPropertyType = type;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : null,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Amenities
                      Text(
                        'Amenities',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.map((amenity) {
                          final isSelected = _selectedAmenities.contains(amenity['id']);
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedAmenities.remove(amenity['id']);
                                } else {
                                  _selectedAmenities.add(amenity['id']);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    amenity['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    amenity['name'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Apply filters button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Apply Filters',
                          onPressed: () {
                            setState(() {
                              _isFilterVisible = false;
                            });
                            _performSearch();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            
            // Search results
            Expanded(
              child: searchResults.error != null
                  ? _buildErrorState(searchResults.error!, () => _performSearch())
                  : searchResults.properties.isEmpty && !searchResults.isLoading
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            _performSearch();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: searchResults.properties.length,
                            itemBuilder: (context, index) {
                              final property = searchResults.properties[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PropertyCard(
                                  property: property,
                                  isHorizontal: true,
                                  onTap: () {
                                    context.go('/property/${property.id}');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search criteria or filters to find more properties.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _location = '';
                  _selectedPropertyType = 'All';
                  _selectedAmenities = [];
                  _priceRange = const RangeValues(0, 1000);
                  _minRating = 0;
                });
                _performSearch();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(String error, VoidCallback onRetry) {
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
              'Error Loading Properties',
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
