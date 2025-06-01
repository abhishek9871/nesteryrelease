# Nestery Architecture

This document provides a comprehensive overview of the Nestery application architecture, detailing the system design, component interactions, data flow, and key design decisions.

## System Overview

Nestery is a hotel booking platform that integrates with multiple external APIs (Booking.com, OYO, Google Maps) to provide users with a comprehensive selection of accommodations. The application follows a client-server architecture with a Flutter mobile client and a NestJS backend.

![System Architecture](https://example.com/architecture-diagram.png)

## Technology Stack

### Backend
- **Framework**: NestJS (TypeScript)
- **Database**: PostgreSQL
- **ORM**: TypeORM
- **Authentication**: JWT (JSON Web Tokens)
- **API Documentation**: OpenAPI/Swagger
- **Testing**: Jest
- **Containerization**: Docker
- **Web Server**: Nginx (for production)

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: flutter_secure_storage, shared_preferences
- **Environment Configuration**: flutter_dotenv
- **Testing**: Flutter Test, Mockito

## Component Architecture

### Backend Components

#### Core Modules
1. **App Module**: Root module that ties together all other modules
2. **Config Module**: Handles environment configuration and validation
3. **Core Module**: Provides shared services like logging, exception handling, and utilities

#### Feature Modules
1. **Auth Module**: Handles user authentication and authorization
   - JWT strategy for token-based authentication
   - Role-based access control
   - Token refresh mechanism

2. **Users Module**: Manages user profiles and preferences
   - User entity and repository
   - Profile management
   - User preferences

3. **Properties Module**: Manages property listings and search
   - Property entity and repository
   - Search functionality with filtering
   - Integration with external APIs

4. **Bookings Module**: Handles booking creation and management
   - Booking entity and repository
   - Booking status management
   - Integration with payment systems

5. **Integrations Module**: Manages external API integrations
   - Booking.com integration
   - OYO integration
   - Google Maps integration

6. **Features Module**: Contains advanced features
   - Price Prediction: Analyzes price trends and provides booking recommendations
   - Recommendation: Generates personalized property recommendations
   - Loyalty: Manages loyalty points and rewards
   - Social Sharing: Handles referrals and social media sharing

### Frontend Components

#### Core Components
1. **Main**: Entry point of the application
2. **App Router**: Handles navigation and routing
3. **Theme Provider**: Manages application theming

#### Feature Components
1. **Auth**: Handles user authentication
   - Login Screen
   - Register Screen
   - Auth Provider

2. **Home**: Main screen of the application
   - Featured Properties
   - Trending Destinations
   - Search Bar

3. **Property**: Property-related screens and components
   - Property Details Screen
   - Property Card Widget
   - Property Search Screen

4. **Booking**: Booking-related screens and components
   - Booking Screen
   - Booking Confirmation Screen
   - Bookings List Screen

5. **Profile**: User profile management
   - Profile Screen
   - Settings
   - Loyalty Status

## Data Flow

### Authentication Flow
1. User enters credentials in the Flutter client
2. Client sends credentials to the NestJS backend
3. Backend validates credentials and generates JWT tokens
4. Tokens are returned to the client and stored securely
5. Client includes access token in subsequent API requests
6. When token expires, client uses refresh token to obtain a new access token

### Property Search Flow
1. User enters search criteria in the Flutter client
2. Client sends search request to the NestJS backend
3. Backend queries internal database and external APIs (Booking.com, OYO)
4. Results are aggregated, normalized, and returned to the client
5. Client displays search results to the user

### Booking Flow
1. User selects a property and enters booking details
2. Client sends booking request to the NestJS backend
3. Backend validates availability with the appropriate source (internal or external API)
4. Backend processes payment and creates booking record
5. Confirmation is returned to the client and displayed to the user
6. Loyalty points are awarded to the user

## Database Schema

The database uses PostgreSQL with the following main entities:

1. **Users**: Stores user information and authentication details
2. **Properties**: Stores property listings (both internal and from external sources)
3. **Bookings**: Stores booking information and status
4. **LoyaltyPoints**: Tracks user loyalty points and transactions
5. **Recommendations**: Stores personalized recommendations for users

See the [Data Dictionary](DATA_DICTIONARY.md) for detailed schema information.

## Security Architecture

### Authentication & Authorization
- JWT-based authentication with short-lived access tokens and longer-lived refresh tokens
- Passwords hashed using bcrypt
- Role-based access control for API endpoints
- HTTPS for all communications

### Data Protection
- Input validation on all API endpoints
- Parameterized queries to prevent SQL injection
- CORS policy configuration
- Rate limiting to prevent abuse
- XSS protection

### External API Security
- API keys stored securely in environment variables
- Credentials never exposed to the client
- Fallback mechanisms for API failures

## Observability Strategy

### Logging
- Structured logging with context information
- Log levels (debug, info, warn, error)
- Request/response logging for API endpoints

### Monitoring
- Health check endpoints
- Performance metrics collection
- Error tracking and alerting

### Error Handling
- Global exception filter for consistent error responses
- Detailed error logging
- Graceful degradation for external API failures

## Scalability Considerations

### Horizontal Scaling
- Stateless backend design allows for multiple instances
- Database connection pooling
- Redis for caching and session storage (future implementation)

### Performance Optimization
- Database indexing for frequently queried fields
- Query optimization for complex searches
- Caching strategy for external API responses
- Pagination for list endpoints
- Lazy loading of images in the frontend

## Key Design Patterns

1. **Dependency Injection**: Used throughout the NestJS backend for loose coupling and testability
2. **Repository Pattern**: Abstracts data access logic
3. **Factory Pattern**: Used for creating service instances
4. **Strategy Pattern**: Used for different authentication strategies
5. **Observer Pattern**: Used for event-based communication
6. **Provider Pattern**: Used in Flutter for state management

## Integration Points

### Booking.com Integration
- Uses Booking.com Demand API 3.1
- Endpoints for property search, details, and booking
- Response transformation to standard format

### OYO Integration
- Uses OYO API (with fallback mechanisms due to limited public documentation)
- Endpoints for property search, details, and booking
- Response transformation to standard format

### Google Maps Integration
- Uses Google Maps API for location services
- Geocoding for address to coordinates conversion
- Places API for nearby attractions

## Future Architecture Considerations

1. **Microservices**: Potential migration to microservices architecture for better scalability
2. **GraphQL**: Consideration for GraphQL API to optimize data fetching
3. **Real-time Updates**: Implementation of WebSockets for real-time notifications
4. **AI/ML Pipeline**: Enhanced recommendation and price prediction systems
5. **Multi-region Deployment**: For improved global performance and redundancy
