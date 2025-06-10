# Technical Stack - Current Implementation Details

## Backend Technology Stack (NestJS)

### Core Framework
- **NestJS 10.x**: Progressive Node.js framework
- **TypeScript 5.x**: Strict type checking enabled
- **Node.js 18+**: LTS runtime environment

### Database & ORM
- **PostgreSQL 15+**: Primary database
- **TypeORM 0.3.x**: Object-relational mapping
- **Database Features**:
  - JSONB columns for flexible data structures
  - UUID primary keys for security
  - Timestamp tracking with timezone support
  - Enum types for categorical data

### Authentication & Security
- **JWT (jsonwebtoken)**: Token-based authentication
- **bcrypt**: Password hashing
- **Passport.js**: Authentication middleware
- **Role-based Access Control**: Custom decorators and guards
- **Rate Limiting**: API protection

### API & Documentation
- **OpenAPI/Swagger**: Comprehensive API documentation
- **Class Validator**: Request validation
- **Class Transformer**: Data transformation
- **CORS**: Cross-origin resource sharing

### Testing & Quality
- **Jest**: Unit and integration testing
- **Supertest**: API endpoint testing
- **ESLint**: Code linting
- **Prettier**: Code formatting

## Frontend Technology Stack (Flutter)

### Core Framework
- **Flutter 3.16+**: Cross-platform UI framework
- **Dart 3.2+**: Programming language with sound null safety

### State Management
- **Riverpod 2.4+**: Reactive state management
- **AsyncNotifier**: Async state handling pattern
- **StateNotifier**: Synchronous state management
- **Provider Pattern**: Dependency injection

### Navigation & Routing
- **GoRouter 12+**: Declarative routing
- **Nested Navigation**: Shell routing for complex UIs
- **Deep Linking**: URL-based navigation support

### Data & Serialization
- **Freezed 2.4+**: Immutable data classes
- **json_serializable 6.7+**: JSON serialization
- **Either Pattern**: Functional error handling
- **Repository Pattern**: Data layer abstraction

### HTTP & API Integration
- **Dio 5.3+**: HTTP client with interceptors
- **Retrofit**: Type-safe API client generation
- **ApiClient**: Custom wrapper for authentication

### UI & Design
- **Material Design 3**: Modern design system
- **Responsive Design**: Adaptive layouts
- **Custom Themes**: Brand-consistent styling
- **Animations**: Smooth transitions and feedback

### Charts & Analytics
- **fl_chart 0.65+**: Interactive charts and graphs
- **Responsive Charts**: Adaptive chart layouts
- **Real-time Data**: Live metric updates

### Additional Packages
- **cached_network_image**: Optimized image loading
- **shimmer**: Loading state animations
- **qr_flutter**: QR code generation
- **share_plus**: Social sharing functionality
- **intl**: Internationalization support

## Development Tools & Workflow

### Code Quality
- **Dart Analyzer**: Static code analysis
- **dart format**: Code formatting
- **Custom Lint Rules**: Project-specific standards

### Testing Framework
- **flutter_test**: Widget and unit testing
- **mockito**: Mocking for tests
- **integration_test**: End-to-end testing

### Build & Deployment
- **Flutter Build**: Multi-platform compilation
- **Code Generation**: Automated code generation
- **Asset Management**: Optimized resource handling

## Architecture Patterns Implementation

### Backend Patterns
```typescript
// Clean Architecture Example
@Injectable()
export class PartnerService {
  constructor(
    @InjectRepository(PartnerEntity)
    private partnerRepository: Repository<PartnerEntity>,
  ) {}

  async getComprehensiveDashboardData(partnerId: string): Promise<DashboardData> {
    // Business logic implementation
  }
}

// Role-based Authorization
@Controller('affiliates')
@UseGuards(JwtAuthGuard)
export class AffiliateController {
  @Get('dashboard')
  @Roles('partner')
  @UseGuards(RolesGuard)
  async getDashboard(@GetPartnerId() partnerId: string) {
    // Protected endpoint implementation
  }
}
```

