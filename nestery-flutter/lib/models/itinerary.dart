import 'package:nestery_flutter/models/booking.dart';
import 'package:nestery_flutter/models/user.dart';

class ItineraryItem {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String type; // e.g., 'flight', 'hotel', 'activity', 'transport'
  final Map<String, dynamic>? metadata;

  ItineraryItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.location,
    required this.type,
    this.metadata,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      location: json['location'],
      type: json['type'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'type': type,
      'metadata': metadata,
    };
  }
}

class Itinerary {
  final String id;
  final String userId;
  final String? bookingId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional related objects
  final Booking? booking;
  final User? user;

  Itinerary({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.booking,
    this.user,
  });

  // Factory constructor to create an Itinerary from JSON
  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'],
      userId: json['userId'],
      bookingId: json['bookingId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ItineraryItem.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      booking: json['booking'] != null 
          ? Booking.fromJson(json['booking']) 
          : null,
      user: json['user'] != null 
          ? User.fromJson(json['user']) 
          : null,
    );
  }

  // Convert Itinerary to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Don't include nested objects in JSON by default
    };
  }

  // Create a copy of Itinerary with updated fields
  Itinerary copyWith({
    String? id,
    String? userId,
    String? bookingId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<ItineraryItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    Booking? booking,
    User? user,
  }) {
    return Itinerary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      booking: booking ?? this.booking,
      user: user ?? this.user,
    );
  }

  // Helper getters
  int get numberOfDays => endDate.difference(startDate).inDays + 1;
  int get numberOfItems => items.length;
  
  // Get items for a specific date
  List<ItineraryItem> getItemsForDate(DateTime date) {
    return items.where((item) {
      final itemDate = DateTime(item.startTime.year, item.startTime.month, item.startTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return itemDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  @override
  String toString() {
    return 'Itinerary(id: $id, userId: $userId, bookingId: $bookingId, title: $title, startDate: $startDate, endDate: $endDate, items: ${items.length}, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Itinerary &&
        other.id == id &&
        other.userId == userId &&
        other.bookingId == bookingId &&
        other.title == title &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        bookingId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
