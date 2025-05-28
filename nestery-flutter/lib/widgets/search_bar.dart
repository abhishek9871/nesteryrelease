import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';

class SearchBar extends ConsumerStatefulWidget {
  final String hint;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchBar({
    Key? key,
    this.hint = 'Search destinations, hotels...',
    this.onSearch,
    this.onFilterTap,
    this.showFilterButton = true,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSearch,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Clear button
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                if (widget.onSearch != null) {
                  widget.onSearch!('');
                }
              },
            ),
          // Filter button
          if (widget.showFilterButton)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: widget.onFilterTap,
                tooltip: 'Filters',
              ),
            ),
        ],
      ),
    );
  }
}

class FilterChip extends ConsumerWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const FilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const FilterSheet({
    Key? key,
    required this.initialFilters,
    required this.onApply,
  }) : super(key: key);

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late Map<String, dynamic> _filters;

  // Price range
  late RangeValues _priceRange;
  final double _minPrice = 0;
  final double _maxPrice = 10000;

  // Rating
  late double _minRating;

  // Property types
  late List<String> _selectedPropertyTypes;
  final List<String> _propertyTypes = [
    'Hotel',
    'Apartment',
    'Resort',
    'Villa',
    'Hostel',
  ];

  // Amenities
  late List<String> _selectedAmenities;
  final List<String> _amenities = [
    'wifi',
    'pool',
    'parking',
    'breakfast',
    'ac',
    'gym',
    'spa',
    'restaurant',
  ];

  // Sort options
  late String _sortBy;
  late String _sortOrder;

  @override
  void initState() {
    super.initState();

    // Initialize filters from props
    _filters = Map<String, dynamic>.from(widget.initialFilters);

    // Initialize price range
    _priceRange = RangeValues(
      _filters['minPrice'] ?? _minPrice,
      _filters['maxPrice'] ?? _maxPrice,
    );

    // Initialize rating
    _minRating = _filters['minRating'] ?? 0.0;

    // Initialize property types
    _selectedPropertyTypes = List<String>.from(_filters['propertyTypes'] ?? []);

    // Initialize amenities
    _selectedAmenities = List<String>.from(_filters['amenities'] ?? []);

    // Initialize sort options
    _sortBy = _filters['sortBy'] ?? 'price';
    _sortOrder = _filters['sortOrder'] ?? 'asc';
  }

  void _applyFilters() {
    // Update filters map
    _filters['minPrice'] = _priceRange.start;
    _filters['maxPrice'] = _priceRange.end;
    _filters['minRating'] = _minRating;
    _filters['propertyTypes'] = _selectedPropertyTypes;
    _filters['amenities'] = _selectedAmenities;
    _filters['sortBy'] = _sortBy;
    _filters['sortOrder'] = _sortOrder;

    // Call onApply callback
    widget.onApply(_filters);

    // Close sheet
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _minRating = 0.0;
      _selectedPropertyTypes = [];
      _selectedAmenities = [];
      _sortBy = 'price';
      _sortOrder = 'asc';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price range
          Text(
            'Price Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_priceRange.start.toInt()}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${_priceRange.end.toInt()}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: _minPrice,
            max: _maxPrice,
            divisions: 100,
            labels: RangeLabels(
              '${_priceRange.start.toInt()}',
              '${_priceRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // Rating
          Text(
            'Minimum Rating',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating.toString(),
                  onChanged: (value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Constants.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _minRating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Property types
          Text(
            'Property Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _propertyTypes.map((type) {
              final isSelected = _selectedPropertyTypes.contains(type);
              return FilterChip(
                label: type,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPropertyTypes.remove(type);
                    } else {
                      _selectedPropertyTypes.add(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Amenities
          Text(
            'Amenities',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((amenity) {
              final isSelected = _selectedAmenities.contains(amenity);
              IconData? icon;

              // Assign icons based on amenity
              switch (amenity) {
                case 'wifi':
                  icon = Icons.wifi;
                  break;
                case 'pool':
                  icon = Icons.pool;
                  break;
                case 'parking':
                  icon = Icons.local_parking;
                  break;
                case 'breakfast':
                  icon = Icons.restaurant;
                  break;
                case 'ac':
                  icon = Icons.ac_unit;
                  break;
                case 'gym':
                  icon = Icons.fitness_center;
                  break;
                case 'spa':
                  icon = Icons.spa;
                  break;
                case 'restaurant':
                  icon = Icons.restaurant_menu;
                  break;
              }

              return FilterChip(
                label: amenity.substring(0, 1).toUpperCase() + amenity.substring(1),
                isSelected: isSelected,
                icon: icon,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAmenities.remove(amenity);
                    } else {
                      _selectedAmenities.add(amenity);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Sort options
          Text(
            'Sort By',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'price',
                      child: Text('Price'),
                    ),
                    DropdownMenuItem(
                      value: 'rating',
                      child: Text('Rating'),
                    ),
                    DropdownMenuItem(
                      value: 'popularity',
                      child: Text('Popularity'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortOrder,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'asc',
                      child: Text('Ascending'),
                    ),
                    DropdownMenuItem(
                      value: 'desc',
                      child: Text('Descending'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOrder = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