### Frontend Patterns
```dart
// Riverpod AsyncNotifier Pattern
class AffiliateOffersNotifier extends StateNotifier<AffiliateOffersState> {
  final AffiliateOffersRepository _repository;

  AffiliateOffersNotifier(this._repository) : super(const AffiliateOffersState.loading());

  Future<void> loadOffers() async {
    final result = await _repository.getActiveOffers();
    result.fold(
      (error) => state = AffiliateOffersState.error(message: error.message),
      (offers) => state = AffiliateOffersState.success(offers: offers),
    );
  }
}

// Repository Pattern with Either
class AffiliateOffersRepositoryImpl implements AffiliateOffersRepository {
  final ApiClient _apiClient;

  @override
  Future<Either<ApiException, List<OfferCardViewModel>>> getActiveOffers() async {
    try {
      final response = await _apiClient.get('/affiliates/offers/active');
      final offers = response.data.map((dto) => _mapDtoToViewModel(dto)).toList();
      return Either.right(offers);
    } on DioException catch (e) {
      return Either.left(ApiException.fromDioError(e));
    }
  }
}
```

## Database Schema Implementation

### Entity Relationships
```typescript
@Entity('affiliate_partners')
export class PartnerEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'enum', enum: PartnerCategoryEnum })
  category: PartnerCategoryEnum;

  @Column({ type: 'jsonb' })
  contactInfo: ContactInfo;

  @OneToMany(() => AffiliateOfferEntity, offer => offer.partner)
  offers: AffiliateOfferEntity[];
}
```

### API Integration
```dart
// Live API Integration (Confirmed)
final response = await _apiClient.get<Map<String, dynamic>>(
  '/affiliates/offers/active',
  queryParameters: queryParams,
);
```

## Performance Optimizations

### Backend Optimizations
- **Database Indexing**: Optimized query performance
- **Connection Pooling**: Efficient database connections
- **Caching Strategy**: Redis for frequently accessed data
- **Pagination**: Efficient data loading

### Frontend Optimizations
- **Lazy Loading**: On-demand widget loading
- **State Caching**: Efficient memory management
- **Image Caching**: Network image optimization
- **Build Optimization**: Tree shaking and minification

## Security Implementation

### Backend Security
- **JWT Validation**: Secure token verification
- **Input Sanitization**: SQL injection prevention
- **Rate Limiting**: API abuse protection
- **CORS Configuration**: Cross-origin security

### Frontend Security
- **Token Storage**: Secure credential management
- **API Interceptors**: Automatic authentication
- **Input Validation**: Client-side data validation
- **Error Handling**: Secure error messaging

## Testing Strategy

### Backend Testing
```typescript
describe('AffiliateController', () => {
  it('should return dashboard data for authenticated partner', async () => {
    const result = await controller.getDashboard('partner-id');
    expect(result).toBeDefined();
  });
});
```

### Frontend Testing
```dart
testWidgets('AffiliateOffersBrowserScreen displays offers', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: AffiliateOffersBrowserScreen()),
    ),
  );
  expect(find.byType(OfferCardWidget), findsWidgets);
});
```

## Development Environment

### Backend Setup
- **Docker**: Containerized development
- **PostgreSQL**: Local database instance
- **Environment Variables**: Configuration management
- **Hot Reload**: Development efficiency

### Frontend Setup
- **Flutter SDK**: Development framework
- **VS Code**: IDE with Flutter extensions
- **Device Testing**: Multiple platform testing
- **Hot Reload**: Instant development feedback

## Deployment Configuration

### Backend Deployment
- **Docker Containers**: Production deployment
- **Environment Configuration**: Secure credential management
- **Health Checks**: Application monitoring
- **Logging**: Comprehensive error tracking

### Frontend Deployment
- **Web Build**: Progressive web application
- **Mobile Build**: iOS and Android applications
- **Asset Optimization**: Performance optimization
- **Version Management**: Release tracking

This technical stack provides a robust foundation for the affiliate marketing system with enterprise-grade quality, performance, and scalability.