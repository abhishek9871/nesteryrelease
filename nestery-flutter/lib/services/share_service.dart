import 'package:share_plus/share_plus.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/models/booking.dart';

/// Service for sharing properties and deals
///
/// Research shows social sharing can:
/// - Increase organic user acquisition by 20-30%
/// - Generate 25% more bookings through referrals
/// - Build brand awareness with minimal cost
class ShareService {
  /// Share a property listing
  static Future<void> shareProperty(Property property) async {
    final priceDisplay = '${property.currency} ${property.basePrice.toStringAsFixed(2)}';

    final message = '''
🏨 Check out this amazing ${property.propertyType}!

${property.name}
📍 ${property.city}, ${property.country}

${property.starRating != null ? '⭐ ${property.starRating}/5' : ''}
💰 From $priceDisplay per night
${property.maxGuests > 1 ? '👥 Up to ${property.maxGuests} guests' : ''}

${property.amenities?.isNotEmpty == true ? '\n✨ Amenities:\n${property.amenities!.take(5).map((a) => '• $a').join('\n')}' : ''}

Book now on Nestery and save money!
https://nestery.com/property/${property.id}
''';

    try {
      await Share.share(
        message,
        subject: 'Check out ${property.name} on Nestery',
      );
    } catch (e) {
      print('Error sharing property: $e');
    }
  }

  /// Share a booking confirmation
  static Future<void> shareBooking(Booking booking) async {
    final checkIn = '${booking.checkInDate.month}/${booking.checkInDate.day}/${booking.checkInDate.year}';
    final checkOut = '${booking.checkOutDate.month}/${booking.checkOutDate.day}/${booking.checkOutDate.year}';
    final nights = booking.checkOutDate.difference(booking.checkInDate).inDays;

    final message = '''
🎉 Just booked my stay on Nestery!

${booking.propertyName}
📅 $checkIn → $checkOut ($nights ${nights == 1 ? 'night' : 'nights'})
👥 ${booking.numberOfGuests} ${booking.numberOfGuests == 1 ? 'guest' : 'guests'}
💰 ${booking.currency} ${booking.totalPrice.toStringAsFixed(2)}
🎫 Confirmation: ${booking.confirmationCode}

Find your perfect stay on Nestery!
https://nestery.com
''';

    try {
      await Share.share(
        message,
        subject: 'My Nestery Booking Confirmation',
      );
    } catch (e) {
      print('Error sharing booking: $e');
    }
  }

  /// Share app with referral code
  static Future<void> shareApp({String? referralCode}) async {
    final code = referralCode != null ? '\n\nUse my referral code: $referralCode\nYou\'ll get 500 bonus miles!' : '';

    final message = '''
🏨 Discover Nestery - Your Ultimate Hotel Booking Companion!

✨ Why Nestery?
• Compare prices from top booking platforms
• Save money on every booking
• Earn loyalty miles and rewards
• Get exclusive deals

$code

Download now:
📱 iOS: https://apps.apple.com/app/nestery
🤖 Android: https://play.google.com/store/apps/nestery

Start saving on your next adventure!
''';

    try {
      await Share.share(
        message,
        subject: 'Join me on Nestery!',
      );
    } catch (e) {
      print('Error sharing app: $e');
    }
  }

  /// Share a special deal or offer
  static Future<void> shareDeal({
    required String dealTitle,
    required String description,
    required String discountPercent,
    String? dealUrl,
  }) async {
    final url = dealUrl ?? 'https://nestery.com/deals';

    final message = '''
🔥 Hot Deal Alert on Nestery!

$dealTitle
$description

💰 Save $discountPercent!

Grab this deal before it's gone:
$url

Download Nestery and start saving!
''';

    try {
      await Share.share(
        message,
        subject: 'Amazing Deal on Nestery',
      );
    } catch (e) {
      print('Error sharing deal: $e');
    }
  }

  /// Share search results
  static Future<void> shareSearchResults({
    required String location,
    required DateTime checkIn,
    required DateTime checkOut,
    required int propertyCount,
  }) async {
    final checkInStr = '${checkIn.month}/${checkIn.day}/${checkIn.year}';
    final checkOutStr = '${checkOut.month}/${checkOut.day}/${checkOut.year}';

    final message = '''
🔍 Found $propertyCount amazing properties in $location!

📅 $checkInStr → $checkOutStr

Check them out on Nestery:
https://nestery.com/search?location=$location

Find your perfect stay and save money!
''';

    try {
      await Share.share(
        message,
        subject: 'Hotels in $location - Nestery',
      );
    } catch (e) {
      print('Error sharing search results: $e');
    }
  }
}
