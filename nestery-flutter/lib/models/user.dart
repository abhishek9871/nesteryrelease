import 'package:nestery_flutter/models/loyalty.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final String role;
  final LoyaltyTier loyaltyTier; // Updated to use LoyaltyTier enum
  final int loyaltyMilesBalance; // Updated field name
  final String? authProvider;
  final bool emailVerified;
  final bool phoneVerified;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPremium;

  // Additional fields expected by UI
  final String? phone; // Alias for phoneNumber for UI compatibility
  final String? preferredCurrency;
  final String? preferredLanguage;
  final int? bookingsCount;
  final int? reviewsCount;
  final int? savedPropertiesCount;
  final String? memberSince; // For host information
  final double? rating; // Host rating
  final int? reviewCount; // Host review count

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePicture,
    required this.role,
    required this.loyaltyTier,
    required this.loyaltyMilesBalance,
    this.authProvider,
    required this.emailVerified,
    required this.phoneVerified,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.preferredCurrency,
    this.preferredLanguage,
    this.bookingsCount,
    this.reviewsCount,
    this.savedPropertiesCount,
    this.memberSince,
    this.rating,
    this.reviewCount,
    this.isPremium = false,
  });

  // Full name getter
  String get fullName => '$firstName $lastName';

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      role: json['role'],
      loyaltyTier: LoyaltyTierExtension.fromString(json['loyaltyTier'] as String?),
      loyaltyMilesBalance: json['loyaltyMilesBalance'] ?? 0,
      authProvider: json['authProvider'],
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPremium: json['isPremium'] ?? false,
      phone: json['phone'] ?? json['phoneNumber'], // Use phone field or fallback to phoneNumber
      preferredCurrency: json['preferredCurrency'],
      preferredLanguage: json['preferredLanguage'],
      bookingsCount: json['bookingsCount'],
      reviewsCount: json['reviewsCount'],
      savedPropertiesCount: json['savedPropertiesCount'],
      memberSince: json['memberSince'],
      rating: json['rating'] != null
          ? (json['rating'] is int
              ? (json['rating'] as int).toDouble()
              : json['rating'])
          : null,
      reviewCount: json['reviewCount'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'role': role,
      'loyaltyTier': loyaltyTier.name, // Store enum name as string
      'loyaltyMilesBalance': loyaltyMilesBalance,
      'authProvider': authProvider,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPremium': isPremium,
      'phone': phone,
      'preferredCurrency': preferredCurrency,
      'preferredLanguage': preferredLanguage,
      'bookingsCount': bookingsCount,
      'reviewsCount': reviewsCount,
      'savedPropertiesCount': savedPropertiesCount,
      'memberSince': memberSince,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    String? role,
    LoyaltyTier? loyaltyTier,
    int? loyaltyMilesBalance,
    String? authProvider,
    bool? emailVerified,
    bool? phoneVerified,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? preferredCurrency,
    String? preferredLanguage,
    int? bookingsCount,
    int? reviewsCount,
    int? savedPropertiesCount,
    String? memberSince,
    double? rating,
    int? reviewCount,
    bool? isPremium,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier, // Use provided or existing
      loyaltyMilesBalance: loyaltyMilesBalance ?? this.loyaltyMilesBalance, // Use provided or existing
      authProvider: authProvider ?? this.authProvider,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      savedPropertiesCount: savedPropertiesCount ?? this.savedPropertiesCount,
      memberSince: memberSince ?? this.memberSince,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
