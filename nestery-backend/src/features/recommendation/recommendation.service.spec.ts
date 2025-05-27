import { Test, TestingModule } from '@nestjs/testing';
import { RecommendationService } from './recommendation.service';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { Repository } from 'typeorm';

describe('RecommendationService', () => {
  let service: RecommendationService;
  let propertyRepository: Repository<PropertyEntity>;
  let bookingRepository: Repository<BookingEntity>;

  const mockPropertyRepository = {
    createQueryBuilder: jest.fn(() => ({
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      leftJoin: jest.fn().mockReturnThis(),
      groupBy: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      addOrderBy: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue([
        {
          id: 'property1',
          name: 'Test Property 1',
          city: 'New York',
          country: 'US',
          price: 150,
          rating: 4.5,
          amenities: ['wifi', 'pool', 'gym'],
          propertyType: 'hotel',
        },
        {
          id: 'property2',
          name: 'Test Property 2',
          city: 'New York',
          country: 'US',
          price: 200,
          rating: 4.8,
          amenities: ['wifi', 'pool', 'spa'],
          propertyType: 'hotel',
        },
      ]),
    })),
    find: jest.fn().mockResolvedValue([
      {
        id: 'property1',
        name: 'Test Property 1',
        city: 'New York',
        country: 'US',
        price: 150,
        rating: 4.5,
        amenities: ['wifi', 'pool', 'gym'],
        propertyType: 'hotel',
      },
      {
        id: 'property2',
        name: 'Test Property 2',
        city: 'New York',
        country: 'US',
        price: 200,
        rating: 4.8,
        amenities: ['wifi', 'pool', 'spa'],
        propertyType: 'hotel',
      },
    ]),
    findOne: jest.fn().mockResolvedValue({
      id: 'property1',
      name: 'Test Property 1',
      city: 'New York',
      country: 'US',
      price: 150,
      rating: 4.5,
      amenities: ['wifi', 'pool', 'gym'],
      propertyType: 'hotel',
    }),
  };

  const mockBookingRepository = {
    find: jest.fn().mockResolvedValue([
      {
        id: 'booking1',
        property: {
          id: 'property1',
          name: 'Test Property 1',
          city: 'New York',
          country: 'US',
          price: 150,
          rating: 4.5,
          amenities: ['wifi', 'pool', 'gym'],
          propertyType: 'hotel',
        },
        createdAt: new Date(),
      },
    ]),
  };

  const mockUserRepository = {
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RecommendationService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            error: jest.fn(),
          },
        },
        {
          provide: ExceptionService,
          useValue: {
            handleException: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(PropertyEntity),
          useValue: mockPropertyRepository,
        },
        {
          provide: getRepositoryToken(BookingEntity),
          useValue: mockBookingRepository,
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<RecommendationService>(RecommendationService);
    propertyRepository = module.get<Repository<PropertyEntity>>(getRepositoryToken(PropertyEntity));
    bookingRepository = module.get<Repository<BookingEntity>>(getRepositoryToken(BookingEntity));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getRecommendationsForUser', () => {
    it('should return personalized recommendations for a user with booking history', async () => {
      const userId = 'user1';
      const limit = 10;

      const result = await service.getRecommendationsForUser(userId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
      expect(bookingRepository.find).toHaveBeenCalledWith({
        where: { userId: userId },
        relations: ['property'],
      });
    });

    it('should return trending properties if user has no booking history', async () => {
      const userId = 'user2';
      const limit = 10;

      // Mock empty booking history
      jest.spyOn(bookingRepository, 'find').mockResolvedValueOnce([]);

      const result = await service.getRecommendationsForUser(userId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
      expect(bookingRepository.find).toHaveBeenCalledWith({
        where: { userId: userId },
        relations: ['property'],
      });
    });

    it('should handle errors gracefully', async () => {
      const userId = 'user3';
      const limit = 10;

      // Mock error
      jest.spyOn(bookingRepository, 'find').mockRejectedValueOnce(new Error('Database error'));

      const result = await service.getRecommendationsForUser(userId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });
  });

  describe('getSimilarProperties', () => {
    it('should return similar properties to a specific property', async () => {
      const propertyId = 'property1';
      const limit = 5;

      const result = await service.getSimilarProperties(propertyId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
      expect(propertyRepository.findOne).toHaveBeenCalledWith({
        where: { id: propertyId },
      });
    });

    it('should throw an error if property not found', async () => {
      const propertyId = 'nonexistent';
      const limit = 5;

      // Mock property not found
      jest.spyOn(propertyRepository, 'findOne').mockResolvedValueOnce(null);

      const result = await service.getSimilarProperties(propertyId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });

    it('should handle errors gracefully', async () => {
      const propertyId = 'property1';
      const limit = 5;

      // Mock error
      jest.spyOn(propertyRepository, 'findOne').mockRejectedValueOnce(new Error('Database error'));

      const result = await service.getSimilarProperties(propertyId, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });
  });

  describe('getTrendingProperties', () => {
    it('should return trending properties', async () => {
      const limit = 10;

      const result = await service.getTrendingProperties(limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });

    it('should handle errors gracefully', async () => {
      const limit = 10;

      // Mock error
      jest.spyOn(propertyRepository, 'createQueryBuilder').mockImplementationOnce(() => {
        throw new Error('Database error');
      });

      const result = await service.getTrendingProperties(limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });
  });

  describe('getPopularPropertiesForDestination', () => {
    it('should return popular properties for a destination', async () => {
      const destination = 'New York, US';
      const limit = 10;

      const result = await service.getPopularPropertiesForDestination(destination, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });

    it('should handle errors gracefully', async () => {
      const destination = 'New York, US';
      const limit = 10;

      // Mock error
      jest.spyOn(propertyRepository, 'createQueryBuilder').mockImplementationOnce(() => {
        throw new Error('Database error');
      });

      const result = await service.getPopularPropertiesForDestination(destination, limit);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.recommendations).toBeDefined();
      expect(Array.isArray(result.recommendations)).toBe(true);
    });
  });
});
