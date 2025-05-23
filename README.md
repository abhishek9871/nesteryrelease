# Nestery Mobile Application

## Project Overview

This package contains the complete implementation of the Nestery mobile application as specified in the Functional Requirements Specification (FRS). The application is a comprehensive hotel booking platform that integrates with external APIs (Booking.com, OYO, Google Maps) and provides advanced features such as price prediction, personalized recommendations, and a loyalty program.

## Package Contents

### Backend (NestJS/TypeScript)
- Complete NestJS application with TypeScript
- Authentication module with JWT
- User management module
- Properties module with search functionality
- Bookings module with loyalty integration
- External API integrations
- Advanced features (price prediction, recommendations, loyalty program)
- Unit tests
- Deployment configuration (Docker, Nginx)
- API documentation

### Frontend (Flutter)
- Complete Flutter application
- Authentication screens
- Home screen with featured properties and trending destinations
- Search screen with filters
- Property details screen
- Booking screens
- Profile screens with loyalty status
- Unit and widget tests

## Getting Started

### Backend Setup

1. Navigate to the backend directory:
```bash
cd nestery-backend
```

2. Create a `.env` file based on the `.env.example` template:
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

### Frontend Setup

1. Navigate to the Flutter directory:
```bash
cd nestery-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update the API base URL in `lib/utils/constants.dart` to point to your backend server.

4. Run the application:
```bash
flutter run
```

## Deployment

### Backend Deployment

The backend can be deployed using Docker and Docker Compose:

1. Build and start the containers:
```bash
docker-compose up -d
```

2. The API will be available at `http://localhost:3000` or at the configured domain if using Nginx.

### Frontend Deployment

The Flutter application can be built for various platforms:

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## API Documentation

Comprehensive API documentation is available in the `API_DOCUMENTATION.md` file in the backend directory. This includes details on all endpoints, request/response formats, authentication, and error handling.

## Architecture

### Backend Architecture

The backend follows a modular architecture with clear separation of concerns:

- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic
- **Repositories**: Handle data access
- **DTOs**: Define data transfer objects for validation
- **Entities**: Define database models
- **Modules**: Group related functionality

### Frontend Architecture

The Flutter application follows a clean architecture approach:

- **Models**: Define data structures
- **Providers**: Handle state management
- **Screens**: Define UI screens
- **Widgets**: Reusable UI components
- **Utils**: Utility functions and constants
- **Services**: Handle API communication

## Testing

### Backend Testing

Run backend tests with:
```bash
npm run test
```

### Frontend Testing

Run Flutter tests with:
```bash
flutter test
```

## Security Considerations

- All user passwords are hashed using bcrypt
- JWT tokens are used for authentication
- HTTPS is configured for production
- Input validation is implemented for all endpoints
- CORS policy is configured
- Rate limiting is implemented
- Protection against common vulnerabilities (XSS, CSRF, SQL Injection)

## Performance Optimizations

- Database indexing for frequently queried fields
- Query optimization for complex searches
- Caching strategy for external API responses
- Pagination for list endpoints
- Lazy loading of images in the frontend
- Efficient list rendering in the frontend

## Validation

All code and artifacts have been validated against the FRS and development plan. The validation results are available in the `validation_results.md` file.

## Contact

For any questions or support, please contact the development team at dev@nestery.com.
