import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/enums.dart';
import 'package:nestery_flutter/providers/missing_providers.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load bookings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userBookingsProvider.notifier).loadUserBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingsState = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: bookingsState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Upcoming bookings
            _buildBookingsList(
              context,
              bookingsState.upcomingBookings,
              bookingsState.isLoading,
              bookingsState.error,
              'No upcoming bookings',
              'You don\'t have any upcoming bookings. Start exploring properties to book your next stay!',
              () => ref.read(userBookingsProvider.notifier).loadUserBookings(),
            ),

            // Past bookings
            _buildBookingsList(
              context,
              bookingsState.pastBookings,
              bookingsState.isLoading,
              bookingsState.error,
              'No past bookings',
              'You don\'t have any past bookings. Book your first stay with Nestery!',
              () => ref.read(userBookingsProvider.notifier).loadUserBookings(),
            ),

            // Cancelled bookings
            _buildBookingsList(
              context,
              bookingsState.cancelledBookings,
              bookingsState.isLoading,
              bookingsState.error,
              'No cancelled bookings',
              'You don\'t have any cancelled bookings.',
              () => ref.read(userBookingsProvider.notifier).loadUserBookings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    List<Booking> bookings,
    bool isLoading,
    String? error,
    String emptyTitle,
    String emptyMessage,
    VoidCallback onRetry,
  ) {
    if (error != null) {
      return _buildErrorState(error, onRetry);
    }

    if (bookings.isEmpty && !isLoading) {
      return _buildEmptyState(emptyTitle, emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRetry();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(context, booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image and details
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: booking.property?.thumbnailImage != null
                  ? DecorationImage(
                      image: NetworkImage(booking.property!.thumbnailImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: booking.property?.thumbnailImage == null
                  ? Colors.grey[300]
                  : null,
            ),
            child: Stack(
              children: [
                // Status badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status.value),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      booking.status.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Source badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      booking.property?.sourceType ?? 'Direct',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Gradient overlay for text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Property name and location
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.property?.name ?? booking.propertyName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${booking.property?.city ?? 'Unknown'}, ${booking.property?.country ?? 'Unknown'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking ID
                Row(
                  children: [
                    Text(
                      'Booking ID:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.id,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dateFormat.format(booking.checkInDate),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-out',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dateFormat.format(booking.checkOutDate),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Guests and total
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guests',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.numberOfGuests} ${booking.numberOfGuests == 1 ? 'guest' : 'guests'}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.currency} ${booking.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'View Details',
                        onPressed: () {
                          context.go('/booking/details/${booking.id}');
                        },
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (booking.status.value.toLowerCase() == 'confirmed') ...[
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: () {
                            _showCancellationDialog(context, booking);
                          },
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          textColor: Colors.red,
                          height: 40,
                        ),
                      ),
                    ] else if (booking.status.value.toLowerCase() == 'completed') ...[
                      Expanded(
                        child: CustomButton(
                          text: 'Review',
                          onPressed: () {
                            _showReviewDialog(context, booking);
                          },
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          textColor: theme.colorScheme.secondary,
                          height: 40,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.search),
              label: const Text('Explore Properties'),
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
              'Error Loading Bookings',
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCancellationDialog(BuildContext context, Booking booking) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this booking?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Cancellation Policy:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              booking.property?.cancellationPolicy ?? 'Standard cancellation policy applies. Please contact support for more information.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No, Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Cancel booking
              ref.read(cancelBookingProvider.notifier).cancelBooking(booking.id).then((success) {
                if (success) {
                  // Refresh bookings list
                  ref.read(userBookingsProvider.notifier).loadUserBookings();

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking cancelled successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    final ratingProvider = StateProvider<double>((ref) => 5.0);
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your stay at ${booking.property?.name ?? 'this property'}?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: Consumer(
                builder: (context, ref, _) {
                  final rating = ref.watch(ratingProvider);

                  return Column(
                    children: [
                      Text(
                        _getRatingText(rating),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(rating),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 1; i <= 5; i++)
                            GestureDetector(
                              onTap: () {
                                ref.read(ratingProvider.notifier).state = i.toDouble();
                              },
                              child: Icon(
                                i <= rating ? Icons.star : Icons.star_border,
                                color: Constants.accentColor,
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final rating = ref.watch(ratingProvider);

              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Submit review
                  if (booking.property?.id != null) {
                    ref.read(submitReviewProvider.notifier).submitReview(
                      bookingId: booking.id,
                      propertyId: booking.property!.id,
                      rating: rating,
                      comment: commentController.text,
                    ).then((success) {
                      if (success && context.mounted) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review submitted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  }
                },
                child: const Text('Submit Review'),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.blue;
    if (rating >= 2) return Colors.orange;
    return Colors.red;
  }
}
