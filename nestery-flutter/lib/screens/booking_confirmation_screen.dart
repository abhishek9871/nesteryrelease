import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/providers/booking_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final Booking booking;

  const BookingConfirmationScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareBooking(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            
            // Success message
            Text(
              'Booking Confirmed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking has been successfully confirmed.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Booking ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Booking ID',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.id,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // QR Code
                  QrImageView(
                    data: 'NESTERY_BOOKING:${booking.id}',
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Show this QR code at check-in',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Booking details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    'Property',
                    booking.property.name,
                  ),
                  _buildDetailRow(
                    theme,
                    'Location',
                    '${booking.property.city}, ${booking.property.country}',
                  ),
                  _buildDetailRow(
                    theme,
                    'Check-in',
                    dateFormat.format(booking.checkInDate),
                  ),
                  _buildDetailRow(
                    theme,
                    'Check-out',
                    dateFormat.format(booking.checkOutDate),
                  ),
                  _buildDetailRow(
                    theme,
                    'Guests',
                    '${booking.numberOfGuests} ${booking.numberOfGuests == 1 ? 'guest' : 'guests'}',
                  ),
                  _buildDetailRow(
                    theme,
                    'Booking Date',
                    dateFormat.format(booking.bookingDate),
                  ),
                  _buildDetailRow(
                    theme,
                    'Status',
                    booking.status,
                    valueColor: _getStatusColor(booking.status),
                  ),
                  _buildDetailRow(
                    theme,
                    'Total Amount',
                    '${booking.property.currency} ${booking.totalAmount.toStringAsFixed(2)}',
                    isLast: true,
                    valueColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    theme,
                    'Payment Method',
                    _formatPaymentMethod(booking.paymentMethod),
                  ),
                  _buildDetailRow(
                    theme,
                    'Payment Status',
                    booking.paymentStatus,
                    valueColor: _getPaymentStatusColor(booking.paymentStatus),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (booking.property.host != null) ...[
                    _buildDetailRow(
                      theme,
                      'Host',
                      '${booking.property.host!.firstName} ${booking.property.host!.lastName}',
                    ),
                    _buildDetailRow(
                      theme,
                      'Phone',
                      booking.property.host!.phone ?? 'Not available',
                    ),
                    _buildDetailRow(
                      theme,
                      'Email',
                      booking.property.host!.email ?? 'Not available',
                      isLast: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      theme,
                      'Contact',
                      'Property contact information not available',
                      isLast: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Special requests
            if (booking.specialRequests != null && booking.specialRequests!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Requests',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      booking.specialRequests!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Booking',
                    onPressed: () {
                      context.go('/bookings');
                    },
                    icon: Icons.visibility,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: 'Back to Home',
                    onPressed: () {
                      context.go('/home');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cancellation policy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancellation Policy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.property.cancellationPolicy ?? 'Standard cancellation policy applies. Please contact support for more information.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value, {
    bool isLast = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
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
      default:
        return Colors.blue;
    }
  }
  
  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'credit_card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return method.substring(0, 1).toUpperCase() + method.substring(1).replaceAll('_', ' ');
    }
  }
  
  void _shareBooking(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    final message = '''
🏨 Nestery Booking Confirmation

Booking ID: ${booking.id}
Property: ${booking.property.name}
Location: ${booking.property.city}, ${booking.property.country}
Check-in: ${dateFormat.format(booking.checkInDate)}
Check-out: ${dateFormat.format(booking.checkOutDate)}
Guests: ${booking.numberOfGuests}
Total Amount: ${booking.property.currency} ${booking.totalAmount.toStringAsFixed(2)}

Thank you for booking with Nestery!
''';
    
    Share.share(message, subject: 'Nestery Booking Confirmation');
  }
}
