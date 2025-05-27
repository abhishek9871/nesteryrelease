import 'user.dart';

/// Data Transfer Object for user registration
class RegisterDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;

  RegisterDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

/// Data Transfer Object for user login
class LoginDto {
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Data Transfer Object for token refresh
class RefreshTokenDto {
  final String refreshToken;

  RefreshTokenDto({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

/// Response object for authentication operations
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// Data Transfer Object for updating user profile
class UpdateUserDto {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final Map<String, dynamic>? preferences;

  UpdateUserDto({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.preferences,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (profilePicture != null) data['profilePicture'] = profilePicture;
    if (preferences != null) data['preferences'] = preferences;
    
    return data;
  }
}
