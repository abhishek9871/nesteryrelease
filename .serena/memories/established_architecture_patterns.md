# Established Architecture Patterns

## Backend Patterns (NestJS)
- **Authentication**: JWT with Passport.js strategies, role-based guards (@Roles decorator)
- **API Structure**: /v1 versioning, OpenAPI/Swagger documentation with @ApiTags
- **Database**: TypeORM with PostgreSQL, UUID primary keys, proper relationships
- **Error Handling**: Comprehensive exception handling with proper HTTP status codes
- **Testing**: Unit tests for all services with Jest framework
- **Validation**: Class-validator for DTOs with proper decorators
- **Modules**: Proper dependency injection and module organization
- **Guards**: JWT authentication guards with @Public decorator support

## Frontend Patterns (Flutter)
- **State Management**: Riverpod with StateNotifier and AsyncNotifier patterns
- **Error Handling**: Either<ApiException, T> pattern for all API operations
- **API Integration**: Repository pattern with Dio HTTP client and interceptors
- **UI Components**: Material Design 3 with consistent theming
- **Navigation**: GoRouter for type-safe routing
- **Data Models**: Freezed for immutable state classes and DTOs
- **Code Generation**: json_serializable for JSON serialization
- **Loading States**: Proper loading, success, error state management

## Integration Patterns
- **API Communication**: RESTful APIs with proper error handling
- **Authentication Flow**: JWT tokens with refresh mechanism
- **Data Flow**: Repository → Provider → UI pattern consistently applied
- **Testing Strategy**: Unit tests for business logic, widget tests for UI
- **File Organization**: Clean architecture with proper separation of concerns

## Quality Standards
- **Code Quality**: Flutter analyze with zero errors/warnings
- **Pattern Compliance**: 100% adherence to established patterns
- **Documentation**: Comprehensive inline documentation and README files
- **Performance**: Optimized for mobile with proper caching strategies