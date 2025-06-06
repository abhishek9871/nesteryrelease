import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';

final affiliateOffersRepositoryProvider = Provider<AffiliateOffersRepository>((ref) {
  return AffiliateOffersRepositoryImpl();
});

class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
  @override
  Future<List<OfferCardViewModel>> getOffers() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return _mockOfferData;
  }
}

List<OfferCardViewModel> get _mockOfferData => [
  OfferCardViewModel(
    offerId: 'tour-001',
    title: 'Goa Beach Adventure Tour',
    partnerName: 'Coastal Adventures',
    category: PartnerCategoryEnum.TOUR_OPERATOR,
    description: 'Experience the best beaches of Goa with our guided tour including water sports and local cuisine.',
    commissionRateMin: 15.0,
    commissionRateMax: 20.0,
    validTo: DateTime.now().add(const Duration(days: 30)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: true,
  ),
  OfferCardViewModel(
    offerId: 'restaurant-001',
    title: '20% Off at Spice Garden Restaurant',
    partnerName: 'Spice Garden',
    category: PartnerCategoryEnum.RESTAURANT,
    description: 'Authentic Indian cuisine with a modern twist. Valid for dinner bookings.',
    commissionRateMin: 10.0,
    commissionRateMax: 10.0,
    validTo: DateTime.now().add(const Duration(days: 15)),
    partnerLogoUrl: null,
    isActive: true,
  ),
  OfferCardViewModel(
    offerId: 'transport-001',
    title: 'Airport Transfer Service',
    partnerName: 'QuickRide Cabs',
    category: PartnerCategoryEnum.TRANSPORTATION,
    description: 'Reliable airport transfers with professional drivers. 24/7 availability.',
    commissionRateMin: 8.0,
    commissionRateMax: 12.0,
    validTo: DateTime.now().add(const Duration(days: 60)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: true,
  ),
  OfferCardViewModel(
    offerId: 'ecommerce-001',
    title: 'Travel Gear Essentials',
    partnerName: 'TravelMart',
    category: PartnerCategoryEnum.ECOMMERCE,
    description: 'Premium travel accessories and luggage with free shipping on orders above ₹2000.',
    commissionRateMin: 8.0,
    commissionRateMax: 12.0,
    validTo: DateTime.now().add(const Duration(days: 45)),
    partnerLogoUrl: 'https://placehold.co/100x100.png',
    isActive: false, // For testing the 'activeOnly' filter
  ),
];
