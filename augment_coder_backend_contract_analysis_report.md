# Nestery Backend Contract Analysis Report

## Executive Summary

This report provides a comprehensive analysis of the nestery-backend project's current data entities and OpenAPI specification against the "Final Consolidated Nestery Functional Requirements Specification" (FRS) and `DATA_DICTIONARY.md`. The analysis reveals significant gaps between the current implementation and the target schema, with most required entities missing and existing entities lacking critical fields and proper TypeORM configurations.

## Key Findings

- **16 missing entity files** required by FRS and Data Dictionary
- **Critical field gaps** in all 3 existing entities
- **Incorrect data types** for monetary and geographic fields
- **Missing OpenAPI schemas** for most required entities
- **API endpoint gaps** between OpenAPI spec and API documentation

---

## Entity File Analysis

### 1. User Entity (`src/users/entities/user.entity.ts`)

#### Missing Fields (Required by DATA_DICTIONARY.md)
| Field Name | Expected Type | Notes |
|------------|---------------|-------|
| preferences | JSONB | User preferences (currency, language, notifications) |
| refresh_token | VARCHAR(255) | JWT refresh token storage |
| loyalty_tier | VARCHAR(20) | User loyalty tier (bronze, silver, gold, platinum) |

#### Missing Fields (Required by FRS)
| Field Name | Expected Type | Notes |
|------------|---------------|-------|
| auth_provider | VARCHAR(50) | OAuth provider (google, facebook, apple) |
| auth_provider_id | VARCHAR(255) | External auth provider user ID |
| stripe_customer_id | VARCHAR(255) | For future payment processing |
| email_verified | BOOLEAN | Email verification status |
| phone_verified | BOOLEAN | Phone verification status |

#### Fields with Incorrect Types
| Field Name | Current Type | Expected Type | Recommended TypeORM Decorator |
|------------|--------------|---------------|-------------------------------|
| firstName | string | VARCHAR(100) | `@Column({ name: "first_name", length: 100 })` |
| lastName | string | VARCHAR(100) | `@Column({ name: "last_name", length: 100 })` |
| phoneNumber | string | VARCHAR(20) | `@Column({ name: "phone_number", length: 20, nullable: true })` |
| profilePicture | string | VARCHAR(255) | `@Column({ name: "profile_picture", length: 255, nullable: true })` |

#### Fields with Incorrect Nullability
| Field Name | Current | Expected | Fix |
|------------|---------|----------|-----|
| firstName | nullable: true | NOT NULL | Remove nullable option |
| lastName | nullable: true | NOT NULL | Remove nullable option |

#### Extra Fields Not in Specification
- `name` - Should be removed, use firstName + lastName
- `isPremium` - Should be managed via PremiumSubscriptions entity
- `referralCode`, `referredBy`, `hasCompletedBooking` - Should be in Referrals entity
- `referredUsers`, `referrer` - Relationships should be in Referrals entity

### 2. Property Entity (`src/properties/entities/property.entity.ts`)

#### Missing Fields (Required by DATA_DICTIONARY.md)
| Field Name | Expected Type | Notes |
|------------|---------------|-------|
| star_rating | DECIMAL(2,1) | Property star rating (0-5) |
| thumbnail_image | VARCHAR(255) | Main thumbnail image URL |
| source_type | VARCHAR(20) | Source (internal, booking, oyo) |
| external_id | VARCHAR(100) | ID from external source |
| external_url | VARCHAR(255) | URL to property on external source |
| metadata | JSONB | Additional property metadata |

#### Fields with Incorrect Types
| Field Name | Current Type | Expected Type | Recommended TypeORM Decorator |
|------------|--------------|---------------|-------------------------------|
| latitude | float | DECIMAL(10,7) | `@Column({ type: "decimal", precision: 10, scale: 7 })` |
| longitude | float | DECIMAL(10,7) | `@Column({ type: "decimal", precision: 10, scale: 7 })` |
| basePrice | float | DECIMAL(10,2) | `@Column({ name: "base_price", type: "decimal", precision: 10, scale: 2 })` |
| zipCode | string | VARCHAR(20) | `@Column({ name: "zip_code", length: 20, nullable: true })` |
| type | string | VARCHAR(50) | `@Column({ name: "property_type", length: 50 })` |
| maxGuests | number | INTEGER | `@Column({ name: "max_guests", type: "int" })` |

