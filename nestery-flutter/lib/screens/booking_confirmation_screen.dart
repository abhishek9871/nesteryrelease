import 'package:flutter/material.dart';
import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  Booking? _booking;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadBooking();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock booking data
      _booking = Booking(
        id: widget.bookingId,
        userId: 'user123',
        propertyId: 'prop123',
        propertyName: 'Luxury Ocean View Suite',
        propertyThumbnail: 'https://example.com/hotel1_thumb.jpg',
        checkInDate: DateTime.now().add(const Duration(days: 30)),
        checkOutDate: DateTime.now().add(const Duration(days: 33)),
        numberOfGuests: 2,
        numberOfRooms: 1,
        totalPrice: 899.97,
        currency: 'USD',
        status: 'confirmed',
        confirmationCode: 'CONF${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        loyaltyPointsEarned: 90,
        isPremiumBooking: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Play confetti animation
      _confettiController.play();
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading booking: ${error.toString()}'),
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
          title: const Text('Booking Confirmation'),
        ),
        body: _booking == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Confetti animation
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.1,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                  
                  // Content
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(Constants.mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Success icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Constants.successColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Constants.successColor,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Success message
                        const Text(
                          'Booking Confirmed!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your booking has been confirmed. Confirmation code: ${_booking!.confirmationCode}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Loyalty points earned
                        Container(
                          padding: const EdgeInsets.all(Constants.mediumPadding),
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Constants.mediumRadius),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Constants.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Loyalty Points Earned',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'You earned ${_booking!.loyaltyPointsEarned} points with this booking!',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Booking details card
                        Container(
                          padding: const EdgeInsets.all(Constants.mediumPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Constants.mediumRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Property details
                              Row(
                                children: [
                                  // Property image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Constants.smallRadius),
                                    child: Image.network(
                                      _booking!.propertyThumbnail,
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
                                  
                                  // Property name
                                  Expanded(
                                    child: Text(
                                      _booking!.propertyName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Divider
                              const Divider(),
                              const SizedBox(height: 16),
                              
                              // Booking details
                              const Text(
                                'Booking Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Check-in and check-out
                              _buildDetailRow(
                                'Check-in',
                                DateFormat('MMM dd, yyyy').format(_booking!.checkInDate),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Check-out',
                                DateFormat('MMM dd, yyyy').format(_booking!.checkOutDate),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Guests',
                                _booking!.numberOfGuests.toString(),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Rooms',
                                _booking!.numberOfRooms.toString(),
                              ),
                              const SizedBox(height: 16),
                              
                              // Divider
                              const Divider(),
                              const SizedBox(height: 16),
                              
                              // Payment details
                              const Text(
                                'Payment Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildDetailRow(
                                'Total Amount',
                                '\$${_booking!.totalPrice.toStringAsFixed(2)}',
                                valueStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Status',
                                'Paid',
                                valueStyle: const TextStyle(
                                  color: Constants.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'View Booking',
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(
                                    Constants.bookingsRoute,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                text: 'Back to Home',
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(
                                    Constants.homeRoute,
                                  );
                                },
                                isOutlined: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Share booking
                        CustomButton(
                          text: 'Share Booking',
                          icon: Icons.share,
                          onPressed: () {
                            // TODO: Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share functionality coming soon'),
                              ),
                            );
                          },
                          backgroundColor: Colors.grey[200],
                          textColor: Colors.black87,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }
}
