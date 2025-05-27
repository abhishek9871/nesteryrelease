import { Test, TestingModule } from '@nestjs/testing';
// Remove the non-existent IntegrationTest import
import { INestApplication } from '@nestjs/common';
import request, { Response } from 'supertest';
import { AppModule } from '../src/app.module';
import { JwtService } from '@nestjs/jwt';
import { UserEntity } from '../src/users/entities/user.entity';
import { PropertyEntity } from '../src/properties/entities/property.entity';
import { BookingEntity } from '../src/bookings/entities/booking.entity';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';

describe('Nestery API (e2e)', () => {
  let app: INestApplication;
  let jwtService: JwtService;
  let userRepository: Repository<UserEntity>;
  let propertyRepository: Repository<PropertyEntity>;
  let bookingRepository: Repository<BookingEntity>;

  // Test user, property, and booking for testing
  let testUser: UserEntity;
  let testProperty: PropertyEntity;
  let testBooking: BookingEntity;
  let authToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Get services and repositories
    jwtService = moduleFixture.get<JwtService>(JwtService);
    userRepository = moduleFixture.get<Repository<UserEntity>>(getRepositoryToken(UserEntity));
    propertyRepository = moduleFixture.get<Repository<PropertyEntity>>(
      getRepositoryToken(PropertyEntity),
    );
    bookingRepository = moduleFixture.get<Repository<BookingEntity>>(
      getRepositoryToken(BookingEntity),
    );

    // Create test data
    testUser = await userRepository.save({
      email: 'test@example.com',
      password: 'hashedpassword',
      name: 'Test User',
      role: 'user',
    });

    testProperty = await propertyRepository.save({
      name: 'Test Property',
      description: 'A test property',
      address: '123 Test St',
      city: 'Test City',
      state: 'Test State',
      country: 'Test Country',
      zipCode: '12345',
      latitude: 40.7128,
      longitude: -74.006,
      propertyType: 'hotel',
      starRating: 4,
      basePrice: 100.0,
      currency: 'USD',
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
      amenities: ['wifi', 'parking'],
      images: ['image1.jpg', 'image2.jpg'],
      thumbnailImage: 'thumbnail.jpg',
      sourceType: 'direct',
      externalId: 'test123',
    });

    testBooking = await bookingRepository.save({
      userId: testUser.id,
      propertyId: testProperty.id,
      checkInDate: new Date('2025-06-01'),
      checkOutDate: new Date('2025-06-05'),
      numberOfGuests: 2,
      totalPrice: 400.0,
      currency: 'USD',
      status: 'confirmed',
      confirmationCode: 'CONF123',
    });

    // Generate auth token for test user
    authToken = jwtService.sign({
      sub: testUser.id,
      email: testUser.email,
      role: testUser.role,
    });
  });

  afterAll(async () => {
    // Clean up test data
    await bookingRepository.delete(testBooking.id);
    await propertyRepository.delete(testProperty.id);
    await userRepository.delete(testUser.id);

    await app.close();
  });

  describe('Auth', () => {
    it('/auth/login (POST) - should authenticate user', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123',
        })
        .expect(200)
        .expect((res: Response) => {
          expect(res.body.access_token).toBeDefined();
          expect(res.body.user).toBeDefined();
          expect(res.body.user.email).toBe('test@example.com');
        });
    });

    it('/auth/register (POST) - should register new user', () => {
      const email = `test${Date.now()}@example.com`;
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email,
          password: 'password123',
          name: 'New Test User',
        })
        .expect(201)
        .expect(res => {
          expect(res.body.id).toBeDefined();
          expect(res.body.email).toBe(email);
        })
        .then(async res => {
          // Clean up the newly created user
          await userRepository.delete(res.body.id);
        });
    });
  });

  describe('Users', () => {
    it('/users/me (GET) - should return user profile with auth', () => {
      return request(app.getHttpServer())
        .get('/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect(res => {
          expect(res.body.id).toBe(testUser.id);
          expect(res.body.email).toBe(testUser.email);
        });
    });

    it('/users/me (GET) - should fail without auth', () => {
      return request(app.getHttpServer()).get('/users/me').expect(401);
    });

    it('/users/me (PATCH) - should update user profile with auth', () => {
      return request(app.getHttpServer())
        .patch('/users/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Updated Test User',
        })
        .expect(200)
        .expect(res => {
          expect(res.body.name).toBe('Updated Test User');
        });
    });
  });

  describe('Properties', () => {
    it('/properties (GET) - should return properties', () => {
      return request(app.getHttpServer())
        .get('/properties')
        .expect(200)
        .expect(res => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThan(0);
        });
    });

    it('/properties/:id (GET) - should return a specific property', () => {
      return request(app.getHttpServer())
        .get(`/properties/${testProperty.id}`)
        .expect(200)
        .expect(res => {
          expect(res.body.id).toBe(testProperty.id);
          expect(res.body.name).toBe(testProperty.name);
        });
    });

    it('/properties/search (POST) - should search properties', () => {
      return request(app.getHttpServer())
        .post('/properties/search')
        .send({
          city: 'Test City',
          checkInDate: '2025-06-15',
          checkOutDate: '2025-06-20',
          guestCount: 2,
        })
        .expect(200)
        .expect(res => {
          expect(Array.isArray(res.body)).toBe(true);
        });
    });
  });

  describe('Bookings', () => {
    it('/bookings (GET) - should return user bookings with auth', () => {
      return request(app.getHttpServer())
        .get('/bookings')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect(res => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThan(0);
        });
    });

    it('/bookings (GET) - should fail without auth', () => {
      return request(app.getHttpServer()).get('/bookings').expect(401);
    });

    it('/bookings/:id (GET) - should return a specific booking with auth', () => {
      return request(app.getHttpServer())
        .get(`/bookings/${testBooking.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect(res => {
          expect(res.body.id).toBe(testBooking.id);
          expect(res.body.property.id).toBe(testProperty.id);
        });
    });

    it('/bookings (POST) - should create a new booking with auth', () => {
      const newBooking = {
        propertyId: testProperty.id,
        checkInDate: '2025-07-15',
        checkOutDate: '2025-07-20',
        guestCount: 2,
        totalAmount: 500,
      };
      return request(app.getHttpServer())
        .post('/bookings')
        .set('Authorization', `Bearer ${authToken}`)
        .send(newBooking)
        .expect(201)
        .expect(res => {
          expect(res.body.id).toBeDefined();
          expect(res.body.property.id).toBe(testProperty.id);
          expect(res.body.user.id).toBe(testUser.id);
        })
        .then(async res => {
          // Clean up the newly created booking
          await bookingRepository.delete(res.body.id);
        });
    });
  });

  describe('Advanced Features', () => {
    it('/price-prediction/predict (POST) - should predict price', () => {
      return request(app.getHttpServer())
        .post('/price-prediction/predict')
        .send({
          city: 'Test City',
          country: 'Test Country',
          checkInDate: '2025-06-15',
          checkOutDate: '2025-06-20',
          guestCount: 2,
          propertyType: 'hotel',
        })
        .expect(200)
        .expect(res => {
          expect(res.body.predictedPrice).toBeDefined();
          expect(res.body.currency).toBeDefined();
          expect(res.body.confidence).toBeDefined();
          expect(res.body.priceRange).toBeDefined();
          expect(res.body.factors).toBeDefined();
        });
    });

    it('/recommendations/trending (GET) - should return trending properties', () => {
      return request(app.getHttpServer())
        .get('/recommendations/trending')
        .expect(200)
        .expect(res => {
          expect(Array.isArray(res.body)).toBe(true);
        });
    });

    it('/loyalty/status/:userId (GET) - should return loyalty status with auth', () => {
      return request(app.getHttpServer())
        .get(`/loyalty/status/${testUser.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect(res => {
          expect(res.body.tier).toBeDefined();
          expect(res.body.points).toBeDefined();
          expect(res.body.nextTier).toBeDefined();
          expect(res.body.benefits).toBeDefined();
        });
    });

    it('/social-sharing/content/:propertyId (GET) - should generate shareable content', () => {
      return request(app.getHttpServer())
        .get(`/social-sharing/content/${testProperty.id}?platform=facebook`)
        .expect(200)
        .expect(res => {
          expect(res.body.title).toBeDefined();
          expect(res.body.description).toBeDefined();
          expect(res.body.imageUrl).toBeDefined();
          expect(res.body.shareUrl).toBeDefined();
          expect(res.body.hashtags).toBeDefined();
        });
    });
  });
});
