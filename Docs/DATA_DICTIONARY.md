# Nestery Data Dictionary

This document provides a comprehensive data dictionary for the PostgreSQL database schema used in the Nestery application. It details all tables, columns, data types, constraints, and relationships.

## Users Table

Stores user account information and authentication details.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the user |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User's email address, used for login |
| password | VARCHAR(255) | NOT NULL | Hashed password |
| first_name | VARCHAR(100) | NOT NULL | User's first name |
| last_name | VARCHAR(100) | NOT NULL | User's last name |
| phone_number | VARCHAR(20) | NULL | User's phone number |
| profile_picture | VARCHAR(255) | NULL | URL to user's profile picture |
| role | VARCHAR(20) | NOT NULL, DEFAULT 'user' | User role (user, admin) |
| preferences | JSONB | NULL | User preferences (currency, language, notifications) |
| refresh_token | VARCHAR(255) | NULL | JWT refresh token |
| loyalty_points | INTEGER | NOT NULL, DEFAULT 0 | User's accumulated loyalty points |
| loyalty_tier | VARCHAR(20) | NOT NULL, DEFAULT 'bronze' | User's loyalty tier (bronze, silver, gold, platinum) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the user was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the user was last updated |

## Properties Table

Stores property listings from both internal and external sources.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the property |
| name | VARCHAR(255) | NOT NULL | Property name |
| description | TEXT | NOT NULL | Detailed description of the property |
| address | VARCHAR(255) | NOT NULL | Street address |
| city | VARCHAR(100) | NOT NULL | City |
| state | VARCHAR(100) | NULL | State or province |
| country | VARCHAR(100) | NOT NULL | Country |
| zip_code | VARCHAR(20) | NULL | Postal or ZIP code |
| latitude | DECIMAL(10,7) | NOT NULL | Geographic latitude |
| longitude | DECIMAL(10,7) | NOT NULL | Geographic longitude |
| property_type | VARCHAR(50) | NOT NULL | Type of property (hotel, apartment, resort, villa, hostel, guesthouse) |
| star_rating | DECIMAL(2,1) | NULL | Star rating (0-5) |
| base_price | DECIMAL(10,2) | NOT NULL | Base price per night |
| currency | VARCHAR(3) | NOT NULL, DEFAULT 'USD' | Currency code (USD, EUR, etc.) |
| max_guests | INTEGER | NOT NULL | Maximum number of guests |
| bedrooms | INTEGER | NULL | Number of bedrooms |
| bathrooms | INTEGER | NULL | Number of bathrooms |
| amenities | TEXT[] | NULL | Array of available amenities |
| images | TEXT[] | NULL | Array of image URLs |
| thumbnail_image | VARCHAR(255) | NULL | URL to the main thumbnail image |
| source_type | VARCHAR(20) | NOT NULL | Source of the property (internal, booking, oyo) |
| external_id | VARCHAR(100) | NULL | ID from external source if applicable |
| external_url | VARCHAR(255) | NULL | URL to the property on external source |
| metadata | JSONB | NULL | Additional property metadata |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Whether the property is active and bookable |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the property was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the property was last updated |

## Bookings Table

Stores booking information and status.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the booking |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user who made the booking |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the booked property |
| check_in_date | DATE | NOT NULL | Check-in date |
| check_out_date | DATE | NOT NULL | Check-out date |
| number_of_guests | INTEGER | NOT NULL | Number of guests |
| total_price | DECIMAL(10,2) | NOT NULL | Total price for the booking |
| currency | VARCHAR(3) | NOT NULL | Currency code (USD, EUR, etc.) |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'confirmed' | Booking status (confirmed, completed, cancelled) |
| confirmation_code | VARCHAR(50) | NOT NULL | Unique confirmation code |
| special_requests | TEXT | NULL | Special requests from the guest |
| payment_method | VARCHAR(20) | NOT NULL | Payment method (credit_card, paypal, points) |
| payment_details | JSONB | NULL | Payment details (masked) |
| loyalty_points_earned | INTEGER | NOT NULL, DEFAULT 0 | Loyalty points earned from this booking |
| source_type | VARCHAR(20) | NOT NULL | Source of the booking (internal, booking, oyo) |
| external_booking_id | VARCHAR(100) | NULL | ID from external source if applicable |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the booking was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the booking was last updated |

## LoyaltyTransactions Table

Tracks loyalty point transactions.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the transaction |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user |
| booking_id | UUID | FOREIGN KEY (bookings.id), NULL | Reference to the booking if applicable |
| type | VARCHAR(20) | NOT NULL | Transaction type (earned, redeemed, expired, adjusted) |
| amount | INTEGER | NOT NULL | Number of points |
| description | VARCHAR(255) | NOT NULL | Description of the transaction |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the transaction occurred |

## LoyaltyRewards Table

