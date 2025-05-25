import { Test, TestingModule } from '@nestjs/testing';
import { IntegrationTest } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
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

    jwtService = app.get<JwtService>(JwtService);
    userRepository = app.get<Repository<UserEntity>>(getRepositoryToken(UserEntity));
    propertyRepository = app.get<Repository<PropertyEntity>>(getRepositoryToken(PropertyEntity));
    bookingRepository = app.get<Repository<BookingEntity>>(getRepositoryToken(BookingEntity));

    // Create test data
    await setupTestData();
  });

  afterAll(async () => {
    // Clean up test data
    await cleanupTestData();
    await app.close();
  });

  async function setupTestData() {
    // Create test user
    testUser = await userRepository.save({
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      password: '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe/QLSUG6xNekdHgTGmrpHEfIoxm', // 'password123'
      role: 'user',
    });

    // Create test property
    testProperty = await propertyRepository.save({
      name: 'Test Property',
      description: 'A test property for e2e testing',
      city: 'Test City',
      country: 'Test Country',
      address: '123 Test Street',
      price: 100,
      rating: 4.5,
      propertyType: 'hotel',
      amenities: ['wifi', 'pool', 'gym'],
      images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
      thumbnailImage: 'https://example.com/thumbnail.jpg',
      latitude: 40.7128,
      longitude: -74.0060,
    });

    // Create test booking
    testBooking = await bookingRepository.save({
      user: testUser,
      property: testProperty,
      checkInDate: new Date('2025-06-15'),
      checkOutDate: new Date('2025-06-20'),
      guestCount: 2,
      totalAmount: 500,
      status: 'confirmed',
    });

    // Generate auth token
    authToken = jwtService.sign({ 
      sub: testUser.id, 
      email: testUser.email,
      role: testUser.role
    });
  }

  async function cleanupTestData() {
    await bookingRepository.delete({ id: testBooking.id });
    await propertyRepository.delete({ id: testProperty.id });
    await userRepository.delete({ id: testUser.id });
  }

  describe('Authentication', () => {
    it('/auth/login (POST) - should login successfully', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'password123' })
        .expect(200)
        .expect(res => {
          expect(res.body.accessToken).toBeDefined();
          expect(res.body.refreshToken).toBeDefined();
          expect(res.body.user).toBeDefined();
          expect(res.body.user.email).toBe('test@example.com');
        });
    });

    it('/auth/login (POST) - should fail with invalid credentials', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'wrongpassword' })
        .expect(401);
    });

    it('/auth/register (POST) - should register a new user', () => {
      const newUser = {
        firstName: 'New',
        lastName: 'User',
        email: 'newuser@example.com',
        password: 'password123',
      };

      return request(app.getHttpServer())
        .post('/auth/register')
        .send(newUser)
        .expect(201)
        .expect(res => {
          expect(res.body.accessToken).toBeDefined();
          expect(res.body.refreshToken).toBeDefined();
          expect(res.body.user).toBeDefined();
          expect(res.body.user.email).toBe(newUser.email);
        })
        .then(async () => {
          // Clean up the newly created user
          const createdUser = await userRepository.findOne({ where: { email: newUser.email } });
          if (createdUser) {
            await userRepository.delete(createdUser.id);
          }
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
      return request(app.getHttpServer())
        .get('/bookings')
        .expect(401);
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
        .then(async (res) => {
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
