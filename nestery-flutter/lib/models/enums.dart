// Shared enums for the Nestery Flutter app

enum BookingStatus {
  confirmed,
  completed,
  cancelled
}

enum PropertyType {
  hotel,
  apartment,
  villa,
  resort,
  guesthouse,
  hostel,
  other
}

enum UserRole {
  guest,
  host,
  admin
}

// LoyaltyTier enum moved to loyalty.dart for better organization with other loyalty models
// enum LoyaltyTier {
//   bronze,
//   silver,
//   gold,
//   platinum
// }

enum AuthProvider {
  email,
  google,
  facebook,
  apple
}

// Extension methods for enum conversions
extension BookingStatusExtension on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  // Add toLowerCase method for UI compatibility
  String toLowerCase() {
    return value.toLowerCase();
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        throw ArgumentError('Invalid booking status: $value');
    }
  }
}

extension PropertyTypeExtension on PropertyType {
  String get value {
    switch (this) {
      case PropertyType.hotel:
        return 'hotel';
      case PropertyType.apartment:
        return 'apartment';
      case PropertyType.villa:
        return 'villa';
      case PropertyType.resort:
        return 'resort';
      case PropertyType.guesthouse:
        return 'guesthouse';
      case PropertyType.hostel:
        return 'hostel';
      case PropertyType.other:
        return 'other';
    }
  }

  static PropertyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hotel':
        return PropertyType.hotel;
      case 'apartment':
        return PropertyType.apartment;
      case 'villa':
        return PropertyType.villa;
      case 'resort':
        return PropertyType.resort;
      case 'guesthouse':
        return PropertyType.guesthouse;
      case 'hostel':
        return PropertyType.hostel;
      case 'other':
        return PropertyType.other;
      default:
        throw ArgumentError('Invalid property type: $value');
    }
  }
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.guest:
        return 'guest';
      case UserRole.host:
        return 'host';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'guest':
        return UserRole.guest;
      case 'host':
        return UserRole.host;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }
}



extension AuthProviderExtension on AuthProvider {
  String get value {
    switch (this) {
      case AuthProvider.email:
        return 'email';
      case AuthProvider.google:
        return 'google';
      case AuthProvider.facebook:
        return 'facebook';
      case AuthProvider.apple:
        return 'apple';
    }
  }

  static AuthProvider fromString(String value) {
    switch (value.toLowerCase()) {
      case 'email':
        return AuthProvider.email;
      case 'google':
        return AuthProvider.google;
      case 'facebook':
        return AuthProvider.facebook;
      case 'apple':
        return AuthProvider.apple;
      default:
        throw ArgumentError('Invalid auth provider: $value');
    }
  }
}
