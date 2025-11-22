# CLAUDE.md - AI Assistant Guide for Nestery Codebase

> **Last Updated:** 2025-11-22
> **Repository:** abhishek9871/nesteryrelease
> **Project:** Nestery - Hotel Booking Platform

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Technology Stack](#technology-stack)
4. [Development Workflows](#development-workflows)
5. [Architecture Patterns](#architecture-patterns)
6. [Coding Conventions](#coding-conventions)
7. [Testing Guidelines](#testing-guidelines)
8. [Git Practices](#git-practices)
9. [Key Implementation Details](#key-implementation-details)
10. [FRS Compliance Tracking](#frs-compliance-tracking)
11. [Common Pitfalls](#common-pitfalls)
12. [AI Assistant Best Practices](#ai-assistant-best-practices)

---

## Project Overview

Nestery is a comprehensive hotel booking platform that integrates with multiple external APIs (Booking.com, OYO, Google Maps) to provide users with a wide selection of accommodations. The application features a Flutter mobile client and a NestJS backend.

### Key Features
- **User Authentication:** JWT-based auth with role-based access control
- **Property Search:** Advanced search with filters for location, dates, price, and amenities
- **External API Integration:** Seamless integration with Booking.com, OYO, and Google Maps
- **Booking Management:** Complete booking flow with confirmation and history
- **Loyalty Program:** Points/miles system with tiered membership (Scout, Explorer, Navigator, Globetrotter)
- **Price Prediction:** AI-powered price trend analysis
- **Personalized Recommendations:** Custom property suggestions based on user preferences
- **Social Sharing:** Property sharing and referral program
- **Caching Strategy:** Redis server-side + Drift/SQLite client-side caching

### Business Model
The platform operates on multiple revenue streams:
- API commission structure (15-25% from Booking.com, OYO)
- Freemium subscription model (Premium tier at ₹999/month or ₹9,999/year)
- Advertising revenue (Google AdMob integration)
- Ancillary affiliate marketing (tours, activities, restaurants, transportation)

---

## Repository Structure

```
nesteryrelease/
├── nestery-backend/              # NestJS backend (TypeScript)
│   ├── src/
│   │   ├── auth/                 # Authentication & JWT strategies
│   │   ├── users/                # User management
│   │   ├── properties/           # Property listings & search
│   │   ├── bookings/             # Booking management
│   │   ├── integrations/         # External API integrations
│   │   │   ├── booking-com/      # Booking.com API integration
│   │   │   ├── oyo/              # OYO API integration
│   │   │   └── google-maps/      # Google Maps integration
│   │   ├── features/             # Advanced features
│   │   │   ├── loyalty/          # Loyalty program (miles/points)
│   │   │   ├── price-prediction/ # ML price prediction
│   │   │   ├── recommendation/   # AI recommendations
│   │   │   ├── social-sharing/   # Social sharing & referrals
│   │   │   ├── referrals/        # Referral system
│   │   │   ├── reviews/          # User reviews
│   │   │   ├── subscriptions/    # Premium subscriptions
│   │   │   └── itineraries/      # AI Trip Weaver
│   │   ├── core/                 # Cross-cutting concerns
│   │   │   ├── logger/           # Logging service
│   │   │   ├── exception/        # Exception handling
│   │   │   ├── security/         # Security utilities
│   │   │   └── utils/            # Utility services
│   │   ├── config/               # Configuration & validation
│   │   ├── migrations/           # TypeORM database migrations
│   │   └── main.ts               # Application bootstrap
│   ├── test/                     # E2E tests
│   ├── package.json              # Dependencies & scripts
│   ├── tsconfig.json             # TypeScript configuration
│   ├── .eslintrc.json            # ESLint rules
│   ├── .prettierrc               # Prettier formatting
│   ├── docker-compose.yml        # Docker orchestration
│   └── Dockerfile                # Multi-stage Docker build
│
├── nestery-flutter/              # Flutter mobile client (Dart)
│   ├── lib/
│   │   ├── main.dart             # App entry point with Riverpod
│   │   ├── core/                 # Core functionality
│   │   │   ├── db/               # Drift/SQLite caching database
│   │   │   └── network/          # API client (Dio)
│   │   ├── data/                 # Data layer
│   │   │   └── repositories/     # API repositories
│   │   ├── models/               # Data models & DTOs
│   │   ├── providers/            # Riverpod state management
│   │   ├── screens/              # UI screens
│   │   ├── widgets/              # Reusable UI components
│   │   ├── services/             # Business logic services
│   │   └── utils/                # Constants & utilities
│   ├── test/                     # Unit & widget tests
│   ├── pubspec.yaml              # Dependencies
│   ├── analysis_options.yaml     # Dart linter rules
│   └── assets/                   # Images & icons
│
├── ARCHITECTURE.md               # System architecture docs
├── DATA_DICTIONARY.md            # Database schema docs
├── DEPLOYMENT_GUIDE.md           # Deployment instructions
├── USER_JOURNEY_FEATURE_MAP.md   # Feature to user journey mapping
├── Final_Consolidated_Nestery_FRS.md  # Functional Requirements Specification
├── Nestery_FRS_Compliance_Implementation.md  # Compliance tracking
└── ultra_detailed_mapping.md     # Detailed FRS compliance mapping
```

---

## Technology Stack

### Backend (NestJS)
| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | NestJS | 11.x | TypeScript-based Node.js framework |
| **Runtime** | Node.js | 20-alpine | JavaScript runtime |
| **Language** | TypeScript | 4.9.5 | Type-safe JavaScript |
| **Database** | PostgreSQL | 14 | Primary relational database |
| **ORM** | TypeORM | 0.3.19 | Database abstraction layer |
| **Cache** | Redis | 4.x | Server-side caching (via Keyv) |
| **Authentication** | JWT + Passport | - | Token-based auth |
| **Password Hashing** | bcrypt | 5.1.1 | Secure password storage |
| **API Docs** | Swagger/OpenAPI | - | API documentation |
| **Testing** | Jest | 29.7.0 | Unit & E2E testing |
| **HTTP Client** | Axios | 1.9.0 | External API calls |
| **Containerization** | Docker | - | Application containerization |
| **Web Server** | Nginx | - | Reverse proxy (production) |

### Frontend (Flutter)
| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | Flutter | 3.0+ | Cross-platform mobile framework |
| **Language** | Dart | 3.0+ | Programming language |
| **State Management** | Riverpod | 2.4.9 | Provider-based state management |
| **HTTP Client** | Dio | 5.4.0 | REST API communication |
| **Local Database** | Drift | 2.15.0 | Type-safe SQLite ORM |
| **Cache Storage** | http_cache_drift_store | 7.0.0 | HTTP response caching |
| **Secure Storage** | flutter_secure_storage | 9.0.0 | JWT token storage |
| **Navigation** | GoRouter | 15.1.2 | Declarative routing |
| **Maps** | google_maps_flutter | 2.5.3 | Maps integration |
| **Payments** | flutter_stripe | 9.5.0 | Payment processing |
| **Analytics** | Firebase | - | Crashlytics & Analytics |
| **Testing** | flutter_test + mockito | - | Unit & widget testing |
| **Fonts** | google_fonts | 6.1.0 | Poppins typography |

---

## Development Workflows

### Backend Development

#### Setup
```bash
cd nestery-backend
cp .env.example .env          # Configure environment variables
npm install                   # Install dependencies
npm run migration:run         # Run database migrations
npm run start:dev             # Start development server (port 3000)
```

#### Common Commands
```bash
npm run start:dev             # Hot-reload development server
npm run build                 # Build for production
npm run start:prod            # Run production build
npm run test                  # Run unit tests
npm run test:e2e              # Run E2E tests
npm run test:cov              # Generate coverage report
npm run lint                  # Lint code
npm run format                # Format code with Prettier
npm run migration:generate    # Generate migration from entity changes
npm run migration:run         # Apply pending migrations
npm run migration:revert      # Rollback last migration
```

#### API Endpoints
- **Base URL:** `http://localhost:3000/v1`
- **Swagger Docs:** `http://localhost:3000/v1/docs`
- **Health Check:** `http://localhost:3000/health`

#### Environment Variables (Critical)
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=nestery

# Authentication
JWT_SECRET=your-secret-key
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d

# External APIs
BOOKING_COM_API_KEY=xxx
BOOKING_COM_API_SECRET=xxx
OYO_API_KEY=xxx
OYO_API_SECRET=xxx
GOOGLE_MAPS_API_KEY=xxx

# Caching
CACHE_HOST=localhost
CACHE_PORT=6379
CACHE_TTL_DEFAULT_SECONDS=3600

# Application
NODE_ENV=development
PORT=3000
API_PREFIX=v1
FRONTEND_URL=http://localhost:3000
```

### Flutter Development

#### Setup
```bash
cd nestery-flutter
cp .env.example .env          # Configure environment variables
flutter pub get               # Install dependencies
flutter pub run build_runner build  # Generate Drift database code
flutter run                   # Run app (select device)
```

#### Common Commands
```bash
flutter run                   # Run on connected device
flutter test                  # Run all tests
flutter analyze               # Analyze code for issues
flutter build apk --release   # Build Android APK
flutter build ios --release   # Build iOS app
flutter pub get               # Get dependencies
flutter pub run build_runner build  # Generate code (Drift)
flutter clean                 # Clean build artifacts
```

#### Environment Variables (Critical)
```env
API_BASE_URL=http://localhost:3000/v1
GOOGLE_MAPS_API_KEY=xxx
STRIPE_PUBLISHABLE_KEY=xxx
ENABLE_ANALYTICS=true
```

---

## Architecture Patterns

### Backend Architecture (NestJS)

#### Module-Based Organization
- **Feature Modules:** Each domain feature (auth, users, properties, bookings, integrations, loyalty, etc.) is encapsulated in its own module
- **Dependency Injection:** NestJS's IoC container manages dependencies via `@Injectable()` and constructor injection
- **Separation of Concerns:** Controller → Service → Repository pattern

#### Key Patterns

**1. Repository Pattern**
```typescript
@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    private readonly logger: LoggerService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {
    this.logger.setContext('PropertiesService');
  }
}
```

**2. Guards & Decorators**
```typescript
// Route protection
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Get('admin-only')
adminEndpoint() { }

// Public routes
@Public()
@Post('login')
login() { }
```

**3. Exception Handling**
```typescript
try {
  // Business logic
} catch (error) {
  this.exceptionService.handleException(error);
  throw error;
}
```

**4. Event-Driven Architecture**
```typescript
// Emit events
this.eventEmitter.emit('booking.created', { bookingId, userId });

// Listen to events
@OnEvent('booking.created')
handleBookingCreated(payload: BookingCreatedEvent) {
  // Award loyalty points
}
```

**5. Caching Strategy**
- **Server-side:** Redis with Keyv store (in-memory fallback)
- **TTL-based expiration:** Configurable per endpoint
- **Cache invalidation:** On data mutations

### Frontend Architecture (Flutter)

#### State Management with Riverpod

**1. Provider Pattern**
```dart
// Repository provider (singleton)
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyRepository(apiClient: apiClient);
});

// State provider
final propertySearchProvider =
  StateNotifierProvider<PropertySearchNotifier, PropertySearchState>((ref) {
    final repository = ref.watch(propertyRepositoryProvider);
    return PropertySearchNotifier(propertyRepository: repository);
  });
```

**2. StateNotifier for Mutable State**
```dart
class PropertySearchState {
  final List<Property> properties;
  final bool isLoading;
  final String? error;

  PropertySearchState copyWith({...}) => PropertySearchState(...);
}

class PropertySearchNotifier extends StateNotifier<PropertySearchState> {
  Future<void> searchProperties(SearchPropertiesDto dto) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.searchProperties(dto);
    result.fold(
      (error) => state = state.copyWith(error: error.message),
      (properties) => state = state.copyWith(properties: properties),
    );
  }
}
```

**3. Either Pattern for Error Handling**
```dart
// Repository returns Either<Error, Success>
Future<Either<ApiException, List<Property>>> searchProperties(dto) async {
  try {
    final response = await _apiClient.get(...);
    return Either.right(properties);
  } on DioException catch (e) {
    return Either.left(ApiException.fromDioError(e));
  }
}

// Consumer handles both cases
result.fold(
  (error) => showError(error),
  (data) => showData(data),
);
```

**4. Caching Strategy**
- **Client-side:** Drift/SQLite database for offline-first approach
- **HTTP caching:** Dio cache interceptor with drift store
- **TTL:** 1 hour default, 30 minutes for property lists, 1 day for user profiles
- **Connectivity-aware:** Force cache usage when offline

---

## Coding Conventions

### Backend (TypeScript)

#### File Naming
- **Controllers:** `*.controller.ts` (e.g., `users.controller.ts`)
- **Services:** `*.service.ts` (e.g., `users.service.ts`)
- **Modules:** `*.module.ts` (e.g., `users.module.ts`)
- **DTOs:** `*.dto.ts` (e.g., `create-user.dto.ts`)
- **Entities:** `*.entity.ts` (e.g., `user.entity.ts`)
- **Tests:** `*.spec.ts` (e.g., `users.service.spec.ts`)
- **E2E Tests:** `*.e2e-spec.ts` (e.g., `app.e2e-spec.ts`)

#### Code Style
- **Line Width:** 100 characters (Prettier)
- **Indentation:** 2 spaces
- **Quotes:** Single quotes for strings
- **Semicolons:** Required
- **Trailing Commas:** All (es5 compatible)

#### Naming Conventions
```typescript
// Classes: PascalCase
class UsersService {}
class CreateUserDto {}

// Interfaces: PascalCase with 'I' prefix (optional)
interface User {}
interface AuthenticatedRequest {}

// Methods: camelCase
async findUserById(id: string) {}

// Constants: SCREAMING_SNAKE_CASE
const JWT_SECRET = process.env.JWT_SECRET;

// Private members: prefix with underscore (optional)
private readonly _logger: LoggerService;
```

#### TypeScript Path Aliases
```typescript
import { AuthService } from '@auth/auth.service';
import { User } from '@users/entities/user.entity';
import { LoggerService } from '@core/logger/logger.service';
```

#### Service Pattern
```typescript
@Injectable()
export class ExampleService {
  constructor(
    @InjectRepository(Entity)
    private readonly repository: Repository<Entity>,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('ExampleService');
  }

  async findAll(): Promise<Entity[]> {
    try {
      this.logger.log('Fetching all entities');
      return await this.repository.find();
    } catch (error) {
      this.logger.error(`Error fetching entities: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }
}
```

#### Controller Pattern
```typescript
@ApiTags('entities')
@Controller('entities')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class EntitiesController {
  constructor(private readonly service: EntitiesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all entities' })
  @ApiResponse({ status: 200, description: 'Success', type: [EntityDto] })
  async findAll(): Promise<EntityDto[]> {
    return this.service.findAll();
  }

  @Post()
  @ApiOperation({ summary: 'Create entity' })
  @ApiResponse({ status: 201, description: 'Created', type: EntityDto })
  async create(@Body() dto: CreateEntityDto): Promise<EntityDto> {
    return this.service.create(dto);
  }
}
```

#### DTO Validation
```typescript
import { IsString, IsEmail, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'john.doe@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'Password123!', minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
  password: string;
}
```

### Frontend (Dart/Flutter)

#### File Naming
- **All files:** `snake_case.dart`
- **Screens:** `*_screen.dart` (e.g., `login_screen.dart`)
- **Widgets:** `*_widget.dart` or descriptive name (e.g., `property_card.dart`)
- **Providers:** `*_provider.dart` (e.g., `auth_provider.dart`)
- **Repositories:** `*_repository.dart` (e.g., `auth_repository.dart`)
- **Models:** Descriptive name (e.g., `user.dart`, `booking.dart`)
- **Tests:** `*_test.dart` (e.g., `login_screen_test.dart`)

#### Code Style
- **Line Width:** 80 characters (Dart default)
- **Indentation:** 2 spaces
- **Trailing Commas:** Always use for multi-line function calls/lists

#### Naming Conventions
```dart
// Classes: PascalCase
class LoginScreen extends StatelessWidget {}
class AuthProvider extends StateNotifier {}

// Files: snake_case
// login_screen.dart, auth_provider.dart

// Methods/Variables: camelCase
Future<void> loginUser() {}
final String userName = 'John';

// Constants: lowerCamelCase for private, SCREAMING_SNAKE_CASE for global
const String _apiBaseUrl = 'https://api.example.com';
const int MAX_RETRY_ATTEMPTS = 3;

// Private members: prefix with underscore
final ApiClient _apiClient;
String _accessToken;
```

#### Widget Pattern
```dart
class PropertyCard extends ConsumerWidget {
  final Property property;

  const PropertyCard({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(property.name),
        subtitle: Text(property.location),
        trailing: Text('\$${property.price}'),
      ),
    );
  }
}
```

#### Provider Pattern
```dart
// State class
@immutable
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(
      LoginDto(email: email, password: password),
    );

    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
```

---

## Testing Guidelines

### Backend Testing (Jest)

#### Unit Tests
- **Location:** Alongside source files (`*.spec.ts`)
- **Naming:** `<module>.service.spec.ts`, `<module>.controller.spec.ts`
- **Pattern:** AAA (Arrange, Act, Assert)

**Example:**
```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repository: Repository<User>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            find: jest.fn(),
            findOne: jest.fn(),
            save: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  it('should find all users', async () => {
    const mockUsers = [{ id: '1', email: 'test@example.com' }];
    jest.spyOn(repository, 'find').mockResolvedValue(mockUsers);

    const result = await service.findAll();

    expect(result).toEqual(mockUsers);
    expect(repository.find).toHaveBeenCalled();
  });
});
```

#### E2E Tests
- **Location:** `/test` directory (`*.e2e-spec.ts`)
- **Uses:** Supertest for HTTP testing
- **Pattern:** Test full request/response cycle

**Example:**
```typescript
describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/auth/login (POST)', () => {
    return request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'test@example.com', password: 'password123' })
      .expect(200)
      .expect((res) => {
        expect(res.body).toHaveProperty('accessToken');
      });
  });

  afterAll(async () => {
    await app.close();
  });
});
```

#### Running Tests
```bash
npm test                # Run all unit tests
npm run test:watch      # Watch mode
npm run test:cov        # With coverage
npm run test:e2e        # Run E2E tests
```

### Flutter Testing (flutter_test + mockito)

#### Unit Tests
- **Location:** `/test` directory (`*_test.dart`)
- **Naming:** `<feature>_test.dart`
- **Pattern:** AAA (Arrange, Act, Assert)

**Example:**
```dart
void main() {
  group('AuthNotifier', () {
    late AuthNotifier authNotifier;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authNotifier = AuthNotifier(authRepository: mockAuthRepository);
    });

    test('login success updates state with user', () async {
      // Arrange
      final user = User(id: '1', email: 'test@example.com');
      when(mockAuthRepository.login(any))
          .thenAnswer((_) async => Either.right(user));

      // Act
      await authNotifier.login('test@example.com', 'password123');

      // Assert
      expect(authNotifier.state.user, equals(user));
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.error, isNull);
    });
  });
}
```

#### Widget Tests
```dart
void main() {
  testWidgets('LoginScreen displays email and password fields', (tester) async {
    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Find widgets
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
```

#### Running Tests
```bash
flutter test                 # Run all tests
flutter test --coverage      # With coverage
flutter test test/auth_provider_test.dart  # Specific test
```

---

## Git Practices

### Branching Strategy
- **Main Branch:** `main` (production-ready code)
- **Feature Branches:** `claude/claude-md-<session-id>-<unique-id>`
  - Example: `claude/claude-md-miaesbaroz6i8f0b-01MXGfwwPixEaw7PQqgqXcx4`
- **CRITICAL:** Always push to branches starting with `claude/` and ending with matching session ID

### Commit Message Convention
Follow conventional commit format:
```
<type>(<scope>): <short summary>

<optional body>

<optional footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Build/tooling changes
- `perf`: Performance improvements

**Examples:**
```bash
feat(auth): implement JWT refresh token mechanism
fix(booking): resolve Booking.com API booking creation failure
docs: update FRS compliance tracking - Task 1.5 completed
refactor(cache): migrate from in-memory to Redis caching
test(loyalty): add unit tests for points calculation
```

### Commit Workflow
```bash
# Check status
git status

# Stage changes
git add <files>

# Commit with descriptive message
git commit -m "feat(loyalty): implement tier progression logic"

# Push to feature branch with retry logic
git push -u origin claude/claude-md-miaesbaroz6i8f0b-01MXGfwwPixEaw7PQqgqXcx4
```

### Important Git Rules
1. **NEVER** update git config without explicit permission
2. **NEVER** run destructive commands (`push --force`, `hard reset`) without explicit request
3. **NEVER** skip hooks (`--no-verify`, `--no-gpg-sign`)
4. **NEVER** force push to main/master
5. **ALWAYS** use `git push -u origin <branch-name>`
6. **RETRY** network failures up to 4 times with exponential backoff (2s, 4s, 8s, 16s)
7. **ONLY** commit when explicitly requested by the user

---

## Key Implementation Details

### Backend Critical Details

#### Authentication Flow
1. User submits credentials to `/v1/auth/login`
2. Backend validates credentials with bcrypt
3. JWT access token (15m) and refresh token (7d) generated
4. Tokens returned to client
5. Client includes access token in `Authorization: Bearer <token>` header
6. When access token expires, client uses `/v1/auth/refresh` with refresh token

#### Booking Flow (IMPORTANT)
- **Booking.com bookings:** Redirect to Booking.com for payment (not handled internally)
- **OYO bookings:** Redirect to OYO for payment
- **Internal properties:** Stripe payment processing
- After successful payment, booking record created in database
- Loyalty points awarded via event emission (`booking.created` event)

#### Loyalty Program Tiers (FRS Compliant)
| Tier | Name | Requirements | Benefits |
|------|------|--------------|----------|
| 1 | Scout | 0-10,000 miles | 5% off bookings, priority support |
| 2 | Explorer | 10,001-50,000 miles | 10% off bookings, free cancellation |
| 3 | Navigator | 50,001-100,000 miles | 15% off bookings, lounge access |
| 4 | Globetrotter | 100,001+ miles | 20% off bookings, concierge service |

**Earning Miles:**
- 1 mile per ₹100 spent
- Bonus miles on first booking (500 miles)
- Referral bonus (1,000 miles)

#### Caching TTL Configuration
- Property lists: 30 minutes
- User profiles: 1 day
- Search results: 1 hour
- Static content: 24 hours

#### Database Indexing
```sql
-- Critical indexes for performance
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_loyalty_transactions_user_id ON loyalty_transactions(user_id);
```

### Flutter Critical Details

#### API Client Configuration
```dart
// Base URL from environment
final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/v1';

// Dio interceptors
- AuthInterceptor: Adds Bearer token automatically
- CacheInterceptor: Caches responses with Drift store
- LoggingInterceptor: Logs requests/responses (dev only)
- ErrorInterceptor: Transforms DioException to ApiException
```

#### Secure Token Storage
```dart
// Using flutter_secure_storage
await _secureStorage.write(key: 'accessToken', value: token);
final token = await _secureStorage.read(key: 'accessToken');
await _secureStorage.delete(key: 'accessToken');
```

#### Offline-First Approach
1. App attempts API call
2. If network available, fetch from API and cache response
3. If network unavailable, serve from cache
4. Display indicator to user when offline

#### Navigation Setup (GoRouter)
```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    // ... more routes
  ],
  redirect: (context, state) {
    final isAuthenticated = ref.read(authProvider).user != null;
    if (!isAuthenticated && state.location != '/login') {
      return '/login';
    }
    return null;
  },
);
```

---

## FRS Compliance Tracking

**Overall Compliance Status:** ~70% (as of latest commits)

### Completed (Phase 1)
- ✅ **Task 1.4:** Server-side Redis caching with Keyv store (FRS 2.2)
- ✅ **Task 1.5:** Client-side API caching with Drift/sqflite (FRS 2.2)
- ✅ **Database Schema:** 100% FRS compliant (all entities defined)
- ✅ **API Versioning:** All endpoints use `/v1` prefix
- ✅ **Loyalty Program:** Tiers corrected to Scout/Explorer/Navigator/Globetrotter

### In Progress
- 🔄 **Booking.com Integration:** Booking creation endpoint functional but needs testing
- 🔄 **Price Prediction:** Basic ML logic implemented, needs refinement
- 🔄 **AI Recommendations:** Personalization logic exists but needs AI enhancement

### Pending (High Priority)
- ❌ **Google AdMob Integration:** Required for advertising revenue (FRS 1.5)
- ❌ **Ancillary Affiliate Marketing:** Tours, activities, restaurants, transportation (FRS 1.3)
- ❌ **Gamification:** Badges, streaks, challenges completely missing (FRS 3.2)
- ❌ **AI Trip Weaver:** Currently lacks actual AI logic (FRS 4.1)

### Reference Documents
- **FRS:** `Final_Consolidated_Nestery_FRS.md`
- **Compliance Tracking:** `Nestery_FRS_Compliance_Implementation.md`
- **Detailed Mapping:** `ultra_detailed_mapping.md`

**When working on features, ALWAYS cross-reference these documents to ensure FRS compliance.**

---

## Common Pitfalls

### Backend Pitfalls

1. **Missing Authentication Guard**
   ```typescript
   // ❌ WRONG: Public endpoint without @Public decorator
   @Get('sensitive-data')
   getSensitiveData() {}

   // ✅ CORRECT: Either use @Public or ensure JwtAuthGuard is active
   @Public()
   @Get('public-data')
   getPublicData() {}
   ```

2. **Not Using Exception Service**
   ```typescript
   // ❌ WRONG: Throwing raw exceptions
   throw new Error('Something went wrong');

   // ✅ CORRECT: Use ExceptionService for consistent error handling
   this.exceptionService.handleException(error);
   ```

3. **Missing Logger Context**
   ```typescript
   // ❌ WRONG: No context set
   this.logger.log('User created');

   // ✅ CORRECT: Set context in constructor
   constructor(private readonly logger: LoggerService) {
     this.logger.setContext('UsersService');
   }
   ```

4. **Not Invalidating Cache on Mutations**
   ```typescript
   // ❌ WRONG: Update data without cache invalidation
   async updateProperty(id: string, dto: UpdatePropertyDto) {
     return this.repository.save({ id, ...dto });
   }

   // ✅ CORRECT: Clear cache after mutation
   async updateProperty(id: string, dto: UpdatePropertyDto) {
     const result = await this.repository.save({ id, ...dto });
     await this.cacheManager.del(`property:${id}`);
     return result;
   }
   ```

5. **Hardcoding API Versions**
   ```typescript
   // ❌ WRONG: No version prefix
   @Controller('users')

   // ✅ CORRECT: Version handled by global prefix in main.ts
   @Controller('users') // Becomes /v1/users via app.setGlobalPrefix('v1')
   ```

### Flutter Pitfalls

1. **Not Handling Loading States**
   ```dart
   // ❌ WRONG: No loading indicator
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     final properties = ref.watch(propertySearchProvider).properties;
     return ListView.builder(...);
   }

   // ✅ CORRECT: Handle loading state
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     final state = ref.watch(propertySearchProvider);
     if (state.isLoading) return CircularProgressIndicator();
     if (state.error != null) return ErrorWidget(state.error);
     return ListView.builder(itemCount: state.properties.length, ...);
   }
   ```

2. **Not Using Either Pattern in Repositories**
   ```dart
   // ❌ WRONG: Throwing exceptions from repository
   Future<List<Property>> searchProperties(dto) async {
     final response = await _apiClient.get(...);
     if (response.statusCode == 200) {
       return parseProperties(response.data);
     }
     throw Exception('Failed to load properties');
   }

   // ✅ CORRECT: Return Either<Error, Success>
   Future<Either<ApiException, List<Property>>> searchProperties(dto) async {
     try {
       final response = await _apiClient.get(...);
       return Either.right(parseProperties(response.data));
     } on DioException catch (e) {
       return Either.left(ApiException.fromDioError(e));
     }
   }
   ```

3. **Not Using Const Constructors**
   ```dart
   // ❌ WRONG: Non-const widget
   class MyWidget extends StatelessWidget {
     MyWidget({Key? key}) : super(key: key);
   }

   // ✅ CORRECT: Const constructor for better performance
   class MyWidget extends StatelessWidget {
     const MyWidget({Key? key}) : super(key: key);
   }
   ```

4. **Mutating State Directly**
   ```dart
   // ❌ WRONG: Direct state mutation
   state.properties.add(newProperty);

   // ✅ CORRECT: Use copyWith to create new state
   state = state.copyWith(
     properties: [...state.properties, newProperty],
   );
   ```

5. **Not Disposing Controllers**
   ```dart
   // ❌ WRONG: No disposal
   class MyWidget extends StatefulWidget {
     final TextEditingController controller = TextEditingController();
   }

   // ✅ CORRECT: Dispose in dispose method
   class MyWidget extends StatefulWidget {
     late TextEditingController controller;

     @override
     void initState() {
       super.initState();
       controller = TextEditingController();
     }

     @override
     void dispose() {
       controller.dispose();
       super.dispose();
     }
   }
   ```

---

## AI Assistant Best Practices

### When Working on This Codebase

1. **Always Read Before Writing**
   - NEVER propose changes to code you haven't read
   - Use `Read` tool to examine existing files before modifications
   - Understand context and existing patterns

2. **Use Specialized Agents**
   - Use `Task` tool with `Explore` agent for codebase exploration
   - Use `Task` tool for complex, multi-step tasks
   - Run agents in parallel when possible for efficiency

3. **Plan with TodoWrite**
   - For complex tasks (3+ steps), use `TodoWrite` tool to create task list
   - Mark tasks as `in_progress` before starting
   - Mark `completed` immediately after finishing (don't batch)
   - Only one task should be `in_progress` at a time

4. **Respect FRS Requirements**
   - Always cross-reference `Final_Consolidated_Nestery_FRS.md`
   - Check `Nestery_FRS_Compliance_Implementation.md` for implementation status
   - Don't deviate from FRS specifications without explicit approval

5. **Follow Existing Patterns**
   - Match naming conventions in the codebase
   - Use same architectural patterns (Repository, Either, StateNotifier)
   - Follow existing error handling approaches
   - Maintain consistent code style

6. **Security Awareness**
   - Never commit `.env` files or credentials
   - Use environment variables for sensitive data
   - Follow OWASP top 10 guidelines
   - Validate all user inputs

7. **Testing is Mandatory**
   - Write unit tests for new services/providers
   - Update E2E tests for new API endpoints
   - Run tests before committing (`npm test`, `flutter test`)
   - Maintain or improve code coverage

8. **Avoid Over-Engineering**
   - Don't add features beyond what's requested
   - Don't create abstractions for one-time operations
   - Keep solutions simple and focused
   - Don't add comments where code is self-evident

9. **Git Workflow**
   - Only commit when explicitly requested
   - Use conventional commit messages
   - Always push to `claude/*` branches with session ID
   - Never force push to main/master

10. **Communication**
    - Explain what you're doing before executing
    - Summarize results after task completion
    - Ask for clarification on ambiguous requirements
    - Report any FRS compliance concerns

### Tool Usage Guidelines

**File Operations:**
- `Read` for reading files (NOT `cat`)
- `Edit` for modifying files (NOT `sed`)
- `Write` for creating files (NOT `echo >`)
- `Glob` for finding files by pattern (NOT `find`)
- `Grep` for searching code (NOT `grep` or `rg`)

**Bash Usage:**
- Use for terminal operations (git, npm, flutter, docker)
- NOT for file operations (use specialized tools)
- NOT for communication (output text directly)
- Chain sequential commands with `&&`
- Run independent commands in parallel

**When to Use Task Tool:**
- Open-ended codebase exploration (use `Explore` agent)
- Complex multi-step implementations
- When search might require multiple rounds
- For tasks matching specialized agent descriptions

### Example Workflow

**Scenario:** Add new loyalty tier benefit

```markdown
1. Read FRS to understand requirement
2. Use TodoWrite to create task list:
   - Read loyalty service and entity files
   - Update tier definition entity
   - Modify loyalty service logic
   - Update API DTOs
   - Update Flutter loyalty provider
   - Update loyalty UI
   - Write unit tests
   - Run tests and verify

3. Mark first task as in_progress
4. Use Read tool to examine loyalty files
5. Make changes using Edit tool
6. Mark task completed, move to next
7. Continue until all tasks done
8. Run tests: `npm test` and `flutter test`
9. Commit with conventional message:
   "feat(loyalty): add concierge service benefit for Globetrotter tier"
10. Push to claude/* branch
```

---

## Quick Reference

### Key Files to Know

**Backend:**
- `src/main.ts` - Application entry point, global config
- `src/app.module.ts` - Root module, imports all features
- `src/auth/auth.service.ts` - Authentication logic
- `src/integrations/integrations.service.ts` - External API orchestration
- `src/features/loyalty/loyalty.service.ts` - Loyalty program logic
- `data-source.ts` - TypeORM configuration for migrations

**Frontend:**
- `lib/main.dart` - App entry point, Riverpod setup
- `lib/core/network/api_client.dart` - Dio HTTP client configuration
- `lib/core/db/app_cache_database.dart` - Drift database setup
- `lib/providers/auth_provider.dart` - Authentication state
- `lib/utils/constants.dart` - App-wide constants, API endpoints
- `lib/utils/app_router.dart` - Navigation routes

### Critical Environment Variables

**Backend:** `JWT_SECRET`, `DATABASE_URL`, `BOOKING_COM_API_KEY`, `GOOGLE_MAPS_API_KEY`, `CACHE_HOST`

**Flutter:** `API_BASE_URL`, `GOOGLE_MAPS_API_KEY`, `STRIPE_PUBLISHABLE_KEY`

### Common Errors & Solutions

| Error | Solution |
|-------|----------|
| `401 Unauthorized` | Check JWT token expiration, use refresh token endpoint |
| `TypeORM migration failed` | Check data-source.ts config, verify DB connection |
| `Booking.com booking creation fails` | Verify API credentials, check payload format against docs |
| `Flutter cache not working` | Run `flutter pub run build_runner build` to generate Drift code |
| `Push rejected (403)` | Ensure branch starts with `claude/` and ends with session ID |

---

## Contact & Support

**Repository:** https://github.com/abhishek9871/nesteryrelease

**Key Documentation:**
- Architecture: `ARCHITECTURE.md`
- Database: `DATA_DICTIONARY.md`
- Deployment: `DEPLOYMENT_GUIDE.md`
- User Journeys: `USER_JOURNEY_FEATURE_MAP.md`
- FRS: `Final_Consolidated_Nestery_FRS.md`

---

**Last Updated:** 2025-11-22
**Codebase Version:** See latest commit in `git log`
