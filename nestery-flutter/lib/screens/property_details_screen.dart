import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:nestery_flutter/providers/booking_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _shortDateFormat = DateFormat('MMM dd');

  // Booking dates
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load property details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertyDetailsProvider(widget.propertyId).notifier).loadPropertyDetails();

      // Set default check-in and check-out dates
      final now = DateTime.now();
      setState(() {
        _checkInDate = now.add(const Duration(days: 1));
        _checkOutDate = now.add(const Duration(days: 3));
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _nightCount {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalPrice {
    final propertyDetails = ref.watch(propertyDetailsProvider(widget.propertyId));
    if (propertyDetails.property == null || _nightCount == 0) return 0;

    final basePrice = propertyDetails.property!.basePrice * _nightCount;
    final taxesAndFees = basePrice * 0.15; // Assuming 15% taxes and fees
    return basePrice + taxesAndFees;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyDetails = ref.watch(propertyDetailsProvider(widget.propertyId));
    final property = propertyDetails.property;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: propertyDetails.isLoading,
        child: property == null && !propertyDetails.isLoading
            ? _buildErrorState(propertyDetails.error ?? 'Property not found')
            : CustomScrollView(
                slivers: [
                  // App Bar with property images
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildPropertyImageGallery(property),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            // Toggle favorite
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            // Share property
                          },
                        ),
                      ),
                    ],
                  ),

                  // Property details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property name and rating
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  property?.name ?? '',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (property?.starRating != null) ...[
                                RatingBar.builder(
                                  initialRating: property!.starRating!,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20,
                                  ignoreGestures: true,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Constants.accentColor,
                                  ),
                                  onRatingUpdate: (_) {},
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  property.starRating!.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Property location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${property?.address ?? ''}, ${property?.city ?? ''}, ${property?.country ?? ''}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Property price
                          Row(
                            children: [
                              Text(
                                '${property?.currency ?? ''} ${property?.basePrice.toStringAsFixed(0) ?? ''}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                ' / night',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  property?.sourceType ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Booking dates selection
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
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
                                                      onPressed: _guestCount < (property?.maxGuests ?? 10)
                                                          ? () {
                                                              setState(() {
                                                                _guestCount++;
                                                              });
                                                            }
                                                          : null,
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                                            'Total',
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
                                                  '${property?.currency ?? ''} ${_totalPrice.toStringAsFixed(0)}',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                                Text(
                                                  '$_nightCount ${_nightCount == 1 ? 'night' : 'nights'}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: GradientButton(
                                    text: 'Book Now',
                                    onPressed: () {
                                      if (_checkInDate != null && _checkOutDate != null) {
                                        context.go('/booking', extra: {
                                          'propertyId': widget.propertyId,
                                          'checkInDate': _checkInDate,
                                          'checkOutDate': _checkOutDate,
                                          'guestCount': _guestCount,
                                          'totalPrice': _totalPrice,
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab bar
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                        indicatorColor: theme.colorScheme.primary,
                        tabs: const [
                          Tab(text: 'Details'),
                          Tab(text: 'Amenities'),
                          Tab(text: 'Location'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),

                  // Tab content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Details tab
                        _buildDetailsTab(property, theme),

                        // Amenities tab
                        _buildAmenitiesTab(property, theme),

                        // Location tab
                        _buildLocationTab(property, theme),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPropertyImageGallery(Property? property) {
    if (property == null) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    final images = property.images ?? [property.thumbnailImage];

    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = images[index];
        return CachedNetworkImage(
          imageUrl: imageUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, size: 64, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab(Property? property, ThemeData theme) {
    if (property == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property description
          Text(
            'Description',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description ?? 'No description available.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Property details
          Text(
            'Property Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPropertyDetailItem(
            theme,
            Icons.home_outlined,
            'Property Type',
            property.propertyType ?? 'Not specified',
          ),
          _buildPropertyDetailItem(
            theme,
            Icons.bed_outlined,
            'Bedrooms',
            '${property.bedrooms ?? 0}',
          ),
          _buildPropertyDetailItem(
            theme,
            Icons.bathtub_outlined,
            'Bathrooms',
            '${property.bathrooms ?? 0}',
          ),
          _buildPropertyDetailItem(
            theme,
            Icons.people_outline,
            'Max Guests',
            '${property.maxGuests ?? 0}',
          ),
          _buildPropertyDetailItem(
            theme,
            Icons.square_foot_outlined,
            'Area',
            property.area != null ? '${property.area} sq ft' : 'Not specified',
          ),
          const SizedBox(height: 24),

          // House rules
          Text(
            'House Rules',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHouseRuleItem(
            theme,
            Icons.smoke_free_outlined,
            'Smoking',
            property.smokingAllowed ?? false ? 'Allowed' : 'Not allowed',
            property.smokingAllowed ?? false,
          ),
          _buildHouseRuleItem(
            theme,
            Icons.pets_outlined,
            'Pets',
            property.petsAllowed ?? false ? 'Allowed' : 'Not allowed',
            property.petsAllowed ?? false,
          ),
          _buildHouseRuleItem(
            theme,
            Icons.celebration_outlined,
            'Parties',
            property.partiesAllowed ?? false ? 'Allowed' : 'Not allowed',
            property.partiesAllowed ?? false,
          ),
          _buildHouseRuleItem(
            theme,
            Icons.access_time,
            'Check-in',
            property.checkInTime ?? 'Not specified',
            true,
          ),
          _buildHouseRuleItem(
            theme,
            Icons.access_time,
            'Check-out',
            property.checkOutTime ?? 'Not specified',
            true,
          ),
          const SizedBox(height: 24),

          // Cancellation policy
          Text(
            'Cancellation Policy',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.cancellationPolicy ?? 'No cancellation policy available.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Host information
          if (property.host != null) ...[
            Text(
              'Host Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: property.host!.profilePicture != null
                      ? NetworkImage(property.host!.profilePicture!)
                      : null,
                  child: property.host!.profilePicture == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${property.host!.firstName} ${property.host!.lastName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${property.host!.memberSince ?? 'Not specified'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Constants.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${property.host!.rating ?? 0} (${property.host!.reviewCount ?? 0} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Contact',
                  onPressed: () {
                    // Contact host
                  },
                  height: 36,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Reviews
          Text(
            'Reviews',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (property.reviews != null && property.reviews!.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: property.reviews!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = property.reviews![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: review.userProfilePicture != null
                              ? NetworkImage(review.userProfilePicture!)
                              : null,
                          child: review.userProfilePicture == null
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName ?? 'Anonymous',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                review.date ?? 'Unknown date',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RatingBar.builder(
                          initialRating: review.rating ?? 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Constants.accentColor,
                          ),
                          onRatingUpdate: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment ?? 'No comment',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to review this property',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailItem(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHouseRuleItem(ThemeData theme, IconData icon, String label, String value, bool isAllowed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAllowed
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isAllowed
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isAllowed || label == 'Check-in' || label == 'Check-out'
                      ? null
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(Property? property, ThemeData theme) {
    if (property == null) return const SizedBox();

    final amenities = property.amenities ?? [];

    // Group amenities by category
    final Map<String, List<String>> amenitiesByCategory = {
      'Basic': [],
      'Facilities': [],
      'Kitchen': [],
      'Entertainment': [],
      'Safety': [],
      'Other': [],
    };

    for (final amenity in amenities) {
      if (['wifi', 'ac', 'heating', 'washer', 'dryer'].contains(amenity)) {
        amenitiesByCategory['Basic']!.add(amenity);
      } else if (['pool', 'gym', 'spa', 'parking', 'elevator'].contains(amenity)) {
        amenitiesByCategory['Facilities']!.add(amenity);
      } else if (['kitchen', 'refrigerator', 'microwave', 'dishwasher', 'oven'].contains(amenity)) {
        amenitiesByCategory['Kitchen']!.add(amenity);
      } else if (['tv', 'cable', 'netflix', 'gaming_console', 'sound_system'].contains(amenity)) {
        amenitiesByCategory['Entertainment']!.add(amenity);
      } else if (['smoke_detector', 'fire_extinguisher', 'first_aid_kit', 'security_camera'].contains(amenity)) {
        amenitiesByCategory['Safety']!.add(amenity);
      } else {
        amenitiesByCategory['Other']!.add(amenity);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: amenitiesByCategory.entries.map((entry) {
          final category = entry.key;
          final categoryAmenities = entry.value;

          if (categoryAmenities.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categoryAmenities.length,
                itemBuilder: (context, index) {
                  final amenity = categoryAmenities[index];
                  IconData icon;

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
                    case 'tv':
                      icon = Icons.tv;
                      break;
                    case 'kitchen':
                      icon = Icons.kitchen;
                      break;
                    case 'washer':
                      icon = Icons.local_laundry_service;
                      break;
                    case 'dryer':
                      icon = Icons.dry;
                      break;
                    case 'heating':
                      icon = Icons.whatshot;
                      break;
                    case 'elevator':
                      icon = Icons.elevator;
                      break;
                    default:
                      icon = Icons.check_circle_outline;
                  }

                  return Row(
                    children: [
                      Icon(
                        icon,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          amenity.substring(0, 1).toUpperCase() + amenity.substring(1).replaceAll('_', ' '),
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationTab(Property? property, ThemeData theme) {
    if (property == null) return const SizedBox();

    return Column(
      children: [
        // Map
        Expanded(
          child: property.latitude != null && property.longitude != null
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(property.latitude!, property.longitude!),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('property'),
                      position: LatLng(property.latitude!, property.longitude!),
                      infoWindow: InfoWindow(
                        title: property.name,
                        snippet: property.address,
                      ),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location not available',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // Location details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${property.address ?? ''}, ${property.city ?? ''}, ${property.country ?? ''}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Get Directions',
                      onPressed: () {
                        // Open maps app with directions
                      },
                      icon: Icons.directions,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            Text(
              'Error Loading Property',
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
                ref.read(propertyDetailsProvider(widget.propertyId).notifier).loadPropertyDetails();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
