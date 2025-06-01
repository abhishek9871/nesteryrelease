# User Journey Feature Map

This document maps key user journeys in the Nestery application to specific features defined in the Functional Requirements Specification (FRS) and their corresponding implementation in the codebase.

## 1. User Registration and Authentication

### User Journey
A new user discovers Nestery, creates an account, and logs in to start using the platform.

### FRS Features
- User Registration (FRS Section 2.1.1)
- User Authentication (FRS Section 2.1.2)
- Social Login Integration (FRS Section 2.1.3)

### Implementation
- **Backend**:
  - `src/auth/auth.controller.ts`: API endpoints for registration and login
  - `src/auth/auth.service.ts`: Business logic for authentication
  - `src/auth/strategies/jwt.strategy.ts`: JWT authentication strategy
  - `src/users/users.service.ts`: User creation and management

- **Frontend**:
  - `lib/screens/register_screen.dart`: Registration UI
  - `lib/screens/login_screen.dart`: Login UI
  - `lib/providers/auth_provider.dart`: Authentication state management
  - `lib/models/user.dart`: User data model

## 2. Property Search and Filtering

### User Journey
A user searches for accommodations based on location, dates, and preferences, then filters and sorts the results.

### FRS Features
- Property Search (FRS Section 2.2.1)
- Advanced Filtering (FRS Section 2.2.2)
- Map-based Search (FRS Section 2.2.3)
- External API Integration (FRS Section 3.1)

### Implementation
- **Backend**:
  - `src/properties/properties.controller.ts`: Search API endpoints
  - `src/properties/properties.service.ts`: Search logic and filtering
  - `src/integrations/booking-com/booking-com.service.ts`: Booking.com API integration
  - `src/integrations/oyo/oyo.service.ts`: OYO API integration
  - `src/integrations/google-maps/google-maps.service.ts`: Google Maps integration

- **Frontend**:
  - `lib/screens/home_screen.dart`: Main search interface
  - `lib/screens/search_screen.dart`: Advanced search and filters
  - `lib/widgets/search_bar.dart`: Search input component
  - `lib/widgets/property_card.dart`: Property display component

## 3. Property Details and Booking

### User Journey
A user views detailed information about a property, checks availability for specific dates, and makes a booking.

### FRS Features
- Property Details (FRS Section 2.3.1)
- Availability Calendar (FRS Section 2.3.2)
- Booking Process (FRS Section 2.4.1)
- Payment Processing (FRS Section 2.4.2)

### Implementation
- **Backend**:
  - `src/properties/properties.controller.ts`: Property details endpoint
  - `src/bookings/bookings.controller.ts`: Booking creation endpoints
  - `src/bookings/bookings.service.ts`: Booking business logic

- **Frontend**:
  - `lib/screens/property_details_screen.dart`: Property details UI
  - `lib/screens/booking_screen.dart`: Booking form and process
  - `lib/screens/booking_confirmation_screen.dart`: Booking confirmation

## 4. User Profile and Bookings Management

### User Journey
A user views and manages their profile information, reviews past bookings, and manages upcoming reservations.

### FRS Features
- User Profile Management (FRS Section 2.5.1)
- Booking History (FRS Section 2.5.2)
- Booking Modifications (FRS Section 2.5.3)

### Implementation
- **Backend**:
  - `src/users/users.controller.ts`: Profile management endpoints
  - `src/bookings/bookings.controller.ts`: Booking management endpoints

- **Frontend**:
  - `lib/screens/profile_screen.dart`: User profile UI
  - `lib/screens/bookings_screen.dart`: Bookings list and management

## 5. Loyalty Program and Rewards

### User Journey
A user earns loyalty points from bookings, tracks their tier status, and redeems points for rewards.

### FRS Features
- Loyalty Points System (FRS Section 2.6.1)
- Tiered Membership (FRS Section 2.6.2)
- Rewards Redemption (FRS Section 2.6.3)

### Implementation
- **Backend**:
  - `src/features/loyalty/loyalty.controller.ts`: Loyalty program endpoints
  - `src/features/loyalty/loyalty.service.ts`: Loyalty business logic

- **Frontend**:
  - `lib/screens/profile_screen.dart`: Loyalty section in profile
  - Components for displaying loyalty status and redemption options

