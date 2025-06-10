# Nesteryrelease Project Architecture

## Project Structure
- **Backend**: NestJS TypeScript application (`nestery-backend/`)
- **Frontend**: Flutter mobile application (`nestery-flutter/`)
- **Documentation**: API docs and implementation guides (`Docs/`)

## Backend Architecture (NestJS)
- **Modular Design**: Feature-based modules (auth, users, properties, bookings, affiliates)
- **Database**: TypeORM with entity-based data modeling
- **API**: RESTful endpoints with OpenAPI documentation
- **Security**: JWT authentication with role-based access control

## Key Modules
- **Auth**: Authentication and authorization
- **Users**: User management and profiles
- **Properties**: Property listings and management
- **Bookings**: Reservation system
- **Affiliates**: Partner program with commission tracking
- **Features**: Loyalty, recommendations, social sharing, price prediction
- **Integrations**: External APIs (Booking.com, OYO, Google Maps)

## Technology Stack
- **Backend**: NestJS, TypeScript, TypeORM, JWT, bcrypt
- **Frontend**: Flutter, Dart
- **Database**: PostgreSQL (inferred from TypeORM usage)
- **Documentation**: OpenAPI/Swagger