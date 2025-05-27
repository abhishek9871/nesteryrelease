import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class PropertyCard extends ConsumerWidget {
  final Property property;
  final bool isHorizontal;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const PropertyCard({
    Key? key,
    required this.property,
    this.isHorizontal = false,
    this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () {
        // Navigate to property details
        context.go('/home/property/${property.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isHorizontal
            ? _buildHorizontalCard(context, theme)
            : _buildVerticalCard(context, theme),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property image
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildPropertyImage(),
              ),
            ),
            // Source badge
            Positioned(
              top: 12,
              left: 12,
              child: _buildSourceBadge(theme),
            ),
            // Favorite button
            if (showFavoriteButton)
              Positioned(
                top: 8,
                right: 8,
                child: _buildFavoriteButton(theme),
              ),
            // Price badge
            Positioned(
              bottom: 12,
              right: 12,
              child: _buildPriceBadge(theme),
            ),
          ],
        ),
        // Property details
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property name
              Text(
                property.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
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
                      '${property.city}, ${property.country}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Property rating and amenities
              Row(
                children: [
                  if (property.starRating != null) ...[
                    RatingBar.builder(
                      initialRating: property.starRating!,
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
                    const SizedBox(width: 8),
                    Text(
                      property.starRating!.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  // Amenities icons
                  _buildAmenitiesIcons(theme),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCard(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPropertyImage(),
                // Source badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildSourceBadge(theme, small: true),
                ),
              ],
            ),
          ),
        ),
        // Property details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Property name
                Text(
                  property.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Property location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.city}, ${property.country}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '${property.currency} ${property.basePrice.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    // Rating
                    if (property.starRating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Constants.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            property.starRating!.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Amenities
                Row(
                  children: [
                    _buildAmenitiesIcons(theme, small: true),
                    if (showFavoriteButton) ...[
                      const Spacer(),
                      _buildFavoriteButton(theme, small: true),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyImage() {
    return property.thumbnailImage != null
        ? CachedNetworkImage(
            imageUrl: property.thumbnailImage!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          )
        : Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 40),
          );
  }

  Widget _buildSourceBadge(ThemeData theme, {bool small = false}) {
    Color badgeColor;
    String sourceText;

    switch (property.sourceType.toLowerCase()) {
      case 'booking.com':
        badgeColor = Colors.blue;
        sourceText = 'Booking.com';
        break;
      case 'oyo':
        badgeColor = Colors.red;
        sourceText = 'OYO';
        break;
      case 'direct':
        badgeColor = Constants.primaryColor;
        sourceText = 'Direct';
        break;
      default:
        badgeColor = Colors.grey;
        sourceText = property.sourceType;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(small ? 4 : 8),
      ),
      child: Text(
        sourceText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: small ? 8 : 10,
        ),
      ),
    );
  }

  Widget _buildPriceBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${property.currency} ${property.basePrice.toStringAsFixed(0)}',
        style: theme.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(ThemeData theme, {bool small = false}) {
    return Container(
      width: small ? 28 : 36,
      height: small ? 28 : 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(small ? 14 : 18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.favorite_border,
          size: small ? 14 : 20,
          color: theme.colorScheme.primary,
        ),
        onPressed: () {
          // Toggle favorite
        },
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: small ? 28 : 36,
          minHeight: small ? 28 : 36,
        ),
      ),
    );
  }

  Widget _buildAmenitiesIcons(ThemeData theme, {bool small = false}) {
    final amenities = property.amenities ?? [];
    final iconSize = small ? 14.0 : 18.0;
    final maxIcons = small ? 3 : 4;

    List<Widget> amenityIcons = [];

    if (amenities.contains('wifi')) {
      amenityIcons.add(Icon(Icons.wifi, size: iconSize, color: theme.colorScheme.onSurfaceVariant));
    }

    if (amenities.contains('pool')) {
      amenityIcons.add(Icon(Icons.pool, size: iconSize, color: theme.colorScheme.onSurfaceVariant));
    }

    if (amenities.contains('parking')) {
      amenityIcons.add(Icon(Icons.local_parking, size: iconSize, color: theme.colorScheme.onSurfaceVariant));
    }

    if (amenities.contains('breakfast')) {
      amenityIcons.add(Icon(Icons.restaurant, size: iconSize, color: theme.colorScheme.onSurfaceVariant));
    }

    if (amenities.contains('ac')) {
      amenityIcons.add(Icon(Icons.ac_unit, size: iconSize, color: theme.colorScheme.onSurfaceVariant));
    }

    // Limit the number of icons shown
    if (amenityIcons.length > maxIcons) {
      amenityIcons = amenityIcons.sublist(0, maxIcons);
      amenityIcons.add(Text(
        '+${amenities.length - maxIcons}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: amenityIcons.map((icon) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: icon,
        );
      }).toList(),
    );
  }
}
