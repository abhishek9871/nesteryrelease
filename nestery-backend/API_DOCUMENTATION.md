# Nestery API Documentation

## Overview

This document provides comprehensive documentation for the Nestery API, which powers the Nestery mobile application for hotel and accommodation booking.

## Base URL

Production: `https://api.nestery.com/v1`
Development: `http://localhost:3000/v1`

## Authentication

The Nestery API uses JWT (JSON Web Token) for authentication. All authenticated endpoints require a valid access token to be included in the request header.

### Headers

```
Authorization: Bearer {access_token}
```

### Authentication Endpoints

#### Register a new user

```
POST /auth/register
```

Request Body:
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "securePassword123"
}
```

Response:
```json
{
  "user": {
    "id": "user-uuid",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "role": "user",
    "createdAt": "2025-05-23T10:30:00.000Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Login

```
POST /auth/login
```

Request Body:
```json
{
  "email": "john.doe@example.com",
  "password": "securePassword123"
}
```

Response:
```json
{
  "user": {
    "id": "user-uuid",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "role": "user",
    "createdAt": "2025-05-23T10:30:00.000Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Refresh Token

```
POST /auth/refresh-token
```

Request Body:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

Response:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## User Endpoints

### Get Current User

```
GET /users/me
```

Response:
```json
{
  "id": "user-uuid",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1 (555) 123-4567",
  "role": "user",
  "createdAt": "2025-05-23T10:30:00.000Z",
  "updatedAt": "2025-05-23T10:30:00.000Z"
}
```

### Update User Profile

```
PATCH /users/me
```

Request Body:
```json
{
  "name": "John Smith",
  "phone": "+1 (555) 987-6543"
}
```

Response:
```json
{
  "id": "user-uuid",
  "name": "John Smith",
  "email": "john.doe@example.com",
  "phone": "+1 (555) 987-6543",
  "role": "user",
  "createdAt": "2025-05-23T10:30:00.000Z",
  "updatedAt": "2025-05-23T11:15:00.000Z"
}
```

## Property Endpoints

### Search Properties

```
GET /properties/search
```

Query Parameters:
- `city` (string, required): City name
- `checkIn` (string, required): Check-in date in ISO format (YYYY-MM-DD)
- `checkOut` (string, required): Check-out date in ISO format (YYYY-MM-DD)
- `guests` (number, required): Number of guests
- `rooms` (number, required): Number of rooms
- `type` (string, optional): Property type (Hotel, Apartment, Villa, Resort, Hostel)
- `minPrice` (number, optional): Minimum price
- `maxPrice` (number, optional): Maximum price
- `starRating` (number, optional): Minimum star rating (1-5)
- `amenities` (string, optional): Comma-separated list of amenities
- `page` (number, optional): Page number for pagination (default: 1)
- `limit` (number, optional): Number of results per page (default: 20)

Response:
```json
{
  "data": [
    {
      "id": "property-uuid",
      "name": "Luxury Ocean View Suite",
      "description": "Experience luxury living with breathtaking ocean views",
      "type": "Hotel",
      "sourceType": "booking_com",
      "sourceId": "bcom_123",
      "address": "123 Beach Road",
      "city": "Miami",
      "country": "USA",
      "latitude": 25.7617,
      "longitude": -80.1918,
      "starRating": 5,
      "basePrice": 299.99,
      "currency": "USD",
      "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
      "images": [
        "https://example.com/hotel1_1.jpg",
        "https://example.com/hotel1_2.jpg"
      ],
      "thumbnailImage": "https://example.com/hotel1_thumb.jpg",
      "rating": 4.8,
      "reviewCount": 245,
      "isFeatured": true,
      "isPremium": true,
      "createdAt": "2025-01-15T08:30:00.000Z",
      "updatedAt": "2025-05-10T14:45:00.000Z"
    }
  ],
  "meta": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

### Get Property Details

```
GET /properties/:id
```

Response:
```json
{
  "id": "property-uuid",
  "name": "Luxury Ocean View Suite",
  "description": "Experience luxury living with breathtaking ocean views",
  "type": "Hotel",
  "sourceType": "booking_com",
  "sourceId": "bcom_123",
  "address": "123 Beach Road",
  "city": "Miami",
  "country": "USA",
  "latitude": 25.7617,
  "longitude": -80.1918,
  "starRating": 5,
  "basePrice": 299.99,
  "currency": "USD",
  "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
  "images": [
    "https://example.com/hotel1_1.jpg",
    "https://example.com/hotel1_2.jpg"
  ],
  "thumbnailImage": "https://example.com/hotel1_thumb.jpg",
  "rating": 4.8,
  "reviewCount": 245,
  "isFeatured": true,
  "isPremium": true,
  "createdAt": "2025-01-15T08:30:00.000Z",
  "updatedAt": "2025-05-10T14:45:00.000Z"
}
```

### Get Featured Properties

```
GET /properties/featured
```

Response:
```json
{
  "data": [
    {
      "id": "property-uuid",
      "name": "Luxury Ocean View Suite",
      "description": "Experience luxury living with breathtaking ocean views",
      "type": "Hotel",
      "sourceType": "booking_com",
      "sourceId": "bcom_123",
      "address": "123 Beach Road",
      "city": "Miami",
      "country": "USA",
      "latitude": 25.7617,
      "longitude": -80.1918,
      "starRating": 5,
      "basePrice": 299.99,
      "currency": "USD",
      "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
      "images": [
        "https://example.com/hotel1_1.jpg",
        "https://example.com/hotel1_2.jpg"
      ],
      "thumbnailImage": "https://example.com/hotel1_thumb.jpg",
      "rating": 4.8,
      "reviewCount": 245,
      "isFeatured": true,
      "isPremium": true,
      "createdAt": "2025-01-15T08:30:00.000Z",
      "updatedAt": "2025-05-10T14:45:00.000Z"
    }
  ]
}
```

### Get Trending Destinations

```
GET /properties/trending-destinations
```

Response:
```json
{
  "data": [
    {
      "city": "Miami",
      "country": "USA",
      "count": 1250,
      "image": "https://example.com/miami.jpg"
    },
    {
      "city": "Paris",
      "country": "France",
      "count": 980,
      "image": "https://example.com/paris.jpg"
    }
  ]
}
```

## Booking Endpoints

### Create Booking

```
POST /bookings
```

Request Body:
```json
{
  "propertyId": "property-uuid",
  "checkInDate": "2025-06-15",
  "checkOutDate": "2025-06-20",
  "numberOfGuests": 2,
  "numberOfRooms": 1,
  "totalPrice": 1499.95,
  "currency": "USD",
  "specialRequests": "High floor room with ocean view if possible"
}
```

Response:
```json
{
  "id": "booking-uuid",
  "userId": "user-uuid",
  "propertyId": "property-uuid",
  "propertyName": "Luxury Ocean View Suite",
  "propertyThumbnail": "https://example.com/hotel1_thumb.jpg",
  "checkInDate": "2025-06-15T00:00:00.000Z",
  "checkOutDate": "2025-06-20T00:00:00.000Z",
  "numberOfGuests": 2,
  "numberOfRooms": 1,
  "totalPrice": 1499.95,
  "currency": "USD",
  "status": "confirmed",
  "confirmationCode": "NEST123456",
  "specialRequests": "High floor room with ocean view if possible",
  "loyaltyPointsEarned": 150,
  "isPremiumBooking": true,
  "createdAt": "2025-05-23T12:30:00.000Z",
  "updatedAt": "2025-05-23T12:30:00.000Z"
}
```

### Get User Bookings

```
GET /bookings
```

Query Parameters:
- `status` (string, optional): Filter by status (confirmed, cancelled, completed)
- `page` (number, optional): Page number for pagination (default: 1)
- `limit` (number, optional): Number of results per page (default: 20)

Response:
```json
{
  "data": [
    {
      "id": "booking-uuid",
      "userId": "user-uuid",
      "propertyId": "property-uuid",
      "propertyName": "Luxury Ocean View Suite",
      "propertyThumbnail": "https://example.com/hotel1_thumb.jpg",
      "checkInDate": "2025-06-15T00:00:00.000Z",
      "checkOutDate": "2025-06-20T00:00:00.000Z",
      "numberOfGuests": 2,
      "numberOfRooms": 1,
      "totalPrice": 1499.95,
      "currency": "USD",
      "status": "confirmed",
      "confirmationCode": "NEST123456",
      "specialRequests": "High floor room with ocean view if possible",
      "loyaltyPointsEarned": 150,
      "isPremiumBooking": true,
      "createdAt": "2025-05-23T12:30:00.000Z",
      "updatedAt": "2025-05-23T12:30:00.000Z"
    }
  ],
  "meta": {
    "total": 5,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  }
}
```

### Get Booking Details

```
GET /bookings/:id
```

Response:
```json
{
  "id": "booking-uuid",
  "userId": "user-uuid",
  "propertyId": "property-uuid",
  "propertyName": "Luxury Ocean View Suite",
  "propertyThumbnail": "https://example.com/hotel1_thumb.jpg",
  "checkInDate": "2025-06-15T00:00:00.000Z",
  "checkOutDate": "2025-06-20T00:00:00.000Z",
  "numberOfGuests": 2,
  "numberOfRooms": 1,
  "totalPrice": 1499.95,
  "currency": "USD",
  "status": "confirmed",
  "confirmationCode": "NEST123456",
  "specialRequests": "High floor room with ocean view if possible",
  "loyaltyPointsEarned": 150,
  "isPremiumBooking": true,
  "createdAt": "2025-05-23T12:30:00.000Z",
  "updatedAt": "2025-05-23T12:30:00.000Z"
}
```

### Cancel Booking

```
PATCH /bookings/:id/cancel
```

Response:
```json
{
  "id": "booking-uuid",
  "userId": "user-uuid",
  "propertyId": "property-uuid",
  "propertyName": "Luxury Ocean View Suite",
  "propertyThumbnail": "https://example.com/hotel1_thumb.jpg",
  "checkInDate": "2025-06-15T00:00:00.000Z",
  "checkOutDate": "2025-06-20T00:00:00.000Z",
  "numberOfGuests": 2,
  "numberOfRooms": 1,
  "totalPrice": 1499.95,
  "currency": "USD",
  "status": "cancelled",
  "confirmationCode": "NEST123456",
  "specialRequests": "High floor room with ocean view if possible",
  "loyaltyPointsEarned": 0,
  "isPremiumBooking": true,
  "createdAt": "2025-05-23T12:30:00.000Z",
  "updatedAt": "2025-05-23T13:45:00.000Z"
}
```

## Loyalty Program Endpoints

### Get User Loyalty Status

```
GET /loyalty/status
```

Response:
```json
{
  "userId": "user-uuid",
  "points": 750,
  "tier": "Gold",
  "tierProgress": 0.75,
  "nextTier": "Platinum",
  "pointsToNextTier": 250,
  "benefits": [
    {
      "name": "Early Check-in",
      "description": "Subject to availability"
    },
    {
      "name": "Room Upgrades",
      "description": "Free upgrades when available"
    },
    {
      "name": "Welcome Amenities",
      "description": "Special welcome gift at check-in"
    }
  ],
  "history": [
    {
      "date": "2025-05-10T14:30:00.000Z",
      "description": "Booking at Luxury Ocean View Suite",
      "points": 150
    },
    {
      "date": "2025-04-05T09:15:00.000Z",
      "description": "Booking at Downtown Luxury Apartment",
      "points": 100
    }
  ]
}
```

## Price Prediction Endpoints

### Get Price Prediction

```
GET /price-prediction
```

Query Parameters:
- `propertyId` (string, required): Property ID
- `checkIn` (string, required): Check-in date in ISO format (YYYY-MM-DD)
- `checkOut` (string, required): Check-out date in ISO format (YYYY-MM-DD)

Response:
```json
{
  "propertyId": "property-uuid",
  "currentPrice": 299.99,
  "predictedPrices": [
    {
      "date": "2025-06-15",
      "price": 299.99
    },
    {
      "date": "2025-06-16",
      "price": 299.99
    },
    {
      "date": "2025-06-17",
      "price": 319.99
    },
    {
      "date": "2025-06-18",
      "price": 319.99
    },
    {
      "date": "2025-06-19",
      "price": 279.99
    }
  ],
  "priceAnalysis": {
    "trend": "stable",
    "recommendation": "Book now, prices are expected to increase in the next week",
    "confidence": 0.85
  }
}
```

## Recommendation Endpoints

### Get Personalized Recommendations

```
GET /recommendations
```

Response:
```json
{
  "data": [
    {
      "id": "property-uuid",
      "name": "Luxury Ocean View Suite",
      "description": "Experience luxury living with breathtaking ocean views",
      "type": "Hotel",
      "sourceType": "booking_com",
      "sourceId": "bcom_123",
      "address": "123 Beach Road",
      "city": "Miami",
      "country": "USA",
      "latitude": 25.7617,
      "longitude": -80.1918,
      "starRating": 5,
      "basePrice": 299.99,
      "currency": "USD",
      "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
      "images": [
        "https://example.com/hotel1_1.jpg",
        "https://example.com/hotel1_2.jpg"
      ],
      "thumbnailImage": "https://example.com/hotel1_thumb.jpg",
      "rating": 4.8,
      "reviewCount": 245,
      "isFeatured": true,
      "isPremium": true,
      "createdAt": "2025-01-15T08:30:00.000Z",
      "updatedAt": "2025-05-10T14:45:00.000Z",
      "recommendationReason": "Based on your previous stays in Miami"
    }
  ]
}
```

## Social Sharing Endpoints

### Create Referral Link

```
POST /social/referral
```

Response:
```json
{
  "userId": "user-uuid",
  "referralCode": "JOHN123",
  "referralLink": "https://nestery.com/refer/JOHN123",
  "pointsPerReferral": 100,
  "expiresAt": "2025-12-31T23:59:59.999Z"
}
```

### Share Property

```
POST /social/share
```

Request Body:
```json
{
  "propertyId": "property-uuid",
  "platform": "facebook" // facebook, twitter, whatsapp, email
}
```

Response:
```json
{
  "success": true,
  "shareLink": "https://nestery.com/share/property-uuid?source=facebook",
  "pointsEarned": 10
}
```

## Error Handling

All API endpoints follow a consistent error format:

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

Common HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Unprocessable Entity
- 500: Internal Server Error

## Rate Limiting

The API implements rate limiting to prevent abuse. The current limits are:

- 100 requests per minute for authenticated users
- 20 requests per minute for unauthenticated users

Rate limit headers are included in all responses:
- `X-RateLimit-Limit`: Maximum number of requests allowed per minute
- `X-RateLimit-Remaining`: Number of requests remaining in the current time window
- `X-RateLimit-Reset`: Time (in seconds) until the rate limit resets

## Versioning

The API uses URL versioning (e.g., `/v1/properties`). When a new version is released, the previous version will be maintained for a minimum of 6 months to allow for client migration.

## Support

For API support, please contact api-support@nestery.com or visit our developer portal at https://developers.nestery.com.
