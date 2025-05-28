import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/property.dart';

class Review {
  final String id;
  final String propertyId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional related objects
  final Property? property;
  final User? user;

  // Additional fields expected by UI
  final String? userProfilePicture;
  final String? userName;
  final String? date; // Formatted date string

  Review({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.property,
    this.user,
    this.userProfilePicture,
    this.userName,
    this.date,
  });

  // Factory constructor to create a Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      propertyId: json['propertyId'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      property: json['property'] != null
          ? Property.fromJson(json['property'])
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : null,
      userProfilePicture: json['userProfilePicture'],
      userName: json['userName'],
      date: json['date'],
    );
  }

  // Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Don't include nested objects in JSON by default
    };
  }

  // Create a copy of Review with updated fields
  Review copyWith({
    String? id,
    String? propertyId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    Property? property,
    User? user,
    String? userProfilePicture,
    String? userName,
    String? date,
  }) {
    return Review(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      property: property ?? this.property,
      user: user ?? this.user,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      userName: userName ?? this.userName,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, propertyId: $propertyId, userId: $userId, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.userId == userId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        userId.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