## 6. Price Prediction and Smart Booking

### User Journey
A user receives price trend analysis and recommendations on the optimal time to book a property.

### FRS Features
- Price Prediction (FRS Section 2.7.1)
- Booking Time Recommendations (FRS Section 2.7.2)

### Implementation
- **Backend**:
  - `src/features/price-prediction/price-prediction.controller.ts`: Price prediction endpoints
  - `src/features/price-prediction/price-prediction.service.ts`: Prediction algorithms

- **Frontend**:
  - Price trend visualization components in property details
  - Booking recommendation UI elements

## 7. Personalized Recommendations

### User Journey
A user receives personalized property recommendations based on their preferences and booking history.

### FRS Features
- Personalized Recommendations (FRS Section 2.8.1)
- Trending Destinations (FRS Section 2.8.2)

### Implementation
- **Backend**:
  - `src/features/recommendation/recommendation.controller.ts`: Recommendation endpoints
  - `src/features/recommendation/recommendation.service.ts`: Recommendation algorithms

- **Frontend**:
  - Recommendation sections in home screen
  - Trending destinations carousel

## 8. Social Sharing and Referrals

### User Journey
A user shares properties with friends and earns rewards for successful referrals.

### FRS Features
- Social Sharing (FRS Section 2.9.1)
- Referral Program (FRS Section 2.9.2)

### Implementation
- **Backend**:
  - `src/features/social-sharing/social-sharing.controller.ts`: Sharing and referral endpoints
  - `src/features/social-sharing/social-sharing.service.ts`: Sharing and referral logic

- **Frontend**:
  - Social sharing buttons in property details
  - Referral code generation and sharing in profile

## 9. Reviews and Ratings

### User Journey
A user leaves reviews and ratings for properties they've stayed at and views reviews from other users.

### FRS Features
- Review Submission (FRS Section 2.10.1)
- Review Display (FRS Section 2.10.2)

### Implementation
- **Backend**:
  - Review endpoints and services (to be implemented)

- **Frontend**:
  - Review submission form in booking details
  - Review display components in property details

## 10. Notifications and Alerts

### User Journey
A user receives notifications about booking confirmations, upcoming stays, special offers, and price alerts.

### FRS Features
- Booking Notifications (FRS Section 2.11.1)
- Price Alerts (FRS Section 2.11.2)

### Implementation
- **Backend**:
  - Notification services (to be implemented)

- **Frontend**:
  - Notification display components
  - Settings for notification preferences

## Cross-Cutting Concerns

### Security
- **FRS Features**: User Data Protection (FRS Section 4.1)
- **Implementation**:
  - `src/auth/guards/jwt-auth.guard.ts`: JWT authentication guard
  - `src/auth/guards/roles.guard.ts`: Role-based access control
  - Secure storage in Flutter client

### Performance
- **FRS Features**: Response Time Optimization (FRS Section 4.2)
- **Implementation**:
  - Database indexing
  - Caching strategies
  - Lazy loading in Flutter client

### Internationalization
- **FRS Features**: Multi-language Support (FRS Section 4.3)
- **Implementation**:
  - Localization framework in Flutter
  - Internationalized text resources

### Accessibility
- **FRS Features**: Accessibility Compliance (FRS Section 4.4)
- **Implementation**:
  - Semantic widgets in Flutter
  - Screen reader support
  - Contrast and text size considerations

## Feature Status and Roadmap

| Feature | Status | Implementation Priority | Planned Release |
|---------|--------|--------------------------|-----------------|
| User Registration and Authentication | Complete | High | v1.0 |
| Property Search and Filtering | Complete | High | v1.0 |
| Property Details and Booking | Complete | High | v1.0 |
| User Profile and Bookings Management | Complete | High | v1.0 |
| Loyalty Program and Rewards | Complete | Medium | v1.0 |
| Price Prediction | Complete | Medium | v1.0 |
| Personalized Recommendations | Complete | Medium | v1.0 |
| Social Sharing and Referrals | Complete | Low | v1.0 |
| Reviews and Ratings | Planned | Medium | v1.1 |
| Notifications and Alerts | Planned | Low | v1.1 |
| Advanced Analytics Dashboard | Planned | Low | v1.2 |
| Virtual Property Tours | Planned | Low | v1.2 |