#### Extra Fields Not in Specification
- `pricePerNight` - Redundant with basePrice
- `rating`, `reviewCount` - Should be calculated from Reviews entity
- `hostId`, `host` - Not in specification
- `bookings` - Relationship should be properly configured

### 3. Booking Entity (`src/bookings/entities/booking.entity.ts`)

#### Missing Fields (Required by DATA_DICTIONARY.md)
| Field Name | Expected Type | Notes |
|------------|---------------|-------|
| payment_details | JSONB | Masked payment details |
| external_booking_id | VARCHAR(100) | ID from external source |

#### Missing Fields (Required by FRS)
| Field Name | Expected Type | Notes |
|------------|---------------|-------|
| supplier_id | UUID | Reference to Suppliers table |
| supplier_booking_reference | VARCHAR(100) | Supplier's booking reference |

#### Fields with Incorrect Types/Names
| Field Name | Current | Expected | Recommended Fix |
|------------|---------|----------|-----------------|
| userId | string | user_id (UUID) | `@Column({ name: "user_id" })` |
| propertyId | string | property_id (UUID) | `@Column({ name: "property_id" })` |
| checkInDate | Date | check_in_date (DATE) | `@Column({ name: "check_in_date", type: "date" })` |
| checkOutDate | Date | check_out_date (DATE) | `@Column({ name: "check_out_date", type: "date" })` |
| numberOfGuests | number | number_of_guests (INTEGER) | `@Column({ name: "number_of_guests", type: "int" })` |
| totalPrice | float | total_price (DECIMAL) | `@Column({ name: "total_price", type: "decimal", precision: 10, scale: 2 })` |

#### Extra Fields Not in Specification
- `guestCount` - Redundant with numberOfGuests
- `isCancelled`, `cancellationReason`, `cancellationDate` - Should use status field
- `isRefunded`, `refundAmount` - Not in specification
- `paymentId`, `isPaid`, `paymentDate` - Should be in payment_details JSONB
- `loyaltyPointsRedeemed`, `isPremiumBooking` - Not in specification

---

## Missing Entity Files

The following entities are completely missing from the current implementation:

### Core Entities (DATA_DICTIONARY.md)
1. **LoyaltyTransactions** (`src/features/loyalty/entities/loyalty-transaction.entity.ts`)
2. **LoyaltyRewards** (`src/features/loyalty/entities/loyalty-reward.entity.ts`)
3. **LoyaltyRedemptions** (`src/features/loyalty/entities/loyalty-redemption.entity.ts`)
4. **Reviews** (`src/features/reviews/entities/review.entity.ts`)
5. **PropertyAvailability** (`src/properties/entities/property-availability.entity.ts`)
6. **Referrals** (`src/features/referrals/entities/referral.entity.ts`)
7. **SocialShares** (`src/features/social-sharing/entities/social-share.entity.ts`)
8. **PricePredictions** (`src/features/price-prediction/entities/price-prediction.entity.ts`)
9. **UserRecommendations** (`src/features/recommendation/entities/user-recommendation.entity.ts`)

### FRS-Specific Entities
10. **Suppliers** (`src/integrations/entities/supplier.entity.ts`)
11. **NesteryMasterProperties** (`src/properties/entities/nestery-master-property.entity.ts`)
12. **SupplierProperties** (`src/integrations/entities/supplier-property.entity.ts`)
13. **LoyaltyPointsLedger** (`src/features/loyalty/entities/loyalty-points-ledger.entity.ts`)
14. **PremiumSubscriptions** (`src/features/subscriptions/entities/premium-subscription.entity.ts`)
15. **Itineraries** (`src/features/itineraries/entities/itinerary.entity.ts`)
16. **ItineraryItems** (`src/features/itineraries/entities/itinerary-item.entity.ts`)

---

## OpenAPI Specification Analysis

### Missing Schemas in `components/schemas`

#### Core Missing Schemas
- `LoyaltyTransactionResponse`
- `LoyaltyRewardResponse`
- `LoyaltyRedemptionResponse`
- `ReviewResponse`, `CreateReviewDto`
- `PropertyAvailabilityResponse`
- `ReferralDetailResponse`
- `SocialShareResponse`
- `UserRecommendationResponse`

