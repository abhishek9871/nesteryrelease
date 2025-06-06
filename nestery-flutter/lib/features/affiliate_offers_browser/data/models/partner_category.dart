import 'package:flutter/material.dart';

enum PartnerCategoryEnum {
  TOUR_OPERATOR,
  ACTIVITY_PROVIDER,
  RESTAURANT,
  TRANSPORTATION,
  ECOMMERCE,
}

extension PartnerCategoryExtension on PartnerCategoryEnum {
  String get displayName {
    switch (this) {
      case PartnerCategoryEnum.TOUR_OPERATOR:
        return 'Tours';
      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
        return 'Activities';
      case PartnerCategoryEnum.RESTAURANT:
        return 'Restaurants';
      case PartnerCategoryEnum.TRANSPORTATION:
        return 'Transport';
      case PartnerCategoryEnum.ECOMMERCE:
        return 'Gear';
    }
  }

  IconData get icon {
    switch (this) {
      case PartnerCategoryEnum.TOUR_OPERATOR:
        return Icons.tour;
      case PartnerCategoryEnum.ACTIVITY_PROVIDER:
        return Icons.local_activity;
      case PartnerCategoryEnum.RESTAURANT:
        return Icons.restaurant;
      case PartnerCategoryEnum.TRANSPORTATION:
        return Icons.directions_car;
      case PartnerCategoryEnum.ECOMMERCE:
        return Icons.shopping_bag;
    }
  }
}
