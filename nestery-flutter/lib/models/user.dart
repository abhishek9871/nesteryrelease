class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final String role;
  final String loyaltyTier;
  final int loyaltyPoints;
  final String? authProvider;
  final bool emailVerified;
  final bool phoneVerified;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePicture,
    required this.role,
    required this.loyaltyTier,
    required this.loyaltyPoints,
    this.authProvider,
    required this.emailVerified,
    required this.phoneVerified,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
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
      loyaltyTier: json['loyaltyTier'] ?? 'bronze',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      authProvider: json['authProvider'],
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'loyaltyTier': loyaltyTier,
      'loyaltyPoints': loyaltyPoints,
      'authProvider': authProvider,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    String? loyaltyTier,
    int? loyaltyPoints,
    String? authProvider,
    bool? emailVerified,
    bool? phoneVerified,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      authProvider: authProvider ?? this.authProvider,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
