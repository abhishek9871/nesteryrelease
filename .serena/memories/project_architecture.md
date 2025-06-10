# Nestery Project Architecture - Current Implementation

## Project Overview
**Nestery** is a comprehensive travel platform with an integrated affiliate marketing system. The project consists of a NestJS backend API and Flutter frontend application, implementing enterprise-grade affiliate management capabilities.

## Technology Stack

### Backend (NestJS)
- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with role-based access control
- **API Documentation**: OpenAPI/Swagger
- **Testing**: Jest with comprehensive unit tests
- **Architecture**: Clean Architecture with Domain-Driven Design

### Frontend (Flutter)
- **Framework**: Flutter with Dart
- **State Management**: Riverpod with AsyncNotifier pattern
- **Navigation**: GoRouter with nested routing
- **UI Framework**: Material Design 3
- **Data Layer**: Repository pattern with Either for error handling
- **Serialization**: Freezed and json_serializable

## Current Implementation Status

### ✅ COMPLETED: Core Affiliate System (Tasks 1-3)

#### Backend Affiliate Module (`nestery-backend/src/affiliates/`)
- **Entities**: Partner, AffiliateOffer, AffiliateLink, AffiliateEarning, AuditLog
- **Services**: Partner, AffiliateOffer, TrackableLink, CommissionCalculation
- **Controllers**: Complete REST API with OpenAPI documentation
- **Security**: Role-based access with partner/admin roles
- **Features**: Link tracking, commission calculation, fraud detection

#### Frontend Partner Dashboard (`nestery-flutter/lib/features/partner_dashboard/`)
- **Screens**: Dashboard overview, offer management, link generation, earnings reports
- **State Management**: Riverpod providers for all data flows
- **UI Components**: Responsive design with fl_chart analytics
- **Features**: Comprehensive partner self-service portal

#### Frontend User Interface (`nestery-flutter/lib/features/affiliate_offers_browser/`)
- **Screens**: Offer browser, offer details, link generation
- **API Integration**: Live backend integration (confirmed)
- **Features**: Offer filtering, search, QR code generation, social sharing
- **State Management**: Complete Riverpod implementation

## Architecture Patterns

### Backend Patterns
- **Clean Architecture**: Clear separation of concerns
- **Domain-Driven Design**: Business logic encapsulation
- **Repository Pattern**: Data access abstraction
- **Decorator Pattern**: Authentication and authorization
- **Strategy Pattern**: Commission calculation strategies

### Frontend Patterns
- **Repository Pattern**: Data layer abstraction
- **Provider Pattern**: State management with Riverpod
- **Either Pattern**: Functional error handling
- **DTO Pattern**: Data transfer with Freezed
- **Observer Pattern**: Reactive UI updates

## Database Schema

### Core Entities
- **Users**: Authentication and role management
- **Partners**: Affiliate partner information
- **AffiliateOffers**: Commission-based offers
- **AffiliateLinks**: Trackable URLs with analytics
- **AffiliateEarnings**: Commission records
- **AuditLogs**: Complete transaction history

### Relationships
- Users → Partners (one-to-one with partner role)
- Partners → AffiliateOffers (one-to-many)
- AffiliateOffers → AffiliateLinks (one-to-many)
- Partners → AffiliateEarnings (one-to-many)

## API Architecture

### Authentication Flow
1. JWT token-based authentication
2. Role-based access control (admin, partner, user)
3. Partner ID extraction from JWT claims
4. Endpoint-level authorization decorators

### Affiliate API Endpoints
- **Partner Management**: Registration, profile, dashboard
- **Offer Management**: CRUD operations with validation
- **Link Generation**: Trackable URLs with fraud detection
- **Analytics**: Performance metrics and reporting

## Frontend Architecture

### State Management Flow
1. **UI Layer**: Screens and widgets
2. **Presentation Layer**: Riverpod providers and state notifiers
3. **Domain Layer**: Entities and use cases
4. **Data Layer**: Repositories and API clients

### Navigation Structure
- **Shell Routing**: Nested navigation with GoRouter
- **Feature-based**: Modular organization by business domain
- **Deep Linking**: Support for direct navigation to specific screens

## Quality Standards

### Code Quality
- **TypeScript**: Strict type checking
- **Dart**: Sound null safety
- **Linting**: ESLint for backend, Dart analyzer for frontend
- **Formatting**: Prettier for backend, dart format for frontend

### Testing Strategy
- **Unit Tests**: Business logic and services
- **Integration Tests**: API endpoints and data flows
- **Widget Tests**: UI components and interactions
- **E2E Tests**: Complete user workflows

## Development Workflow

### NSI 3.0 MCP-Enhanced Process
- **Context Loading**: Automatic project knowledge retrieval
- **Pattern Recognition**: Reuse of established implementations
- **Real-time Validation**: Architectural compliance checking
- **Quality Assurance**: Enterprise-grade standards maintenance

### MCP Server Integration
- **Serena MCP**: Code analysis and project memories
- **Vector Search MCP**: Semantic knowledge storage and retrieval
- **File System MCP**: Direct project file access
- **Task Master MCP**: Project planning and task management

## Security Implementation

### Authentication & Authorization
- **JWT Tokens**: Secure authentication with refresh tokens
- **Role-based Access**: Granular permission control
- **API Security**: Rate limiting and input validation
- **Data Protection**: Encrypted sensitive information

### Affiliate Security
- **Link Validation**: Fraud detection and prevention
- **Commission Verification**: Audit trail for all transactions
- **Partner Verification**: Identity validation for payouts

## Performance Considerations

### Backend Optimization
- **Database Indexing**: Optimized queries for analytics
- **Caching Strategy**: Redis for frequently accessed data
- **API Pagination**: Efficient data loading
- **Background Jobs**: Asynchronous processing

### Frontend Optimization
- **Lazy Loading**: On-demand screen loading
- **State Caching**: Efficient data management
- **Image Optimization**: Cached network images
- **Responsive Design**: Adaptive layouts for all devices

## Deployment Architecture

### Infrastructure
- **Backend**: Containerized NestJS application
- **Database**: PostgreSQL with connection pooling
- **Frontend**: Flutter web and mobile applications
- **CDN**: Static asset delivery optimization

### CI/CD Pipeline
- **Testing**: Automated test execution
- **Building**: Multi-platform builds
- **Deployment**: Staged rollout process
- **Monitoring**: Application performance tracking

## Future Scalability

### Horizontal Scaling
- **Microservices**: Domain-based service separation
- **Load Balancing**: Traffic distribution
- **Database Sharding**: Data partitioning strategies
- **Caching Layers**: Multi-level caching implementation

### Feature Expansion
- **Advanced Analytics**: Machine learning integration
- **Multi-currency**: International market support
- **API Ecosystem**: Third-party integrations
- **Mobile Apps**: Native iOS and Android applications

This architecture provides a solid foundation for the affiliate marketing system while maintaining flexibility for future enhancements and scalability requirements.