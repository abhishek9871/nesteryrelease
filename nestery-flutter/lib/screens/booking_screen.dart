import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/booking_provider.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/custom_text_field.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingScreen({
    super.key,
    required this.bookingData,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  String _selectedPaymentMethod = 'credit_card';
  bool _savePaymentInfo = false;
  bool _agreeToTerms = false;

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();

    // Load property details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Property details are automatically loaded by the provider

      // Pre-fill user information if available
      final userProfile = ref.read(Provider<Map<String, dynamic>?>((ref) => null));
      if (userProfile != null) {
        _firstNameController.text = userProfile['firstName'] ?? '';
        _lastNameController.text = userProfile['lastName'] ?? '';
        _emailController.text = userProfile['email'] ?? '';
        _phoneController.text = userProfile['phone'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyId = widget.bookingData['propertyId'] as String;
    final propertyDetails = ref.watch(propertyDetailsProvider(propertyId));
    final property = propertyDetails.property;
    final createBookingState = ref.watch(createBookingProvider);

    final checkInDate = widget.bookingData['checkInDate'] as DateTime;
    final checkOutDate = widget.bookingData['checkOutDate'] as DateTime;
    final guestCount = widget.bookingData['guestCount'] as int;
    final totalPrice = widget.bookingData['totalPrice'] as double;

    final nightCount = checkOutDate.difference(checkInDate).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: propertyDetails.isLoading || createBookingState.isLoading,
        loadingText: createBookingState.isLoading ? 'Processing your booking...' : null,
        child: property == null && !propertyDetails.isLoading
            ? _buildErrorState(propertyDetails.error ?? 'Property not found')
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Booking details
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Property summary
                            _buildPropertySummary(property, theme),
                            const SizedBox(height: 24),

                            // Booking details
                            SectionTitle(
                              title: 'Booking Details',
                              showSeeAll: false,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            _buildBookingDetailItem(
                              theme,
                              'Check-in',
                              _dateFormat.format(checkInDate),
                            ),
                            _buildBookingDetailItem(
                              theme,
                              'Check-out',
                              _dateFormat.format(checkOutDate),
                            ),
                            _buildBookingDetailItem(
                              theme,
                              'Guests',
                              '$guestCount ${guestCount == 1 ? 'guest' : 'guests'}',
                            ),
                            _buildBookingDetailItem(
                              theme,
                              'Duration',
                              '$nightCount ${nightCount == 1 ? 'night' : 'nights'}',
                            ),
                            const SizedBox(height: 24),

                            // Guest information
                            SectionTitle(
                              title: 'Guest Information',
                              showSeeAll: false,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'First Name',
                                    controller: _firstNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Last Name',
                                    controller: _lastNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Phone Number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Special Requests (Optional)',
                              controller: _specialRequestsController,
                              maxLines: 3,
                              hint: 'Any special requests or preferences?',
                            ),
                            const SizedBox(height: 24),

                            // Payment method
                            SectionTitle(
                              title: 'Payment Method',
                              showSeeAll: false,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentMethodSelector(theme),
                            const SizedBox(height: 16),
                            if (_selectedPaymentMethod == 'credit_card')
                              _buildCreditCardForm(theme),
                            if (_selectedPaymentMethod == 'paypal')
                              _buildPayPalForm(theme),
                            if (_selectedPaymentMethod == 'apple_pay')
                              _buildApplePayForm(theme),
                            if (_selectedPaymentMethod == 'google_pay')
                              _buildGooglePayForm(theme),
                            const SizedBox(height: 16),
                            CheckboxListTile(
                              value: _savePaymentInfo,
                              onChanged: (value) {
                                setState(() {
                                  _savePaymentInfo = value ?? false;
                                });
                              },
                              title: Text(
                                'Save payment information for future bookings',
                                style: theme.textTheme.bodyMedium,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 24),

                            // Price breakdown
                            SectionTitle(
                              title: 'Price Details',
                              showSeeAll: false,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            _buildPriceBreakdown(property, nightCount, totalPrice, theme),
                            const SizedBox(height: 24),

                            // Terms and conditions
                            CheckboxListTile(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              title: RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(
                                      text: 'I agree to the ',
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      // Add GestureRecognizer here if needed
                                    ),
                                    const TextSpan(
                                      text: ' and ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      // Add GestureRecognizer here if needed
                                    ),
                                  ],
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),

                            // Error message
                            if (createBookingState.error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        createBookingState.error!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Success message
                            if (createBookingState.isSuccess) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Booking successful! Redirecting to confirmation page...',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 100), // Space for bottom button
                          ],
                        ),
                      ),
                    ),

                    // Bottom button
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
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${property?.currency ?? ''} ${totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GradientButton(
                              text: 'Confirm Booking',
                              onPressed: (_agreeToTerms && !createBookingState.isLoading)
                                  ? () => _confirmBooking(propertyId, checkInDate, checkOutDate, guestCount, totalPrice)
                                  : () {},
                              isLoading: createBookingState.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPropertySummary(Property? property, ThemeData theme) {
    if (property == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: property.thumbnailImage != null
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
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Property details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Constants.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${property.starRating ?? 0}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property.sourceType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    return Column(
      children: [
        _buildPaymentMethodOption(
          theme,
          'credit_card',
          'Credit Card',
          'Visa, Mastercard, Amex',
          Icons.credit_card,
        ),
        _buildPaymentMethodOption(
          theme,
          'paypal',
          'PayPal',
          'Pay with your PayPal account',
          Icons.paypal,
        ),
        _buildPaymentMethodOption(
          theme,
          'apple_pay',
          'Apple Pay',
          'Quick and secure payment',
          Icons.apple,
        ),
        _buildPaymentMethodOption(
          theme,
          'google_pay',
          'Google Pay',
          'Quick and secure payment',
          Icons.g_mobiledata,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    ThemeData theme,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Card Number',
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          controller: TextEditingController(),
          prefixIcon: const Icon(Icons.credit_card),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Expiry Date',
                hint: 'MM/YY',
                keyboardType: TextInputType.number,
                controller: TextEditingController(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'CVV',
                hint: '123',
                keyboardType: TextInputType.number,
                controller: TextEditingController(),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Cardholder Name',
          hint: 'John Doe',
          controller: TextEditingController(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayPalForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.paypal,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'You will be redirected to PayPal to complete your payment securely.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.apple,
            size: 48,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          Text(
            'You will be redirected to Apple Pay to complete your payment securely.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGooglePayForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.g_mobiledata,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'You will be redirected to Google Pay to complete your payment securely.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(Property? property, int nightCount, double totalPrice, ThemeData theme) {
    if (property == null) return const SizedBox();

    final basePrice = property.basePrice * nightCount;
    final taxesAndFees = totalPrice - basePrice;

    return Column(
      children: [
        _buildPriceItem(
          theme,
          '${property.basePrice.toStringAsFixed(2)} x $nightCount ${nightCount == 1 ? 'night' : 'nights'}',
          '${property.currency} ${basePrice.toStringAsFixed(2)}',
          false,
        ),
        _buildPriceItem(
          theme,
          'Taxes and fees',
          '${property.currency} ${taxesAndFees.toStringAsFixed(2)}',
          false,
        ),
        const Divider(),
        _buildPriceItem(
          theme,
          'Total',
          '${property.currency} ${totalPrice.toStringAsFixed(2)}',
          true,
        ),
      ],
    );
  }

  Widget _buildPriceItem(ThemeData theme, String label, String value, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking(String propertyId, DateTime checkInDate, DateTime checkOutDate, int guestCount, double totalPrice) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare payment details based on selected method
    Map<String, dynamic> paymentDetails = {};

    if (_selectedPaymentMethod == 'credit_card') {
      // In a real app, you would collect and validate card details
      paymentDetails = {
        'type': 'credit_card',
        'card_number': '************1234', // Masked for security
        'expiry_date': '12/25',
        'cardholder_name': '${_firstNameController.text} ${_lastNameController.text}',
      };
    } else {
      paymentDetails = {
        'type': _selectedPaymentMethod,
      };
    }

    // Create booking
    ref.read(createBookingProvider.notifier).createBooking(
      propertyId: propertyId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfGuests: guestCount,
      specialRequests: _specialRequestsController.text,
      paymentMethod: _selectedPaymentMethod,
      paymentDetails: paymentDetails,
    ).then((success) {
      if (success) {
        // Navigate to confirmation page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          final booking = ref.read(createBookingProvider).booking;
          if (booking != null) {
            context.go('/booking/confirmation', extra: booking);
          }
        });
      }
    });
  }
}