#### FRS-Specific Missing Schemas
- `SupplierResponse`
- `NesteryMasterPropertyResponse`
- `SupplierPropertyResponse`
- `PremiumSubscriptionResponse`
- `ItineraryResponse`, `CreateItineraryDto`
- `ItineraryItemResponse`

### Fields Missing in Existing Schemas

#### UserResponse Schema
| Missing Field | Type | Notes |
|---------------|------|-------|
| loyaltyTier | string | enum: [bronze, silver, gold, platinum] |
| refreshToken | string | JWT refresh token |

#### PropertyResponse Schema
| Missing Field | Type | Notes |
|---------------|------|-------|
| sourceType | string | enum: [internal, booking, oyo] |
| externalId | string | ID from external source |
| externalUrl | string | URL to external source |
| metadata | object | Additional property metadata |

#### BookingResponse Schema
| Missing Field | Type | Notes |
|---------------|------|-------|
| paymentDetails | object | Masked payment information |
| externalBookingId | string | External booking reference |
| supplierId | string | Reference to supplier |
| supplierBookingReference | string | Supplier's booking reference |

### Missing API Endpoints

#### Endpoints in API_DOCUMENTATION.md but not in OpenAPI
- `GET /properties/featured`
- `GET /properties/trending-destinations`
- `PATCH /bookings/{id}/cancel`
- `GET /loyalty/status` (different from `/loyalty/points`)

#### Missing CRUD Endpoints for Required Entities
- Reviews: `GET/POST/PUT/DELETE /reviews`
- Property Availability: `GET /properties/{id}/availability`
- Referrals: `GET /users/me/referrals`
- Itineraries: `GET/POST/PUT/DELETE /itineraries`
- Suppliers: `GET/POST/PUT/DELETE /suppliers` (admin)
- Master Properties: `GET/POST/PUT/DELETE /master-properties` (admin)

---

## TypeORM Best Practices Issues

### Data Type Issues
1. **Monetary Fields**: Using `float` instead of `DECIMAL(10,2)` for prices
2. **Geographic Coordinates**: Using `float` instead of `DECIMAL(10,7)` for lat/lng
3. **Timestamps**: Missing timezone configuration for PostgreSQL
4. **Arrays**: Using `simple-array` instead of proper PostgreSQL array types

### Column Configuration Issues
1. **Missing Length Constraints**: VARCHAR fields without length specifications
2. **Missing Nullable Configurations**: Incorrect nullability settings
3. **Missing Default Values**: No default values where specified
4. **Missing Enum Constraints**: Status fields without enum validation

### Relationship Issues
1. **Missing Foreign Key Constraints**: No `onDelete`/`onUpdate` configurations
2. **Incomplete Join Configurations**: Missing proper `@JoinColumn` setups
3. **Circular Dependencies**: Commented relationships indicate incomplete setup

---

## Recommendations

### Immediate Actions Required

1. **Create Missing Entity Files**: Implement all 16 missing entities with proper TypeORM decorators
2. **Fix Existing Entities**: Correct field types, names, and configurations in User, Property, and Booking entities
3. **Update OpenAPI Specification**: Add missing schemas and endpoints
4. **Implement Proper Data Types**: Use DECIMAL for monetary/geographic fields, proper PostgreSQL types
5. **Add Validation**: Implement enum constraints, length limits, and range validations
6. **Configure Relationships**: Set up proper foreign keys with cascade options

### TypeORM Decorator Examples

```typescript
// Correct decimal usage for prices
@Column({ name: "base_price", type: "decimal", precision: 10, scale: 2 })
basePrice: number;

// Correct decimal usage for coordinates  
@Column({ type: "decimal", precision: 10, scale: 7 })
latitude: number;

// Proper JSONB column
@Column({ type: "jsonb", nullable: true })
preferences: object;

// Proper enum column
@Column({ 
  type: "enum", 
  enum: ["bronze", "silver", "gold", "platinum"],
  default: "bronze"
})
loyaltyTier: string;

// Proper foreign key with constraints
@ManyToOne(() => User, { onDelete: "CASCADE" })
@JoinColumn({ name: "user_id" })
user: User;
```

This analysis reveals that the current backend implementation requires substantial work to align with the FRS and Data Dictionary specifications. The missing entities and incorrect configurations represent a significant technical debt that must be addressed for full FRS compliance.
