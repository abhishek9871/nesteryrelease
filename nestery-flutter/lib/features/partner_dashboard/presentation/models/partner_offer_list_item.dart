// nestery-flutter/lib/features/partner_dashboard/presentation/models/partner_offer_list_item.dart

enum OfferStatus { active, inactive, pending, expired }

String offerStatusToString(OfferStatus status) {
  switch (status) {
    case OfferStatus.active:
      return 'Active';
    case OfferStatus.inactive:
      return 'Inactive';
    case OfferStatus.pending:
      return 'Pending';
    case OfferStatus.expired:
      return 'Expired';
  }
}

class PartnerOfferListItem {
  final String id;
  final String title;
  final OfferStatus status;
  final String partnerCategory; // FRS categories: TOUR_OPERATOR, ACTIVITY_PROVIDER, RESTAURANT, TRANSPORTATION, ECOMMERCE
  final DateTime validFrom;
  final DateTime validTo;
  final String? thumbnailUrl;

  PartnerOfferListItem({
    required this.id,
    required this.title,
    required this.status,
    required this.partnerCategory,
    required this.validFrom,
    required this.validTo,
    this.thumbnailUrl,
  });
}
