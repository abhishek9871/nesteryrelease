# Authentication System Overview

## Core Components
- **AuthService**: Handles user registration, login, token generation, and validation
- **JwtAuthGuard**: Protects routes using JWT tokens with public route bypass
- **JwtStrategy**: Passport strategy for JWT token validation
- **RolesGuard**: Role-based access control (admin, partner, host, user)

## Key Functions
- `login()`: Email/password authentication with bcrypt validation
- `register()`: User registration with password hashing
- `generateTokens()`: Creates access/refresh tokens with partner support
- `validateUser()`: JWT payload validation
- `refreshToken()`: Token refresh functionality

## Security Features
- bcrypt password hashing with salt
- JWT access and refresh tokens
- Role-based authorization
- Public route decorator for bypassing auth
- Partner-specific token payload enhancement

## Usage Across Application
Authentication is used by 25+ controllers including Users, Bookings, Properties, Affiliates, Loyalty, Social Sharing, Recommendations, and Integrations.