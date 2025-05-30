# Nestery - Hotel Booking Platform

![Nestery Logo](https://example.com/nestery-logo.png)

Nestery is a comprehensive hotel booking platform that integrates with multiple external APIs (Booking.com, OYO, Google Maps) to provide users with a wide selection of accommodations. The application features a Flutter mobile client and a NestJS backend, offering advanced features such as price prediction, personalized recommendations, and a loyalty program.

## Repository Structure

This repository contains the complete implementation of the Nestery application:

```
nesteryrelease/
├── nestery-backend/     # NestJS backend application
├── nestery-flutter/     # Flutter mobile client
├── ARCHITECTURE.md      # System architecture documentation
├── DATA_DICTIONARY.md   # Database schema documentation
├── DEPLOYMENT_GUIDE.md  # Deployment instructions
└── USER_JOURNEY_FEATURE_MAP.md  # Feature mapping to user journeys
```

## Features

- **User Authentication**: Secure registration and login system with JWT
- **Property Search**: Advanced search with filters for location, dates, price, and amenities
- **External API Integration**: Seamless integration with Booking.com, OYO, and Google Maps
- **Booking Management**: Complete booking flow with confirmation and history
- **Loyalty Program**: Points system with tiered membership and rewards
- **Price Prediction**: AI-powered price trend analysis and booking recommendations
- **Personalized Recommendations**: Custom property suggestions based on user preferences
- **Social Sharing**: Property sharing and referral program

## Technology Stack

### Backend
- **Framework**: NestJS (TypeScript)
- **Database**: PostgreSQL
- **ORM**: TypeORM
- **Authentication**: JWT
- **API Documentation**: OpenAPI/Swagger
- **Containerization**: Docker

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: flutter_secure_storage, shared_preferences
- **Maps Integration**: Google Maps Flutter

## Getting Started

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd nestery-backend
   ```

2. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

3. Update the environment variables in the `.env` file with your actual values.

4. Install dependencies:
   ```bash
   npm install
   ```

5. Run database migrations:
   ```bash
   npm run migration:run
   ```

6. Start the development server:
   ```bash
   npm run start:dev
   ```

The API will be available at `http://localhost:3000/v1`.
The Swagger documentation will be available at `http://localhost:3000/v1/docs`.

### Flutter Client Setup

1. Navigate to the Flutter directory:
   ```bash
   cd nestery-flutter
   ```

2. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

3. Update the environment variables in the `.env` file with your actual values.

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Run the application:
   ```bash
   flutter run
   ```

## API Documentation

The backend API is documented using OpenAPI/Swagger. You can access the documentation at `http://localhost:3000/v1/docs` when running the backend locally.

For a static version of the API documentation, see the `openapi.yaml` file in the backend directory or the `API_DOCUMENTATION.md` file.

## Database Schema

The application uses a PostgreSQL database with the following main entities:
- Users
- Properties
- Bookings
- LoyaltyPoints
- Recommendations

For detailed schema information, see the [Data Dictionary](DATA_DICTIONARY.md).

## Architecture

The application follows a client-server architecture with a clear separation of concerns. For detailed architecture information, see the [Architecture Documentation](ARCHITECTURE.md).

## Deployment

For detailed deployment instructions, see the [Deployment Guide](DEPLOYMENT_GUIDE.md).

## User Journeys and Features

For a mapping of user journeys to specific features and their implementation, see the [User Journey Feature Map](USER_JOURNEY_FEATURE_MAP.md).

## Development

### Backend Development

```bash
# Run in development mode
npm run start:dev

# Run tests
npm run test

# Run linting
npm run lint

# Build for production
npm run build
```

### Flutter Development

```bash
# Run in development mode
flutter run

# Run tests
flutter test

# Build Android APK
flutter build apk --release

# Build iOS app
flutter build ios --release
```

## Security

The application implements several security measures:
- JWT-based authentication
- Password hashing with bcrypt
- HTTPS for all communications
- Input validation on all API endpoints
- CORS policy configuration
- Rate limiting to prevent abuse

## Performance Optimization

- Database indexing for frequently queried fields
- Query optimization for complex searches
- Caching strategy for external API responses
- Pagination for list endpoints
- Lazy loading of images in the frontend

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Development Team - dev@nestery.com

Project Link: [https://github.com/abhishek9871/nesteryrelease](https://github.com/abhishek9871/nesteryrelease)