Stores available loyalty rewards.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the reward |
| name | VARCHAR(100) | NOT NULL | Reward name |
| description | TEXT | NOT NULL | Detailed description |
| points_cost | INTEGER | NOT NULL | Points required to redeem |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Whether the reward is currently available |
| valid_until | DATE | NULL | Expiration date of the reward |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the reward was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the reward was last updated |

## LoyaltyRedemptions Table

Tracks redemption of loyalty rewards.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the redemption |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user |
| reward_id | UUID | FOREIGN KEY (loyalty_rewards.id), NOT NULL | Reference to the redeemed reward |
| points_used | INTEGER | NOT NULL | Points used for redemption |
| redemption_code | VARCHAR(50) | NOT NULL | Unique redemption code |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'active' | Status (active, used, expired) |
| expiry_date | DATE | NULL | Expiration date of the redemption |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the redemption occurred |
| used_at | TIMESTAMP | NULL | Timestamp when the redemption was used |

## Reviews Table

Stores property reviews.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the review |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user who wrote the review |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the reviewed property |
| booking_id | UUID | FOREIGN KEY (bookings.id), NULL | Reference to the booking if applicable |
| rating | INTEGER | NOT NULL | Rating (1-5) |
| comment | TEXT | NULL | Review comment |
| is_verified | BOOLEAN | NOT NULL, DEFAULT false | Whether the review is from a verified stay |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the review was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the review was last updated |

## PropertyAvailability Table

Tracks property availability and pricing by date.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the availability record |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the property |
| date | DATE | NOT NULL | Date |
| is_available | BOOLEAN | NOT NULL, DEFAULT true | Whether the property is available on this date |
| price | DECIMAL(10,2) | NOT NULL | Price for this date |
| currency | VARCHAR(3) | NOT NULL | Currency code (USD, EUR, etc.) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the record was created |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the record was last updated |

## Referrals Table

Tracks user referrals.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the referral |
| referrer_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the referring user |
| referred_id | UUID | FOREIGN KEY (users.id), NULL | Reference to the referred user |
| referral_code | VARCHAR(50) | NOT NULL, UNIQUE | Unique referral code |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'pending' | Status (pending, completed, expired) |
| points_awarded | INTEGER | NULL | Points awarded for successful referral |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the referral was created |
| completed_at | TIMESTAMP | NULL | Timestamp when the referral was completed |

## SocialShares Table

Tracks property shares on social media.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the share |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user who shared |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the shared property |
| platform | VARCHAR(20) | NOT NULL | Social media platform (facebook, twitter, whatsapp, email) |
| share_link | VARCHAR(255) | NOT NULL | Generated share link |
| points_earned | INTEGER | NOT NULL, DEFAULT 0 | Points earned for sharing |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the share occurred |

## PricePredictions Table

Stores price prediction data.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the prediction |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the property |
| date | DATE | NOT NULL | Date of the prediction |
| predicted_price | DECIMAL(10,2) | NOT NULL | Predicted price |
| confidence | DECIMAL(5,4) | NOT NULL | Confidence level (0-1) |
| trend | VARCHAR(20) | NOT NULL | Price trend (rising, falling, stable) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the prediction was created |

## UserRecommendations Table

Stores personalized property recommendations.

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier for the recommendation |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Reference to the user |
| property_id | UUID | FOREIGN KEY (properties.id), NOT NULL | Reference to the recommended property |
| score | DECIMAL(5,4) | NOT NULL | Recommendation score (0-1) |
| reason | VARCHAR(100) | NULL | Reason for the recommendation |
| is_viewed | BOOLEAN | NOT NULL, DEFAULT false | Whether the recommendation has been viewed |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the recommendation was created |

## Database Indexes

| Table Name | Index Name | Columns | Type | Description |
|------------|------------|---------|------|-------------|
| users | users_email_idx | email | BTREE | Optimize user lookup by email |
| properties | properties_location_idx | latitude, longitude | GIST | Optimize geospatial queries |
| properties | properties_city_country_idx | city, country | BTREE | Optimize property search by location |
| properties | properties_price_idx | base_price | BTREE | Optimize property search by price |
| bookings | bookings_user_id_idx | user_id | BTREE | Optimize booking lookup by user |
| bookings | bookings_property_id_idx | property_id | BTREE | Optimize booking lookup by property |
| bookings | bookings_dates_idx | check_in_date, check_out_date | BTREE | Optimize booking search by dates |
| property_availability | property_availability_date_idx | property_id, date | BTREE | Optimize availability lookup |
| loyalty_transactions | loyalty_transactions_user_id_idx | user_id | BTREE | Optimize transaction lookup by user |
| reviews | reviews_property_id_idx | property_id | BTREE | Optimize review lookup by property |

## Database Constraints

### Primary Keys
All tables have a UUID primary key named `id`.

