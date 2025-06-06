class FRSCommissionValidator {
  static String? validateCommission(String? value, String partnerCategory) {
    if (value == null || value.trim().isEmpty) {
      return 'Commission rate is required';
    }
    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Please enter a valid number';
    }

    switch (partnerCategory) {
      case 'TOUR_OPERATOR':
      case 'ACTIVITY_PROVIDER':
        if (rate < 15.0 || rate > 20.0) return 'Rate must be 15% - 20%';
        break;
      case 'RESTAURANT':
        if (rate != 10.0) return 'Rate must be exactly 10%';
        break;
      case 'TRANSPORTATION':
      case 'ECOMMERCE':
        if (rate < 8.0 || rate > 12.0) return 'Rate must be 8% - 12%';
        break;
    }
    return null; // Valid
  }
}