### Foreign Keys
- bookings.user_id → users.id
- bookings.property_id → properties.id
- loyalty_transactions.user_id → users.id
- loyalty_transactions.booking_id → bookings.id
- loyalty_redemptions.user_id → users.id
- loyalty_redemptions.reward_id → loyalty_rewards.id
- reviews.user_id → users.id
- reviews.property_id → properties.id
- reviews.booking_id → bookings.id
- property_availability.property_id → properties.id
- referrals.referrer_id → users.id
- referrals.referred_id → users.id
- social_shares.user_id → users.id
- social_shares.property_id → properties.id
- price_predictions.property_id → properties.id
- user_recommendations.user_id → users.id
- user_recommendations.property_id → properties.id

### Unique Constraints
- users.email
- referrals.referral_code
- property_availability: (property_id, date)

## Database Migrations

Database migrations are managed using TypeORM and can be found in the `src/migrations` directory. Each migration file contains both the up and down methods for applying and reverting changes.

Key migrations include:
1. CreateUsersTable
2. CreatePropertiesTable
3. CreateBookingsTable
4. CreateLoyaltyTables
5. CreateReviewsTable
6. CreateAvailabilityTable
7. CreateReferralsTable
8. CreateSocialSharesTable
9. CreatePredictionsTable
10. CreateRecommendationsTable

## Data Relationships

### One-to-Many Relationships
- User → Bookings: A user can have multiple bookings
- Property → Bookings: A property can have multiple bookings
- User → Reviews: A user can write multiple reviews
- Property → Reviews: A property can have multiple reviews
- User → LoyaltyTransactions: A user can have multiple loyalty transactions
- User → LoyaltyRedemptions: A user can redeem multiple rewards
- Property → PropertyAvailability: A property has availability records for multiple dates

### Many-to-One Relationships
- Booking → User: A booking belongs to one user
- Booking → Property: A booking is for one property
- Review → User: A review is written by one user
- Review → Property: A review is for one property
- LoyaltyTransaction → User: A transaction belongs to one user
- LoyaltyRedemption → User: A redemption belongs to one user
- LoyaltyRedemption → LoyaltyReward: A redemption is for one reward
- PropertyAvailability → Property: An availability record belongs to one property

## Data Types

### Custom JSONB Structures

#### User Preferences (users.preferences)
```json
{
  "currency": "USD",
  "language": "en",
  "notifications": true,
  "darkMode": false,
  "emailFrequency": "daily"
}
```

#### Payment Details (bookings.payment_details)
```json
{
  "cardType": "visa",
  "lastFour": "1234",
  "expiryMonth": "12",
  "expiryYear": "2028"
}
```

#### Property Metadata (properties.metadata)
```json
{
  "rating": 4.5,
  "reviewCount": 120,
  "policies": {
    "checkIn": "14:00",
    "checkOut": "11:00",
    "cancellation": "Free cancellation up to 24 hours before check-in"
  },
  "roomTypes": [
    {
      "id": "standard",
      "name": "Standard Room",
      "description": "Comfortable room with all basic amenities",
      "price": 199.99
    },
    {
      "id": "deluxe",
      "name": "Deluxe Room",
      "description": "Spacious room with premium amenities",
      "price": 299.99
    }
  ]
}
```

## Data Validation Rules

### Users
- Email: Valid email format, unique
- Password: Minimum 8 characters, hashed before storage
- Phone Number: Valid international format
- Role: Must be one of: 'user', 'admin'
- Loyalty Tier: Must be one of: 'bronze', 'silver', 'gold', 'platinum'

### Properties
- Base Price: Positive decimal
- Star Rating: Between 0 and 5
- Latitude: Between -90 and 90
- Longitude: Between -180 and 180
- Property Type: Must be one of: 'hotel', 'apartment', 'resort', 'villa', 'hostel', 'guesthouse'
- Source Type: Must be one of: 'internal', 'booking', 'oyo'

### Bookings
- Check-in Date: Must be a future date
- Check-out Date: Must be after check-in date
- Number of Guests: Positive integer, not exceeding property's max_guests
- Total Price: Positive decimal
- Status: Must be one of: 'confirmed', 'completed', 'cancelled'
- Payment Method: Must be one of: 'credit_card', 'paypal', 'points'

## Data Security

- Passwords are hashed using bcrypt before storage
- Payment details are tokenized and only the last four digits are stored
- Personal information is encrypted at rest
- Database access is restricted by role-based permissions
- Regular security audits and vulnerability assessments are conducted

## Backup and Recovery

- Daily automated backups
- Point-in-time recovery capability
- 30-day backup retention
- Regular backup restoration tests

## Performance Considerations

- Indexes on frequently queried columns
- Partitioning of large tables (e.g., bookings, property_availability) by date
- Regular database maintenance (VACUUM, ANALYZE)
- Query optimization for complex searches
- Connection pooling for efficient resource utilization
